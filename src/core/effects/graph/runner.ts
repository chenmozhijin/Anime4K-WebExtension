import { Downscale } from '../../shared-effects/downscale';
import type {
  PipelinePass,
  PipelineProfileRecorder,
  PipelineTextureResourcePlan,
  TerminalTextureTarget,
} from '../backend-types';
import { ComputeTexturePass } from '../../gpu-passes/compute-texture-pass';
import { DepthToSpacePass } from '../../gpu-passes/depth-to-space-pass';
import { LumaRecomposePass } from '../../gpu-passes/luma-recompose-pass';
import { MultiOutputComputePass } from '../../gpu-passes/multi-output-compute-pass';
import { ModelTailPass } from '../../gpu-passes/model-tail-pass';
import { RenderCompositePass } from '../../gpu-passes/render-composite-pass';
import { borrowTexture, getTextureAllocationInfo, releaseTexture } from '../../texture-pool';
import {
  defaultOptimizationFeatureFlags,
  type OptimizationFeatureFlags,
} from '../../optimization-flags';
import type {
  DimensionExpression,
  EffectGraph,
  GraphStage,
  TextureSymbol,
} from './types';

export interface EffectGraphRunnerDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  graph: EffectGraph;
  terminalTarget?: TerminalTextureTarget;
  optimizationFlags?: OptimizationFeatureFlags;
}

interface TextureDescriptor {
  width: number;
  height: number;
  format: GPUTextureFormat;
  usage: GPUTextureUsageFlags;
}

interface TextureVersion extends TextureDescriptor {
  id: number;
  symbol: TextureSymbol;
  producerStage: number;
  lastUse: number;
  texture?: GPUTexture;
}

interface ResolvedStage {
  stage: GraphStage;
  inputVersions: number[];
  outputVersions: number[];
  outputSize: { width: number; height: number };
  dispatchSize?: { width: number; height: number };
}

interface PhysicalTextureSlot extends TextureDescriptor {
  texture: GPUTexture;
  lastUse: number;
}

function stageInputSymbols(stage: GraphStage): TextureSymbol[] {
  switch (stage.op) {
    case 'compute':
    case 'multi-compute':
    case 'depth-to-space':
    case 'render-composite':
      return [...stage.inputs];
    case 'resize':
      return [stage.input];
    case 'luma-recompose':
      return [stage.source, stage.luma];
    case 'model-tail':
      return [stage.source, ...stage.features];
    default:
      return assertNever(stage);
  }
}

function outputFormat(stage: GraphStage): GPUTextureFormat {
  switch (stage.op) {
    case 'compute':
    case 'render-composite':
      return stage.outputFormat ?? 'rgba16float';
    case 'multi-compute':
    case 'model-tail':
    case 'depth-to-space':
    case 'resize':
    case 'luma-recompose':
      return 'rgba16float';
    default:
      return assertNever(stage);
  }
}

function outputUsage(stage: GraphStage): GPUTextureUsageFlags {
  switch (stage.op) {
    case 'compute':
      return stage.outputUsage ?? (GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING);
    case 'multi-compute':
      return GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING;
    case 'depth-to-space':
    case 'luma-recompose':
      return GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING;
    case 'render-composite':
      return stage.outputUsage ?? (GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT);
    case 'resize':
    case 'model-tail':
      return GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT;
    default:
      return assertNever(stage);
  }
}

function textureSlotKey(descriptor: TextureDescriptor): string {
  return [descriptor.width, descriptor.height, descriptor.format, descriptor.usage].join('|');
}

function assertNever(value: never): never {
  throw new Error(`Unsupported effect graph stage: ${JSON.stringify(value)}`);
}

export class EffectGraphRunner implements PipelinePass {
  readonly pipelines: PipelinePass[] = [];

  readonly presentsToTerminal: boolean;

  private readonly versions: TextureVersion[];

  private readonly outputVersion: number;

  private readonly terminalOutputVersion: number | null;

  private readonly ownedTextures: GPUTexture[] = [];

  private destroyed = false;

  private readonly terminalTarget?: TerminalTextureTarget;

  private readonly optimizationFlags: OptimizationFeatureFlags;

  constructor({
    device,
    inputTexture,
    graph,
    terminalTarget,
    optimizationFlags = defaultOptimizationFeatureFlags,
  }: EffectGraphRunnerDescriptor) {
    this.terminalTarget = terminalTarget;
    this.optimizationFlags = optimizationFlags;
    const analysis = this.analyzeGraph(inputTexture, graph);
    this.versions = analysis.versions;
    this.outputVersion = analysis.outputVersion;
    const outputStage = analysis.resolvedStages.find(
      resolved => resolved.outputVersions.includes(analysis.outputVersion),
    )?.stage;
    // A matching canvas size is not enough: only stage kinds with a separately
    // verified terminal shader may bypass the RGBA16F output texture.
    const supportsCertifiedTerminalOutput = (
      outputStage?.op === 'render-composite' && outputStage.terminalDirect === true
    )
      || outputStage?.op === 'resize'
      || (
        outputStage?.op === 'model-tail'
        && outputStage.kind === 'upscale'
        && outputStage.terminalDirect === true
      );
    this.terminalOutputVersion = terminalTarget
      && supportsCertifiedTerminalOutput
      ? analysis.outputVersion
      : null;

    try {
      this.allocateTextureSlots(device, analysis.versions);
      analysis.resolvedStages.forEach(resolved => {
        const pass = this.createStagePass(device, resolved);
        this.pipelines.push(pass);
      });
      this.presentsToTerminal = this.pipelines.some(pipeline => pipeline.presentsToTerminal);
    } catch (error) {
      this.pipelines.forEach(pipeline => pipeline.destroy?.());
      this.ownedTextures.forEach(releaseTexture);
      this.ownedTextures.length = 0;
      throw error;
    }
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.versions[this.outputVersion]?.texture
      ?? this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  destroy(): void {
    if (this.destroyed) {
      return;
    }
    this.destroyed = true;
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
    this.ownedTextures.forEach(releaseTexture);
    this.ownedTextures.length = 0;
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  getTextureResourcePlan(): PipelineTextureResourcePlan {
    return {
      peakTextureBytes: this.ownedTextures.reduce(
        (total, texture) => total + (getTextureAllocationInfo(texture)?.byteSize ?? 0),
        0,
      ),
      textureSlotCount: this.ownedTextures.length,
      resourceReleasePlan: this.versions
        .filter(version => version.producerStage >= 0)
        .map(version => ({
          afterPass: version.lastUse,
          textureLabel: `${version.symbol}@${version.id}`,
        })),
    };
  }

  private analyzeGraph(inputTexture: GPUTexture, graph: EffectGraph): {
    versions: TextureVersion[];
    resolvedStages: ResolvedStage[];
    outputVersion: number;
  } {
    const versions: TextureVersion[] = [{
      id: 0,
      symbol: graph.input,
      producerStage: -1,
      lastUse: -1,
      width: inputTexture.width,
      height: inputTexture.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING,
      texture: inputTexture,
    }];
    const currentVersionBySymbol = new Map<TextureSymbol, number>([[graph.input, 0]]);
    const resolvedStages: ResolvedStage[] = [];

    const requireVersion = (symbol: TextureSymbol): TextureVersion => {
      const versionId = currentVersionBySymbol.get(symbol);
      if (versionId === undefined) {
        throw new Error(`Effect graph texture is not defined: ${symbol}`);
      }
      return versions[versionId];
    };
    const resolveDimensions = (expression: DimensionExpression): { width: number; height: number } => {
      if (expression.kind === 'absolute') {
        return { width: expression.width, height: expression.height };
      }
      const version = requireVersion(expression.texture);
      const scale = expression.scale ?? 1;
      return {
        width: Math.round(version.width * scale),
        height: Math.round(version.height * scale),
      };
    };

    graph.stages.forEach((stage, stageIndex) => {
      // Treat every graph write as a new SSA version, even when a symbol is reused.
      // Residual/skip connections may still need an older version of that symbol.
      const inputVersions = stageInputSymbols(stage).map(symbol => requireVersion(symbol).id);
      for (const versionId of new Set(inputVersions)) {
        versions[versionId].lastUse = stageIndex;
      }

      let size: { width: number; height: number };
      switch (stage.op) {
        case 'compute':
        case 'multi-compute':
          size = stage.outputSize
            ? resolveDimensions(stage.outputSize)
            : { width: versions[inputVersions[0]].width, height: versions[inputVersions[0]].height };
          break;
        case 'depth-to-space':
          size = {
            width: versions[inputVersions[0]].width * 2,
            height: versions[inputVersions[0]].height * 2,
          };
          break;
        case 'render-composite':
        case 'resize':
        case 'luma-recompose':
        case 'model-tail':
          size = resolveDimensions(stage.outputSize);
          break;
        default:
          size = assertNever(stage);
      }

      const dispatchSize = stage.op === 'compute' && stage.dispatchSize
        ? resolveDimensions(stage.dispatchSize)
        : undefined;
      const outputSymbols = stage.op === 'multi-compute' ? stage.outputs : [stage.output];
      const outputVersions = outputSymbols.map(symbol => {
        const outputVersion = versions.length;
        versions.push({
          id: outputVersion,
          symbol,
          producerStage: stageIndex,
          lastUse: stageIndex,
          width: size.width,
          height: size.height,
          format: outputFormat(stage),
          usage: outputUsage(stage),
        });
        currentVersionBySymbol.set(symbol, outputVersion);
        return outputVersion;
      });
      resolvedStages.push({ stage, inputVersions, outputVersions, outputSize: size, dispatchSize });
    });

    const outputVersion = currentVersionBySymbol.get(graph.output);
    if (outputVersion === undefined) {
      throw new Error(`Effect graph output texture is not defined: ${graph.output}`);
    }
    // Keep the graph result alive through the consumer outside the graph runner.
    versions[outputVersion].lastUse = Math.max(versions[outputVersion].lastUse, graph.stages.length);

    return { versions, resolvedStages, outputVersion };
  }

  private allocateTextureSlots(device: GPUDevice, versions: TextureVersion[]): void {
    const slotsByKey = new Map<string, PhysicalTextureSlot[]>();
    for (const version of versions) {
      if (version.producerStage < 0) {
        continue;
      }
      if (version.id === this.terminalOutputVersion) {
        // The terminal pass writes the current canvas view, so allocating an SSA
        // texture for this logical output would recreate the bandwidth we removed.
        continue;
      }

      const key = textureSlotKey(version);
      const slots = slotsByKey.get(key) ?? [];
      // Strictly less is essential. lastUse === producerStage means the old value is
      // an input to the same pass; aliasing it with the output is invalid read/write use.
      let slot = this.optimizationFlags.textureLifetimeReuse
        ? slots.find(candidate => candidate.lastUse < version.producerStage)
        : undefined;
      if (!slot) {
        const texture = borrowTexture({
          device,
          width: version.width,
          height: version.height,
          format: version.format,
          usage: version.usage,
          labelGroup: 'core/effect-graph/ssa-output',
          label: `effect graph SSA slot ${this.ownedTextures.length}`,
        });
        this.ownedTextures.push(texture);
        slot = { ...version, texture, lastUse: version.lastUse };
        slots.push(slot);
        slotsByKey.set(key, slots);
      } else {
        slot.lastUse = version.lastUse;
      }
      version.texture = slot.texture;
    }
  }

  private createStagePass(device: GPUDevice, resolved: ResolvedStage): PipelinePass {
    const { stage, inputVersions, outputVersions, outputSize, dispatchSize } = resolved;
    const inputTextures = inputVersions.map(version => this.requireVersionTexture(version));
    const terminalTarget = this.terminalOutputVersion !== null
      && outputVersions.includes(this.terminalOutputVersion)
      && this.terminalTarget?.width === outputSize.width
      && this.terminalTarget.height === outputSize.height
      ? this.terminalTarget
      : undefined;
    const outputTextures = outputVersions.map(outputVersion => (
      terminalTarget && outputVersion === this.terminalOutputVersion
      ? undefined
      : this.requireVersionTexture(outputVersion)
    ));
    const outputTexture = outputTextures[0];

    switch (stage.op) {
      case 'compute':
        {
          const useOptimizedShader = Boolean(
            stage.optimizedShaderWGSL
            && stage.optimizationFlag
            && this.optimizationFlags[stage.optimizationFlag]
          );
        return new ComputeTexturePass({
          device,
          inputTextures,
          outputTexture: outputTexture!,
          shaderWGSL: useOptimizedShader ? stage.optimizedShaderWGSL! : stage.shaderWGSL,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          outputSize,
          outputFormat: stage.outputFormat,
          outputUsage: stage.outputUsage,
          includeSampler: stage.includeSampler,
          samplerBindingOrder: stage.samplerBindingOrder,
          samplerKey: stage.samplerKey,
          samplerDescriptor: stage.samplerDescriptor,
          workgroupSize: useOptimizedShader && stage.optimizedWorkgroupSize
            ? stage.optimizedWorkgroupSize
            : stage.workgroupSize,
          dispatchSize,
          entryPoint: stage.entryPoint,
          extraLayoutEntries: stage.extraLayoutEntries,
          extraBindGroupEntries: stage.extraBindGroupEntries,
          extraLayoutKey: stage.extraLayoutKey,
        });
        }
      case 'multi-compute':
        {
          const limits = (device as GPUDevice & { limits?: GPUSupportedLimits }).limits;
          // Keep the baseline dispatches when fusion would exceed either binding
          // limit. Splitting here changes scheduling only, not the model outputs.
          const supportsFusedBindings = outputTextures.length
              <= (limits?.maxStorageTexturesPerShaderStage ?? 4)
            && inputTextures.length <= (limits?.maxSampledTexturesPerShaderStage ?? 16);
          return new MultiOutputComputePass({
            device,
            inputTextures,
            outputTextures: outputTextures as GPUTexture[],
            shaderWGSL: stage.shaderWGSL,
            baselineShaders: stage.baselineShaders,
            name: stage.name ?? stage.id,
            cacheKeyPrefix: stage.cacheKeyPrefix,
            outputSize,
            workgroupSize: stage.workgroupSize,
            optimized: this.optimizationFlags[stage.optimizationFlag ?? 'multiOutputDispatch']
              && supportsFusedBindings,
          });
        }
      case 'depth-to-space':
        return new DepthToSpacePass({
          device,
          inputTextures,
          outputTexture: outputTexture!,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          vectorized: this.optimizationFlags.vectorizedPixelShuffle,
        });
      case 'render-composite':
        return new RenderCompositePass({
          device,
          inputTextures,
          outputTexture,
          outputSize,
          fragmentWGSL: stage.fragmentWGSL,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          samplerKey: stage.samplerKey,
          outputFormat: stage.outputFormat,
          outputUsage: stage.outputUsage,
          terminalTarget,
        });
      case 'resize':
        return new Downscale({
          device,
          inputTexture: inputTextures[0],
          outputTexture,
          targetDimensions: outputSize,
          name: stage.name ?? stage.id,
          terminalTarget,
        });
      case 'luma-recompose':
        return new LumaRecomposePass({
          device,
          sourceTexture: inputTextures[0],
          lumaTexture: inputTextures[1],
          outputTexture,
          outputSize,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          shaderWGSL: stage.shaderWGSL,
          workgroupSize: stage.workgroupSize,
        });
      case 'model-tail':
        return new ModelTailPass({
          device,
          sourceTexture: inputTextures[0],
          featureTextures: inputTextures.slice(1),
          headShaders: stage.headShaders,
          kind: stage.kind,
          outputSize,
          outputTexture,
          terminalTarget,
          optimized: this.optimizationFlags.fusedModelTail,
          multiOutputDispatch: this.optimizationFlags.multiOutputDispatch,
          vectorizedPixelShuffle: this.optimizationFlags.vectorizedPixelShuffle,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
        });
      default:
        return assertNever(stage);
    }
  }

  private requireVersionTexture(versionId: number): GPUTexture {
    const texture = this.versions[versionId]?.texture;
    if (!texture) {
      throw new Error(`Effect graph texture version is not allocated: ${versionId}`);
    }
    return texture;
  }
}

import type { Dimensions } from '../../types';
import type { GpuCapabilities, KernelVariant } from '../gpu-capabilities';
import type {
  PipelinePass,
  PipelineProfileRecorder,
  PipelineTextureResourcePlan,
  TerminalTextureTarget,
} from '../effects/backend-types';
import { ComputeTexturePass } from '../gpu-passes/compute-texture-pass';
import { PixelShuffleRecomposePass } from '../gpu-passes/pixel-shuffle-recompose-pass';
import {
  defaultLumaRecomposeWGSL,
  defaultLumaRecomposeTerminalWGSL,
  LumaRecomposePass,
} from '../gpu-passes/luma-recompose-pass';
import { borrowTexture, getTextureAllocationInfo, releaseTexture } from '../texture-pool';
import {
  defaultOptimizationFeatureFlags,
  type OptimizationFeatureFlags,
} from '../optimization-flags';
import { selectKernelVariant } from '../kernel-variant-tuner';

export type GeneratedLumaScale = number | { x: number; y: number };

export interface GeneratedLumaStageConfig {
  name: string;
  shaderWGSL: string;
  bindings: string[];
  outputName: string;
  outputScale: GeneratedLumaScale;
  final: boolean;
  optimizedShaderWGSL?: string;
  optimizationFlag?: keyof OptimizationFeatureFlags;
  optimizedDispatchScale?: GeneratedLumaScale;
  optimizedWorkgroupSize?: Dimensions;
  kernelVariants?: KernelVariant[];
  finalOperation?: 'pixel-shuffle-2x';
}

export interface GeneratedLumaModelConfig {
  key: string;
  name: string;
  stages: GeneratedLumaStageConfig[];
}

export interface GeneratedLumaModelPipelineOptions<TStage extends GeneratedLumaStageConfig> {
  device: GPUDevice;
  inputTexture: GPUTexture;
  nativeDimensions: Dimensions;
  model: {
    key: string;
    name: string;
    stages: TStage[];
  };
  cacheKeyPrefix: string;
  stageUsesSampler?: boolean | ((stage: TStage) => boolean);
  samplerBindingOrder?: 'before-output' | 'after-output';
  stageDispatchSize?: 'output' | 'native' | ((stage: TStage, outputSize: Dimensions, nativeDimensions: Dimensions) => Dimensions);
  stageWorkgroupSize?: Dimensions;
  outputRecomposeShaderWGSL?: string;
  outputRecomposeTerminalWGSL?: string;
  outputRecomposeWorkgroupSize?: Dimensions;
  terminalTarget?: TerminalTextureTarget;
  optimizationFlags?: OptimizationFeatureFlags;
}

interface TuneGeneratedLumaModelOptions<
  TStage extends GeneratedLumaStageConfig,
  TModel extends { key: string; name: string; stages: TStage[] },
> {
  device: GPUDevice;
  capabilities?: GpuCapabilities;
  nativeDimensions: Dimensions;
  model: TModel;
  cacheKeyPrefix: string;
  stageUsesSampler?: boolean | ((stage: TStage) => boolean);
  samplerBindingOrder?: 'before-output' | 'after-output';
  stageDispatchSize?: GeneratedLumaModelPipelineOptions<TStage>['stageDispatchSize'];
  optimizationFlags?: OptimizationFeatureFlags;
}

const tuningStartedAtByDevice = new WeakMap<GPUDevice, number>();
const tuningReportByDevice = new WeakMap<GPUDevice, GeneratedKernelTuningRecord[]>();
const tuningOverrideByDevice = new WeakMap<GPUDevice, string>();
// This budget is shared by all generated models on a device. A per-model budget
// multiplied startup stalls enough to erase the value of online tuning.
const GENERATED_KERNEL_TUNING_BUDGET_MS = 300;

export interface GeneratedKernelTuningRecord {
  cacheNamespace: string;
  modelKey: string;
  variantId: string;
  source: 'cache' | 'benchmark' | 'baseline' | 'override';
  gainPercent: number;
  elapsedMs: number;
}

export function getGeneratedKernelTuningReport(device: GPUDevice): GeneratedKernelTuningRecord[] {
  return [...(tuningReportByDevice.get(device) ?? [])];
}

export function setGeneratedKernelVariantOverride(device: GPUDevice, variantId?: string): void {
  if (variantId) {
    tuningOverrideByDevice.set(device, variantId);
  } else {
    tuningOverrideByDevice.delete(device);
  }
}

function hashString(value: string): string {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(16).padStart(8, '0');
}

function median(values: number[]): number {
  const sorted = [...values].sort((left, right) => left - right);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[middle - 1] + sorted[middle]) / 2
    : sorted[middle];
}

async function benchmarkGeneratedKernelVariant<TStage extends GeneratedLumaStageConfig>({
  device,
  nativeDimensions,
  stage,
  variant,
  cacheKeyPrefix,
  stageUsesSampler,
  samplerBindingOrder,
  stageDispatchSize,
}: {
  device: GPUDevice;
  nativeDimensions: Dimensions;
  stage: TStage;
  variant: KernelVariant;
  cacheKeyPrefix: string;
  stageUsesSampler: boolean | ((stage: TStage) => boolean);
  samplerBindingOrder: 'before-output' | 'after-output';
  stageDispatchSize: GeneratedLumaModelPipelineOptions<TStage>['stageDispatchSize'];
}): Promise<number> {
  // A small representative surface keeps startup tuning bounded. This measures
  // kernel shape, not end-to-end model throughput; formal benchmarks remain authoritative.
  const sampleDimensions = {
    width: Math.min(nativeDimensions.width, 256),
    height: Math.min(nativeDimensions.height, 144),
  };
  const inputTextures = Array.from({ length: stage.bindings.length }, (_, index) =>
    device.createTexture({
      label: `${cacheKeyPrefix}/autotune/input/${index}`,
      size: sampleDimensions,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST,
    }));
  const scale = resolveScale(stage.outputScale);
  const outputSize = {
    width: sampleDimensions.width * scale.x,
    height: sampleDimensions.height * scale.y,
  };
  const dispatchSize = typeof stageDispatchSize === 'function'
    ? stageDispatchSize(stage, outputSize, sampleDimensions)
    : stageDispatchSize === 'native'
      ? sampleDimensions
      : outputSize;
  const includeSampler = typeof stageUsesSampler === 'function'
    ? stageUsesSampler(stage)
    : stageUsesSampler;
  const pass = new ComputeTexturePass({
    device,
    inputTextures,
    shaderWGSL: variant.wgsl,
    name: `${cacheKeyPrefix} autotune ${variant.id}`,
    cacheKeyPrefix: `${cacheKeyPrefix}/autotune/${hashString(variant.wgsl)}`,
    outputSize,
    dispatchSize,
    workgroupSize: variant.workgroup,
    includeSampler,
    samplerBindingOrder,
    samplerKey: `${cacheKeyPrefix}/autotune/sampler`,
  });

  try {
    const warmup = device.createCommandEncoder({ label: `${cacheKeyPrefix}/autotune/warmup` });
    pass.pass(warmup);
    device.queue.submit([warmup.finish()]);
    // Startup tuning is the only runtime path allowed to synchronize the queue.
    // Never copy this wait into per-frame rendering.
    await device.queue.onSubmittedWorkDone();

    const samples: number[] = [];
    const dispatchesPerSample = 3;
    for (let sample = 0; sample < 3; sample += 1) {
      const encoder = device.createCommandEncoder({ label: `${cacheKeyPrefix}/autotune/sample` });
      for (let dispatch = 0; dispatch < dispatchesPerSample; dispatch += 1) {
        pass.pass(encoder);
      }
      const startedAt = performance.now();
      device.queue.submit([encoder.finish()]);
      await device.queue.onSubmittedWorkDone();
      samples.push((performance.now() - startedAt) / dispatchesPerSample);
    }
    return median(samples);
  } finally {
    pass.destroy();
    inputTextures.forEach(texture => texture.destroy());
  }
}

export async function tuneGeneratedLumaModel<
  TStage extends GeneratedLumaStageConfig,
  TModel extends { key: string; name: string; stages: TStage[] },
>({
  device,
  capabilities,
  nativeDimensions,
  model,
  cacheKeyPrefix,
  stageUsesSampler = false,
  samplerBindingOrder = 'after-output',
  stageDispatchSize = 'output',
  optimizationFlags = defaultOptimizationFeatureFlags,
}: TuneGeneratedLumaModelOptions<TStage, TModel>): Promise<TModel> {
  if (!capabilities || !optimizationFlags.kernelAutotune) {
    return model;
  }
  // Tune one common non-final stage and apply its workgroup shape to compatible
  // stages. Benchmarking every stage cannot fit the shared 300 ms startup budget.
  const representative = model.stages.find(stage =>
    stage.kernelVariants
    && stage.kernelVariants.length > 1
    && stage.optimizationFlag
    && optimizationFlags[stage.optimizationFlag]
    && !stage.final);
  if (!representative?.kernelVariants) {
    return model;
  }

  const applyVariant = (variantId: string): TModel => ({
    ...model,
    stages: model.stages.map(stage => {
      const variant = stage.kernelVariants?.find(candidate => candidate.id === variantId);
      return variant ? {
        ...stage,
        optimizedShaderWGSL: variant.wgsl,
        optimizedWorkgroupSize: variant.workgroup,
      } : stage;
    }),
  } as TModel);
  const override = tuningOverrideByDevice.get(device);
  if (override) {
    const variant = representative.kernelVariants.find(candidate => candidate.id === override);
    if (!variant) {
      throw new Error(`Kernel variant override is unavailable for ${model.key}: ${override}`);
    }
    const reports = tuningReportByDevice.get(device) ?? [];
    reports.push({
      cacheNamespace: `${cacheKeyPrefix}/${model.key}/workgroup`,
      modelKey: model.key,
      variantId: variant.id,
      source: 'override',
      gainPercent: 0,
      elapsedMs: 0,
    });
    tuningReportByDevice.set(device, reports);
    return applyVariant(variant.id);
  }

  const baselineId = representative.kernelVariants.some(variant => variant.id === 'untiled-8x8')
    ? 'untiled-8x8'
    : 'tile-8x8';

  const firstStartedAt = tuningStartedAtByDevice.get(device) ?? performance.now();
  tuningStartedAtByDevice.set(device, firstStartedAt);
  const remainingBudget = GENERATED_KERNEL_TUNING_BUDGET_MS - (performance.now() - firstStartedAt);
  if (remainingBudget <= 0) {
    return applyVariant(baselineId);
  }

  const tuningStartedAt = performance.now();
  const cacheNamespace = `${cacheKeyPrefix}/${model.key}/workgroup`;
  const selection = await selectKernelVariant({
    capabilities,
    variants: representative.kernelVariants,
    baselineId,
    shaderHash: hashString(representative.kernelVariants.map(variant => variant.wgsl).join('\n')),
    cacheNamespace,
    allowedCorrectness: ['exact'],
    budgetMs: remainingBudget,
    minimumGainPercent: 3,
    benchmark: variant => benchmarkGeneratedKernelVariant({
      device,
      nativeDimensions,
      stage: representative,
      variant,
      cacheKeyPrefix: `${cacheKeyPrefix}/${model.key}`,
      stageUsesSampler,
      samplerBindingOrder,
      stageDispatchSize,
    }),
  });
  const reports = tuningReportByDevice.get(device) ?? [];
  reports.push({
    cacheNamespace,
    modelKey: model.key,
    variantId: selection.variant.id,
    source: selection.source,
    gainPercent: selection.gainPercent,
    elapsedMs: performance.now() - tuningStartedAt,
  });
  tuningReportByDevice.set(device, reports);

  return applyVariant(selection.variant.id);
}

export async function prepareGeneratedLumaComputePipelines<
  TStage extends GeneratedLumaStageConfig,
>({
  device,
  model,
  cacheKeyPrefix,
  stageUsesSampler = false,
  samplerBindingOrder = 'after-output',
  optimizationFlags = defaultOptimizationFeatureFlags,
}: Pick<
  GeneratedLumaModelPipelineOptions<TStage>,
  'device' | 'model' | 'cacheKeyPrefix' | 'stageUsesSampler' | 'samplerBindingOrder' | 'optimizationFlags'
>): Promise<void> {
  const tasks = model.stages
    .filter(stage => !(
      optimizationFlags.fusedPixelShuffleRecompose
      && stage.final
      && stage.finalOperation === 'pixel-shuffle-2x'
    ))
    .map(stage => async () => {
      const useOptimizedShader = Boolean(
        stage.optimizedShaderWGSL
        && stage.optimizationFlag
        && optimizationFlags[stage.optimizationFlag],
      );
      const includeSampler = typeof stageUsesSampler === 'function'
        ? stageUsesSampler(stage)
        : stageUsesSampler;
      await ComputeTexturePass.preparePipeline({
        device,
        inputTextureCount: stage.bindings.length,
        shaderWGSL: useOptimizedShader ? stage.optimizedShaderWGSL! : stage.shaderWGSL,
        name: `${model.name}: ${stage.name}`,
        cacheKeyPrefix: `${cacheKeyPrefix}/stage`,
        includeSampler,
        samplerBindingOrder,
      });
    });

  const concurrency = Math.min(8, tasks.length);
  let nextTask = 0;
  await Promise.all(Array.from({ length: concurrency }, async () => {
    while (nextTask < tasks.length) {
      const task = tasks[nextTask];
      nextTask += 1;
      await task();
    }
  }));
}

interface LumaTextureVersion {
  id: number;
  symbol: string;
  producerStage: number;
  lastUse: number;
  width: number;
  height: number;
  texture?: GPUTexture;
}

interface ResolvedLumaStage<TStage> {
  stage: TStage;
  inputVersions: number[];
  outputVersion: number;
  outputSize: Dimensions;
}

function resolveScale(scale: GeneratedLumaScale): { x: number; y: number } {
  return typeof scale === 'number'
    ? { x: scale, y: scale }
    : scale;
}

export class GeneratedLumaModelPipeline<TStage extends GeneratedLumaStageConfig = GeneratedLumaStageConfig> implements PipelinePass {
  private readonly pipelines: PipelinePass[] = [];

  private readonly finalLumaTexture?: GPUTexture;

  private readonly ownedStageTextures: GPUTexture[] = [];

  private readonly versions: LumaTextureVersion[];

  private destroyed = false;

  constructor({
    device,
    inputTexture,
    nativeDimensions,
    model,
    cacheKeyPrefix,
    stageUsesSampler = false,
    samplerBindingOrder = 'after-output',
    stageDispatchSize = 'output',
    stageWorkgroupSize = { width: 8, height: 8 },
    outputRecomposeShaderWGSL = defaultLumaRecomposeWGSL,
    outputRecomposeTerminalWGSL = defaultLumaRecomposeTerminalWGSL,
    outputRecomposeWorkgroupSize = { width: 8, height: 8 },
    terminalTarget,
    optimizationFlags = defaultOptimizationFeatureFlags,
  }: GeneratedLumaModelPipelineOptions<TStage>) {
    const analysis = this.analyzeStages(inputTexture, nativeDimensions, model);
    this.versions = analysis.versions;
    const finalStage = analysis.stages[analysis.stages.length - 1];
    const fusePixelShuffleRecompose = Boolean(
      optimizationFlags.fusedPixelShuffleRecompose
      && finalStage?.stage.finalOperation === 'pixel-shuffle-2x',
    );

    try {
      this.allocateStageTextures(
        device,
        cacheKeyPrefix,
        analysis.versions,
        optimizationFlags.textureLifetimeReuse,
        fusePixelShuffleRecompose ? analysis.finalVersion : undefined,
      );
      for (const resolved of analysis.stages) {
        const { stage, inputVersions, outputVersion, outputSize } = resolved;
        const inputTextures = inputVersions.map(version => this.requireVersionTexture(version));
        if (fusePixelShuffleRecompose && outputVersion === analysis.finalVersion) {
          this.pipelines.push(new PixelShuffleRecomposePass({
            device,
            sourceTexture: inputTexture,
            packedLumaTexture: inputTextures[0],
            outputSize,
            name: model.name,
            cacheKeyPrefix,
            terminalTarget,
          }));
          continue;
        }
        const useOptimizedShader = Boolean(
          stage.optimizedShaderWGSL
          && stage.optimizationFlag
          && optimizationFlags[stage.optimizationFlag],
        );
        const optimizedDispatchScale = useOptimizedShader && stage.optimizedDispatchScale
          ? resolveScale(stage.optimizedDispatchScale)
          : null;
        const dispatchSize = typeof stageDispatchSize === 'function'
          ? stageDispatchSize(stage, outputSize, nativeDimensions)
          : stageDispatchSize === 'native'
            ? nativeDimensions
            : optimizedDispatchScale
              ? {
                width: nativeDimensions.width * optimizedDispatchScale.x,
                height: nativeDimensions.height * optimizedDispatchScale.y,
              }
              : outputSize;
        const includeSampler = typeof stageUsesSampler === 'function'
          ? stageUsesSampler(stage)
          : stageUsesSampler;

        this.pipelines.push(new ComputeTexturePass({
          device,
          inputTextures,
          outputTexture: this.requireVersionTexture(outputVersion),
          shaderWGSL: useOptimizedShader ? stage.optimizedShaderWGSL! : stage.shaderWGSL,
          name: `${model.name}: ${stage.name}`,
          cacheKeyPrefix: `${cacheKeyPrefix}/stage`,
          outputSize,
          dispatchSize,
          includeSampler,
          samplerBindingOrder,
          samplerKey: `${cacheKeyPrefix}/stage/sampler/linear`,
          workgroupSize: useOptimizedShader && stage.optimizedWorkgroupSize
            ? stage.optimizedWorkgroupSize
            : stageWorkgroupSize,
          outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
        }));
      }

      if (!fusePixelShuffleRecompose) {
        this.finalLumaTexture = this.requireVersionTexture(analysis.finalVersion);
        this.pipelines.push(new LumaRecomposePass({
          device,
          sourceTexture: inputTexture,
          lumaTexture: this.finalLumaTexture,
          outputSize: { width: nativeDimensions.width * 2, height: nativeDimensions.height * 2 },
          name: model.name,
          cacheKeyPrefix,
          shaderWGSL: outputRecomposeShaderWGSL,
          terminalFragmentWGSL: outputRecomposeTerminalWGSL,
          terminalTarget,
          workgroupSize: outputRecomposeWorkgroupSize,
        }));
      }
    } catch (error) {
      this.pipelines.forEach(pipeline => pipeline.destroy?.());
      this.ownedStageTextures.forEach(releaseTexture);
      this.ownedStageTextures.length = 0;
      throw error;
    }
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  getLumaOutputTexture(): GPUTexture | undefined {
    return this.finalLumaTexture;
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  getTextureResourcePlan(): PipelineTextureResourcePlan {
    const outputTexture = this.getOutputTexture();
    const textures = new Set(this.ownedStageTextures);
    textures.add(outputTexture);
    return {
      peakTextureBytes: [...textures].reduce(
        (total, texture) => total + (getTextureAllocationInfo(texture)?.byteSize ?? 0),
        0,
      ),
      textureSlotCount: textures.size,
      resourceReleasePlan: [
        ...this.versions
          .filter(version => version.producerStage >= 0)
          .map(version => ({
            afterPass: version.lastUse,
            textureLabel: `${version.symbol}@${version.id}`,
          })),
        {
          afterPass: this.pipelines.length - 1,
          textureLabel: 'rgba-output',
        },
      ],
    };
  }

  destroy(): void {
    if (this.destroyed) {
      return;
    }
    this.destroyed = true;
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
    this.ownedStageTextures.forEach(releaseTexture);
    this.ownedStageTextures.length = 0;
  }

  private analyzeStages(
    inputTexture: GPUTexture,
    nativeDimensions: Dimensions,
    model: { name: string; stages: TStage[] },
  ): {
    versions: LumaTextureVersion[];
    stages: ResolvedLumaStage<TStage>[];
    finalVersion: number;
  } {
    const versions: LumaTextureVersion[] = [{
      id: 0,
      symbol: 'LUMA',
      producerStage: -1,
      lastUse: -1,
      width: nativeDimensions.width,
      height: nativeDimensions.height,
      texture: inputTexture,
    }];
    const currentVersionBySymbol = new Map<string, number>([['LUMA', 0]]);
    const stages: ResolvedLumaStage<TStage>[] = [];
    let finalVersion: number | null = null;

    model.stages.forEach((stage, stageIndex) => {
      // Each assignment creates a fresh SSA version. Dense and residual models can
      // read older versions after the same symbolic output name has been overwritten.
      const inputVersions = stage.bindings.map(binding => {
        const version = currentVersionBySymbol.get(binding);
        if (version === undefined) {
          throw new Error(`${model.name}: missing texture binding ${binding} for ${stage.name}.`);
        }
        return version;
      });
      for (const version of new Set(inputVersions)) {
        versions[version].lastUse = stageIndex;
      }

      const scale = resolveScale(stage.outputScale);
      const outputSize = {
        width: nativeDimensions.width * scale.x,
        height: nativeDimensions.height * scale.y,
      };
      const outputVersion = versions.length;
      versions.push({
        id: outputVersion,
        symbol: stage.outputName,
        producerStage: stageIndex,
        lastUse: stageIndex,
        ...outputSize,
      });
      stages.push({ stage, inputVersions, outputVersion, outputSize });

      if (stage.final) {
        finalVersion = outputVersion;
      } else {
        currentVersionBySymbol.set(stage.outputName, outputVersion);
      }
    });

    if (finalVersion === null) {
      throw new Error(`${model.name}: no final luma output stage generated.`);
    }
    // The final luma survives one extra logical step for output recomposition.
    versions[finalVersion].lastUse = model.stages.length;
    return { versions, stages, finalVersion };
  }

  private allocateStageTextures(
    device: GPUDevice,
    cacheKeyPrefix: string,
    versions: LumaTextureVersion[],
    reuseTextures: boolean,
    skippedVersion?: number,
  ): void {
    const slotsBySize = new Map<string, Array<{ texture: GPUTexture; lastUse: number }>>();
    for (const version of versions) {
      if (version.producerStage < 0) {
        continue;
      }
      if (version.id === skippedVersion) {
        // Fused pixel-shuffle/recompose consumes the final packed inputs directly;
        // allocating the logical final luma texture would be dead storage.
        continue;
      }
      const key = `${version.width}|${version.height}`;
      const slots = slotsBySize.get(key) ?? [];
      // Do not weaken this to <=. Equality means the previous version is read by the
      // producing pass, which would bind one texture as both sampled input and output.
      let slot = reuseTextures
        ? slots.find(candidate => candidate.lastUse < version.producerStage)
        : undefined;
      if (!slot) {
        const texture = borrowTexture({
          device,
          width: version.width,
          height: version.height,
          format: 'rgba16float',
          usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
          labelGroup: `${cacheKeyPrefix}/ssa-stage-output`,
          label: `${cacheKeyPrefix} SSA stage slot ${this.ownedStageTextures.length}`,
        });
        this.ownedStageTextures.push(texture);
        slot = { texture, lastUse: version.lastUse };
        slots.push(slot);
        slotsBySize.set(key, slots);
      } else {
        slot.lastUse = version.lastUse;
      }
      version.texture = slot.texture;
    }
  }

  private requireVersionTexture(version: number): GPUTexture {
    const texture = this.versions[version]?.texture;
    if (!texture) {
      throw new Error(`Generated luma texture version is not allocated: ${version}`);
    }
    return texture;
  }
}

import { Downscale } from '../../shared-effects/downscale';
import type { PipelinePass, PipelineProfileRecorder } from '../backend-types';
import { ComputeTexturePass } from '../../gpu-passes/compute-texture-pass';
import { DepthToSpacePass } from '../../gpu-passes/depth-to-space-pass';
import { LumaRecomposePass } from '../../gpu-passes/luma-recompose-pass';
import { RenderCompositePass } from '../../gpu-passes/render-composite-pass';
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
}

export class EffectGraphRunner implements PipelinePass {
  readonly pipelines: PipelinePass[];

  private readonly texturesBySymbol = new Map<TextureSymbol, GPUTexture>();

  private readonly outputSymbol: TextureSymbol;

  constructor({
    device,
    inputTexture,
    graph,
  }: EffectGraphRunnerDescriptor) {
    this.outputSymbol = graph.output;
    this.pipelines = [];
    this.texturesBySymbol.set(graph.input, inputTexture);

    graph.stages.forEach((stage) => {
      const pass = this.createStagePass(device, stage);
      this.pipelines.push(pass);
      this.texturesBySymbol.set(stage.output, pass.getOutputTexture());
    });

    if (!this.texturesBySymbol.has(graph.output)) {
      throw new Error(`Effect graph output texture is not defined: ${graph.output}`);
    }
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.requireTexture(this.outputSymbol);
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  private createStagePass(device: GPUDevice, stage: GraphStage): PipelinePass {
    switch (stage.op) {
      case 'compute':
        return new ComputeTexturePass({
          device,
          inputTextures: stage.inputs.map(input => this.requireTexture(input)),
          shaderWGSL: stage.shaderWGSL,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          outputSize: stage.outputSize ? this.resolveDimensions(stage.outputSize) : undefined,
          outputFormat: stage.outputFormat,
          outputUsage: stage.outputUsage,
          includeSampler: stage.includeSampler,
          samplerBindingOrder: stage.samplerBindingOrder,
          samplerKey: stage.samplerKey,
          samplerDescriptor: stage.samplerDescriptor,
          workgroupSize: stage.workgroupSize,
          dispatchSize: stage.dispatchSize ? this.resolveDimensions(stage.dispatchSize) : undefined,
          entryPoint: stage.entryPoint,
          extraLayoutEntries: stage.extraLayoutEntries,
          extraBindGroupEntries: stage.extraBindGroupEntries,
          extraLayoutKey: stage.extraLayoutKey,
        });
      case 'depth-to-space':
        return new DepthToSpacePass({
          device,
          inputTextures: stage.inputs.map(input => this.requireTexture(input)),
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
        });
      case 'render-composite':
        return new RenderCompositePass({
          device,
          inputTextures: stage.inputs.map(input => this.requireTexture(input)),
          outputSize: this.resolveDimensions(stage.outputSize),
          fragmentWGSL: stage.fragmentWGSL,
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          samplerKey: stage.samplerKey,
          outputFormat: stage.outputFormat,
          outputUsage: stage.outputUsage,
        });
      case 'resize':
        return new Downscale({
          device,
          inputTexture: this.requireTexture(stage.input),
          targetDimensions: this.resolveDimensions(stage.outputSize),
          name: stage.name ?? stage.id,
        });
      case 'luma-recompose':
        return new LumaRecomposePass({
          device,
          sourceTexture: this.requireTexture(stage.source),
          lumaTexture: this.requireTexture(stage.luma),
          outputSize: this.resolveDimensions(stage.outputSize),
          name: stage.name ?? stage.id,
          cacheKeyPrefix: stage.cacheKeyPrefix,
          shaderWGSL: stage.shaderWGSL,
          workgroupSize: stage.workgroupSize,
        });
      default:
        return this.assertNever(stage);
    }
  }

  private resolveDimensions(expression: DimensionExpression): { width: number; height: number } {
    if (expression.kind === 'absolute') {
      return {
        width: expression.width,
        height: expression.height,
      };
    }

    const texture = this.requireTexture(expression.texture);
    const scale = expression.scale ?? 1;
    return {
      width: Math.round(texture.width * scale),
      height: Math.round(texture.height * scale),
    };
  }

  private requireTexture(symbol: TextureSymbol): GPUTexture {
    const texture = this.texturesBySymbol.get(symbol);
    if (!texture) {
      throw new Error(`Effect graph texture is not defined: ${symbol}`);
    }
    return texture;
  }

  private assertNever(stage: never): never {
    throw new Error(`Unsupported effect graph stage: ${JSON.stringify(stage)}`);
  }
}

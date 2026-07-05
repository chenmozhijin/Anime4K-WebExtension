import type { Dimensions } from '../../types';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';
import { ComputeTexturePass } from '../gpu-passes/compute-texture-pass';
import {
  defaultLumaRecomposeWGSL,
  LumaRecomposePass,
} from '../gpu-passes/luma-recompose-pass';

export type GeneratedLumaScale = number | { x: number; y: number };

export interface GeneratedLumaStageConfig {
  name: string;
  shaderWGSL: string;
  bindings: string[];
  outputName: string;
  outputScale: GeneratedLumaScale;
  final: boolean;
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
  outputRecomposeWorkgroupSize?: Dimensions;
}

function resolveScale(scale: GeneratedLumaScale): { x: number; y: number } {
  return typeof scale === 'number'
    ? { x: scale, y: scale }
    : scale;
}

export class GeneratedLumaModelPipeline<TStage extends GeneratedLumaStageConfig = GeneratedLumaStageConfig> implements PipelinePass {
  private readonly pipelines: PipelinePass[] = [];

  private readonly finalLumaTexture: GPUTexture;

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
      outputRecomposeWorkgroupSize = { width: 8, height: 8 },
  }: GeneratedLumaModelPipelineOptions<TStage>) {
    const textures = new Map<string, GPUTexture>([['LUMA', inputTexture]]);
    let finalLumaTexture: GPUTexture | null = null;

    for (const stage of model.stages) {
      const inputTextures = stage.bindings.map(binding => {
        const texture = textures.get(binding);
        if (!texture) {
          throw new Error(`${model.name}: missing texture binding ${binding} for ${stage.name}.`);
        }

        return texture;
      });
      const scale = resolveScale(stage.outputScale);
      const outputSize = {
        width: nativeDimensions.width * scale.x,
        height: nativeDimensions.height * scale.y,
      };
      const dispatchSize = typeof stageDispatchSize === 'function'
        ? stageDispatchSize(stage, outputSize, nativeDimensions)
        : stageDispatchSize === 'native'
          ? nativeDimensions
          : outputSize;
      const includeSampler = typeof stageUsesSampler === 'function'
        ? stageUsesSampler(stage)
        : stageUsesSampler;

      const pass = new ComputeTexturePass({
        device,
        inputTextures,
        shaderWGSL: stage.shaderWGSL,
        name: `${model.name}: ${stage.name}`,
        cacheKeyPrefix: `${cacheKeyPrefix}/stage`,
        outputSize,
        dispatchSize,
        workgroupSize: stageWorkgroupSize,
        includeSampler,
        samplerBindingOrder,
        samplerKey: `${cacheKeyPrefix}/stage/sampler/linear`,
        outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      });
      this.pipelines.push(pass);

      if (stage.final) {
        finalLumaTexture = pass.getOutputTexture();
      } else {
        textures.set(stage.outputName, pass.getOutputTexture());
      }
    }

    if (!finalLumaTexture) {
      throw new Error(`${model.name}: no final luma output stage generated.`);
    }
    this.finalLumaTexture = finalLumaTexture;

    this.pipelines.push(new LumaRecomposePass({
      device,
      sourceTexture: inputTexture,
      lumaTexture: finalLumaTexture,
      outputSize: { width: nativeDimensions.width * 2, height: nativeDimensions.height * 2 },
      name: model.name,
      cacheKeyPrefix,
      shaderWGSL: outputRecomposeShaderWGSL,
      workgroupSize: outputRecomposeWorkgroupSize,
    }));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  getLumaOutputTexture(): GPUTexture {
    return this.finalLumaTexture;
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}

import type { Dimensions } from '../../types';
import {
  GeneratedLumaModelPipeline,
  type GeneratedLumaStageConfig,
} from '../../core/generated-models/luma-model-pipeline';

export interface ACNetGeneratedStageConfig extends GeneratedLumaStageConfig {
  outputScale: 1 | 2;
}

export interface ACNetGeneratedModelConfig {
  key: string;
  name: string;
  sourceFamily: string;
  stages: ACNetGeneratedStageConfig[];
}

export interface ACNetPipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  nativeDimensions: Dimensions;
  model: ACNetGeneratedModelConfig;
}

export class ACNetGeneratedPipeline extends GeneratedLumaModelPipeline<ACNetGeneratedStageConfig> {
  constructor({ device, inputTexture, nativeDimensions, model }: ACNetPipelineDescriptor) {
    super({
      device,
      inputTexture,
      nativeDimensions,
      model,
      cacheKeyPrefix: 'acnet',
      stageUsesSampler: false,
      stageDispatchSize: 'output',
    });
  }
}

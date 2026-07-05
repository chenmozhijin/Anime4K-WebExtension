// SPDX-License-Identifier: LGPL-3.0-or-later

import type { Dimensions } from '../../types';
import {
  GeneratedLumaModelPipeline,
  type GeneratedLumaStageConfig,
} from '../../core/generated-models/luma-model-pipeline';

export interface CuNNyGeneratedStageConfig extends GeneratedLumaStageConfig {
  outputScale: { x: number; y: number };
}

export interface CuNNyGeneratedModelConfig {
  key: string;
  name: string;
  variant: string;
  stages: CuNNyGeneratedStageConfig[];
}

export interface CuNNyPipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  nativeDimensions: Dimensions;
  model: CuNNyGeneratedModelConfig;
}

export class CuNNyGeneratedPipeline extends GeneratedLumaModelPipeline<CuNNyGeneratedStageConfig> {
  constructor({ device, inputTexture, nativeDimensions, model }: CuNNyPipelineDescriptor) {
    super({
      device,
      inputTexture,
      nativeDimensions,
      model,
      cacheKeyPrefix: 'cunny',
      stageUsesSampler: true,
      samplerBindingOrder: 'before-output',
      stageDispatchSize: 'native',
    });
  }
}

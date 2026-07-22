// SPDX-License-Identifier: LGPL-3.0-or-later

import type { Dimensions } from '../../types';
import {
  GeneratedLumaModelPipeline,
  prepareGeneratedLumaComputePipelines,
  tuneGeneratedLumaModel,
  type GeneratedLumaStageConfig,
} from '../../core/generated-models/luma-model-pipeline';
import type { OptimizationFeatureFlags } from '../../core/optimization-flags';
import type { TerminalTextureTarget } from '../../core/effects/backend-types';
import type { GpuCapabilities } from '../../core/gpu-capabilities';

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
  optimizationFlags?: OptimizationFeatureFlags;
  terminalTarget?: TerminalTextureTarget;
  capabilities?: GpuCapabilities;
}

export class CuNNyGeneratedPipeline extends GeneratedLumaModelPipeline<CuNNyGeneratedStageConfig> {
  static async create(options: CuNNyPipelineDescriptor): Promise<CuNNyGeneratedPipeline> {
    const model = await tuneGeneratedLumaModel({
      device: options.device,
      capabilities: options.capabilities,
      nativeDimensions: options.nativeDimensions,
      model: options.model,
      cacheKeyPrefix: 'cunny',
      stageUsesSampler: true,
      samplerBindingOrder: 'before-output',
      stageDispatchSize: 'native',
      optimizationFlags: options.optimizationFlags,
    });
    await prepareGeneratedLumaComputePipelines({
      device: options.device,
      model,
      cacheKeyPrefix: 'cunny',
      stageUsesSampler: true,
      samplerBindingOrder: 'before-output',
      optimizationFlags: options.optimizationFlags,
    });
    return new CuNNyGeneratedPipeline({ ...options, model });
  }

  constructor({ device, inputTexture, nativeDimensions, model, optimizationFlags }: CuNNyPipelineDescriptor) {
    super({
      device,
      inputTexture,
      nativeDimensions,
      model,
      cacheKeyPrefix: 'cunny',
      stageUsesSampler: true,
      samplerBindingOrder: 'before-output',
      stageDispatchSize: 'native',
      optimizationFlags,
      terminalTarget: undefined,
    });
  }
}

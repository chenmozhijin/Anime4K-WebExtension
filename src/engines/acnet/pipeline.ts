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
  optimizationFlags?: OptimizationFeatureFlags;
  terminalTarget?: TerminalTextureTarget;
  capabilities?: GpuCapabilities;
}

export class ACNetGeneratedPipeline extends GeneratedLumaModelPipeline<ACNetGeneratedStageConfig> {
  static async create(options: ACNetPipelineDescriptor): Promise<ACNetGeneratedPipeline> {
    const model = await tuneGeneratedLumaModel({
      device: options.device,
      capabilities: options.capabilities,
      nativeDimensions: options.nativeDimensions,
      model: options.model,
      cacheKeyPrefix: 'acnet',
      stageUsesSampler: false,
      samplerBindingOrder: 'after-output',
      stageDispatchSize: 'output',
      optimizationFlags: options.optimizationFlags,
    });
    await prepareGeneratedLumaComputePipelines({
      device: options.device,
      model,
      cacheKeyPrefix: 'acnet',
      stageUsesSampler: false,
      samplerBindingOrder: 'after-output',
      optimizationFlags: options.optimizationFlags,
    });
    return new ACNetGeneratedPipeline({ ...options, model });
  }

  constructor({ device, inputTexture, nativeDimensions, model, optimizationFlags, terminalTarget }: ACNetPipelineDescriptor) {
    super({
      device,
      inputTexture,
      nativeDimensions,
      model,
      cacheKeyPrefix: 'acnet',
      stageUsesSampler: false,
      stageDispatchSize: 'output',
      optimizationFlags,
      terminalTarget: model.sourceFamily === 'acnet-legacy' ? undefined : terminalTarget,
    });
  }
}

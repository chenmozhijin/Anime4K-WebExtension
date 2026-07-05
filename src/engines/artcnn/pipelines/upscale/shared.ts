import type { Dimensions } from '../../../../types';
import {
  GeneratedLumaModelPipeline,
  type GeneratedLumaStageConfig,
} from '../../../../core/generated-models/luma-model-pipeline';
import outputRecomposeWGSL from '../helpers/OutputRecompose/shaders/outputRecompose.wgsl';

export interface ArtCNNPipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  nativeDimensions: Dimensions;
  targetDimensions: Dimensions;
}

export interface ArtCNNVariantConfig {
  name: string;
  packedScale: { x: number; y: number };
  shaders: {
    stage0: string;
    stage1: string;
    stage2: string;
    stage3: string;
    stage4: string;
    stage5: string;
    stage6: string;
  };
}

function createStages(config: ArtCNNVariantConfig): GeneratedLumaStageConfig[] {
  return [
    {
      name: 'stage0',
      shaderWGSL: config.shaders.stage0,
      bindings: ['LUMA'],
      outputName: 'stage0',
      outputScale: config.packedScale,
      final: false,
    },
    ...(['stage1', 'stage2', 'stage3', 'stage4', 'stage5'] as const).map((stageName, index) => ({
      name: stageName,
      shaderWGSL: config.shaders[stageName],
      bindings: [index === 0 ? 'stage0' : `stage${index}`],
      outputName: stageName,
      outputScale: config.packedScale,
      final: false,
    })),
    {
      name: 'stage6',
      shaderWGSL: config.shaders.stage6,
      bindings: ['stage0', 'stage5'],
      outputName: 'stage6',
      outputScale: 1,
      final: true,
    },
  ];
}

export class ArtCNNUpscalePipeline extends GeneratedLumaModelPipeline {
  constructor(options: ArtCNNPipelineDescriptor, config: ArtCNNVariantConfig) {
    super({
      device: options.device,
      inputTexture: options.inputTexture,
      nativeDimensions: options.nativeDimensions,
      model: {
        key: config.name,
        name: config.name,
        stages: createStages(config),
      },
      cacheKeyPrefix: 'artcnn',
      stageDispatchSize: 'native',
      stageWorkgroupSize: { width: 12, height: 16 },
      outputRecomposeShaderWGSL: outputRecomposeWGSL,
      outputRecomposeWorkgroupSize: { width: 12, height: 16 },
    });
  }
}

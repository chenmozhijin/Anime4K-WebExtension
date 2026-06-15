import type { PipelinePass } from '../../../../core/effects/backend-types';
import type { Dimensions } from '../../../../types';
import { ArtCNNOutputRecompose, ArtCNNStagePass } from '../helpers';

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

export class ArtCNNUpscalePipeline implements PipelinePass {
  protected readonly pipelines: PipelinePass[] = [];

  constructor(options: ArtCNNPipelineDescriptor, config: ArtCNNVariantConfig) {
    const { device, inputTexture, nativeDimensions } = options;
    const packedTextureSize = {
      width: nativeDimensions.width * config.packedScale.x,
      height: nativeDimensions.height * config.packedScale.y,
    };

    const stage0 = new ArtCNNStagePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: config.shaders.stage0,
      outputTextureSize: packedTextureSize,
      dispatchDimensions: nativeDimensions,
      name: `${config.name}: stage0`,
    });
    this.pipelines.push(stage0);

    let previousTexture = stage0.getOutputTexture();
    for (const [stageName, shaderWGSL] of [
      ['stage1', config.shaders.stage1],
      ['stage2', config.shaders.stage2],
      ['stage3', config.shaders.stage3],
      ['stage4', config.shaders.stage4],
      ['stage5', config.shaders.stage5],
    ] as const) {
      const stage = new ArtCNNStagePass({
        device,
        inputTextures: [previousTexture],
        shaderWGSL,
        outputTextureSize: packedTextureSize,
        dispatchDimensions: nativeDimensions,
        name: `${config.name}: ${stageName}`,
      });
      this.pipelines.push(stage);
      previousTexture = stage.getOutputTexture();
    }

    const stage6 = new ArtCNNStagePass({
      device,
      inputTextures: [stage0.getOutputTexture(), previousTexture],
      shaderWGSL: config.shaders.stage6,
      outputTextureSize: nativeDimensions,
      dispatchDimensions: nativeDimensions,
      name: `${config.name}: stage6`,
    });
    this.pipelines.push(stage6);

    const output = new ArtCNNOutputRecompose({
      device,
      sourceTexture: inputTexture,
      lumaTexture: stage6.getOutputTexture(),
      outputTextureSize: {
        width: nativeDimensions.width * 2,
        height: nativeDimensions.height * 2,
      },
      name: `${config.name}: output`,
    });
    this.pipelines.push(output);
  }

  updateParam(): void {
    throw new Error('Method not implemented.');
  }

  pass(encoder: GPUCommandEncoder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}


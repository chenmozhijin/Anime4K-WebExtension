import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { RenderCompositePass } from '../../../../../core/gpu-passes/render-composite-pass';
import { Anime4KPipeline, OverlayPipelineDescriptor } from '../../interfaces';
import overlay2WGSL from './shaders/overlay2.wgsl';

export class Overlay implements Anime4KPipeline {
  readonly outputTexture: GPUTexture;

  readonly pipeline: GPURenderPipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  private readonly passImpl: RenderCompositePass;

  constructor({
    device,
    inputTextures,
    outputTextureSize,
    fragmentWGSL = overlay2WGSL,
    name = 'overlay',
  }: OverlayPipelineDescriptor) {
    this.name = name;
    this.passImpl = new RenderCompositePass({
      device,
      inputTextures,
      outputSize: {
        width: outputTextureSize[0],
        height: outputTextureSize[1],
      },
      fragmentWGSL,
      name,
      cacheKeyPrefix: 'anime4k/helper/Overlay',
      samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
    });
    this.outputTexture = this.passImpl.outputTexture;
    this.pipeline = this.passImpl.pipeline;
    this.bindGroup = this.passImpl.bindGroup;
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.passImpl.pass(encoder, profile);
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    this.passImpl.destroy();
  }

  getProfileChildren(): PipelinePass[] {
    return [this.passImpl];
  }
}

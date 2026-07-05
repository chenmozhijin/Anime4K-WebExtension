import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { ComputeTexturePass } from '../../../../../core/gpu-passes/compute-texture-pass';
import { Anime4KPipeline, Conv2dPipelineDescriptor } from '../../interfaces';

/**
 * Conv2d pipeline. Takes N input textures and writes one same-sized output texture.
 */
export class Conv2d implements Anime4KPipeline {
  readonly outputTexture: GPUTexture;

  readonly pipeline: GPUComputePipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  private readonly passImpl: ComputeTexturePass;

  constructor({
    device,
    inputTextures,
    shaderWGSL,
    name = 'conv2d',
  }: Conv2dPipelineDescriptor) {
    this.name = name;
    this.passImpl = new ComputeTexturePass({
      device,
      inputTextures,
      shaderWGSL,
      name,
      cacheKeyPrefix: 'anime4k/helper/Conv2d',
      includeSampler: true,
      samplerKey: 'anime4k/helper/Conv2d/sampler/linear-clamp',
      outputSize: {
        width: inputTextures[0]?.width ?? 0,
        height: inputTextures[0]?.height ?? 0,
      },
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
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

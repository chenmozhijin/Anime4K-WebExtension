import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { DepthToSpacePass } from '../../../../../core/gpu-passes/depth-to-space-pass';
import { Anime4KPipeline, DepthToSpacePipelineDescriptor } from '../../interfaces';

export class DepthToSpace implements Anime4KPipeline {
  readonly outputTexture: GPUTexture;

  readonly pipeline: GPUComputePipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  private readonly passImpl: DepthToSpacePass;

  constructor({
    device,
    inputTextures,
    name = 'depth to space',
  }: DepthToSpacePipelineDescriptor) {
    this.name = name;
    this.passImpl = new DepthToSpacePass({
      device,
      inputTextures,
      name,
      cacheKeyPrefix: 'anime4k/helper/DepthToSpace',
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

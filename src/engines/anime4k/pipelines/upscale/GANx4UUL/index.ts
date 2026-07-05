import { EffectGraphRunner } from '../../../../../core/effects/graph';
import type { PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { createGANx4UULGraph } from './graph';

export class GANx4UUL implements Anime4KPipeline {
  readonly pipelines: Anime4KPipeline[];

  private readonly graphRunner: EffectGraphRunner;

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.graphRunner = new EffectGraphRunner({
      device,
      inputTexture,
      graph: createGANx4UULGraph(),
    });
    this.pipelines = this.graphRunner.pipelines;
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.graphRunner.pass(encoder, profile);
  }

  getOutputTexture(): GPUTexture {
    return this.graphRunner.getOutputTexture();
  }

  destroy(): void {
    this.graphRunner.destroy();
  }
}

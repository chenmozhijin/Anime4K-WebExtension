import { EffectGraphRunner } from '../../../../../core/effects/graph';
import type { PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { createCNNULGraph } from './graph';

export class CNNUL implements Anime4KPipeline {
  readonly pipelines: Anime4KPipeline[];

  private readonly graphRunner: EffectGraphRunner;

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.graphRunner = new EffectGraphRunner({
      device,
      inputTexture,
      graph: createCNNULGraph(),
    });
    this.pipelines = this.graphRunner.pipelines;
  }

  getOutputTexture() : GPUTexture {
    return this.graphRunner.getOutputTexture();
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder) {
    this.graphRunner.pass(encoder, profile);
  }

  destroy(): void {
    this.graphRunner.destroy();
  }
}

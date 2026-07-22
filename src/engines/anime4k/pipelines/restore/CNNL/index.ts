import { EffectGraphRunner } from '../../../../../core/effects/graph';
import type { PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { createCNNLGraph } from './graph';

export class CNNL implements Anime4KPipeline {
  private readonly graphRunner: EffectGraphRunner;

  constructor({ device, inputTexture, terminalTarget, optimizationFlags }: Anime4KPipelineDescriptor) {
    this.graphRunner = new EffectGraphRunner({
      device,
      inputTexture,
      terminalTarget,
      optimizationFlags,
      graph: createCNNLGraph(),
    });
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.graphRunner.pass(encoder, profile);
  }

  getOutputTexture(): GPUTexture {
    return this.graphRunner.getOutputTexture();
  }

  getProfileChildren() {
    return this.graphRunner.getProfileChildren();
  }

  destroy(): void {
    this.graphRunner.destroy();
  }
}

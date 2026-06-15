import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import stage4WGSL from './shaders/stage4.wgsl';
import stage5WGSL from './shaders/stage5.wgsl';
import stage6WGSL from './shaders/stage6.wgsl';
import { ArtCNNUpscalePipeline, type ArtCNNPipelineDescriptor } from '../shared';

export class ArtCNNC4F32DN extends ArtCNNUpscalePipeline {
  constructor(options: ArtCNNPipelineDescriptor) {
    super(options, {
      name: 'ArtCNN C4F32 DN',
      packedScale: { x: 4, y: 2 },
      shaders: {
        stage0: stage0WGSL,
        stage1: stage1WGSL,
        stage2: stage2WGSL,
        stage3: stage3WGSL,
        stage4: stage4WGSL,
        stage5: stage5WGSL,
        stage6: stage6WGSL,
      },
    });
  }
}


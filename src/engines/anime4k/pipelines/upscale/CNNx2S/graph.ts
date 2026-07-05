import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createDepthToSpaceStage,
  createGraph,
  createOverlayStage,
  createSerialConvStages,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2dlasttfWGSL from './shaders/conv2dlasttf.wgsl';

const convShaders = [
  conv2dtfWGSL,
  conv2d1tfWGSL,
  conv2d2tfWGSL,
];

export function createCNNx2SGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createSerialConvStages(convShaders);

  stages.push(createConvStage({
    id: 'conv2d_last_tf',
    inputs: ['conv2'],
    output: 'conv-last',
    shaderWGSL: conv2dlasttfWGSL,
  }));

  stages.push(createDepthToSpaceStage('conv-last'));

  stages.push(createOverlayStage({ addon: 'depth', outputSizeScale: 2 }));

  return createGraph(stages);
}

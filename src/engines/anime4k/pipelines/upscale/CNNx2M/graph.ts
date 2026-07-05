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
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2dlasttfWGSL from './shaders/conv2dlasttf.wgsl';

const convShaders = [
  conv2dtfWGSL,
  conv2d1tfWGSL,
  conv2d2tfWGSL,
  conv2d3tfWGSL,
  conv2d4tfWGSL,
  conv2d5tfWGSL,
  conv2d6tfWGSL,
];

export function createCNNx2MGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createSerialConvStages(convShaders);

  stages.push(createConvStage({
    id: 'conv2d_last_tf',
    inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4', 'conv5', 'conv6'],
    output: 'conv-last',
    shaderWGSL: conv2dlasttfWGSL,
  }));

  stages.push(createDepthToSpaceStage('conv-last'));

  stages.push(createOverlayStage({ addon: 'depth', outputSizeScale: 2 }));

  return createGraph(stages);
}

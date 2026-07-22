import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createGraph,
  createRestoreTailStage,
  createSerialConvStages,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import outputWGSL from './shaders/output.wgsl';

const convShaders = [
  conv2dtfWGSL,
  conv2d1tfWGSL,
  conv2d2tfWGSL,
  conv2d3tfWGSL,
  conv2d4tfWGSL,
  conv2d5tfWGSL,
  conv2d6tfWGSL,
];

export function createCNNMGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createSerialConvStages(convShaders);

  stages.push(createRestoreTailStage({
    features: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4', 'conv5', 'conv6'],
    headShader: outputWGSL,
  }));

  return createGraph(stages);
}

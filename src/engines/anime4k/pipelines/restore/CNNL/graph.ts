import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createPairedBranchConvStages,
  createGraph,
  createRestoreTailStage,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import outputWGSL from './shaders/output.wgsl';

export function createCNNLGraph(): EffectGraph {
  const stages = createPairedBranchConvStages([
    conv2dtfWGSL,
    conv2dtf1WGSL,
    conv2d1tfWGSL,
    conv2d1tf1WGSL,
    conv2d2tfWGSL,
    conv2d2tf1WGSL,
    conv2d3tfWGSL,
    conv2d3tf1WGSL,
  ], 4);
  stages.push(createRestoreTailStage({
    features: ['conv6', 'conv7'],
    headShader: outputWGSL,
  }));

  return createGraph(stages);
}

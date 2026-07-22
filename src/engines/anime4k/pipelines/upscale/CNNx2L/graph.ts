import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createPairedBranchConvStages,
  createGraph,
  createUpscaleTailStage,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2dlasttfWGSL from './shaders/conv2dlasttf.wgsl';
import conv2dlasttf1WGSL from './shaders/conv2dlasttf1.wgsl';
import conv2dlasttf2WGSL from './shaders/conv2dlasttf2.wgsl';

export function createCNNx2LGraph(): EffectGraph {
  const stages = createPairedBranchConvStages([
    conv2dtfWGSL,
    conv2dtf1WGSL,
    conv2d1tfWGSL,
    conv2d1tf1WGSL,
    conv2d2tfWGSL,
    conv2d2tf1WGSL,
  ], 3);
  stages.push(createUpscaleTailStage({
    features: ['conv4', 'conv5'],
    headShaders: [conv2dlasttfWGSL, conv2dlasttf1WGSL, conv2dlasttf2WGSL],
  }));

  return createGraph(stages);
}

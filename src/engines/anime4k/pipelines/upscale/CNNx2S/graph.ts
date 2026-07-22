import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createGraph,
  createUpscaleTailStage,
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

  stages.push(createUpscaleTailStage({
    features: ['conv2'],
    headShaders: [conv2dlasttfWGSL],
    terminalDirect: true,
  }));

  return createGraph(stages);
}

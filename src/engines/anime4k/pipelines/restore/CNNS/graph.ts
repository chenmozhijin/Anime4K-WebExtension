import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createGraph,
  createOverlayStage,
  createSerialConvStages,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import outputWGSL from './shaders/output.wgsl';

const convShaders = [
  conv2dtfWGSL,
  conv2d1tfWGSL,
  conv2d2tfWGSL,
];

export function createCNNSGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createSerialConvStages(convShaders);

  stages.push(createConvStage({
    id: 'output',
    inputs: ['conv2'],
    output: 'restore',
    shaderWGSL: outputWGSL,
  }));

  stages.push(createOverlayStage({ addon: 'restore' }));

  return createGraph(stages);
}

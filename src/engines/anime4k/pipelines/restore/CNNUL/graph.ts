import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createConvSymbols,
  createGraph,
  createOverlayStage,
  createTripleBranchConvStages,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2dtf2WGSL from './shaders/conv2dtf2.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d1tf2WGSL from './shaders/conv2d1tf2.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2d2tf2WGSL from './shaders/conv2d2tf2.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d4tf1WGSL from './shaders/conv2d4tf1.wgsl';
import conv2d4tf2WGSL from './shaders/conv2d4tf2.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d5tf1WGSL from './shaders/conv2d5tf1.wgsl';
import conv2d5tf2WGSL from './shaders/conv2d5tf2.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import conv2d6tf2WGSL from './shaders/conv2d6tf2.wgsl';
import conv2d7tfWGSL from './shaders/conv2d7tf.wgsl';
import conv2d7tf1WGSL from './shaders/conv2d7tf1.wgsl';
import conv2d7tf2WGSL from './shaders/conv2d7tf2.wgsl';
import outputWGSL from './shaders/output.wgsl';

const branchShaders = [
  conv2dtfWGSL,
  conv2dtf1WGSL,
  conv2dtf2WGSL,
  conv2d1tfWGSL,
  conv2d1tf1WGSL,
  conv2d1tf2WGSL,
  conv2d2tfWGSL,
  conv2d2tf1WGSL,
  conv2d2tf2WGSL,
  conv2d3tfWGSL,
  conv2d3tf1WGSL,
  conv2d3tf2WGSL,
  conv2d4tfWGSL,
  conv2d4tf1WGSL,
  conv2d4tf2WGSL,
  conv2d5tfWGSL,
  conv2d5tf1WGSL,
  conv2d5tf2WGSL,
  conv2d6tfWGSL,
  conv2d6tf1WGSL,
  conv2d6tf2WGSL,
  conv2d7tfWGSL,
  conv2d7tf1WGSL,
  conv2d7tf2WGSL,
];

export function createCNNULGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createTripleBranchConvStages(branchShaders, 8);

  stages.push(createConvStage({
    id: 'output',
    inputs: createConvSymbols(9, 15),
    output: 'restore',
    shaderWGSL: outputWGSL,
  }));
  stages.push(createOverlayStage({ addon: 'restore' }));

  return createGraph(stages);
}

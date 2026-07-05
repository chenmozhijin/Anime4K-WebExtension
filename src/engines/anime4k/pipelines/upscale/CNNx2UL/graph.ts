import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createConvSymbols,
  createDepthToSpaceStage,
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
import conv2dlasttfWGSL from './shaders/conv2dlasttf.wgsl';
import conv2dlasttf1WGSL from './shaders/conv2dlasttf1.wgsl';
import conv2dlasttf2WGSL from './shaders/conv2dlasttf2.wgsl';

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
];

export function createCNNx2ULGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = createTripleBranchConvStages(branchShaders, 7);
  const lastInputs = createConvSymbols(6, 15);

  stages.push(createConvStage({
    id: 'conv2d_last_tf_0',
    inputs: lastInputs,
    output: 'last0',
    shaderWGSL: conv2dlasttfWGSL,
  }));
  stages.push(createConvStage({
    id: 'conv2d_last_tf_1',
    inputs: lastInputs,
    output: 'last1',
    shaderWGSL: conv2dlasttf1WGSL,
  }));
  stages.push(createConvStage({
    id: 'conv2d_last_tf_2',
    inputs: lastInputs,
    output: 'last2',
    shaderWGSL: conv2dlasttf2WGSL,
  }));
  stages.push(createDepthToSpaceStage(['last0', 'last1', 'last2']));
  stages.push(createOverlayStage({ addon: 'depth', outputSizeScale: 2 }));

  return createGraph(stages);
}

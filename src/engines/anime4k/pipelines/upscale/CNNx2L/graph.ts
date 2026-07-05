import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createDepthToSpaceStage,
  createGraph,
  createOverlayStage,
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
  const stages: EffectGraph['stages'] = [
    createConvStage({
      id: 'conv2d_tf',
      inputs: ['input'],
      output: 'conv0',
      shaderWGSL: conv2dtfWGSL,
    }),
    createConvStage({
      id: 'conv2d_tf_1',
      inputs: ['input'],
      output: 'conv1',
      shaderWGSL: conv2dtf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_1_tf',
      inputs: ['conv0', 'conv1'],
      output: 'conv2',
      shaderWGSL: conv2d1tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_1_tf_1',
      inputs: ['conv0', 'conv1'],
      output: 'conv3',
      shaderWGSL: conv2d1tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_2_tf',
      inputs: ['conv2', 'conv3'],
      output: 'conv4',
      shaderWGSL: conv2d2tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_2_tf_1',
      inputs: ['conv2', 'conv3'],
      output: 'conv5',
      shaderWGSL: conv2d2tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_last_tf_0',
      inputs: ['conv4', 'conv5'],
      output: 'last0',
      shaderWGSL: conv2dlasttfWGSL,
    }),
    createConvStage({
      id: 'conv2d_last_tf_1',
      inputs: ['conv4', 'conv5'],
      output: 'last1',
      shaderWGSL: conv2dlasttf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_last_tf_2',
      inputs: ['conv4', 'conv5'],
      output: 'last2',
      shaderWGSL: conv2dlasttf2WGSL,
    }),
    createDepthToSpaceStage(['last0', 'last1', 'last2'], 'depth'),
  ];
  stages.push(createOverlayStage({ addon: 'depth', outputSizeScale: 2 }));

  return createGraph(stages);
}

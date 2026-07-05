import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createGraph,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d1tf2WGSL from './shaders/conv2d1tf2.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d4tf1WGSL from './shaders/conv2d4tf1.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d5tf1WGSL from './shaders/conv2d5tf1.wgsl';
import conv2d5tf2WGSL from './shaders/conv2d5tf2.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import outputWGSL from './shaders/output.wgsl';
import overlayHalfResidualWGSL from './shaders/overlayHalfResidual.wgsl';

export function createGANUULGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = [
    createConvStage({
      id: 'conv2d_tf',
      inputs: ['input'],
      output: 'conv0',
      shaderWGSL: conv2dtfWGSL,
    }),
    createConvStage({
      id: 'conv2d_tf1',
      inputs: ['input'],
      output: 'conv1',
      shaderWGSL: conv2dtf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_1_tf_0',
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
      id: 'conv2d_1_tf_2',
      inputs: ['conv0', 'conv1'],
      output: 'conv4',
      shaderWGSL: conv2d1tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_2_tf_0',
      inputs: ['conv2', 'conv3', 'conv4'],
      output: 'conv5',
      shaderWGSL: conv2d2tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_2_tf_1',
      inputs: ['conv2', 'conv3', 'conv4'],
      output: 'conv6',
      shaderWGSL: conv2d2tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf_0',
      inputs: ['conv0', 'conv1', 'conv5', 'conv6'],
      output: 'conv7',
      shaderWGSL: conv2d3tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf_1',
      inputs: ['conv0', 'conv1', 'conv5', 'conv6'],
      output: 'conv8',
      shaderWGSL: conv2d3tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf_2',
      inputs: ['conv0', 'conv1', 'conv5', 'conv6'],
      output: 'conv9',
      shaderWGSL: conv2d3tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_4_tf_0',
      inputs: ['conv7', 'conv8', 'conv9'],
      output: 'conv10',
      shaderWGSL: conv2d4tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_4_tf_1',
      inputs: ['conv7', 'conv8', 'conv9'],
      output: 'conv11',
      shaderWGSL: conv2d4tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_5_tf_0',
      inputs: ['conv5', 'conv6', 'conv10', 'conv11'],
      output: 'conv12',
      shaderWGSL: conv2d5tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_5_tf_1',
      inputs: ['conv5', 'conv6', 'conv10', 'conv11'],
      output: 'conv13',
      shaderWGSL: conv2d5tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_5_tf_2',
      inputs: ['conv5', 'conv6', 'conv10', 'conv11'],
      output: 'conv14',
      shaderWGSL: conv2d5tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_6_tf_0',
      inputs: ['conv12', 'conv13', 'conv14'],
      output: 'conv15',
      shaderWGSL: conv2d6tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_6_tf_1',
      inputs: ['conv12', 'conv13', 'conv14'],
      output: 'conv16',
      shaderWGSL: conv2d6tf1WGSL,
    }),
    createConvStage({
      id: 'output',
      inputs: ['conv10', 'conv11', 'conv15', 'conv16'],
      output: 'residual',
      shaderWGSL: outputWGSL,
    }),
    {
      id: 'output-half-residual',
      name: 'output-half-residual',
      op: 'render-composite',
      inputs: ['input', 'residual'],
      output: 'output',
      fragmentWGSL: overlayHalfResidualWGSL,
      outputSize: { kind: 'texture', texture: 'input' },
      cacheKeyPrefix: 'anime4k/helper/Overlay',
      samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
    },
  ];

  return createGraph(stages);
}

import type { EffectGraph } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createGraph,
} from '../../graph-helpers';
import conv2d0tf0WGSL from './shaders/conv2d0tf0.wgsl';
import conv2d0tf1WGSL from './shaders/conv2d0tf1.wgsl';
import conv2d0tf2WGSL from './shaders/conv2d0tf2.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tf0WGSL from './shaders/conv2d3tf0.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tf0WGSL from './shaders/conv2d6tf0.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import conv2d6tf2WGSL from './shaders/conv2d6tf2.wgsl';
import conv2d7tfWGSL from './shaders/conv2d7tf.wgsl';
import conv2d8tfWGSL from './shaders/conv2d8tf.wgsl';
import conv2d9tf0WGSL from './shaders/conv2d9tf0.wgsl';
import conv2d9tf1WGSL from './shaders/conv2d9tf1.wgsl';
import conv2d9tf2WGSL from './shaders/conv2d9tf2.wgsl';
import conv2d10tfWGSL from './shaders/conv2d10tf.wgsl';
import conv2d11tfWGSL from './shaders/conv2d11tf.wgsl';
import conv2d12tf0WGSL from './shaders/conv2d12tf0.wgsl';
import conv2d12tf1WGSL from './shaders/conv2d12tf1.wgsl';
import conv2d12tf2WGSL from './shaders/conv2d12tf2.wgsl';
import conv2d13tfWGSL from './shaders/conv2d13tf.wgsl';
import conv0ups0WGSL from './shaders/conv0ups0.wgsl';
import conv0ups1WGSL from './shaders/conv0ups1.wgsl';
import conv0ups2WGSL from './shaders/conv0ups2.wgsl';
import overlayConv1ups0WGSL from './shaders/overlayConv1ups0.wgsl';
import overlayConv1ups1WGSL from './shaders/overlayConv1ups1.wgsl';
import overlayOutputWGSL from './shaders/overlayOutput.wgsl';

export function createGANx3LGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = [
    createConvStage({
      id: 'conv2d_tf',
      inputs: ['input'],
      output: 'conv0',
      shaderWGSL: conv2d0tf0WGSL,
    }),
    createConvStage({
      id: 'conv2d_tf1',
      inputs: ['input'],
      output: 'conv1',
      shaderWGSL: conv2d0tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_tf2',
      inputs: ['input'],
      output: 'conv2',
      shaderWGSL: conv2d0tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_2_tf',
      inputs: ['conv0', 'conv1', 'conv2'],
      output: 'conv3',
      shaderWGSL: conv2d2tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_1_tf',
      inputs: ['conv0', 'conv1', 'conv2'],
      output: 'conv4',
      shaderWGSL: conv2d1tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf',
      inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4'],
      output: 'conv5',
      shaderWGSL: conv2d3tf0WGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf1',
      inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4'],
      output: 'conv6',
      shaderWGSL: conv2d3tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_3_tf2',
      inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4'],
      output: 'conv7',
      shaderWGSL: conv2d3tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_5_tf',
      inputs: ['conv5', 'conv6', 'conv7'],
      output: 'conv8',
      shaderWGSL: conv2d5tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_4_tf',
      inputs: ['conv5', 'conv6', 'conv7'],
      output: 'conv9',
      shaderWGSL: conv2d4tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_6_tf',
      inputs: ['conv5', 'conv6', 'conv7', 'conv8', 'conv4', 'conv9'],
      output: 'conv10',
      shaderWGSL: conv2d6tf0WGSL,
    }),
    createConvStage({
      id: 'conv2d_6_tf1',
      inputs: ['conv5', 'conv6', 'conv7', 'conv8', 'conv4', 'conv9'],
      output: 'conv11',
      shaderWGSL: conv2d6tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_6_tf2',
      inputs: ['conv5', 'conv6', 'conv7', 'conv8', 'conv4', 'conv9'],
      output: 'conv12',
      shaderWGSL: conv2d6tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_8_tf',
      inputs: ['conv10', 'conv11', 'conv12'],
      output: 'conv13',
      shaderWGSL: conv2d8tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_7_tf',
      inputs: ['conv10', 'conv11', 'conv12'],
      output: 'conv14',
      shaderWGSL: conv2d7tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_9_tf',
      inputs: ['conv10', 'conv11', 'conv12', 'conv13', 'conv4', 'conv9', 'conv14'],
      output: 'conv15',
      shaderWGSL: conv2d9tf0WGSL,
    }),
    createConvStage({
      id: 'conv2d_9_tf1',
      inputs: ['conv10', 'conv11', 'conv12', 'conv13', 'conv4', 'conv9', 'conv14'],
      output: 'conv16',
      shaderWGSL: conv2d9tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_9_tf2',
      inputs: ['conv10', 'conv11', 'conv12', 'conv13', 'conv4', 'conv9', 'conv14'],
      output: 'conv17',
      shaderWGSL: conv2d9tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_11_tf',
      inputs: ['conv15', 'conv16', 'conv17'],
      output: 'conv18',
      shaderWGSL: conv2d11tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_10_tf',
      inputs: ['conv15', 'conv16', 'conv17'],
      output: 'conv19',
      shaderWGSL: conv2d10tfWGSL,
    }),
    createConvStage({
      id: 'conv2d_12_tf',
      inputs: ['conv15', 'conv16', 'conv17', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19'],
      output: 'conv20',
      shaderWGSL: conv2d12tf0WGSL,
    }),
    createConvStage({
      id: 'conv2d_12_tf1',
      inputs: ['conv15', 'conv16', 'conv17', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19'],
      output: 'conv21',
      shaderWGSL: conv2d12tf1WGSL,
    }),
    createConvStage({
      id: 'conv2d_12_tf2',
      inputs: ['conv15', 'conv16', 'conv17', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19'],
      output: 'conv22',
      shaderWGSL: conv2d12tf2WGSL,
    }),
    createConvStage({
      id: 'conv2d_13_tf',
      inputs: ['conv20', 'conv21', 'conv22'],
      output: 'conv23',
      shaderWGSL: conv2d13tfWGSL,
    }),
    createConvStage({
      id: 'conv0ups',
      inputs: ['conv20', 'conv21', 'conv22', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19', 'conv23'],
      output: 'ups0',
      shaderWGSL: conv0ups0WGSL,
    }),
    createConvStage({
      id: 'conv0ups1',
      inputs: ['conv20', 'conv21', 'conv22', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19', 'conv23'],
      output: 'ups1',
      shaderWGSL: conv0ups1WGSL,
    }),
    createConvStage({
      id: 'conv0ups2',
      inputs: ['conv20', 'conv21', 'conv22', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19', 'conv23'],
      output: 'ups2',
      shaderWGSL: conv0ups2WGSL,
    }),
    {
      id: 'conv1ups',
      name: 'conv1ups',
      op: 'render-composite',
      inputs: ['ups0', 'ups1', 'ups2'],
      output: 'overlay0',
      fragmentWGSL: overlayConv1ups0WGSL,
      outputSize: { kind: 'texture', texture: 'input', scale: 3 },
      cacheKeyPrefix: 'anime4k/helper/Overlay',
      samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
    },
    {
      id: 'conv1ups1',
      name: 'conv1ups1',
      op: 'render-composite',
      inputs: ['ups0', 'ups1', 'ups2'],
      output: 'overlay1',
      fragmentWGSL: overlayConv1ups1WGSL,
      outputSize: { kind: 'texture', texture: 'input', scale: 3 },
      cacheKeyPrefix: 'anime4k/helper/Overlay',
      samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
    },
    {
      id: 'output',
      name: 'output',
      op: 'render-composite',
      inputs: ['overlay0', 'overlay1', 'input'],
      output: 'output',
      fragmentWGSL: overlayOutputWGSL,
      outputSize: { kind: 'texture', texture: 'input', scale: 3 },
      cacheKeyPrefix: 'anime4k/helper/Overlay',
      samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
    },
  ];

  return createGraph(stages);
}

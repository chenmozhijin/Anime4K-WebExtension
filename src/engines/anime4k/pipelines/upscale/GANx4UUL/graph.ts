import type { EffectGraph, GraphStage, TextureSymbol } from '../../../../../core/effects/graph';
import {
  createConvStage,
  createGraph,
  createMultiOutputConvStage,
  createOverlayStage,
} from '../../graph-helpers';
import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2dtf2WGSL from './shaders/conv2dtf2.wgsl';
import conv2dtf3WGSL from './shaders/conv2dtf3.wgsl';
import conv2dtf4WGSL from './shaders/conv2dtf4.wgsl';
import conv2dtf5WGSL from './shaders/conv2dtf5.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d3tf3WGSL from './shaders/conv2d3tf3.wgsl';
import conv2d3tf4WGSL from './shaders/conv2d3tf4.wgsl';
import conv2d3tf5WGSL from './shaders/conv2d3tf5.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import conv2d6tf2WGSL from './shaders/conv2d6tf2.wgsl';
import conv2d6tf3WGSL from './shaders/conv2d6tf3.wgsl';
import conv2d6tf4WGSL from './shaders/conv2d6tf4.wgsl';
import conv2d6tf5WGSL from './shaders/conv2d6tf5.wgsl';
import conv2d7tfWGSL from './shaders/conv2d7tf.wgsl';
import conv2d8tfWGSL from './shaders/conv2d8tf.wgsl';
import conv2d9tfWGSL from './shaders/conv2d9tf.wgsl';
import conv2d9tf1WGSL from './shaders/conv2d9tf1.wgsl';
import conv2d9tf2WGSL from './shaders/conv2d9tf2.wgsl';
import conv2d9tf3WGSL from './shaders/conv2d9tf3.wgsl';
import conv2d9tf4WGSL from './shaders/conv2d9tf4.wgsl';
import conv2d9tf5WGSL from './shaders/conv2d9tf5.wgsl';
import conv2d10tfWGSL from './shaders/conv2d10tf.wgsl';
import conv2d11tfWGSL from './shaders/conv2d11tf.wgsl';
import conv2d12tfWGSL from './shaders/conv2d12tf.wgsl';
import conv2d12tf1WGSL from './shaders/conv2d12tf1.wgsl';
import conv2d12tf2WGSL from './shaders/conv2d12tf2.wgsl';
import conv2d12tf3WGSL from './shaders/conv2d12tf3.wgsl';
import conv2d12tf4WGSL from './shaders/conv2d12tf4.wgsl';
import conv2d12tf5WGSL from './shaders/conv2d12tf5.wgsl';
import conv2d13tfWGSL from './shaders/conv2d13tf.wgsl';
import conv2d14tfWGSL from './shaders/conv2d14tf.wgsl';
import conv2d15tfWGSL from './shaders/conv2d15tf.wgsl';
import conv2d15tf1WGSL from './shaders/conv2d15tf1.wgsl';
import conv2d15tf2WGSL from './shaders/conv2d15tf2.wgsl';
import conv2d15tf3WGSL from './shaders/conv2d15tf3.wgsl';
import conv2d15tf4WGSL from './shaders/conv2d15tf4.wgsl';
import conv2d15tf5WGSL from './shaders/conv2d15tf5.wgsl';
import conv2d16tfWGSL from './shaders/conv2d16tf.wgsl';
import conv2d17tfWGSL from './shaders/conv2d17tf.wgsl';
import conv2d18tfWGSL from './shaders/conv2d18tf.wgsl';
import conv2d18tf1WGSL from './shaders/conv2d18tf1.wgsl';
import conv2d18tf2WGSL from './shaders/conv2d18tf2.wgsl';
import conv2d18tf3WGSL from './shaders/conv2d18tf3.wgsl';
import conv2d18tf4WGSL from './shaders/conv2d18tf4.wgsl';
import conv2d18tf5WGSL from './shaders/conv2d18tf5.wgsl';
import conv2d19tfWGSL from './shaders/conv2d19tf.wgsl';
import conv2d20tfWGSL from './shaders/conv2d20tf.wgsl';
import conv2d21tfWGSL from './shaders/conv2d21tf.wgsl';
import conv2d21tf1WGSL from './shaders/conv2d21tf1.wgsl';
import conv2d21tf2WGSL from './shaders/conv2d21tf2.wgsl';
import conv2d21tf3WGSL from './shaders/conv2d21tf3.wgsl';
import conv2d21tf4WGSL from './shaders/conv2d21tf4.wgsl';
import conv2d21tf5WGSL from './shaders/conv2d21tf5.wgsl';
import conv2d22tfWGSL from './shaders/conv2d22tf.wgsl';
import conv2d23tfWGSL from './shaders/conv2d23tf.wgsl';
import conv2d24tfWGSL from './shaders/conv2d24tf.wgsl';
import conv2d24tf1WGSL from './shaders/conv2d24tf1.wgsl';
import conv2d24tf2WGSL from './shaders/conv2d24tf2.wgsl';
import conv2d24tf3WGSL from './shaders/conv2d24tf3.wgsl';
import conv2d24tf4WGSL from './shaders/conv2d24tf4.wgsl';
import conv2d24tf5WGSL from './shaders/conv2d24tf5.wgsl';
import conv2d25tfWGSL from './shaders/conv2d25tf.wgsl';
import conv0upsWGSL from './shaders/conv0ups.wgsl';
import conv0ups1WGSL from './shaders/conv0ups1.wgsl';
import conv0ups2WGSL from './shaders/conv0ups2.wgsl';
import conv0ups3WGSL from './shaders/conv0ups3.wgsl';
import conv0ups4WGSL from './shaders/conv0ups4.wgsl';
import conv0ups5WGSL from './shaders/conv0ups5.wgsl';
import overlayConv1upsWGSL from './shaders/overlayConv1ups.wgsl';
import overlayConv1ups1WGSL from './shaders/overlayConv1ups1.wgsl';
import overlayConv1ups2WGSL from './shaders/overlayConv1ups2.wgsl';
import overlayConv1ups3WGSL from './shaders/overlayConv1ups3.wgsl';
import overlayConv1ups4WGSL from './shaders/overlayConv1ups4.wgsl';
import overlayConv1ups5WGSL from './shaders/overlayConv1ups5.wgsl';
import outputWGSL from './shaders/output.wgsl';

const convCacheKeyPrefix = 'anime4k/helper/Conv2d';
const convSamplerKey = 'anime4k/helper/Conv2d/sampler/linear-clamp';
const overlayCacheKeyPrefix = 'anime4k/helper/Overlay';
const overlaySamplerKey = 'anime4k/helper/Overlay/sampler/linear-linear';

const branchShaders = [
  [conv2dtfWGSL, conv2dtf1WGSL, conv2dtf2WGSL, conv2dtf3WGSL, conv2dtf4WGSL, conv2dtf5WGSL],
  [conv2d3tfWGSL, conv2d3tf1WGSL, conv2d3tf2WGSL, conv2d3tf3WGSL, conv2d3tf4WGSL, conv2d3tf5WGSL],
  [conv2d6tfWGSL, conv2d6tf1WGSL, conv2d6tf2WGSL, conv2d6tf3WGSL, conv2d6tf4WGSL, conv2d6tf5WGSL],
  [conv2d9tfWGSL, conv2d9tf1WGSL, conv2d9tf2WGSL, conv2d9tf3WGSL, conv2d9tf4WGSL, conv2d9tf5WGSL],
  [conv2d12tfWGSL, conv2d12tf1WGSL, conv2d12tf2WGSL, conv2d12tf3WGSL, conv2d12tf4WGSL, conv2d12tf5WGSL],
  [conv2d15tfWGSL, conv2d15tf1WGSL, conv2d15tf2WGSL, conv2d15tf3WGSL, conv2d15tf4WGSL, conv2d15tf5WGSL],
  [conv2d18tfWGSL, conv2d18tf1WGSL, conv2d18tf2WGSL, conv2d18tf3WGSL, conv2d18tf4WGSL, conv2d18tf5WGSL],
  [conv2d21tfWGSL, conv2d21tf1WGSL, conv2d21tf2WGSL, conv2d21tf3WGSL, conv2d21tf4WGSL, conv2d21tf5WGSL],
  [conv2d24tfWGSL, conv2d24tf1WGSL, conv2d24tf2WGSL, conv2d24tf3WGSL, conv2d24tf4WGSL, conv2d24tf5WGSL],
];

const skipShaders = [
  conv2d1tfWGSL,
  conv2d2tfWGSL,
  conv2d4tfWGSL,
  conv2d5tfWGSL,
  conv2d7tfWGSL,
  conv2d8tfWGSL,
  conv2d10tfWGSL,
  conv2d11tfWGSL,
  conv2d13tfWGSL,
  conv2d14tfWGSL,
  conv2d16tfWGSL,
  conv2d17tfWGSL,
  conv2d19tfWGSL,
  conv2d20tfWGSL,
  conv2d22tfWGSL,
  conv2d23tfWGSL,
];

const upsampleShaders = [
  conv0upsWGSL,
  conv0ups1WGSL,
  conv0ups2WGSL,
  conv0ups3WGSL,
  conv0ups4WGSL,
  conv0ups5WGSL,
];

const overlayShaders = [
  overlayConv1upsWGSL,
  overlayConv1ups1WGSL,
  overlayConv1ups2WGSL,
  overlayConv1ups3WGSL,
  overlayConv1ups4WGSL,
  overlayConv1ups5WGSL,
];

function convName(index: number): TextureSymbol {
  return index === 0 ? 'conv2d_tf' : `conv2d_${index}_tf`;
}

function branchName(block: number, branch: number): TextureSymbol {
  const suffix = branch === 0 ? '' : `${branch}`;
  return `${convName(block * 3)}${suffix}`;
}

function branchOutputs(block: number): TextureSymbol[] {
  return Array.from({ length: 6 }, (_, branch) => branchName(block, branch));
}

function upsampleName(branch: number): TextureSymbol {
  return branch === 0 ? 'conv0ups' : `conv0ups${branch}`;
}

function overlayName(branch: number): TextureSymbol {
  return branch === 0 ? 'conv1ups' : `conv1ups${branch}`;
}

function addBranchStages(
  stages: GraphStage[],
  block: number,
  inputs: TextureSymbol[],
) {
  stages.push(createMultiOutputConvStage({
    id: `${convName(block * 3)}-branches`,
    inputs,
    outputs: branchOutputs(block),
    shaders: branchShaders[block],
    optimizationFlag: 'ganMultiOutputDispatch',
  }));
}

export function createGANx4UULGraph(): EffectGraph {
  const stages: EffectGraph['stages'] = [];
  const residuals: TextureSymbol[] = [];

  addBranchStages(stages, 0, ['input']);

  for (let block = 1; block <= 8; block += 1) {
    const previousOutputs = branchOutputs(block - 1);
    const residual = convName(3 * (block - 1) + 1);
    const bridge = convName(3 * (block - 1) + 2);

    stages.push(createMultiOutputConvStage({
      id: `${residual}-pair`,
      inputs: previousOutputs,
      outputs: [residual, bridge],
      shaders: [
        skipShaders[2 * (block - 1)],
        skipShaders[2 * (block - 1) + 1],
      ],
      optimizationFlag: 'ganMultiOutputDispatch',
    }));

    residuals.push(residual);
    addBranchStages(stages, block, [
      ...previousOutputs,
      bridge,
      ...residuals,
    ]);
  }

  const finalBranchOutputs = branchOutputs(8);
  stages.push(createConvStage({
    id: 'conv2d_25_tf',
    inputs: finalBranchOutputs,
    output: 'conv2d_25_tf',
    shaderWGSL: conv2d25tfWGSL,
  }));

  const upsampleInputs: TextureSymbol[] = [
    ...finalBranchOutputs,
    'conv2d_23_tf',
    ...residuals,
    'conv2d_25_tf',
  ];
  stages.push(createMultiOutputConvStage({
    id: 'conv0ups-branches',
    inputs: upsampleInputs,
    outputs: Array.from({ length: 6 }, (_, branch) => upsampleName(branch)),
    shaders: upsampleShaders,
    optimizationFlag: 'ganMultiOutputDispatch',
  }));

  const upsampleOutputs = Array.from({ length: 6 }, (_, branch) => upsampleName(branch));
  for (let branch = 0; branch < 6; branch += 1) {
    const output = overlayName(branch);
    stages.push({
      id: output,
      name: output,
      op: 'render-composite',
      inputs: upsampleOutputs,
      output,
      fragmentWGSL: overlayShaders[branch],
      outputSize: { kind: 'texture', texture: 'input', scale: 4 },
      cacheKeyPrefix: overlayCacheKeyPrefix,
      samplerKey: overlaySamplerKey,
    });
  }

  stages.push({
    id: 'output',
    name: 'output',
    op: 'compute',
    inputs: Array.from({ length: 6 }, (_, branch) => overlayName(branch)),
    output: 'output-conv',
    shaderWGSL: outputWGSL,
    cacheKeyPrefix: convCacheKeyPrefix,
    includeSampler: true,
    samplerKey: convSamplerKey,
  });
  stages.push(createOverlayStage({ addon: 'output-conv', outputSizeScale: 4 }));

  return createGraph(stages);
}

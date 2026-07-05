import type { EffectGraph, GraphStage, TextureSymbol } from '../../../core/effects/graph';
import overlay2WGSL from './helpers/Overlay/shaders/overlay2.wgsl';

const convCacheKeyPrefix = 'anime4k/helper/Conv2d';
const convSamplerKey = 'anime4k/helper/Conv2d/sampler/linear-clamp';

export function createSerialConvStages(
  shaders: string[],
  input: TextureSymbol = 'input',
  outputPrefix = 'conv',
): GraphStage[] {
  return shaders.map((shaderWGSL, index) => ({
    id: index === 0 ? 'conv2d_tf' : `conv2d_${index}_tf`,
    op: 'compute',
    inputs: [index === 0 ? input : `${outputPrefix}${index - 1}`],
    output: `${outputPrefix}${index}`,
    shaderWGSL,
    cacheKeyPrefix: convCacheKeyPrefix,
    includeSampler: true,
    samplerKey: convSamplerKey,
  }));
}

export function createConvStage({
  id,
  inputs,
  output,
  shaderWGSL,
}: {
  id: string;
  inputs: TextureSymbol[];
  output: TextureSymbol;
  shaderWGSL: string;
}): GraphStage {
  return {
    id,
    op: 'compute',
    inputs,
    output,
    shaderWGSL,
    cacheKeyPrefix: convCacheKeyPrefix,
    includeSampler: true,
    samplerKey: convSamplerKey,
  };
}

export function createPairedBranchConvStages(shaders: string[], groups: number): GraphStage[] {
  const stages: GraphStage[] = [];

  for (let group = 0; group < groups; group += 1) {
    const inputs: TextureSymbol[] = group === 0
      ? ['input']
      : [`conv${2 * (group - 1)}`, `conv${2 * (group - 1) + 1}`];
    const prefix = group === 0 ? 'conv2d_tf' : `conv2d_${group}_tf`;
    stages.push(createConvStage({
      id: prefix,
      inputs,
      output: `conv${2 * group}`,
      shaderWGSL: shaders[2 * group],
    }));
    stages.push(createConvStage({
      id: `${prefix}_1`,
      inputs,
      output: `conv${2 * group + 1}`,
      shaderWGSL: shaders[2 * group + 1],
    }));
  }

  return stages;
}

export function createTripleBranchConvStages(shaders: string[], groups: number): GraphStage[] {
  const stages: GraphStage[] = [];

  for (let group = 0; group < groups; group += 1) {
    const inputs: TextureSymbol[] = group === 0
      ? ['input']
      : [
        `conv${3 * (group - 1)}`,
        `conv${3 * (group - 1) + 1}`,
        `conv${3 * (group - 1) + 2}`,
      ];
    const prefix = group === 0 ? 'conv2d_tf' : `conv2d_${group}_tf`;
    for (let branch = 0; branch < 3; branch += 1) {
      stages.push(createConvStage({
        id: `${prefix}_${branch}`,
        inputs,
        output: `conv${3 * group + branch}`,
        shaderWGSL: shaders[3 * group + branch],
      }));
    }
  }

  return stages;
}

export function createConvSymbols(from: number, count: number): TextureSymbol[] {
  return Array.from({ length: count }, (_, index) => `conv${from + index}`);
}

export function createDepthToSpaceStage(
  input: TextureSymbol | [TextureSymbol, TextureSymbol, TextureSymbol],
  output: TextureSymbol = 'depth',
): GraphStage {
  const inputs: [TextureSymbol, TextureSymbol, TextureSymbol] = Array.isArray(input) ? input : [input, input, input];
  return {
    id: 'depth-to-space',
    name: 'DepthToSpace',
    op: 'depth-to-space',
    inputs,
    output,
    cacheKeyPrefix: 'anime4k/helper/DepthToSpace',
  };
}

export function createOverlayStage({
  addon,
  outputSizeScale = 1,
}: {
  addon: TextureSymbol;
  outputSizeScale?: number;
}): GraphStage {
  return {
    id: 'overlay',
    op: 'render-composite',
    inputs: ['input', addon],
    output: 'output',
    fragmentWGSL: overlay2WGSL,
    outputSize: outputSizeScale === 1
      ? { kind: 'texture', texture: 'input' }
      : { kind: 'texture', texture: 'input', scale: outputSizeScale },
    cacheKeyPrefix: 'anime4k/helper/Overlay',
    samplerKey: 'anime4k/helper/Overlay/sampler/linear-linear',
  };
}

export function createGraph(stages: GraphStage[]): EffectGraph {
  return {
    input: 'input',
    output: 'output',
    stages,
  };
}

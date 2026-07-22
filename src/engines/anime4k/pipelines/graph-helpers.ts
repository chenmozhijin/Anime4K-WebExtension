import type { EffectGraph, GraphStage, TextureSymbol } from '../../../core/effects/graph';
import type { OptimizationFeatureFlags } from '../../../core/optimization-flags';
import { createAnime4KWorkgroupTileVariants } from '../../../core/generated-models/anime4k-workgroup-tile-variant';
import overlay2WGSL from './helpers/Overlay/shaders/overlay2.wgsl';

const convCacheKeyPrefix = 'anime4k/helper/Conv2d';
const convSamplerKey = 'anime4k/helper/Conv2d/sampler/linear-clamp';

export function createSerialConvStages(
  shaders: string[],
  input: TextureSymbol = 'input',
  outputPrefix = 'conv',
): GraphStage[] {
  return shaders.map((shaderWGSL, index) => {
    const variants = createAnime4KWorkgroupTileVariants(shaderWGSL);
    return {
    id: index === 0 ? 'conv2d_tf' : `conv2d_${index}_tf`,
    op: 'compute',
    inputs: [index === 0 ? input : `${outputPrefix}${index - 1}`],
    output: `${outputPrefix}${index}`,
    shaderWGSL,
    cacheKeyPrefix: convCacheKeyPrefix,
    includeSampler: true,
    samplerKey: convSamplerKey,
    ...(variants ? {
      optimizedShaderWGSL: variants[0].wgsl,
      optimizedWorkgroupSize: variants[0].workgroup,
      optimizationFlag: 'anime4kWorkgroupTile' as const,
    } : {}),
  };
  });
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
  const variants = createAnime4KWorkgroupTileVariants(shaderWGSL);
  return {
    id,
    op: 'compute',
    inputs,
    output,
    shaderWGSL,
    cacheKeyPrefix: convCacheKeyPrefix,
    includeSampler: true,
    samplerKey: convSamplerKey,
    ...(variants ? {
      optimizedShaderWGSL: variants[0].wgsl,
      optimizedWorkgroupSize: variants[0].workgroup,
      optimizationFlag: 'anime4kWorkgroupTile' as const,
    } : {}),
  };
}

interface ParsedConvShader {
  inputDeclarations: string[];
  outputDeclaration: string;
  outputName: string;
  commonHelpers: string;
  goFunctions: string[];
  body: string;
}

function parseConvShader(shaderWGSL: string): ParsedConvShader {
  const inputDeclarations = [...shaderWGSL.matchAll(
    /@group\(0\) @binding\(\d+\) var [A-Za-z0-9_]+_tex: texture_2d<f32>;/g,
  )].map(match => match[0]);
  const outputMatch = /@group\(0\) @binding\(\d+\) var ([A-Za-z0-9_]+)_tex: texture_storage_2d<rgba16float, write>;/.exec(shaderWGSL);
  if (!outputMatch) {
    throw new Error('Anime4K multi-output fusion could not find the output declaration.');
  }
  const computeIndex = shaderWGSL.indexOf('@compute');
  const firstGoIndex = shaderWGSL.indexOf('fn go_');
  const helperEnd = firstGoIndex >= 0 ? firstGoIndex : computeIndex;
  const outputEnd = outputMatch.index + outputMatch[0].length;
  const commonHelpers = shaderWGSL.slice(outputEnd, helperEnd).trim();
  const goFunctions = [...shaderWGSL.matchAll(/fn go_\d+\([^)]*\) -> vec4f \{[\s\S]*?\n\}/g)]
    .map(match => match[0]);
  const bodyStart = shaderWGSL.indexOf('  var result:', computeIndex);
  const bodyEnd = shaderWGSL.lastIndexOf('\n}');
  if (bodyStart < 0 || bodyEnd <= bodyStart) {
    throw new Error('Anime4K multi-output fusion could not find the compute body.');
  }
  return {
    inputDeclarations,
    outputDeclaration: outputMatch[0],
    outputName: outputMatch[1],
    commonHelpers,
    goFunctions,
    body: shaderWGSL.slice(bodyStart, bodyEnd),
  };
}

export function createMultiOutputConvShader(shaders: string[]): string {
  if (shaders.length < 2) {
    throw new Error('Anime4K multi-output fusion requires at least two shaders.');
  }
  const parsed = shaders.map(parseConvShader);
  const inputDeclarations = parsed[0].inputDeclarations;
  // Fusion is valid only for branches reading identical resources. Reordering or
  // silently unioning bindings would change which feature map each generated body sees.
  for (const branch of parsed.slice(1)) {
    if (JSON.stringify(branch.inputDeclarations) !== JSON.stringify(inputDeclarations)) {
      throw new Error('Anime4K multi-output fusion requires identical input bindings.');
    }
  }
  const outputDeclarations = parsed.map((branch, index) => branch.outputDeclaration.replace(
    /@binding\(\d+\)/,
    `@binding(${inputDeclarations.length + index})`,
  ));
  // Keep one rgba16float storage output per branch. Combining values in registers
  // would remove the original branch-specific half-precision boundary.
  const branchFunctions = parsed.flatMap((branch, index) => branch.goFunctions.map(source =>
    source.replace(/\bgo_(\d+)\b/g, `branch${index}_go_$1`)));
  const branchBodies = parsed.map((branch, index) => branch.body
    .replace(/\bgo_(\d+)\b/g, `branch${index}_go_$1`)
    .replace(/\bresult\b/g, `result${index}`));

  const commonHelpers = parsed[0].commonHelpers.replace(
    /@group\(0\) @binding\(\d+\) var anime4kLinearSampler: sampler;/,
    `@group(0) @binding(${inputDeclarations.length + parsed.length}) var anime4kLinearSampler: sampler;`,
  );

  return `// Fused Anime4K multi-output convolution.
${inputDeclarations.join('\n')}
${outputDeclarations.join('\n')}

${commonHelpers}

${branchFunctions.join('\n\n')}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dim_out: vec2u = textureDimensions(${parsed[0].outputName}_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

${branchBodies.join('\n\n')}
}
`;
}

export function createMultiOutputConvStage({
  id,
  inputs,
  outputs,
  shaders,
  optimizationFlag = 'multiOutputDispatch',
}: {
  id: string;
  inputs: TextureSymbol[];
  outputs: TextureSymbol[];
  shaders: string[];
  optimizationFlag?: keyof OptimizationFeatureFlags;
}): GraphStage {
  return {
    id,
    op: 'multi-compute',
    inputs,
    outputs,
    shaderWGSL: createMultiOutputConvShader(shaders),
    baselineShaders: shaders,
    cacheKeyPrefix: `${convCacheKeyPrefix}/multi-output`,
    optimizationFlag,
  };
}

export function createPairedBranchConvStages(shaders: string[], groups: number): GraphStage[] {
  const stages: GraphStage[] = [];

  for (let group = 0; group < groups; group += 1) {
    const inputs: TextureSymbol[] = group === 0
      ? ['input']
      : [`conv${2 * (group - 1)}`, `conv${2 * (group - 1) + 1}`];
    const prefix = group === 0 ? 'conv2d_tf' : `conv2d_${group}_tf`;
    stages.push(createMultiOutputConvStage({
      id: `${prefix}_pair`,
      inputs,
      outputs: [`conv${2 * group}`, `conv${2 * group + 1}`],
      shaders: [shaders[2 * group], shaders[2 * group + 1]],
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
    stages.push(createMultiOutputConvStage({
      id: `${prefix}_triple`,
      inputs,
      outputs: createConvSymbols(3 * group, 3),
      shaders: shaders.slice(3 * group, 3 * group + 3),
    }));
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

export function createRestoreTailStage({
  features,
  headShader,
}: {
  features: TextureSymbol[];
  headShader: string;
}): GraphStage {
  return {
    id: 'restore-tail',
    name: 'Restore head + Overlay',
    op: 'model-tail',
    source: 'input',
    features,
    headShaders: [headShader],
    kind: 'restore',
    output: 'output',
    outputSize: { kind: 'texture', texture: 'input' },
    cacheKeyPrefix: 'anime4k/model-tail/restore',
  };
}

export function createUpscaleTailStage({
  features,
  headShaders,
  terminalDirect = false,
}: {
  features: TextureSymbol[];
  headShaders: string[];
  terminalDirect?: boolean;
}): GraphStage {
  return {
    id: 'upscale-tail',
    name: 'Upscale heads + DepthToSpace + Overlay',
    op: 'model-tail',
    terminalDirect,
    source: 'input',
    features,
    headShaders,
    kind: 'upscale',
    output: 'output',
    outputSize: { kind: 'texture', texture: 'input', scale: 2 },
    cacheKeyPrefix: 'anime4k/model-tail/upscale',
  };
}

export function createGraph(stages: GraphStage[]): EffectGraph {
  return {
    input: 'input',
    output: 'output',
    stages,
  };
}

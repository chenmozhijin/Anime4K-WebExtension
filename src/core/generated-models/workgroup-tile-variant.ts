function replaceRequired(source: string, search: string, replacement: string, label: string): string {
  const index = source.indexOf(search);
  if (index < 0) {
    // Fail closed when generator output changes. Returning a partially transformed
    // shader can compile successfully while sampling the wrong neighborhood.
    throw new Error(`Unable to build ${label}: expected shader anchor was not found.`);
  }
  return source.slice(0, index) + replacement + source.slice(index + search.length);
}

function getTextureBindingNames(shaderWGSL: string): string[] {
  return [...shaderWGSL.matchAll(
    /@group\(0\) @binding\(\d+\) var tex_([A-Za-z0-9_]+): texture_2d<f32>;/g,
  )].map(match => match[1]);
}

export function createACNetWorkgroupTileVariant(
  shaderWGSL: string,
  workgroup: { width: number; height: number } = { width: 8, height: 8 },
): string {
  const bindingNames = getTextureBindingNames(shaderWGSL);
  if (bindingNames.length === 0) {
    throw new Error('Unable to build ACNet workgroup tile variant: no input textures were found.');
  }

  const tileWidth = workgroup.width + 2;
  const tileHeight = workgroup.height + 2;
  const declarations = bindingNames.map(name =>
    `var<workgroup> tile_${name}: array<array<vec4f, ${tileWidth}>, ${tileHeight}>;`).join('\n');
  const outputDeclaration = shaderWGSL.match(
    /@group\(0\) @binding\(\d+\) var out_tex: texture_storage_2d<rgba16float, write>;/,
  )?.[0];
  if (!outputDeclaration) {
    throw new Error('Unable to build ACNet workgroup tile variant: output texture was not found.');
  }

  let tiled = replaceRequired(
    shaderWGSL,
    `\n\n\n${outputDeclaration}`,
    `\n${declarations}\n\n${outputDeclaration}`,
    'ACNet workgroup tile variant',
  );

  const tileLoads = bindingNames.map(name => `      tile_${name}[tileY][tileX] = sample_${name}(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );`).join('\n');
  // Cooperative loads and the barrier are inserted before the original bounds
  // return so edge lanes still populate halo values for their in-range neighbors.
  const preamble = `
  let groupOrigin = pixel.xy - localId.xy;
  for (var tileY = localId.y; tileY < ${tileHeight}u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < ${tileWidth}u; tileX += WG_X) {
${tileLoads}
    }
  }
  workgroupBarrier();
`;
  tiled = replaceRequired(
    tiled,
    '  let outputSize = textureDimensions(out_tex);\n\n  if',
    `  let outputSize = textureDimensions(out_tex);\n${preamble}\n  if`,
    'ACNet workgroup tile variant',
  );

  tiled = replaceRequired(
    tiled,
    'const WG_X: u32 = 8u;\nconst WG_Y: u32 = 8u;',
    `const WG_X: u32 = ${workgroup.width}u;\nconst WG_Y: u32 = ${workgroup.height}u;`,
    'ACNet workgroup dimensions',
  );

  for (const name of bindingNames) {
    const samplePattern = new RegExp(
      `sample_${name}\\(pixel\\.xy, vec2i\\((-?\\d+), (-?\\d+)\\)\\)`,
      'g',
    );
    tiled = tiled.replace(samplePattern, (_match, x: string, y: string) =>
      `tile_${name}[localId.y + ${Number(y) + 1}u][localId.x + ${Number(x) + 1}u]`);
  }

  return tiled;
}

export function createACNetWorkgroupTileVariants(shaderWGSL: string): KernelVariant[] {
  const inputTextureCount = getTextureBindingNames(shaderWGSL).length;
  return [{
    id: 'untiled-8x8',
    correctness: 'exact' as const,
    wgsl: shaderWGSL,
    workgroup: { width: 8, height: 8 },
    requiredStorageTexturesPerShaderStage: 1,
    requiredSampledTexturesPerShaderStage: inputTextureCount,
    benchmarkCacheVersion: 4,
  }, ...[
    { width: 8, height: 8 },
    { width: 16, height: 8 },
  ].map(workgroup => ({
    id: `tile-${workgroup.width}x${workgroup.height}`,
    correctness: 'exact' as const,
    wgsl: createACNetWorkgroupTileVariant(shaderWGSL, workgroup),
    workgroup,
    requiredWorkgroupStorageBytes:
      inputTextureCount * (workgroup.width + 2) * (workgroup.height + 2) * 16,
    requiredStorageTexturesPerShaderStage: 1,
    requiredSampledTexturesPerShaderStage: inputTextureCount,
    benchmarkCacheVersion: 4,
  }))];
}

interface CuNNySampleMatch {
  expression: string;
  offsetX: number;
  offsetY: number;
  valueType: 'f32' | 'vec4f';
}

const cunnySamplePattern = /sample_[A-Za-z0-9_]+_(f32|vec4)\(pixel\.xy, vec2i\((-?\d+), (-?\d+)\)(?:, vec2i\(-?\d+, -?\d+\), vec2i\(\d+, \d+\))?\)/g;

function getCuNNySamples(shaderWGSL: string): CuNNySampleMatch[] {
  return [...shaderWGSL.matchAll(cunnySamplePattern)].map(match => ({
    expression: match[0],
    offsetX: Number(match[2]),
    offsetY: Number(match[3]),
    valueType: match[1] === 'f32' ? 'f32' : 'vec4f',
  }));
}

export function createCuNNyWorkgroupTileVariant(
  shaderWGSL: string,
  workgroup: { width: number; height: number } = { width: 8, height: 8 },
): string {
  const samples = getCuNNySamples(shaderWGSL);
  if (samples.length === 0 || samples.length % 9 !== 0) {
    throw new Error(`Unable to build CuNNy workgroup tile variant: expected 9 samples per channel, found ${samples.length}.`);
  }

  const channels = samples.length / 9;
  const valueType = samples[0].valueType;
  if (samples.some(sample => sample.valueType !== valueType)) {
    throw new Error('Unable to build CuNNy workgroup tile variant: mixed shared value types.');
  }
  for (let index = 0; index < samples.length; index += 1) {
    const sample = samples[index];
    const position = index % 9;
    const expectedX = position % 3 - 1;
    const expectedY = Math.floor(position / 3) - 1;
    // Channel and 3x3 sample order are part of the translated weight layout. Refuse
    // tiling if a generator change reorders loads instead of guessing a mapping.
    if (sample.offsetX !== expectedX || sample.offsetY !== expectedY) {
      throw new Error(`Unable to build CuNNy workgroup tile variant: unexpected sample order at ${index}.`);
    }
  }

  const tileWidth = workgroup.width + 2;
  const tileHeight = workgroup.height + 2;
  const declaration = `var<workgroup> G: array<array<array<${valueType}, ${tileWidth}>, ${tileHeight}>, ${channels}>;`;
  const outputDeclaration = shaderWGSL.match(
    /@group\(0\) @binding\(\d+\) var out_tex: texture_storage_2d<rgba16float, write>;/,
  )?.[0];
  if (!outputDeclaration) {
    throw new Error('Unable to build CuNNy workgroup tile variant: output texture was not found.');
  }
  let tiled = replaceRequired(
    shaderWGSL,
    `${outputDeclaration}\n\n`,
    `${outputDeclaration}\n${declaration}\n`,
    'CuNNy workgroup tile variant',
  );

  const dynamicOffset = 'vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1)';
  const tileLoads = Array.from({ length: channels }, (_, channel) => {
    const firstSample = samples[channel * 9].expression;
    const expression = firstSample.replace('vec2i(-1, -1)', dynamicOffset);
    return `      G[${channel}][tileY][tileX] = ${expression};`;
  }).join('\n');
  const preamble = `
  for (var tileY = localId.y; tileY < ${tileHeight}u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < ${tileWidth}u; tileX += WG_X) {
${tileLoads}
    }
  }
  workgroupBarrier();
`;
  tiled = replaceRequired(
    tiled,
    '  let sourceSize = textureDimensions(tex_LUMA);\n\n  if',
    `  let sourceSize = textureDimensions(tex_LUMA);\n${preamble}\n  if`,
    'CuNNy workgroup tile variant',
  );

  tiled = replaceRequired(
    tiled,
    'const WG_X: u32 = 8u;\nconst WG_Y: u32 = 8u;',
    `const WG_X: u32 = ${workgroup.width}u;\nconst WG_Y: u32 = ${workgroup.height}u;`,
    'CuNNy workgroup dimensions',
  );

  let sampleIndex = 0;
  tiled = tiled.replace(cunnySamplePattern, () => {
    const sample = samples[sampleIndex];
    const channel = Math.floor(sampleIndex / 9);
    sampleIndex += 1;
    return `G[${channel}][localId.y + ${sample.offsetY + 1}u][localId.x + ${sample.offsetX + 1}u]`;
  });

  return tiled;
}

export function createCuNNyWorkgroupTileVariants(shaderWGSL: string): KernelVariant[] {
  const samples = getCuNNySamples(shaderWGSL);
  if (samples.length === 0 || samples.length % 9 !== 0) {
    throw new Error('Unable to build CuNNy workgroup variants: invalid sample layout.');
  }
  const channels = samples.length / 9;
  const bytesPerValue = samples[0].valueType === 'f32' ? 4 : 16;
  const inputTextureCount = getTextureBindingNames(shaderWGSL).length;
  return [{
    id: 'untiled-8x8',
    correctness: 'exact' as const,
    wgsl: shaderWGSL,
    workgroup: { width: 8, height: 8 },
    requiredStorageTexturesPerShaderStage: 1,
    requiredSampledTexturesPerShaderStage: inputTextureCount,
    benchmarkCacheVersion: 4,
  }, ...[
    { width: 8, height: 8 },
    { width: 16, height: 8 },
  ].map(workgroup => ({
    id: `tile-${workgroup.width}x${workgroup.height}`,
    correctness: 'exact' as const,
    wgsl: createCuNNyWorkgroupTileVariant(shaderWGSL, workgroup),
    workgroup,
    // Include the two-pixel halo in capability checks. Under-reporting this value
    // can select a shader that exceeds maxComputeWorkgroupStorageSize at creation.
    requiredWorkgroupStorageBytes:
      channels * (workgroup.width + 2) * (workgroup.height + 2) * bytesPerValue,
    requiredStorageTexturesPerShaderStage: 1,
    requiredSampledTexturesPerShaderStage: inputTextureCount,
    benchmarkCacheVersion: 4,
  }))];
}
import type { KernelVariant } from '../gpu-capabilities';

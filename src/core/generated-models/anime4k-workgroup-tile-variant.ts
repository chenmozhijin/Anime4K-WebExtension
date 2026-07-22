import type { KernelVariant } from '../gpu-capabilities';

function replaceRequired(source: string, search: string, replacement: string, label: string): string {
  const index = source.indexOf(search);
  if (index < 0) {
    throw new Error(`Unable to build ${label}: expected shader anchor was not found.`);
  }
  return source.slice(0, index) + replacement + source.slice(index + search.length);
}

function getInputTextureNames(shaderWGSL: string): string[] {
  return [...shaderWGSL.matchAll(
    /@group\(0\) @binding\(\d+\) var ([A-Za-z0-9_]+)_tex: texture_2d<f32>;/g,
  )].map(match => match[1]);
}

interface GoTextureAccess {
  textureName: string;
  activation: 'identity' | 'positive' | 'negative';
}

function getGoTextureMap(shaderWGSL: string): Map<string, GoTextureAccess> {
  const mapping = new Map<string, GoTextureAccess>();
  for (const match of shaderWGSL.matchAll(/fn (go_\d+)\([^)]*\) -> vec4f \{([\s\S]*?)\n\}/g)) {
    const body = match[2];
    const texture = /(?:textureSample(?:Level)?|anime4kTextureLoadClamped)\(\s*([A-Za-z0-9_]+)_tex,/.exec(body);
    if (texture) {
      const activation = /return\s+max4\(\s*-/.test(body)
        ? 'negative'
        : /return\s+max4\(/.test(body)
          ? 'positive'
          : /return\s+(?:textureSample(?:Level)?|anime4kTextureLoadClamped)\(/.test(body)
            ? 'identity'
            : null;
      if (activation) {
        mapping.set(match[1], { textureName: texture[1], activation });
      }
    }
  }
  return mapping;
}

const goCallPattern = /\b(go_\d+)\(pixel\.xy,\s*(-?\d+),\s*(-?\d+)\)/g;

export function createAnime4KWorkgroupTileVariant(
  shaderWGSL: string,
  workgroup: { width: number; height: number } = { width: 8, height: 8 },
): string | null {
  shaderWGSL = shaderWGSL.replace(/\r\n/g, '\n');
  const inputTextureNames = getInputTextureNames(shaderWGSL);
  if (inputTextureNames.length < 1 || inputTextureNames.length > 3) {
    return null;
  }
  const outputDeclaration = shaderWGSL.match(
    /@group\(0\) @binding\(\d+\) var [A-Za-z0-9_]+_tex: texture_storage_2d<rgba16float, write>;/,
  )?.[0];
  if (!outputDeclaration) {
    return null;
  }
  const goTextureMap = getGoTextureMap(shaderWGSL);
  const calls = [...shaderWGSL.matchAll(goCallPattern)];
  if (calls.length === 0 || calls.some(call => {
    const offsetX = Number(call[2]);
    const offsetY = Number(call[3]);
    return !goTextureMap.has(call[1])
      || offsetX < -1 || offsetX > 1
      || offsetY < -1 || offsetY > 1;
  })) {
    return null;
  }
  if (!shaderWGSL.includes('@workgroup_size(8, 8)')
    || !shaderWGSL.includes('fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {')) {
    return null;
  }

  const tileWidth = workgroup.width + 2;
  const tileHeight = workgroup.height + 2;
  const declarations = inputTextureNames.map(name =>
    `var<workgroup> anime4kTile_${name}: array<array<vec4f, ${tileWidth}>, ${tileHeight}>;`).join('\n');
  let tiled = replaceRequired(
    shaderWGSL,
    outputDeclaration,
    `${outputDeclaration}\n${declarations}`,
    'Anime4K workgroup tile variant',
  );
  tiled = replaceRequired(
    tiled,
    '@workgroup_size(8, 8)',
    `@workgroup_size(${workgroup.width}, ${workgroup.height})`,
    'Anime4K workgroup dimensions',
  );
  tiled = replaceRequired(
    tiled,
    'fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {',
    `fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {`,
    'Anime4K local invocation input',
  );

  const loads = inputTextureNames.map(name => `
      let ${name}Size = vec2i(textureDimensions(${name}_tex));
      let ${name}Coord = clamp(
        groupOrigin + vec2i(i32(tileX) - 1, i32(tileY) - 1),
        vec2i(0),
        ${name}Size - vec2i(1),
      );
      anime4kTile_${name}[tileY][tileX] = textureLoad(${name}_tex, ${name}Coord, 0);`).join('');
  const preamble = `
  let groupOrigin = vec2i(pixel.xy) - vec2i(localId.xy);
  for (var tileY = localId.y; tileY < ${tileHeight}u; tileY += ${workgroup.height}u) {
    for (var tileX = localId.x; tileX < ${tileWidth}u; tileX += ${workgroup.width}u) {${loads}
    }
  }
  workgroupBarrier();

`;
  const oobAnchor = tiled.includes('  // OOB check\n') ? '  // OOB check\n' : '  let dim_out:';
  tiled = replaceRequired(
    tiled,
    oobAnchor,
    `${preamble}${oobAnchor}`,
    'Anime4K tile loading preamble',
  );

  tiled = tiled.replace(goCallPattern, (_call, functionName: string, x: string, y: string) => {
    const access = goTextureMap.get(functionName)!;
    const sample = `anime4kTile_${access.textureName}[localId.y + ${Number(y) + 1}u][localId.x + ${Number(x) + 1}u]`;
    switch (access.activation) {
      case 'positive':
        return `max4(${sample}, 0.0)`;
      case 'negative':
        return `max4(-${sample}, 0.0)`;
      case 'identity':
        return sample;
    }
  });
  return tiled;
}

export function createAnime4KWorkgroupTileVariants(shaderWGSL: string): KernelVariant[] | null {
  const inputTextureCount = getInputTextureNames(shaderWGSL).length;
  const variants: KernelVariant[] = [];
  for (const workgroup of [
    { width: 8, height: 8 },
    { width: 16, height: 8 },
  ]) {
    const wgsl = createAnime4KWorkgroupTileVariant(shaderWGSL, workgroup);
    if (wgsl) {
      variants.push({
      id: `tile-${workgroup.width}x${workgroup.height}`,
      correctness: 'exact',
      wgsl,
      workgroup,
      requiredWorkgroupStorageBytes:
        inputTextureCount * (workgroup.width + 2) * (workgroup.height + 2) * 16,
      requiredStorageTexturesPerShaderStage: 1,
      requiredSampledTexturesPerShaderStage: inputTextureCount,
      benchmarkCacheVersion: 1,
      });
    }
  }
  return variants.length === 2 ? variants : null;
}

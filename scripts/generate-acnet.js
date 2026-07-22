const fs = require('fs');
const path = require('path');
const { parseMpvHookStages } = require('./lib/mpv-glsl-parser');

const repoRoot = path.resolve(__dirname, '..');
const sourceRoot = path.join(repoRoot, '.reference', 'ACNetGLSL', 'glsl');
const outputRoot = path.join(repoRoot, 'src', 'engines', 'acnet', 'generated');

const families = ['acnet', 'acnet-legacy', 'arnet'];

function toPascalCase(value) {
  return value
    .split(/[-_]+/)
    .filter(Boolean)
    .map(part => part.charAt(0).toUpperCase() + part.slice(1))
    .join('');
}

function toTitle(value) {
  if (value.startsWith('acnet_legacy_')) {
    return `ACNet Legacy ${value.replace('acnet_legacy_', '').toUpperCase()}`;
  }

  return value
    .replace(/^acnet_/, 'ACNet ')
    .replace(/^arnet_/, 'ARNet ')
    .replace(/_/g, ' ')
    .replace(/\bf(\d+)b(\d+)\b/gi, (_, f, b) => `F${f}B${b}`)
    .replace(/\bbox\b/g, 'Box')
    .replace(/\bhdn\b/g, 'HDN');
}

function descriptorId(modelName) {
  if (modelName.startsWith('acnet_legacy_')) {
    return `acnet/Upscale/Legacy/${modelName.replace('acnet_legacy_', '').toUpperCase()}`;
  }

  if (modelName.startsWith('acnet_')) {
    return `acnet/Upscale/${modelName.replace('acnet_', '').toUpperCase()}`;
  }

  return `acnet/Upscale/ARNet/${modelName.replace('arnet_', '').toUpperCase()}`;
}

function modelKey(modelName) {
  return modelName.toUpperCase();
}

function sanitizeName(value) {
  return value.replace(/[^A-Za-z0-9_]/g, '_');
}

function splitStages(source) {
  return parseMpvHookStages(source, { parseDimensions: true });
}

function extractHookBody(stage) {
  const source = stage.bodyLines.join('\n');
  const match = source.match(/vec4\s+hook\s*\(\)\s*\{([\s\S]*)\}\s*$/);
  if (!match) {
    throw new Error(`Unable to extract hook body for ${stage.desc}`);
  }

  return match[1].trim();
}

function glslOffsetToVec2i(offset) {
  const match = offset.match(/vec2\s*\(\s*([-+0-9.eE]+)\s*,\s*([-+0-9.eE]+)\s*\)/);
  if (!match) {
    throw new Error(`Unsupported texture offset: ${offset}`);
  }

  return `vec2i(${Math.trunc(Number(match[1]))}, ${Math.trunc(Number(match[2]))})`;
}

function translateCommon(body, stage) {
  let translated = body;

  translated = translated.replace(/^\s*return\s+result\s*;\s*$/gm, '');
  translated = translated.replace(/\bvec4\b/g, 'vec4f');
  translated = translated.replace(/\bmat4\b/g, 'mat4x4<f32>');
  translated = translated.replace(/\bfloat\s+([A-Za-z_]\w*)\s*=/g, 'var $1: f32 =');
  translated = translated.replace(/\bvec4f\s+([A-Za-z_]\w*)\s*=/g, 'var $1: vec4f =');
  translated = translated.replace(/\bmat4x4<f32>\s+([A-Za-z_]\w*)\s*=/g, 'var $1: mat4x4<f32> =');
  translated = translated.replace(/max\(([^,\n]+),\s*0\.0\)/g, 'max($1, vec4f(0.0))');

  for (const bindName of stage.binds) {
    const safe = sanitizeName(bindName);
    const pattern = new RegExp(`${bindName}_texOff\\s*\\(\\s*(vec2\\s*\\([^\\)]*\\))\\s*\\)`, 'g');
    translated = translated.replace(pattern, (_, offset) => `sample_${safe}(pixel.xy, ${glslOffsetToVec2i(offset)})`);
  }

  translated = translated.replace(
    /result\s*=\s*result\s*\+\s*([A-Za-z_]\w*\([^;]+?\)\.x)\s*;/g,
    'result = result + vec4f($1);',
  );

  return translated.trim();
}

function makeTextureHelpers(bindNames) {
  return bindNames.map((bindName, index) => {
    const safe = sanitizeName(bindName);
    const lumaReturn = bindName === 'LUMA'
      ? '  let color = textureLoad(tex_' + safe + ', coord, 0);\n  return vec4f(luma709(color.rgb), 0.0, 0.0, color.a);'
      : '  return textureLoad(tex_' + safe + ', coord, 0);';

    // Explicit clamping preserves the source shader's edge semantics and avoids
    // relying on implementation-dependent assumptions about out-of-range loads.
    return `@group(0) @binding(${index}) var tex_${safe}: texture_2d<f32>;

fn sample_${safe}(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_${safe}));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
${lumaReturn}
}`;
  }).join('\n\n');
}

function makeStageWGSL(stage, useWorkgroupTile = false) {
  const outputBinding = stage.binds.length;
  const helpers = makeTextureHelpers(stage.binds);
  let body = translateCommon(extractHookBody(stage), stage);
  if (useWorkgroupTile) {
    for (const bindName of stage.binds) {
      const safe = sanitizeName(bindName);
      const pattern = new RegExp(`sample_${safe}\\(pixel\\.xy, vec2i\\((-?\\d+), (-?\\d+)\\)\\)`, 'g');
      body = body.replace(pattern, (_, x, y) =>
        `tile_${safe}[localId.y + ${Number(y) + 1}u][localId.x + ${Number(x) + 1}u]`);
    }
  }
  const tileDeclarations = useWorkgroupTile
    ? stage.binds.map(bindName =>
      `var<workgroup> tile_${sanitizeName(bindName)}: array<array<vec4f, 10>, 10>;`).join('\n')
    : '';
  const tileLoads = useWorkgroupTile
    ? stage.binds.map(bindName => {
      const safe = sanitizeName(bindName);
      return `      tile_${safe}[tileY][tileX] = sample_${safe}(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );`;
    }).join('\n')
    : '';
  // The generated bounds check must remain after workgroupBarrier(): every lane in a
  // partially covered edge workgroup is required to participate in cooperative loading.
  const tilePreamble = useWorkgroupTile ? `
  let groupOrigin = pixel.xy - localId.xy;
  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
${tileLoads}
    }
  }
  workgroupBarrier();
` : '';

  return `const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

${helpers}
${tileDeclarations}

@group(0) @binding(${outputBinding}) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);
${tilePreamble}
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

${body.split('\n').map(line => `  ${line}`).join('\n')}
  textureStore(out_tex, pixel.xy, result);
}
`;
}

function makePixelShuffleBaselineWGSL(stage) {
  const sourceName = stage.binds[0];
  const safe = sanitizeName(sourceName);

  return `const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var tex_${safe}: texture_2d<f32>;
@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let sourcePixel = pixel.xy / vec2u(2u, 2u);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let value = textureLoad(tex_${safe}, vec2i(sourcePixel), 0)[lane];
  textureStore(out_tex, pixel.xy, vec4f(clamp(value, 0.0, 1.0), 0.0, 0.0, 1.0));
}
`;
}

function makePixelShuffleVectorizedWGSL(stage) {
  const sourceName = stage.binds[0];
  const safe = sanitizeName(sourceName);

  // One source invocation writes a disjoint 2x2 block. This is the same lane mapping
  // as the baseline shader with one quarter of the invocation count.
  return `const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var tex_${safe}: texture_2d<f32>;
@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_${safe});
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let values = textureLoad(tex_${safe}, vec2i(pixel.xy), 0);
  let outputBase = pixel.xy * vec2u(2u, 2u);
  textureStore(out_tex, outputBase, vec4f(clamp(values.x, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(1u, 0u), vec4f(clamp(values.y, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(0u, 1u), vec4f(clamp(values.z, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(1u, 1u), vec4f(clamp(values.w, 0.0, 1.0), 0.0, 0.0, 1.0));
}
`;
}

function makeLegacyDeconvWGSL(stage) {
  const body = extractHookBody(stage);
  const caseBlocks = [...body.matchAll(/case\s+(\d+)\s*:\s*([\s\S]*?)break\s*;/g)]
    .map(match => {
      const dots = [...match[2].matchAll(/dot\s*\(\s*vec4\s*\(([^\)]*)\)\s*,\s*(r[01])\s*\)/g)];
      if (dots.length !== 2) {
        throw new Error(`Unsupported legacy deconv case in ${stage.desc}`);
      }

      return {
        lane: Number(match[1]),
        r0: dots.find(dot => dot[2] === 'r0')[1],
        r1: dots.find(dot => dot[2] === 'r1')[1],
      };
    })
    .sort((a, b) => a.lane - b.lane);

  if (caseBlocks.length !== 4) {
    throw new Error(`Expected 4 deconv cases in ${stage.desc}`);
  }

  const cases = caseBlocks.map(block => `  if (lane == ${block.lane}u) {
    result += dot(vec4f(${block.r0}), r0);
    result += dot(vec4f(${block.r1}), r1);
  }`).join('\n');

  return `const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var tex_0: texture_2d<f32>;
@group(0) @binding(1) var tex_1: texture_2d<f32>;
@group(0) @binding(2) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let sourcePixel = pixel.xy / vec2u(2u, 2u);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let r0 = textureLoad(tex_0, vec2i(sourcePixel), 0);
  let r1 = textureLoad(tex_1, vec2i(sourcePixel), 0);
  var result: f32 = 0.0;
${cases}
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
`;
}

function stageOutputName(stage, index) {
  return stage.save ?? `__FINAL_LUMA_${index}`;
}

function makeWGSL(stage) {
  if (!stage.save && /pixelshuff/i.test(stage.desc)) {
    return makePixelShuffleBaselineWGSL(stage);
  }

  if (!stage.save && /deconv/i.test(stage.desc)) {
    return makeLegacyDeconvWGSL(stage);
  }

  return makeStageWGSL(stage);
}

function removeGeneratedOutput() {
  try {
    fs.rmSync(outputRoot, {
      recursive: true,
      force: true,
      maxRetries: 5,
      retryDelay: 200,
    });
  } catch (error) {
    console.warn(`Unable to fully clean ${outputRoot}; generated files will be overwritten in place.`);
    console.warn(error instanceof Error ? error.message : String(error));
  }
  fs.mkdirSync(outputRoot, { recursive: true });
}

function writeFile(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content.replace(/\r\n/g, '\n'), 'utf8');
}

function generateModel(family, filePath) {
  const modelName = path.basename(filePath, '.glsl');
  const modelDir = path.join(outputRoot, modelName);
  const shaderDir = path.join(modelDir, 'shaders');
  const source = fs.readFileSync(filePath, 'utf8');
  const stages = splitStages(source);

  const imports = [];
  const stageConfigs = [];
  let usesRuntimeTiledVariant = false;
  stages.forEach((stage, index) => {
    const shaderName = `stage${index}.wgsl`;
    const shaderVar = `stage${index}WGSL`;
    const wgsl = makeWGSL(stage);
    const isVectorizedPixelShuffle = !stage.save && /pixelshuff/i.test(stage.desc);
    const isTiledConvolution = !isVectorizedPixelShuffle
      && !(!stage.save && /deconv/i.test(stage.desc))
      && stage.binds.length >= 1
      && stage.binds.length <= 3;
    writeFile(path.join(shaderDir, shaderName), wgsl);
    imports.push(`import ${shaderVar} from './shaders/${shaderName}';`);
    let optimizedConfig = '';
    if (isVectorizedPixelShuffle) {
      const optimizedShaderName = `stage${index}.vectorized.wgsl`;
      const optimizedShaderVar = `stage${index}VectorizedWGSL`;
      writeFile(path.join(shaderDir, optimizedShaderName), makePixelShuffleVectorizedWGSL(stage));
      imports.push(`import ${optimizedShaderVar} from './shaders/${optimizedShaderName}';`);
      optimizedConfig = `
      optimizedShaderWGSL: ${optimizedShaderVar},
      optimizationFlag: 'vectorizedPixelShuffle',
      optimizedDispatchScale: 1,
      finalOperation: 'pixel-shuffle-2x',`;
    } else if (isTiledConvolution) {
      const optimizedShaderName = `stage${index}.tiled.wgsl`;
      writeFile(path.join(shaderDir, optimizedShaderName), makeStageWGSL(stage, true));
      usesRuntimeTiledVariant = true;
      optimizedConfig = `
      optimizedShaderWGSL: createACNetWorkgroupTileVariant(${shaderVar}),
      kernelVariants: createACNetWorkgroupTileVariants(${shaderVar}),
      optimizationFlag: 'acnetWorkgroupTile',`;
    }
    stageConfigs.push(`    {
      name: ${JSON.stringify(stage.desc)},
      shaderWGSL: ${shaderVar},
      bindings: ${JSON.stringify(stage.binds)},
      outputName: ${JSON.stringify(stageOutputName(stage, index))},
      outputScale: ${stage.widthScale === 2 || stage.heightScale === 2 ? 2 : 1},
${optimizedConfig}
      final: ${stage.save ? 'false' : 'true'},
    }`);
  });

  const exportName = `${toPascalCase(modelName)}Config`;
  const variantImport = usesRuntimeTiledVariant
    ? "import { createACNetWorkgroupTileVariant, createACNetWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';\n"
    : '';
  writeFile(path.join(modelDir, 'index.ts'), `${variantImport}${imports.join('\n')}
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const ${exportName}: ACNetGeneratedModelConfig = {
  key: ${JSON.stringify(modelKey(modelName))},
  name: ${JSON.stringify(toTitle(modelName))},
  sourceFamily: ${JSON.stringify(family)},
  stages: [
${stageConfigs.join(',\n')}
  ],
};

export default ${exportName};
`);

  return {
    key: modelKey(modelName),
    id: descriptorId(modelName),
    name: toTitle(modelName),
    family,
    sourceFile: path.relative(repoRoot, filePath).replace(/\\/g, '/'),
    directory: modelName,
    stageCount: stages.length,
    exportName,
  };
}

function main() {
  removeGeneratedOutput();
  const models = [];

  for (const family of families) {
    const familyDir = path.join(sourceRoot, family);
    const files = fs.readdirSync(familyDir)
      .filter(file => file.endsWith('.glsl'))
      .sort((a, b) => a.localeCompare(b));
    for (const file of files) {
      models.push(generateModel(family, path.join(familyDir, file)));
    }
  }

  const runtimeModels = models.map(({ sourceFile, exportName, ...model }) => model);
  const referenceModels = models.map(({ exportName, ...model }) => model);

  writeFile(path.join(outputRoot, 'models.ts'), `export interface ACNetGeneratedModelMeta {
  key: string;
  id: string;
  name: string;
  family: string;
  directory: string;
  stageCount: number;
}

export const acnetGeneratedModelMetas: ACNetGeneratedModelMeta[] = ${JSON.stringify(runtimeModels, null, 2)};
`);

  writeFile(path.join(outputRoot, 'reference-models.ts'), `export interface ACNetGeneratedReferenceModelMeta {
  key: string;
  id: string;
  name: string;
  family: string;
  sourceFile: string;
  directory: string;
  stageCount: number;
}

export const acnetGeneratedReferenceModelMetas: ACNetGeneratedReferenceModelMeta[] = ${JSON.stringify(referenceModels, null, 2)};
`);

  const loaderEntries = models.map(model => {
    const chunkName = `acnet-effect-${model.directory.replace(/_/g, '-')}`;
    return `  ${JSON.stringify(model.key)}: async () => (await import(/* webpackChunkName: ${JSON.stringify(chunkName)} */ './${model.directory}')).default`;
  });
  writeFile(path.join(outputRoot, 'loaders.ts'), `import type { ACNetGeneratedModelConfig } from '../pipeline';

export type ACNetGeneratedModelLoader = () => Promise<ACNetGeneratedModelConfig>;

export const acnetGeneratedModelLoaders: Record<string, ACNetGeneratedModelLoader> = {
${loaderEntries.join(',\n')},
};
`);

  console.log(`Generated ${models.length} ACNetGLSL models in ${path.relative(repoRoot, outputRoot)}`);
}

main();

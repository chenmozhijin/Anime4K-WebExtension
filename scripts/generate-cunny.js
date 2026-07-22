const fs = require('fs');
const path = require('path');
const { parseMpvHookStages } = require('./lib/mpv-glsl-parser');

const repoRoot = path.resolve(__dirname, '..');
const sourceRoot = path.join(repoRoot, '.reference', 'CuNNy', 'mpv');
const outputRoot = path.join(repoRoot, 'src', 'engines', 'cunny', 'generated');
const variants = ['ds', 'soft'];
const expectedModelCount = 18;
const generatedTsHeader = `// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

`;

function toPascalCase(value) {
  return value
    .split(/[-_]+/)
    .filter(Boolean)
    .map(part => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join('');
}

function toModelSlug(filePath) {
  return path.basename(filePath, '.glsl').replace(/^CuNNy-/, '').toLowerCase();
}

function toTitle(slug) {
  return `CuNNy ${slug
    .replace(/-/g, ' ')
    .replace(/\bds\b/gi, 'DS')
    .replace(/\bsoft\b/gi, 'SOFT')
    .replace(/\b(\d+)x(\d+)\b/gi, (_, n, d) => `${n}x${d}`)
    .replace(/\bveryfast\b/gi, 'veryfast')
    .replace(/\bfaster\b/gi, 'faster')
    .replace(/\bfast\b/gi, 'fast')}`;
}

function descriptorId(slug) {
  const parts = slug.split('-');
  const variant = parts.pop().toUpperCase();
  const size = parts.join('-');
  return `cunny/Upscale/${variant}/${size.replace(/\b\w/g, char => char.toUpperCase())}`;
}

function modelKey(slug) {
  return `CUNNY_${slug.toUpperCase().replace(/[^A-Z0-9]+/g, '_')}`;
}

function sanitizeName(value) {
  return value.replace(/[^A-Za-z0-9_]/g, '_');
}

function splitStages(source) {
  return parseMpvHookStages(source, { parseDimensions: true });
}

function extractHookBody(stage) {
  const source = stage.bodyLines.join('\n');
  const match = source.match(/void\s+hook\s*\(\)\s*\{([\s\S]*)\}\s*$/);
  if (!match) {
    throw new Error(`Unable to extract hook body for ${stage.desc}`);
  }

  return match[1].trim();
}

function splitStatements(source) {
  const statements = [];
  for (const line of source.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed) {
      continue;
    }
    const parts = trimmed.split(';');
    for (const part of parts) {
      const statement = part.trim();
      if (statement) {
        statements.push(statement);
      }
    }
  }
  return statements;
}

function parseLumaMacro(line) {
  const match = line.match(/^#define\s+l(\d+)\(x,\s*y\).*?(\w+)_raw.*?ivec2\((\d+),\s*(\d+)\)\s*\+\s*ivec2\((\d+),\s*(\d+)\).*?0\)\)(?:\.r)?\)/);
  if (!match) {
    return null;
  }

  return {
    macro: Number(match[1]),
    source: match[2],
    packedScale: { x: Number(match[3]), y: Number(match[4]) },
    lane: { x: Number(match[5]), y: Number(match[6]) },
    scalar: line.includes(')).r)'),
  };
}

const gatherComponentOffsets = {
  w: { x: -1, y: -1 },
  z: { x: 0, y: -1 },
  x: { x: -1, y: 0 },
  y: { x: 0, y: 0 },
};

function parseGMappings(stage) {
  const hookBody = extractHookBody(stage);
  const beforeBarrier = hookBody.split(/barrier\s*\(\)\s*;/)[0] ?? '';
  const lumaMacros = new Map();
  const mappings = new Map();

  for (const line of stage.bodyLines) {
    const macro = parseLumaMacro(line.trim());
    if (macro) {
      lumaMacros.set(macro.macro, macro);
    }
  }

  for (const line of beforeBarrier.split(/\r?\n/)) {
    const assignment = line.match(/G\[(\d+)\]\[ay\]\[ax\]\s*=\s*l(\d+)\(x\s*-\s*1,\s*y\s*-\s*1\)/);
    if (!assignment) {
      continue;
    }
    const macro = lumaMacros.get(Number(assignment[2]));
    if (!macro) {
      throw new Error(`${stage.desc}: missing l${assignment[2]} macro.`);
    }
    mappings.set(Number(assignment[1]), macro);
  }

  if (mappings.size > 0) {
    return mappings;
  }

  let currentGather = null;
  const gatherGroups = new Map();
  for (const line of beforeBarrier.split(/\r?\n/)) {
    const p = line.match(/p\s*=\s*vec2\(clamp\(pos\s*\+\s*ivec2\(x\s*-\s*1,\s*y\s*-\s*1\).*?\*\s*ivec2\((\d+),\s*(\d+)\)\s*\+\s*ivec2\((\d+),\s*(\d+)\)\)\s*\*\s*(\w+)_pt/);
    if (p) {
      currentGather = {
        packedScale: { x: Number(p[1]), y: Number(p[2]) },
        base: { x: Number(p[3]), y: Number(p[4]) },
        source: p[5],
      };
      continue;
    }

    const gather = line.match(/V4\s+sr(\d+)\s*=\s*V4\((\w+)_gather\(p,\s*0\)\)/);
    if (gather) {
      if (!currentGather) {
        throw new Error(`${stage.desc}: gather group without p expression.`);
      }
      gatherGroups.set(Number(gather[1]), currentGather);
      continue;
    }

    const assignment = line.match(/G\[(\d+)\]\[ay\]\[ax\]\s*=\s*V4\(sr(\d+)\.([xyzw]),/);
    if (assignment) {
      const group = gatherGroups.get(Number(assignment[2]));
      const componentOffset = gatherComponentOffsets[assignment[3]];
      if (!group || !componentOffset) {
        throw new Error(`${stage.desc}: unsupported gather assignment ${line.trim()}`);
      }
      mappings.set(Number(assignment[1]), {
        source: group.source,
        packedScale: group.packedScale,
        lane: {
          x: group.base.x + componentOffset.x,
          y: group.base.y + componentOffset.y,
        },
        scalar: false,
      });
    }
  }

  if (mappings.size === 0) {
    throw new Error(`${stage.desc}: unable to map shared tile inputs.`);
  }

  return mappings;
}

function parseSharedDeclaration(stage) {
  const source = stage.bodyLines.join('\n');
  const match = source.match(/shared\s+(F|V4)\s+G\[(\d+)\]\[10\]\[10\]/);
  if (!match) {
    throw new Error(`${stage.desc}: missing shared G declaration.`);
  }
  return {
    type: match[1] === 'F' ? 'f32' : 'vec4f',
    channels: Number(match[2]),
  };
}

function makeSampleExpression(mapping, offsetExpr) {
  const safe = sanitizeName(mapping.source);
  if (mapping.source === 'LUMA') {
    return `sample_${safe}_f32(pixel.xy, ${offsetExpr})`;
  }

  return `sample_${safe}_vec4(pixel.xy, ${offsetExpr}, vec2i(${mapping.lane.x}, ${mapping.lane.y}), vec2i(${mapping.packedScale.x}, ${mapping.packedScale.y}))`;
}

function translateDeclaration(statement, typeName) {
  const names = statement
    .slice(typeName.length)
    .split(',')
    .map(name => name.trim())
    .filter(Boolean);
  const wgslType = typeName === 'F' ? 'f32' : 'vec4f';
  return names.map(name => `var ${name}: ${wgslType};`);
}

function translateExpression(statement) {
  return statement
    .replace(/\bV4\s*\(/g, 'vec4f(')
    .replace(/\bM4\s*\(/g, 'mat4x4<f32>(')
    .replace(/\bvec4\s*\(/g, 'vec4f(')
    .replace(/\bvec2\s*\(/g, 'vec2f(')
    .replace(/\bivec2\s*\(/g, 'vec2i(');
}

function translateImageStore(statement, stage) {
  const store = statement.match(/imageStore\(out_image,\s*opos\s*\+\s*ivec2\((\d+),\s*(\d+)\),\s*(.+)\)$/);
  if (!store) {
    return null;
  }

  const dx = Number(store[1]);
  const dy = Number(store[2]);
  const value = store[3];
  const coord = `outBase + vec2i(${dx}, ${dy})`;

  if (stage.final) {
    const residual = value.match(/vec4\(r0\.([xyzw])\s*\+\s*LUMA_tex/);
    if (!residual) {
      throw new Error(`${stage.desc}: unsupported final imageStore ${statement}`);
    }
    return `textureStore(out_tex, ${coord}, vec4f(r0.${residual[1]} + sample_original_luma(${coord}), 0.0, 0.0, 1.0));`;
  }

  const packed = value.match(/^vec4\((r\d+)\)$/);
  if (packed) {
    return `textureStore(out_tex, ${coord}, ${packed[1]});`;
  }

  throw new Error(`${stage.desc}: unsupported imageStore ${statement}`);
}

function translatePostBarrier(stage, gMappings, useWorkgroupTile) {
  const hookBody = extractHookBody(stage);
  // CuNNy's math after the source barrier is authoritative. Reconstructing only this
  // section prevents the translated shader from duplicating the original preload code.
  const postBarrier = hookBody.split(/barrier\s*\(\)\s*;/)[1];
  if (!postBarrier) {
    throw new Error(`${stage.desc}: missing barrier.`);
  }

  const lines = [];
  for (const statement of splitStatements(postBarrier.replace(/\}\s*$/, ''))) {
    if (statement === 'vec2 opt = 0.5 * LUMA_pt' || statement.startsWith('vec2 fpos =')) {
      continue;
    }

    const store = translateImageStore(statement, stage);
    if (store) {
      lines.push(store);
      continue;
    }

    const fDecl = statement.match(/^F\s+/);
    if (fDecl) {
      lines.push(...translateDeclaration(statement, 'F'));
      continue;
    }

    const vDecl = statement.match(/^V4\s+/);
    if (vDecl) {
      lines.push(...translateDeclaration(statement, 'V4'));
      continue;
    }

    const gLoad = statement.match(/^(\w+)\s*=\s*G\[(\d+)\]\[xy\.y\+(\d+)\]\[xy\.x\+(\d+)\]$/);
    if (gLoad) {
      const mapping = gMappings.get(Number(gLoad[2]));
      if (!mapping) {
        throw new Error(`${stage.desc}: missing G[${gLoad[2]}] mapping.`);
      }
      if (useWorkgroupTile) {
        lines.push(`${gLoad[1]} = G[${gLoad[2]}][localId.y + ${gLoad[3]}u][localId.x + ${gLoad[4]}u];`);
      } else {
        const offsetX = Number(gLoad[4]) - 1;
        const offsetY = Number(gLoad[3]) - 1;
        lines.push(`${gLoad[1]} = ${makeSampleExpression(mapping, `vec2i(${offsetX}, ${offsetY})`)};`);
      }
      continue;
    }

    lines.push(`${translateExpression(statement)};`);
  }

  return lines.join('\n');
}

function makeTextureHelpers(stage, gMappings) {
  const helpers = [];
  stage.binds.forEach((bindName, index) => {
    const safe = sanitizeName(bindName);
    helpers.push(`@group(0) @binding(${index}) var tex_${safe}: texture_2d<f32>;`);
  });

  const neededSources = new Set([...gMappings.values()].map(mapping => mapping.source));
  for (const source of neededSources) {
    const safe = sanitizeName(source);
    if (source === 'LUMA') {
      helpers.push(`fn sample_${safe}_f32(pos: vec2u, offset: vec2i) -> f32 {
  let size = vec2i(textureDimensions(tex_${safe}));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return luma709(textureLoad(tex_${safe}, coord, 0).rgb);
}`);
    } else {
      helpers.push(`fn sample_${safe}_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_${safe})) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_${safe}, sourceCoord * packedScale + lane, 0);
}`);
    }
  }

  return helpers.join('\n\n');
}

function makeWGSL(stage, useWorkgroupTile) {
  const gMappings = parseGMappings(stage);
  const shared = useWorkgroupTile ? parseSharedDeclaration(stage) : null;
  if (shared && gMappings.size !== shared.channels) {
    throw new Error(`${stage.desc}: expected ${shared.channels} shared channels, mapped ${gMappings.size}.`);
  }
  const textureHelpers = makeTextureHelpers(stage, gMappings);
  const samplerBinding = stage.binds.length;
  const outputBinding = stage.binds.length + 1;
  const isFinalStage = !stage.save;
  const body = translatePostBarrier({ ...stage, final: isFinalStage }, gMappings, useWorkgroupTile);
  const originalLumaHelper = isFinalStage ? `
fn sample_original_luma(coord: vec2i) -> f32 {
  let outputSize = textureDimensions(out_tex);
  let uv = (vec2f(coord) + vec2f(0.5)) / vec2f(outputSize);
  return luma709(textureSampleLevel(tex_LUMA, linearSampler, uv, 0.0).rgb);
}
` : '';
  const tileLoads = [...gMappings.entries()].map(([channel, mapping]) =>
    `      G[${channel}][tileY][tileX] = ${makeSampleExpression(
      mapping,
      'vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1)',
    )};`).join('\n');
  const sharedDeclaration = shared
    ? `var<workgroup> G: array<array<array<${shared.type}, 10>, 10>, ${shared.channels}>;`
    : '';
  // Keep cooperative loading and the barrier before the bounds return. Edge lanes may
  // be outside the image but still provide halo values needed by in-range neighbors.
  const tilePreamble = useWorkgroupTile ? `
  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
${tileLoads}
    }
  }
  workgroupBarrier();
` : '';

  return `// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

${textureHelpers}

@group(0) @binding(${samplerBinding}) var linearSampler: sampler;
@group(0) @binding(${outputBinding}) var out_tex: texture_storage_2d<rgba16float, write>;
${sharedDeclaration}
${originalLumaHelper}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let sourceSize = textureDimensions(tex_LUMA);
${tilePreamble}
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let outBase = vec2i(pixel.xy) * vec2i(${stage.widthScale}, ${stage.heightScale});

${body.split('\n').map(line => `  ${line}`).join('\n')}
}
`;
}

function stageOutputName(stage, index) {
  return stage.save ?? `__FINAL_LUMA_${index}`;
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

function generateModel(variant, filePath) {
  const slug = toModelSlug(filePath);
  const modelDirName = slug.replace(/-/g, '_');
  const modelDir = path.join(outputRoot, modelDirName);
  const shaderDir = path.join(modelDir, 'shaders');
  const source = fs.readFileSync(filePath, 'utf8');
  const stages = splitStages(source);

  const imports = [];
  const stageConfigs = [];
  stages.forEach((stage, index) => {
    const shaderName = `stage${index}.wgsl`;
    const shaderVar = `stage${index}WGSL`;
    const wgsl = makeWGSL(stage, false);
    const tiledShaderName = `stage${index}.tiled.wgsl`;
    writeFile(path.join(shaderDir, shaderName), wgsl);
    writeFile(path.join(shaderDir, tiledShaderName), makeWGSL(stage, true));
    imports.push(`import ${shaderVar} from './shaders/${shaderName}';`);
    stageConfigs.push(`    {
      name: ${JSON.stringify(stage.desc)},
      shaderWGSL: ${shaderVar},
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(${shaderVar}),
      kernelVariants: createCuNNyWorkgroupTileVariants(${shaderVar}),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ${JSON.stringify(stage.binds)},
      outputName: ${JSON.stringify(stageOutputName(stage, index))},
      outputScale: ${JSON.stringify({ x: stage.widthScale, y: stage.heightScale })},
      final: ${stage.save ? 'false' : 'true'},
    }`);
  });

  const exportName = `CuNNy${toPascalCase(slug)}Config`;
  writeFile(path.join(modelDir, 'index.ts'), `${generatedTsHeader}import { createCuNNyWorkgroupTileVariant, createCuNNyWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';
${imports.join('\n')}
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const ${exportName}: CuNNyGeneratedModelConfig = {
  key: ${JSON.stringify(modelKey(slug))},
  name: ${JSON.stringify(toTitle(slug))},
  variant: ${JSON.stringify(variant)},
  stages: [
${stageConfigs.join(',\n')}
  ],
};

export default ${exportName};
`);

  return {
    key: modelKey(slug),
    id: descriptorId(slug),
    name: toTitle(slug),
    variant,
    sourceFile: path.relative(repoRoot, filePath).replace(/\\/g, '/'),
    directory: modelDirName,
    stageCount: stages.length,
  };
}

function main() {
  removeGeneratedOutput();
  const models = [];

  for (const variant of variants) {
    const variantDir = path.join(sourceRoot, variant);
    const files = fs.readdirSync(variantDir, { withFileTypes: true })
      .filter(entry => entry.isFile() && entry.name.endsWith('.glsl') && !/-Q\.glsl$/i.test(entry.name))
      .map(entry => entry.name)
      .sort((a, b) => a.localeCompare(b));
    for (const file of files) {
      models.push(generateModel(variant, path.join(variantDir, file)));
    }
  }

  if (models.length !== expectedModelCount) {
    throw new Error(`Expected ${expectedModelCount} CuNNy models, found ${models.length}.`);
  }

  const runtimeModels = models.map(({ sourceFile, ...model }) => model);

  writeFile(path.join(outputRoot, 'models.ts'), `${generatedTsHeader}export interface CuNNyGeneratedModelMeta {
  key: string;
  id: string;
  name: string;
  variant: string;
  directory: string;
  stageCount: number;
}

export const cunnyGeneratedModelMetas: CuNNyGeneratedModelMeta[] = ${JSON.stringify(runtimeModels, null, 2)};
`);

  writeFile(path.join(outputRoot, 'reference-models.ts'), `${generatedTsHeader}export interface CuNNyGeneratedReferenceModelMeta {
  key: string;
  id: string;
  name: string;
  variant: string;
  sourceFile: string;
  directory: string;
  stageCount: number;
}

export const cunnyGeneratedReferenceModelMetas: CuNNyGeneratedReferenceModelMeta[] = ${JSON.stringify(models, null, 2)};
`);

  const loaderEntries = models.map(model => {
    const chunkName = `cunny-effect-${model.directory.replace(/_/g, '-')}`;
    return `  ${JSON.stringify(model.key)}: async () => (await import(/* webpackChunkName: ${JSON.stringify(chunkName)} */ './${model.directory}')).default`;
  });
  writeFile(path.join(outputRoot, 'loaders.ts'), `${generatedTsHeader}import type { CuNNyGeneratedModelConfig } from '../pipeline';

export type CuNNyGeneratedModelLoader = () => Promise<CuNNyGeneratedModelConfig>;

export const cunnyGeneratedModelLoaders: Record<string, CuNNyGeneratedModelLoader> = {
${loaderEntries.join(',\n')},
};
`);

  console.log(`Generated ${models.length} CuNNy models in ${path.relative(repoRoot, outputRoot)}`);
}

main();

const fs = require('node:fs');
const path = require('node:path');
const { parseMpvHookStages } = require('./lib/mpv-glsl-parser');

const repoRoot = path.resolve(__dirname, '..');

const models = [
  {
    className: 'CNNS',
    source: '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_S.glsl',
    outDir: 'src/engines/anime4k/pipelines/restore/CNNS',
    kind: 'restore-single',
    convCount: 3,
  },
  {
    className: 'CNNL',
    source: '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_L.glsl',
    outDir: 'src/engines/anime4k/pipelines/restore/CNNL',
    kind: 'restore-paired',
    pairGroups: 4,
  },
  {
    className: 'CNNx2S',
    source: '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_S.glsl',
    outDir: 'src/engines/anime4k/pipelines/upscale/CNNx2S',
    kind: 'upscale-single',
    convCount: 3,
  },
  {
    className: 'CNNx2L',
    source: '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_L.glsl',
    outDir: 'src/engines/anime4k/pipelines/upscale/CNNx2L',
    kind: 'upscale-paired',
    pairGroups: 3,
  },
];

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function parseStages(source) {
  return parseMpvHookStages(source)
    .filter(stage => !stage.desc.includes('Depth-to-Space'));
}

function shaderFileName(saveName) {
  if (saveName === 'MAIN') return 'output.wgsl';
  return `${saveName.replace(/_/g, '')}.wgsl`;
}

function toVarName(name) {
  return name === 'MAIN' ? 'MAIN' : name;
}

function parseGoDefines(code) {
  return code
    .filter(line => line.startsWith('#define go_'))
    .map(line => {
      const match = /^#define\s+(go_\d+)\(x_off,\s*y_off\)\s+\((.+)\)$/.exec(line.trim());
      if (!match) {
        throw new Error(`Unsupported go macro: ${line}`);
      }
      const [, name, expression] = match;
      const textureMatch = /([A-Za-z0-9_]+)_texOff/.exec(expression);
      if (!textureMatch) {
        throw new Error(`Unsupported go macro expression: ${line}`);
      }
      return {
        name,
        source: textureMatch[1],
        negative: expression.includes('max(-'),
        relu: expression.includes('max('),
      };
    });
}

function extractHookBody(code) {
  const text = code
    .filter(line => !line.startsWith('//!') && !line.startsWith('#define'))
    .join('\n');
  const match = /vec4\s+hook\(\)\s*\{([\s\S]*)\}\s*$/.exec(text.trim());
  if (!match) {
    throw new Error('Unable to find hook() body.');
  }
  return match[1].trim();
}

function transformHookBody(body, outputVar) {
  const lines = body.split(/\r?\n/);
  const transformed = [];
  for (const rawLine of lines) {
    let line = rawLine.trim();
    if (!line) continue;
    line = line.replace(/\bvec4\s+result\s*=\s*/, 'var result: vec4f = ');
    line = line.replace(/\bmat4\(/g, 'mat4x4<f32>(');
    line = line.replace(/\bvec4\(/g, 'vec4f(');
    line = line.replace(/\bgo_(\d+)\((-?\d+)\.0,\s*(-?\d+)\.0\)/g, 'go_$1(pixel.xy, $2, $3)');
    line = line.replace(/\bgo_(\d+)\((-?\d+),\s*(-?\d+)\)/g, 'go_$1(pixel.xy, $2, $3)');
    if (line.startsWith('return result')) {
      transformed.push(`  textureStore(${outputVar}_tex, pixel.xy, result);`);
      continue;
    }
    transformed.push(`  ${line}`);
  }
  return transformed.join('\n');
}

function makeWgsl(stage) {
  const outputName = stage.save === 'MAIN' ? 'output' : stage.save;
  const residualOutput = /return\s+result\s+\+\s+MAIN_tex\(MAIN_pos\)/.test(stage.code.join('\n'));
  const inputs = residualOutput ? stage.binds.filter(input => input !== 'MAIN') : stage.binds;
  const goDefines = parseGoDefines(stage.code);
  const body = transformHookBody(extractHookBody(stage.code), outputName);
  const inputBindings = inputs.map((input, index) => (
    `@group(0) @binding(${index}) var ${toVarName(input)}_tex: texture_2d<f32>;`
  ));
  const outputBinding = `@group(0) @binding(${inputs.length}) var ${outputName}_tex: texture_storage_2d<rgba16float, write>;`;
  const samplerBinding = `@group(0) @binding(${inputs.length + 1}) var anime4kLinearSampler: sampler;`;
  const helper = `fn anime4kTextureLoadClamped(texture: texture_2d<f32>, pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  let dim = vec2f(textureDimensions(texture));
  let uv = (vec2f(pos) + vec2f(0.5, 0.5) + vec2f(f32(x_off), f32(y_off))) / dim;
  return textureSampleLevel(texture, anime4kLinearSampler, uv, 0.0);
}

fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}`;
  const functions = goDefines.map((macro) => {
    const sample = `anime4kTextureLoadClamped(${toVarName(macro.source)}_tex, pos, x_off, y_off)`;
    const value = macro.negative ? `-${sample}` : sample;
    const returned = macro.relu ? `max4(${value}, 0.0)` : value;
    return `fn ${macro.name}(pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  return ${returned};
}`;
  });
  return `// Layer: ${stage.desc}
// Inputs: ${JSON.stringify(inputs)}
// Output: ${outputName}
${inputBindings.join('\n')}
${outputBinding}
${samplerBinding}

${helper}

${functions.join('\n\n')}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dim_out: vec2u = textureDimensions(${outputName}_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

${body}
}
`;
}

function importName(fileName) {
  return fileName
    .replace(/\.wgsl$/, '')
    .replace(/[^A-Za-z0-9]+(.)/g, (_, char) => char.toUpperCase());
}

function makeSingleIndex(model, shaderFiles) {
  const imports = shaderFiles.map(file => `import ${importName(file)}WGSL from './shaders/${file}';`).join('\n');
  const convFiles = model.kind === 'restore-single'
    ? shaderFiles.filter(file => file !== 'output.wgsl')
    : shaderFiles.filter(file => file !== 'conv2dlasttf.wgsl');
  if (model.kind === 'restore-single') {
    return `${imports}

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class ${model.className} implements Anime4KPipeline {
  pipelines: Anime4KPipeline[] = [];

  constructor({ device, inputTexture }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [${convFiles.map(file => `${importName(file)}WGSL`).join(', ')}];
    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');
    for (let i = 1; i < shaders.length; i += 1) {
      this.pushPipeline(device, [this.pipelines[i - 1].getOutputTexture()], shaders[i], \`conv2d_\${i}_tf\`);
    }
    const outputTextures: GPUTexture[] = [this.pipelines[this.pipelines.length - 1].getOutputTexture()];
    this.pushPipeline(device, outputTextures, outputWGSL, 'output');
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.getOutputTexture()],
      outputTextureSize: [inputTexture.width, inputTexture.height],
    }));
  }

  pass(encoder: GPUCommandEncoder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  private pushPipeline(device: GPUDevice, inputTextures: GPUTexture[], shaderWGSL: string, name: string): void {
    this.pipelines.push(new Conv2d({ device, inputTextures, shaderWGSL, name }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number): void {
    for (let i = from; i < from + count; i += 1) outputTextures.push(this.pipelines[i].getOutputTexture());
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}
`;
  }
  return `${imports}

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, DepthToSpace, Overlay } from '../../helpers';

export class ${model.className} implements Anime4KPipeline {
  pipelines: Anime4KPipeline[] = [];

  constructor({ device, inputTexture }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [${convFiles.map(file => `${importName(file)}WGSL`).join(', ')}];
    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');
    for (let i = 1; i < shaders.length; i += 1) {
      this.pushPipeline(device, [this.pipelines[i - 1].getOutputTexture()], shaders[i], \`conv2d_\${i}_tf\`);
    }
    const lastInputs: GPUTexture[] = [this.pipelines[this.pipelines.length - 1].getOutputTexture()];
    this.pushPipeline(device, lastInputs, conv2dlasttfWGSL, 'conv2d_last_tf');
    const depthInputs = [this.getOutputTexture(), this.getOutputTexture(), this.getOutputTexture()];
    this.pipelines.push(new DepthToSpace({ device, inputTextures: depthInputs, name: 'DepthToSpace' }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.getOutputTexture()],
      outputTextureSize: [2 * inputTexture.width, 2 * inputTexture.height],
    }));
  }

  pass(encoder: GPUCommandEncoder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  private pushPipeline(device: GPUDevice, inputTextures: GPUTexture[], shaderWGSL: string, name: string): void {
    this.pipelines.push(new Conv2d({ device, inputTextures, shaderWGSL, name }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number): void {
    for (let i = from; i < from + count; i += 1) outputTextures.push(this.pipelines[i].getOutputTexture());
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}
`;
}

function makePairedIndex(model, shaderFiles) {
  const imports = shaderFiles.map(file => `import ${importName(file)}WGSL from './shaders/${file}';`).join('\n');
  const shaderList = shaderFiles
    .filter(file => file !== 'output.wgsl')
    .map(file => `${importName(file)}WGSL`);
  if (model.kind === 'restore-paired') {
    return `${imports}

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class ${model.className} implements Anime4KPipeline {
  pipelines: Anime4KPipeline[] = [];

  constructor({ device, inputTexture }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [${shaderList.join(', ')}];
    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');
    this.pushPipeline(device, [inputTexture], shaders[1], 'conv2d_tf_1');
    const inputTextures: GPUTexture[] = [];
    for (let group = 1; group < ${model.pairGroups}; group += 1) {
      inputTextures.length = 0;
      this.fillOutputTextures(inputTextures, 2 * (group - 1), 2);
      this.pushPipeline(device, inputTextures, shaders[2 * group], \`conv2d_\${group}_tf\`);
      this.pushPipeline(device, inputTextures, shaders[2 * group + 1], \`conv2d_\${group}_tf_1\`);
    }
    inputTextures.length = 0;
    this.fillOutputTextures(inputTextures, this.pipelines.length - 2, 2);
    this.pushPipeline(device, inputTextures, outputWGSL, 'output');
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.getOutputTexture()],
      outputTextureSize: [inputTexture.width, inputTexture.height],
    }));
  }

  pass(encoder: GPUCommandEncoder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  private pushPipeline(device: GPUDevice, inputTextures: GPUTexture[], shaderWGSL: string, name: string): void {
    this.pipelines.push(new Conv2d({ device, inputTextures, shaderWGSL, name }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number): void {
    for (let i = from; i < from + count; i += 1) outputTextures.push(this.pipelines[i].getOutputTexture());
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}
`;
  }
  const baseShaders = shaderFiles.filter(file => !file.startsWith('conv2dlast')).map(file => `${importName(file)}WGSL`);
  const lastShaders = shaderFiles.filter(file => file.startsWith('conv2dlast')).map(file => `${importName(file)}WGSL`);
  return `${imports}

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, DepthToSpace, Overlay } from '../../helpers';

export class ${model.className} implements Anime4KPipeline {
  pipelines: Anime4KPipeline[] = [];

  constructor({ device, inputTexture }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [${baseShaders.join(', ')}];
    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');
    this.pushPipeline(device, [inputTexture], shaders[1], 'conv2d_tf_1');
    const inputTextures: GPUTexture[] = [];
    for (let group = 1; group < ${model.pairGroups}; group += 1) {
      inputTextures.length = 0;
      this.fillOutputTextures(inputTextures, 2 * (group - 1), 2);
      this.pushPipeline(device, inputTextures, shaders[2 * group], \`conv2d_\${group}_tf\`);
      this.pushPipeline(device, inputTextures, shaders[2 * group + 1], \`conv2d_\${group}_tf_1\`);
    }
    const lastShaders: string[] = [${lastShaders.join(', ')}];
    inputTextures.length = 0;
    this.fillOutputTextures(inputTextures, this.pipelines.length - 2, 2);
    for (let i = 0; i < lastShaders.length; i += 1) {
      this.pushPipeline(device, inputTextures, lastShaders[i], \`conv2d_last_tf_\${i}\`);
    }
    inputTextures.length = 0;
    this.fillOutputTextures(inputTextures, this.pipelines.length - 3, 3);
    this.pipelines.push(new DepthToSpace({ device, inputTextures, name: 'DepthToSpace' }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.getOutputTexture()],
      outputTextureSize: [2 * inputTexture.width, 2 * inputTexture.height],
    }));
  }

  pass(encoder: GPUCommandEncoder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  private pushPipeline(device: GPUDevice, inputTextures: GPUTexture[], shaderWGSL: string, name: string): void {
    this.pipelines.push(new Conv2d({ device, inputTextures, shaderWGSL, name }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number): void {
    for (let i = from; i < from + count; i += 1) outputTextures.push(this.pipelines[i].getOutputTexture());
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}
`;
}

function generateModel(model) {
  const source = fs.readFileSync(path.join(repoRoot, model.source), 'utf8');
  const stages = parseStages(source);
  const outDir = path.join(repoRoot, model.outDir);
  const shaderDir = path.join(outDir, 'shaders');
  ensureDir(shaderDir);
  const shaderFiles = [];
  for (const stage of stages) {
    const fileName = shaderFileName(stage.save);
    fs.writeFileSync(path.join(shaderDir, fileName), makeWgsl(stage));
    shaderFiles.push(fileName);
  }
  const index = model.kind.includes('paired')
    ? makePairedIndex(model, shaderFiles)
    : makeSingleIndex(model, shaderFiles);
  fs.writeFileSync(path.join(outDir, 'index.ts'), index);
  console.log(`${model.className}: generated ${shaderFiles.length} shaders`);
}

for (const model of models) {
  generateModel(model);
}

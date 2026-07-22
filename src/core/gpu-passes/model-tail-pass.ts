import type { Dimensions } from '../../types';
import type {
  PipelinePass,
  PipelineProfileRecorder,
  TerminalTextureTarget,
} from '../effects/backend-types';
import { borrowTexture, releaseTexture } from '../texture-pool';
import { ComputeTexturePass } from './compute-texture-pass';
import { DepthToSpacePass } from './depth-to-space-pass';
import { MultiOutputComputePass } from './multi-output-compute-pass';
import { RenderCompositePass } from './render-composite-pass';

const overlayWGSL = `
@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTexture: texture_2d<f32>;
@group(0) @binding(2) var addonTexture: texture_2d<f32>;

@fragment
fn main(@location(0) uv: vec2f) -> @location(0) vec4f {
  let color = textureSample(sourceTexture, linearSampler, uv)
    + textureSample(addonTexture, linearSampler, uv);
  return vec4f(color.rgb, 1.0);
}
`;

interface ParsedHeadShader {
  inputDeclarations: string[];
  support: string;
  body: string;
}

function parseHeadShader(shaderWGSL: string, index: number): ParsedHeadShader {
  const inputDeclarations = [...shaderWGSL.matchAll(
    /@group\(0\) @binding\(\d+\) var ([A-Za-z0-9_]+_tex): texture_2d<f32>;/g,
  )].map((match, binding) => `@group(0) @binding(${binding + 2}) var ${match[1]}: texture_2d<f32>;`);
  const outputMatch = /@group\(0\) @binding\(\d+\) var [A-Za-z0-9_]+_tex: texture_storage_2d<rgba16float, write>;/.exec(shaderWGSL);
  const computeIndex = shaderWGSL.indexOf('@compute');
  if (!outputMatch || computeIndex < 0) {
    throw new Error('Anime4K model tail fusion could not parse a head shader.');
  }
  const functionMap = new Map<string, string>();
  let support = shaderWGSL.slice(outputMatch.index + outputMatch[0].length, computeIndex)
    .replace(/@group\(0\) @binding\(\d+\) var anime4kLinearSampler: sampler;\s*/g, '')
    .replace(/\banime4kLinearSampler\b/g, 'tailSampler');
  for (const match of support.matchAll(/fn ([A-Za-z0-9_]+)\(/g)) {
    functionMap.set(match[1], `head${index}_${match[1]}`);
  }
  for (const [original, renamed] of functionMap) {
    support = support.replace(new RegExp(`\\b${original}\\b`, 'g'), renamed);
  }

  const bodyStart = shaderWGSL.indexOf('  var result:', computeIndex);
  const bodyEnd = shaderWGSL.lastIndexOf('\n}');
  if (bodyStart < 0 || bodyEnd <= bodyStart) {
    throw new Error('Anime4K model tail fusion could not find the head body.');
  }
  let body = shaderWGSL.slice(bodyStart, bodyEnd)
    .replace(/^\s*textureStore\([^\n]+\);\s*$/gm, '')
    .replace(/\bresult\b/g, `result${index}`);
  for (const [original, renamed] of functionMap) {
    body = body.replace(new RegExp(`\\b${original}\\b`, 'g'), renamed);
  }
  return { inputDeclarations, support: support.trim(), body: body.trimEnd() };
}

function createTailFragment(headShaders: string[], kind: 'restore' | 'upscale'): string {
  const heads = headShaders.map(parseHeadShader);
  const inputDeclarations = heads[0].inputDeclarations;
  for (const head of heads.slice(1)) {
    if (JSON.stringify(head.inputDeclarations) !== JSON.stringify(inputDeclarations)) {
      throw new Error('Anime4K model tail fusion requires identical head inputs.');
    }
  }
  const headSupports = heads.map(head => head.support).join('\n\n');
  // Each standalone head wrote rgba16float. Quantize every branch independently
  // before lane selection so fusion cannot accidentally retain f32 intermediates.
  const headPrograms = heads.map((head, index) => `${head.body}
  let head${index} = quantizeRgba16(result${index});`).join('\n\n');
  const addon = kind === 'restore'
    ? 'head0'
    // DepthToSpace also wrote rgba16float in the baseline path, so preserve its
    // post-shuffle boundary separately from each already-quantized head.
    : `quantizeRgba16(vec4f(
    head0[lane],
    ${(heads.length > 1 ? 'head1' : 'head0')}[lane],
    ${(heads.length > 2 ? 'head2' : 'head0')}[lane],
    ${(heads.length > 2 ? 'head2' : 'head0')}[lane]
  ))`;
  const sourcePixel = kind === 'restore'
    ? 'pixel'
    : 'pixel / vec2u(2u, 2u)';
  const lane = kind === 'upscale'
    ? '  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);\n'
    : '';

  return `
@group(0) @binding(0) var tailSampler: sampler;
@group(0) @binding(1) var sourceTexture: texture_2d<f32>;
${inputDeclarations.join('\n')}

fn quantizeRgba16(value: vec4f) -> vec4f {
  return vec4f(
    unpack2x16float(pack2x16float(value.rg)),
    unpack2x16float(pack2x16float(value.ba))
  );
}

${headSupports}

@fragment
fn main(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let pixel = vec2u(position.xy);
  let sourcePixel = ${sourcePixel};
${lane}${headPrograms.replace(/pixel\.xy/g, 'sourcePixel')}
  let addon = ${addon};
  let outputSize = ${kind === 'restore' ? 'textureDimensions(sourceTexture)' : 'textureDimensions(sourceTexture) * vec2u(2u, 2u)'};
  let source = textureSampleLevel(
    sourceTexture,
    tailSampler,
    position.xy / vec2f(outputSize),
    0.0
  );
  // Overlay was the final rgba16float writer before presentation/downstream effects.
  return quantizeRgba16(vec4f((source + addon).rgb, 1.0));
}
`;
}

export interface ModelTailPassOptions {
  device: GPUDevice;
  sourceTexture: GPUTexture;
  featureTextures: GPUTexture[];
  headShaders: string[];
  kind: 'restore' | 'upscale';
  outputSize: Dimensions;
  outputTexture?: GPUTexture;
  terminalTarget?: TerminalTextureTarget;
  optimized: boolean;
  multiOutputDispatch: boolean;
  vectorizedPixelShuffle: boolean;
  name: string;
  cacheKeyPrefix: string;
}

export class ModelTailPass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  private readonly pipelines: PipelinePass[] = [];
  private readonly ownedHeadTextures: GPUTexture[] = [];

  constructor(private readonly options: ModelTailPassOptions) {
    this.profileLabel = options.name;
    if (options.optimized) {
      // The fused fragment reproduces all removed rgba16float boundaries explicitly;
      // do not simplify its quantization calls without rerunning optimization audit.
      this.pipelines.push(new RenderCompositePass({
        device: options.device,
        inputTextures: [options.sourceTexture, ...options.featureTextures],
        outputTexture: options.outputTexture,
        outputSize: options.outputSize,
        fragmentWGSL: createTailFragment(options.headShaders, options.kind),
        name: options.name,
        cacheKeyPrefix: `${options.cacheKeyPrefix}/fused`,
        terminalTarget: options.terminalTarget,
      }));
      return;
    }

    const headTextures = this.createBaselineHeads();
    let addonTexture: GPUTexture;
    if (options.kind === 'upscale') {
      const depthInputs = headTextures.length === 1
        ? [headTextures[0], headTextures[0], headTextures[0]]
        : headTextures;
      const depth = new DepthToSpacePass({
        device: options.device,
        inputTextures: depthInputs,
        name: `${options.name}: DepthToSpace`,
        cacheKeyPrefix: `${options.cacheKeyPrefix}/depth-to-space`,
        vectorized: options.vectorizedPixelShuffle,
      });
      this.pipelines.push(depth);
      addonTexture = depth.getOutputTexture();
    } else {
      addonTexture = headTextures[0];
    }
    this.pipelines.push(new RenderCompositePass({
      device: options.device,
      inputTextures: [options.sourceTexture, addonTexture],
      outputTexture: options.outputTexture,
      outputSize: options.outputSize,
      fragmentWGSL: overlayWGSL,
      name: `${options.name}: Overlay`,
      cacheKeyPrefix: `${options.cacheKeyPrefix}/overlay`,
      terminalTarget: options.terminalTarget,
    }));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
    this.ownedHeadTextures.forEach(releaseTexture);
    this.ownedHeadTextures.length = 0;
  }

  private createBaselineHeads(): GPUTexture[] {
    const { options } = this;
    if (options.headShaders.length === 1) {
      const pass = new ComputeTexturePass({
        device: options.device,
        inputTextures: options.featureTextures,
        shaderWGSL: options.headShaders[0],
        name: `${options.name}: head`,
        cacheKeyPrefix: `${options.cacheKeyPrefix}/head`,
        outputSize: {
          width: options.sourceTexture.width,
          height: options.sourceTexture.height,
        },
        includeSampler: options.headShaders[0].includes('var anime4kLinearSampler: sampler;'),
      });
      this.pipelines.push(pass);
      return [pass.getOutputTexture()];
    }

    const headSize = {
      width: options.sourceTexture.width,
      height: options.sourceTexture.height,
    };
    for (let index = 0; index < options.headShaders.length; index += 1) {
      this.ownedHeadTextures.push(borrowTexture({
        device: options.device,
        ...headSize,
        format: 'rgba16float',
        usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
        labelGroup: `${options.cacheKeyPrefix}/head-output`,
        label: `${options.name}: head ${index}`,
      }));
    }
    this.pipelines.push(new MultiOutputComputePass({
      device: options.device,
      inputTextures: options.featureTextures,
      outputTextures: this.ownedHeadTextures,
      shaderWGSL: createFusedHeadShader(options.headShaders),
      baselineShaders: options.headShaders,
      name: `${options.name}: heads`,
      cacheKeyPrefix: `${options.cacheKeyPrefix}/heads`,
      outputSize: headSize,
      optimized: options.multiOutputDispatch,
    }));
    return this.ownedHeadTextures;
  }
}

function createFusedHeadShader(headShaders: string[]): string {
  const heads = headShaders.map(parseHeadShader);
  const inputs = heads[0].inputDeclarations.map((declaration, index) => declaration.replace(
    /@binding\(\d+\)/,
    `@binding(${index})`,
  ));
  const outputs = headShaders.map((_, index) => (
    `@group(0) @binding(${inputs.length + index}) var head${index}_out: texture_storage_2d<rgba16float, write>;`
  ));
  const supports = heads.map(head => head.support).join('\n\n');
  const programs = heads.map((head, index) => `${head.body}
  textureStore(head${index}_out, pixel.xy, result${index});`).join('\n\n');
  return `${inputs.join('\n')}
${outputs.join('\n')}

${supports}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let size = textureDimensions(head0_out);
  if (pixel.x >= size.x || pixel.y >= size.y) {
    return;
  }

${programs}
}
`;
}

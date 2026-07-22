import type { Dimensions } from '../../types';
import type {
  PipelinePass,
  PipelineProfileRecorder,
  TerminalTextureTarget,
} from '../effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateRenderPipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';

export const defaultLumaRecomposeWGSL = `
const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const KR: f32 = 0.2126;
const KG: f32 = 0.7152;
const KB: f32 = 0.0722;
const CB_SCALE: f32 = 2.0 * (1.0 - KB);
const CR_SCALE: f32 = 2.0 * (1.0 - KR);
const G_CB_COEFF: f32 = 2.0 * KB * (1.0 - KB) / KG;
const G_CR_COEFF: f32 = 2.0 * KR * (1.0 - KR) / KG;

@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTex: texture_2d<f32>;
@group(0) @binding(2) var lumaTex: texture_2d<f32>;
@group(0) @binding(3) var outTex: texture_storage_2d<rgba16float, write>;

fn rgbToY(rgb: vec3f) -> f32 {
  return dot(rgb, vec3f(KR, KG, KB));
}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(outTex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let uv = (vec2f(pixel.xy) + vec2f(0.5)) / vec2f(outputSize);
  let baseRgb = textureSampleLevel(sourceTex, linearSampler, uv, 0.0).rgb;
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let yNew = textureLoad(lumaTex, vec2i(pixel.xy), 0).r;

  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));

  textureStore(outTex, pixel.xy, vec4f(rgb, 1.0));
}
`;

const terminalVertexWGSL = `
struct VertexOutput {
  @builtin(position) position: vec4f,
}

@vertex
fn vertexMain(@builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
  let positions = array(vec2f(-1.0, -1.0), vec2f(3.0, -1.0), vec2f(-1.0, 3.0));
  var output: VertexOutput;
  output.position = vec4f(positions[vertexIndex], 0.0, 1.0);
  return output;
}
`;

export const defaultLumaRecomposeTerminalWGSL = `
const KR: f32 = 0.2126;
const KG: f32 = 0.7152;
const KB: f32 = 0.0722;
const CB_SCALE: f32 = 2.0 * (1.0 - KB);
const CR_SCALE: f32 = 2.0 * (1.0 - KR);
const G_CB_COEFF: f32 = 2.0 * KB * (1.0 - KB) / KG;
const G_CR_COEFF: f32 = 2.0 * KR * (1.0 - KR) / KG;

@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTex: texture_2d<f32>;
@group(0) @binding(2) var lumaTex: texture_2d<f32>;

fn rgbToY(rgb: vec3f) -> f32 {
  return dot(rgb, vec3f(KR, KG, KB));
}

fn quantizeRgba16(value: vec4f) -> vec4f {
  // Direct presentation removes the compute path's rgba16float output texture.
  // Recreate its rounding before the canvas format conversion.
  return vec4f(
    unpack2x16float(pack2x16float(value.rg)),
    unpack2x16float(pack2x16float(value.ba))
  );
}

@fragment
fn fragmentMain(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let pixel = vec2u(position.xy);
  let outputSize = textureDimensions(lumaTex);
  let uv = position.xy / vec2f(outputSize);
  let baseRgb = textureSampleLevel(sourceTex, linearSampler, uv, 0.0).rgb;
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let yNew = textureLoad(lumaTex, vec2i(pixel), 0).r;

  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));

  return quantizeRgba16(vec4f(rgb, 1.0));
}
`;

function hashString(value: string): string {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(16).padStart(8, '0');
}

export interface LumaRecomposePassDescriptor {
  device: GPUDevice;
  sourceTexture: GPUTexture;
  lumaTexture: GPUTexture;
  outputSize: Dimensions;
  name: string;
  cacheKeyPrefix: string;
  shaderWGSL?: string;
  workgroupSize?: Dimensions;
  outputTexture?: GPUTexture;
  terminalTarget?: TerminalTextureTarget;
  terminalFragmentWGSL?: string;
}

export class LumaRecomposePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  readonly presentsToTerminal: boolean;

  private readonly outputTexture: GPUTexture;

  private readonly computePipeline?: GPUComputePipeline;

  private readonly renderPipeline?: GPURenderPipeline;

  private readonly bindGroup: GPUBindGroup;

  private readonly workgroupSize: Dimensions;

  private readonly ownsOutputTexture: boolean;

  private readonly terminalTarget?: TerminalTextureTarget;

  constructor({
    device,
    sourceTexture,
    lumaTexture,
    outputSize,
    name,
    cacheKeyPrefix,
    shaderWGSL = defaultLumaRecomposeWGSL,
    workgroupSize = { width: 8, height: 8 },
    outputTexture,
    terminalTarget,
    terminalFragmentWGSL,
  }: LumaRecomposePassDescriptor) {
    this.profileLabel = `${name}: output recompose`;
    this.workgroupSize = workgroupSize;
    // Supplying a canvas target is insufficient by itself. A dedicated terminal
    // fragment is required because compute WGSL cannot be assumed render-equivalent.
    this.presentsToTerminal = Boolean(terminalTarget && terminalFragmentWGSL && !outputTexture);
    this.terminalTarget = this.presentsToTerminal ? terminalTarget : undefined;
    if (this.terminalTarget && (
      this.terminalTarget.width !== outputSize.width || this.terminalTarget.height !== outputSize.height
    )) {
      throw new Error(`${name}: terminal target has incorrect dimensions.`);
    }
    this.ownsOutputTexture = !outputTexture && !this.presentsToTerminal;
    // Terminal mode returns lumaTexture only as a lifetime anchor. The chain compiler
    // guarantees no downstream effect will interpret it as RGBA output.
    this.outputTexture = outputTexture ?? (this.presentsToTerminal ? lumaTexture : borrowTexture({
        device,
        width: outputSize.width,
        height: outputSize.height,
        format: 'rgba16float',
        usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
        labelGroup: `${cacheKeyPrefix}/output-recompose/output`,
        label: `${name}: output texture`,
      }));
    if (!this.presentsToTerminal && outputTexture && (
      this.outputTexture.width !== outputSize.width || this.outputTexture.height !== outputSize.height
    )) {
      throw new Error(`${name}: preallocated output texture has incorrect dimensions.`);
    }

    const shaderVisibility = this.presentsToTerminal ? GPUShaderStage.FRAGMENT : GPUShaderStage.COMPUTE;
    const bindGroupLayout = getOrCreateBindGroupLayout(device, `${cacheKeyPrefix}/output-recompose/layout/${this.presentsToTerminal ? 'terminal' : 'compute'}`, () => ({
      label: `${name}: output recompose bind group layout`,
      entries: [
        {
          binding: 0,
          visibility: shaderVisibility,
          sampler: { type: 'filtering' },
        },
        {
          binding: 1,
          visibility: shaderVisibility,
          texture: {},
        },
        {
          binding: 2,
          visibility: shaderVisibility,
          texture: {},
        },
        ...(!this.presentsToTerminal ? [{
          binding: 3,
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        } satisfies GPUBindGroupLayoutEntry] : []),
      ],
    }));

    const pipelineLayout = device.createPipelineLayout({
      label: `${name}: output recompose pipeline layout`,
      bindGroupLayouts: [bindGroupLayout],
    });
    if (this.presentsToTerminal) {
      const fragmentHash = hashString(terminalFragmentWGSL!);
      const vertexModule = getOrCreateShaderModule(
        device,
        `${cacheKeyPrefix}/output-recompose/shader/terminal-vertex`,
        () => ({ label: `${name}: terminal vertex shader`, code: terminalVertexWGSL }),
      );
      const fragmentModule = getOrCreateShaderModule(
        device,
        `${cacheKeyPrefix}/output-recompose/shader/terminal-fragment/${fragmentHash}`,
        () => ({ label: `${name}: terminal fragment shader`, code: terminalFragmentWGSL! }),
      );
      this.renderPipeline = getOrCreateRenderPipeline(
        device,
        `${cacheKeyPrefix}/output-recompose/pipeline/terminal/${fragmentHash}/${terminalTarget!.format}`,
        () => ({
          label: `${name}: terminal output recompose pipeline`,
          layout: pipelineLayout,
          vertex: { module: vertexModule, entryPoint: 'vertexMain' },
          fragment: {
            module: fragmentModule,
            entryPoint: 'fragmentMain',
            targets: [{ format: terminalTarget!.format }],
          },
          primitive: { topology: 'triangle-list' },
        }),
      );
    } else {
      const shaderModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/output-recompose/shader/main`, () => ({
        label: `${name}: output recompose shader`,
        code: shaderWGSL,
      }));
      this.computePipeline = getOrCreateComputePipeline(device, `${cacheKeyPrefix}/output-recompose/pipeline/main`, () => ({
        label: `${name}: output recompose pipeline`,
        layout: pipelineLayout,
        compute: {
          module: shaderModule,
          entryPoint: 'computeMain',
        },
      }));
    }

    const sampler = getOrCreateSampler(device, `${cacheKeyPrefix}/output-recompose/sampler/linear`, () => ({
      magFilter: 'linear',
      minFilter: 'linear',
      addressModeU: 'clamp-to-edge',
      addressModeV: 'clamp-to-edge',
    }));

    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/output-recompose/${name}/bind-group`, () => ({
      label: `${name}: output recompose bind group`,
      layout: bindGroupLayout,
      entries: [
        { binding: 0, resource: sampler },
        { binding: 1, resource: sourceTexture.createView() },
        { binding: 2, resource: lumaTexture.createView() },
        ...(!this.presentsToTerminal
          ? [{ binding: 3, resource: this.outputTexture.createView() } satisfies GPUBindGroupEntry]
          : []),
      ],
    }));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    if (profile) {
      profile.recordPass(this, () => this.encodePass(encoder, profile));
      return;
    }

    this.encodePass(encoder);
  }

  private encodePass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    if (this.presentsToTerminal) {
      const descriptor: GPURenderPassDescriptor = {
        colorAttachments: [{
          view: this.terminalTarget!.getCurrentView(),
          clearValue: { r: 0, g: 0, b: 0, a: 1 },
          loadOp: 'clear',
          storeOp: 'store',
        }],
      };
      const pass = encoder.beginRenderPass(
        profile?.createRenderPassDescriptor?.(this, descriptor) ?? descriptor,
      );
      pass.setPipeline(this.renderPipeline!);
      pass.setBindGroup(0, this.bindGroup);
      pass.draw(3);
      pass.end();
      return;
    }

    const pass = encoder.beginComputePass(profile?.createComputePassDescriptor?.(this));
    pass.setPipeline(this.computePipeline!);
    pass.setBindGroup(0, this.bindGroup);
    pass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / this.workgroupSize.width),
      Math.ceil(this.outputTexture.height / this.workgroupSize.height),
    );
    pass.end();
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    if (this.ownsOutputTexture) {
      releaseTexture(this.outputTexture);
    }
  }
}

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

const commonWGSL = `
const KR: f32 = 0.2126;
const KG: f32 = 0.7152;
const KB: f32 = 0.0722;
const CB_SCALE: f32 = 2.0 * (1.0 - KB);
const CR_SCALE: f32 = 2.0 * (1.0 - KR);
const G_CB_COEFF: f32 = 2.0 * KB * (1.0 - KB) / KG;
const G_CR_COEFF: f32 = 2.0 * KR * (1.0 - KR) / KG;

fn rgbToY(rgb: vec3f) -> f32 {
  return dot(rgb, vec3f(KR, KG, KB));
}

fn quantizeF16(value: f32) -> f32 {
  // PixelShuffle previously wrote rgba16float before recomposition. Keep its scalar
  // luma rounding even though the fused path never materializes that texture.
  return unpack2x16float(pack2x16float(vec2f(value, 0.0))).x;
}

fn quantizeRgba16(value: vec4f) -> vec4f {
  // Terminal presentation removes the final rgba16float texture as well; reproduce
  // that boundary before conversion to the canvas presentation format.
  return vec4f(
    unpack2x16float(pack2x16float(value.rg)),
    unpack2x16float(pack2x16float(value.ba))
  );
}
`;

const computeWGSL = `
const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTex: texture_2d<f32>;
@group(0) @binding(2) var packedLumaTex: texture_2d<f32>;
@group(0) @binding(3) var outTex: texture_storage_2d<rgba16float, write>;

${commonWGSL}

fn recompose(outputPixel: vec2u, yPacked: f32) -> vec4f {
  let outputSize = textureDimensions(outTex);
  let uv = (vec2f(outputPixel) + vec2f(0.5)) / vec2f(outputSize);
  let baseRgb = textureSampleLevel(sourceTex, linearSampler, uv, 0.0).rgb;
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let yNew = quantizeF16(clamp(yPacked, 0.0, 1.0));
  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));
  return vec4f(rgb, 1.0);
}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(packedLumaTex);
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let values = textureLoad(packedLumaTex, vec2i(pixel.xy), 0);
  let outputBase = pixel.xy * vec2u(2u, 2u);
  textureStore(outTex, outputBase, recompose(outputBase, values.x));
  textureStore(outTex, outputBase + vec2u(1u, 0u), recompose(outputBase + vec2u(1u, 0u), values.y));
  textureStore(outTex, outputBase + vec2u(0u, 1u), recompose(outputBase + vec2u(0u, 1u), values.z));
  textureStore(outTex, outputBase + vec2u(1u, 1u), recompose(outputBase + vec2u(1u, 1u), values.w));
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

const terminalFragmentWGSL = `
@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTex: texture_2d<f32>;
@group(0) @binding(2) var packedLumaTex: texture_2d<f32>;

${commonWGSL}

@fragment
fn fragmentMain(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let outputPixel = vec2u(position.xy);
  let outputSize = textureDimensions(packedLumaTex) * vec2u(2u, 2u);
  let sourcePixel = outputPixel / vec2u(2u, 2u);
  let lane = (outputPixel.y % 2u) * 2u + (outputPixel.x % 2u);
  let yNew = quantizeF16(clamp(textureLoad(packedLumaTex, vec2i(sourcePixel), 0)[lane], 0.0, 1.0));
  let uv = position.xy / vec2f(outputSize);
  let baseRgb = textureSampleLevel(sourceTex, linearSampler, uv, 0.0).rgb;
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));
  return quantizeRgba16(vec4f(rgb, 1.0));
}
`;

export interface PixelShuffleRecomposePassDescriptor {
  device: GPUDevice;
  sourceTexture: GPUTexture;
  packedLumaTexture: GPUTexture;
  outputSize: Dimensions;
  name: string;
  cacheKeyPrefix: string;
  terminalTarget?: TerminalTextureTarget;
}

export class PixelShuffleRecomposePass implements PipelinePass {
  readonly profileLabel: string;

  readonly presentsToTerminal: boolean;

  private readonly outputTexture: GPUTexture;

  private readonly computePipeline?: GPUComputePipeline;

  private readonly renderPipeline?: GPURenderPipeline;

  private readonly bindGroup: GPUBindGroup;

  private readonly terminalTarget?: TerminalTextureTarget;

  private readonly ownsOutputTexture: boolean;

  constructor({
    device,
    sourceTexture,
    packedLumaTexture,
    outputSize,
    name,
    cacheKeyPrefix,
    terminalTarget,
  }: PixelShuffleRecomposePassDescriptor) {
    this.profileLabel = `${name}: fused pixel shuffle + output recompose`;
    this.presentsToTerminal = Boolean(terminalTarget);
    this.terminalTarget = terminalTarget;
    if (terminalTarget && (terminalTarget.width !== outputSize.width || terminalTarget.height !== outputSize.height)) {
      throw new Error(`${name}: terminal target has incorrect dimensions.`);
    }

    this.ownsOutputTexture = !this.presentsToTerminal;
    // In terminal mode this is only a lifetime anchor for the PipelinePass contract.
    // The compiler guarantees this is the final effect; its contents are not RGBA output.
    this.outputTexture = this.presentsToTerminal ? packedLumaTexture : borrowTexture({
      device,
      width: outputSize.width,
      height: outputSize.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: `${cacheKeyPrefix}/pixel-shuffle-recompose/output`,
      label: `${name}: fused pixel shuffle recompose output`,
    });

    const visibility = this.presentsToTerminal ? GPUShaderStage.FRAGMENT : GPUShaderStage.COMPUTE;
    const bindGroupLayout = getOrCreateBindGroupLayout(
      device,
      `${cacheKeyPrefix}/pixel-shuffle-recompose/layout/${this.presentsToTerminal ? 'terminal' : 'compute'}`,
      () => ({
        label: `${name}: fused pixel shuffle recompose bind group layout`,
        entries: [
          { binding: 0, visibility, sampler: { type: 'filtering' } },
          { binding: 1, visibility, texture: {} },
          { binding: 2, visibility, texture: {} },
          ...(!this.presentsToTerminal ? [{
            binding: 3,
            visibility: GPUShaderStage.COMPUTE,
            storageTexture: { access: 'write-only', format: 'rgba16float' },
          } satisfies GPUBindGroupLayoutEntry] : []),
        ],
      }),
    );
    const pipelineLayout = device.createPipelineLayout({
      label: `${name}: fused pixel shuffle recompose pipeline layout`,
      bindGroupLayouts: [bindGroupLayout],
    });

    if (this.presentsToTerminal) {
      const vertexModule = getOrCreateShaderModule(
        device,
        `${cacheKeyPrefix}/pixel-shuffle-recompose/shader/terminal-vertex`,
        () => ({ label: `${name}: fused terminal vertex shader`, code: terminalVertexWGSL }),
      );
      const fragmentModule = getOrCreateShaderModule(
        device,
        `${cacheKeyPrefix}/pixel-shuffle-recompose/shader/terminal-fragment`,
        () => ({ label: `${name}: fused terminal fragment shader`, code: terminalFragmentWGSL }),
      );
      this.renderPipeline = getOrCreateRenderPipeline(
        device,
        `${cacheKeyPrefix}/pixel-shuffle-recompose/pipeline/terminal/${terminalTarget!.format}`,
        () => ({
          label: `${name}: fused terminal pixel shuffle recompose pipeline`,
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
      const module = getOrCreateShaderModule(
        device,
        `${cacheKeyPrefix}/pixel-shuffle-recompose/shader/compute`,
        () => ({ label: `${name}: fused pixel shuffle recompose shader`, code: computeWGSL }),
      );
      this.computePipeline = getOrCreateComputePipeline(
        device,
        `${cacheKeyPrefix}/pixel-shuffle-recompose/pipeline/compute`,
        () => ({
          label: `${name}: fused pixel shuffle recompose pipeline`,
          layout: pipelineLayout,
          compute: { module, entryPoint: 'computeMain' },
        }),
      );
    }

    const sampler = getOrCreateSampler(device, `${cacheKeyPrefix}/pixel-shuffle-recompose/sampler/linear`, () => ({
      magFilter: 'linear',
      minFilter: 'linear',
      addressModeU: 'clamp-to-edge',
      addressModeV: 'clamp-to-edge',
    }));
    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/pixel-shuffle-recompose/${name}`, () => ({
      label: `${name}: fused pixel shuffle recompose bind group`,
      layout: bindGroupLayout,
      entries: [
        { binding: 0, resource: sampler },
        { binding: 1, resource: sourceTexture.createView() },
        { binding: 2, resource: packedLumaTexture.createView() },
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
      const pass = encoder.beginRenderPass(profile?.createRenderPassDescriptor?.(this, descriptor) ?? descriptor);
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
      Math.ceil((this.outputTexture.width / 2) / 8),
      Math.ceil((this.outputTexture.height / 2) / 8),
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

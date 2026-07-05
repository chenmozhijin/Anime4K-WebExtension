import type { Dimensions } from '../../types';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
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

export interface LumaRecomposePassDescriptor {
  device: GPUDevice;
  sourceTexture: GPUTexture;
  lumaTexture: GPUTexture;
  outputSize: Dimensions;
  name: string;
  cacheKeyPrefix: string;
  shaderWGSL?: string;
  workgroupSize?: Dimensions;
}

export class LumaRecomposePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  private readonly outputTexture: GPUTexture;

  private readonly pipeline: GPUComputePipeline;

  private readonly bindGroup: GPUBindGroup;

  private readonly workgroupSize: Dimensions;

  constructor({
    device,
    sourceTexture,
    lumaTexture,
    outputSize,
    name,
    cacheKeyPrefix,
    shaderWGSL = defaultLumaRecomposeWGSL,
    workgroupSize = { width: 8, height: 8 },
  }: LumaRecomposePassDescriptor) {
    this.profileLabel = `${name}: output recompose`;
    this.workgroupSize = workgroupSize;
    this.outputTexture = borrowTexture({
      device,
      width: outputSize.width,
      height: outputSize.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: `${cacheKeyPrefix}/output-recompose/output`,
      label: `${name}: output texture`,
    });

    const shaderModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/output-recompose/shader/main`, () => ({
      label: `${name}: output recompose shader`,
      code: shaderWGSL,
    }));

    const bindGroupLayout = getOrCreateBindGroupLayout(device, `${cacheKeyPrefix}/output-recompose/layout/main`, () => ({
      label: `${name}: output recompose bind group layout`,
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.COMPUTE,
          sampler: { type: 'filtering' },
        },
        {
          binding: 1,
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        },
        {
          binding: 2,
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        },
        {
          binding: 3,
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    }));

    this.pipeline = getOrCreateComputePipeline(device, `${cacheKeyPrefix}/output-recompose/pipeline/main`, () => ({
      label: `${name}: output recompose pipeline`,
      layout: device.createPipelineLayout({
        label: `${name}: output recompose pipeline layout`,
        bindGroupLayouts: [bindGroupLayout],
      }),
      compute: {
        module: shaderModule,
        entryPoint: 'computeMain',
      },
    }));

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
        { binding: 3, resource: this.outputTexture.createView() },
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
    const pass = encoder.beginComputePass(profile?.createComputePassDescriptor?.(this));
    pass.setPipeline(this.pipeline);
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
    releaseTexture(this.outputTexture);
  }
}

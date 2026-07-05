import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';

const DEPTH_TO_SPACE_WORKGROUP_SIZE = 8;

const depthToSpaceWGSL = `
@group(0) @binding(0) var tex_0: texture_2d<f32>;
@group(0) @binding(1) var tex_1: texture_2d<f32>;
@group(0) @binding(2) var tex_2: texture_2d<f32>;
@group(0) @binding(3) var tex_out: texture_storage_2d<rgba16float, write>;

fn colorAt(texture: texture_2d<f32>, x: u32, y: u32) -> vec4<f32> {
  return textureLoad(texture, vec2u(x, y), 0);
}

@compute
@workgroup_size(${DEPTH_TO_SPACE_WORKGROUP_SIZE}, ${DEPTH_TO_SPACE_WORKGROUP_SIZE})
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dim_out: vec2u = textureDimensions(tex_out);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  let loc: vec2u = pixel.xy / vec2u(2, 2);
  let sub_loc: vec2u = pixel.xy % vec2u(2, 2);
  let channel: u32 = sub_loc.y * 2 + sub_loc.x;
  let c0: f32 = colorAt(tex_0, loc.x, loc.y)[channel];
  let c1: f32 = colorAt(tex_1, loc.x, loc.y)[channel];
  let c2: f32 = colorAt(tex_2, loc.x, loc.y)[channel];
  let c3: f32 = c2;

  textureStore(tex_out, pixel.xy, vec4f(c0, c1, c2, c3));
}
`;

export interface DepthToSpacePassDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  name?: string;
  cacheKeyPrefix?: string;
}

export class DepthToSpacePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  readonly outputTexture: GPUTexture;

  readonly pipeline: GPUComputePipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  constructor({
    device,
    inputTextures,
    name = 'depth to space',
    cacheKeyPrefix = 'core/gpu-passes/DepthToSpacePass',
  }: DepthToSpacePassDescriptor) {
    if (inputTextures.length !== 3) {
      throw Error(`expect 3 textures for depth2Space, got ${inputTextures.length}`);
    }
    this.name = name;
    this.profileLabel = name;

    this.outputTexture = borrowTexture({
      device,
      width: 2 * inputTextures[0].width,
      height: 2 * inputTextures[0].height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: `${cacheKeyPrefix}/output`,
      label: `${name}: depth_to_space_texture`,
    });

    const shaderModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/shader/main`, () => ({
      label: `${name}: depthToSpace Module`,
      code: depthToSpaceWGSL,
    }));

    const bindGroupLayout = getOrCreateBindGroupLayout(device, `${cacheKeyPrefix}/layout/3in1out`, () => ({
      label: `${name} depth to space bind group layout`,
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
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

    this.pipeline = getOrCreateComputePipeline(device, `${cacheKeyPrefix}/pipeline/main`, () => ({
      label: 'depth to space pipeline',
      layout: device.createPipelineLayout({
        label: 'depth to space pipeline layout',
        bindGroupLayouts: [bindGroupLayout],
      }),
      compute: {
        module: shaderModule,
        entryPoint: 'computeMain',
      },
    }));

    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/${name}/bind-group`, () => ({
      layout: bindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: inputTextures[0].createView(),
        },
        {
          binding: 1,
          resource: inputTextures[1].createView(),
        },
        {
          binding: 2,
          resource: inputTextures[2].createView(),
        },
        {
          binding: 3,
          resource: this.outputTexture.createView(),
        },
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
      Math.ceil(this.outputTexture.width / DEPTH_TO_SPACE_WORKGROUP_SIZE),
      Math.ceil(this.outputTexture.height / DEPTH_TO_SPACE_WORKGROUP_SIZE),
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

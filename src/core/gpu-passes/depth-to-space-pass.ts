import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';

const DEPTH_TO_SPACE_WORKGROUP_SIZE = 8;

const baselineDepthToSpaceWGSL = `
@group(0) @binding(0) var tex_0: texture_2d<f32>;
@group(0) @binding(1) var tex_1: texture_2d<f32>;
@group(0) @binding(2) var tex_2: texture_2d<f32>;
@group(0) @binding(3) var tex_out: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(${DEPTH_TO_SPACE_WORKGROUP_SIZE}, ${DEPTH_TO_SPACE_WORKGROUP_SIZE})
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(tex_out);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let sourcePixel = pixel.xy / vec2u(2u, 2u);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let c0 = textureLoad(tex_0, vec2i(sourcePixel), 0)[lane];
  let c1 = textureLoad(tex_1, vec2i(sourcePixel), 0)[lane];
  let c2 = textureLoad(tex_2, vec2i(sourcePixel), 0)[lane];
  textureStore(tex_out, pixel.xy, vec4f(c0, c1, c2, c2));
}
`;

const vectorizedDepthToSpaceWGSL = `
@group(0) @binding(0) var tex_0: texture_2d<f32>;
@group(0) @binding(1) var tex_1: texture_2d<f32>;
@group(0) @binding(2) var tex_2: texture_2d<f32>;
@group(0) @binding(3) var tex_out: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(${DEPTH_TO_SPACE_WORKGROUP_SIZE}, ${DEPTH_TO_SPACE_WORKGROUP_SIZE})
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_0);
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let c0 = textureLoad(tex_0, vec2i(pixel.xy), 0);
  let c1 = textureLoad(tex_1, vec2i(pixel.xy), 0);
  let c2 = textureLoad(tex_2, vec2i(pixel.xy), 0);
  let outputBase = pixel.xy * vec2u(2u, 2u);
  // One low-resolution invocation owns a disjoint 2x2 block, reducing invocation
  // count by four without atomics or cross-invocation write overlap.
  textureStore(tex_out, outputBase, vec4f(c0.x, c1.x, c2.x, c2.x));
  textureStore(tex_out, outputBase + vec2u(1u, 0u), vec4f(c0.y, c1.y, c2.y, c2.y));
  textureStore(tex_out, outputBase + vec2u(0u, 1u), vec4f(c0.z, c1.z, c2.z, c2.z));
  textureStore(tex_out, outputBase + vec2u(1u, 1u), vec4f(c0.w, c1.w, c2.w, c2.w));
}
`;

export interface DepthToSpacePassDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  name?: string;
  cacheKeyPrefix?: string;
  outputTexture?: GPUTexture;
  vectorized?: boolean;
}

export class DepthToSpacePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  readonly outputTexture: GPUTexture;

  readonly pipeline: GPUComputePipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  private readonly ownsOutputTexture: boolean;

  private readonly vectorized: boolean;

  constructor({
    device,
    inputTextures,
    name = 'depth to space',
    cacheKeyPrefix = 'core/gpu-passes/DepthToSpacePass',
    outputTexture,
    vectorized = true,
  }: DepthToSpacePassDescriptor) {
    if (inputTextures.length !== 3) {
      throw Error(`expect 3 textures for depth2Space, got ${inputTextures.length}`);
    }
    this.name = name;
    this.profileLabel = name;
    this.vectorized = vectorized;

    this.ownsOutputTexture = !outputTexture;
    this.outputTexture = outputTexture ?? borrowTexture({
        device,
        width: 2 * inputTextures[0].width,
        height: 2 * inputTextures[0].height,
        format: 'rgba16float',
        usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
        labelGroup: `${cacheKeyPrefix}/output`,
        label: `${name}: depth_to_space_texture`,
      });
    if (outputTexture && (
      this.outputTexture.width !== 2 * inputTextures[0].width
      || this.outputTexture.height !== 2 * inputTextures[0].height
    )) {
      throw new Error(`${name}: preallocated output texture has incorrect dimensions.`);
    }

    const variant = vectorized ? 'vectorized' : 'baseline';
    const shaderModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/shader/${variant}`, () => ({
      label: `${name}: depthToSpace Module`,
      code: vectorized ? vectorizedDepthToSpaceWGSL : baselineDepthToSpaceWGSL,
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

    this.pipeline = getOrCreateComputePipeline(device, `${cacheKeyPrefix}/pipeline/${variant}`, () => ({
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
    // The vectorized shader dispatches in source-pixel space; using output dimensions
    // here would restore the original invocation count and issue redundant stores.
    pass.dispatchWorkgroups(
      Math.ceil((this.vectorized ? this.outputTexture.width / 2 : this.outputTexture.width)
        / DEPTH_TO_SPACE_WORKGROUP_SIZE),
      Math.ceil((this.vectorized ? this.outputTexture.height / 2 : this.outputTexture.height)
        / DEPTH_TO_SPACE_WORKGROUP_SIZE),
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

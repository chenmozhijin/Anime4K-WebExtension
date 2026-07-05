import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateRenderPipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';
import vertexWGSL from './shaders/downscale-vertex.wgsl';
import fragmentWGSL from './shaders/downscale-fragment.wgsl';

interface DownscalePipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  targetDimensions: { width: number; height: number };
  name?: string;
}

interface DeviceCache {
  bindGroupLayout: GPUBindGroupLayout;
  pipeline: GPURenderPipeline;
  sampler: GPUSampler;
}

const cacheByDevice = new WeakMap<GPUDevice, DeviceCache>();

function getDeviceCache(device: GPUDevice): DeviceCache {
  const cached = cacheByDevice.get(device);
  if (cached) {
    return cached;
  }

  const vertexModule = getOrCreateShaderModule(device, 'core/downscale/shader/vertex', () => ({
    label: 'shared downscale vertex module',
    code: vertexWGSL,
  }));

  const fragmentModule = getOrCreateShaderModule(device, 'core/downscale/shader/fragment', () => ({
    label: 'shared downscale fragment module',
    code: fragmentWGSL,
  }));

  const bindGroupLayout = getOrCreateBindGroupLayout(device, 'core/downscale/layout/render', () => ({
    label: 'shared downscale bind group layout',
    entries: [
      {
        binding: 1,
        visibility: GPUShaderStage.FRAGMENT,
        sampler: {},
      },
      {
        binding: 2,
        visibility: GPUShaderStage.FRAGMENT,
        texture: {},
      },
    ],
  }));

  const pipeline = getOrCreateRenderPipeline(device, 'core/downscale/pipeline/rgba16float', () => ({
    layout: device.createPipelineLayout({
      label: 'shared downscale pipeline layout',
      bindGroupLayouts: [bindGroupLayout],
    }),
    vertex: {
      module: vertexModule,
      entryPoint: 'vert_main',
    },
    fragment: {
      module: fragmentModule,
      entryPoint: 'main',
      targets: [{ format: 'rgba16float' }],
    },
    primitive: {
      topology: 'triangle-list',
    },
  }));

  const sampler = getOrCreateSampler(device, 'core/downscale/sampler/linear-linear', () => ({
    magFilter: 'linear',
    minFilter: 'linear',
  }));

  const deviceCache = {
    bindGroupLayout,
    pipeline,
    sampler,
  };
  cacheByDevice.set(device, deviceCache);
  return deviceCache;
}

export class Downscale implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  private readonly outputTexture: GPUTexture;
  private readonly bindGroup: GPUBindGroup;
  private readonly pipeline: GPURenderPipeline;
  private readonly name: string;

  constructor({
    device,
    inputTexture,
    targetDimensions,
    name = 'downscale',
  }: DownscalePipelineDescriptor) {
    this.name = name;
    this.profileLabel = name;

    const cache = getDeviceCache(device);
    this.pipeline = cache.pipeline;

    this.outputTexture = borrowTexture({
      device,
      width: targetDimensions.width,
      height: targetDimensions.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING
      | GPUTextureUsage.RENDER_ATTACHMENT
      | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'core/downscale/output',
      label: `${name} output texture`,
    });

    this.bindGroup = createBindGroupChecked(device, `core/downscale/${name}`, () => ({
      layout: cache.bindGroupLayout,
      entries: [
        {
          binding: 1,
          resource: cache.sampler,
        },
        {
          binding: 2,
          resource: inputTexture.createView(),
        },
      ],
    }));
  }

  updateParam(param: string, value: any): void {
    throw new Error(`${this.name} has no param`);
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    if (profile) {
      profile.recordPass(this, () => this.encodePass(encoder, profile));
      return;
    }

    this.encodePass(encoder);
  }

  private encodePass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    const descriptor: GPURenderPassDescriptor = {
      colorAttachments: [
        {
          view: this.outputTexture.createView(),
          clearValue: {
            r: 0.0, g: 0.0, b: 0.0, a: 1.0,
          },
          loadOp: 'clear',
          storeOp: 'store',
        },
      ],
    };
    const pass = encoder.beginRenderPass(profile?.createRenderPassDescriptor?.(this, descriptor) ?? descriptor);
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.draw(6);
    pass.end();
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    releaseTexture(this.outputTexture);
  }
}

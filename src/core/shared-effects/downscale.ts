import type {
  PipelinePass,
  PipelineProfileRecorder,
  TerminalTextureTarget,
} from '../effects/backend-types';
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
  outputTexture?: GPUTexture;
  terminalTarget?: TerminalTextureTarget;
}

interface DeviceCache {
  bindGroupLayout: GPUBindGroupLayout;
  pipeline: GPURenderPipeline;
  sampler: GPUSampler;
}

const cacheByDevice = new WeakMap<GPUDevice, Map<GPUTextureFormat, DeviceCache>>();

function getDeviceCache(device: GPUDevice, outputFormat: GPUTextureFormat): DeviceCache {
  let deviceCaches = cacheByDevice.get(device);
  if (!deviceCaches) {
    deviceCaches = new Map();
    cacheByDevice.set(device, deviceCaches);
  }
  const cached = deviceCaches.get(outputFormat);
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

  const pipeline = getOrCreateRenderPipeline(device, `core/downscale/pipeline/${outputFormat}`, () => ({
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
      targets: [{ format: outputFormat }],
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
  deviceCaches.set(outputFormat, deviceCache);
  return deviceCache;
}

export class Downscale implements PipelinePass {
  readonly profileLabel: string;

  readonly presentsToTerminal: boolean;

  profileGroup?: string;

  private readonly outputTexture: GPUTexture;
  private readonly bindGroup: GPUBindGroup;
  private readonly pipeline: GPURenderPipeline;
  private readonly name: string;
  private readonly renderPassDescriptor?: GPURenderPassDescriptor;
  private readonly ownsOutputTexture: boolean;
  private readonly terminalTarget?: TerminalTextureTarget;

  constructor({
    device,
    inputTexture,
    targetDimensions,
    name = 'downscale',
    outputTexture,
    terminalTarget,
  }: DownscalePipelineDescriptor) {
    this.name = name;
    this.profileLabel = name;
    this.terminalTarget = terminalTarget;
    this.presentsToTerminal = Boolean(terminalTarget);

    const cache = getDeviceCache(device, terminalTarget?.format ?? 'rgba16float');
    this.pipeline = cache.pipeline;

    this.ownsOutputTexture = !outputTexture && !terminalTarget;
    this.outputTexture = outputTexture ?? (terminalTarget ? inputTexture : borrowTexture({
        device,
        width: targetDimensions.width,
        height: targetDimensions.height,
        format: 'rgba16float',
        usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT,
        labelGroup: 'core/downscale/output',
        label: `${name} output texture`,
      }));
    if (!terminalTarget && outputTexture && (
      this.outputTexture.width !== targetDimensions.width
      || this.outputTexture.height !== targetDimensions.height
    )) {
      throw new Error(`${name}: preallocated output texture has incorrect dimensions.`);
    }

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
    if (!terminalTarget) {
      this.renderPassDescriptor = this.createRenderPassDescriptor(this.outputTexture.createView());
    }
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
    const descriptor = this.renderPassDescriptor
      ?? this.createRenderPassDescriptor(this.terminalTarget!.getCurrentView());
    const pass = encoder.beginRenderPass(profile?.createRenderPassDescriptor?.(this, descriptor) ?? descriptor);
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.draw(3);
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

  private createRenderPassDescriptor(view: GPUTextureView): GPURenderPassDescriptor {
    return {
      colorAttachments: [{
        view,
        clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
        loadOp: 'clear',
        storeOp: 'store',
      }],
    };
  }
}

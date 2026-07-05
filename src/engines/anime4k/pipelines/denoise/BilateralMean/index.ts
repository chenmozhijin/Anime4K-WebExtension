import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import denoiseBilateralMeanWGSL from './shaders/bilateralMean.wgsl';
import { ComputeTexturePass } from '../../../../../core/gpu-passes/compute-texture-pass';

const DEFAULT_INTENSITY_SIGMA = 0.1;
const DEFAULT_SPATIAL_SIGMA = 1.0;

export class BilateralMean implements Anime4KPipeline {
  texture: GPUTexture;

  bindGroup: GPUBindGroup;

  pipeline: GPUComputePipeline;

  strengthBuffer: GPUBuffer;

  strengthBuffer2: GPUBuffer;

  inputTexWidth: number;

  inputTexHeight: number;

  inputTexture: GPUTexture;

  // passed in by constructor
  device: GPUDevice;

  private readonly passImpl: ComputeTexturePass;

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.device = device;
    this.inputTexWidth = inputTexture.width;
    this.inputTexHeight = inputTexture.height;
    this.inputTexture = inputTexture;

    this.strengthBuffer = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    this.strengthBuffer2 = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });
    this.device.queue.writeBuffer(this.strengthBuffer, 0, new Float32Array([DEFAULT_INTENSITY_SIGMA]));
    this.device.queue.writeBuffer(this.strengthBuffer2, 0, new Float32Array([DEFAULT_SPATIAL_SIGMA]));

    this.passImpl = new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: denoiseBilateralMeanWGSL,
      name: 'Denoise Bilateral Mean',
      cacheKeyPrefix: 'anime4k/denoise/BilateralMean',
      outputSize: {
        width: this.inputTexWidth,
        height: this.inputTexHeight,
      },
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      entryPoint: 'denoiseMain',
      extraLayoutKey: 'uniforms-2-3',
      extraLayoutEntries: [
        {
          binding: 2,
          visibility: GPUShaderStage.COMPUTE,
          buffer: { type: 'uniform' },
        },
        {
          binding: 3,
          visibility: GPUShaderStage.COMPUTE,
          buffer: { type: 'uniform' },
        },
      ],
      extraBindGroupEntries: [
        {
          binding: 2,
          resource: {
            buffer: this.strengthBuffer,
          },
        },
        {
          binding: 3,
          resource: {
            buffer: this.strengthBuffer2,
          },
        },
      ],
    });

    this.texture = this.passImpl.outputTexture;
    this.pipeline = this.passImpl.pipeline;
    this.bindGroup = this.passImpl.bindGroup;
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder) {
    this.passImpl.pass(encoder, profile);
  }

  getOutputTexture(): GPUTexture {
    return this.texture;
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  updateParam(param: string, value: any): void {
    if (param !== 'strength' && param !== 'strength2') {
      throw new Error(`No param name as ${param}`);
    }
    if (typeof value !== 'number') {
      throw new Error('strength must be a number');
    }
    if (value < 0) {
      throw new Error(`negative strength (${value}) is not allowed`);
    }
    if (param === 'strength') {
      this.device.queue.writeBuffer(this.strengthBuffer, 0, new Float32Array([value]));
    } else if (param === 'strength2') {
      this.device.queue.writeBuffer(this.strengthBuffer2, 0, new Float32Array([value]));
    }
  }

  destroy(): void {
    this.passImpl.destroy();

    try {
      this.strengthBuffer.destroy();
    } catch {
      // Ignore buffer destruction errors during teardown.
    }

    try {
      this.strengthBuffer2.destroy();
    } catch {
      // Ignore buffer destruction errors during teardown.
    }
  }

  getProfileChildren(): PipelinePass[] {
    return [this.passImpl];
  }
}


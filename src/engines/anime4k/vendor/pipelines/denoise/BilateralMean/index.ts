import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import denoiseBilateralMeanWGSL from './shaders/bilateralMean.wgsl';
import { createBindGroupChecked } from '../../../../../../core/gpu-resource-cache';

export class BilateralMean implements Anime4KPipeline {
  texture: GPUTexture;

  module: GPUShaderModule;

  bindGroupLayout: GPUBindGroupLayout;

  bindGroup: GPUBindGroup;

  pipelineLayout: GPUPipelineLayout;

  pipeline: GPUComputePipeline;

  strengthBuffer: GPUBuffer;

  strengthBuffer2: GPUBuffer;

  inputTexWidth: number;

  inputTexHeight: number;

  inputTexture: GPUTexture;

  // passed in by constructor
  device: GPUDevice;

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.device = device;
    this.inputTexWidth = inputTexture.width;
    this.inputTexHeight = inputTexture.height;
    this.inputTexture = inputTexture;

    const denoiseMeanModule = this.device.createShaderModule({
      label: 'Denoise Bilateral Mean Module',
      code: denoiseBilateralMeanWGSL,
    });

    const denoiseMeanBindGroupLayout = device.createBindGroupLayout({
      label: 'Denoise Bilateral Mean Bind Group Layout',
      entries: [{
        binding: 0, // input frame texture
        visibility: GPUShaderStage.COMPUTE,
        texture: {},
      },
      {
        binding: 1,
        visibility: GPUShaderStage.COMPUTE,
        storageTexture: {
          access: 'write-only',
          format: 'rgba16float',
        },
      },
      {
        binding: 2,
        visibility: GPUShaderStage.COMPUTE,
        buffer: { type: 'uniform' },
      },
      {
        binding: 3,
        visibility: GPUShaderStage.COMPUTE,
        buffer: { type: 'uniform' },
      }],
    });

    const denoiseMeanTexture = this.device.createTexture({
      size: [this.inputTexWidth, this.inputTexHeight, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    this.strengthBuffer = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    this.strengthBuffer2 = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    const denoiseMeanBindGroup = createBindGroupChecked(this.device, 'anime4k/denoise/BilateralMean/bind-group', () => ({
      layout: denoiseMeanBindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: this.inputTexture.createView(),
        },
        {
          binding: 1,
          resource: denoiseMeanTexture.createView(),
        },
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
    }));

    const denoisePipelineLayout = this.device.createPipelineLayout({
      label: 'Denoise Bilateral Mean Pipeline Layout',
      bindGroupLayouts: [denoiseMeanBindGroupLayout],
    });

    const denoiseMeanPipeline = device.createComputePipeline({
      label: 'Denoise Bilateral Mean Compute Pipeline',
      layout: denoisePipelineLayout,
      compute: {
        module: denoiseMeanModule,
        entryPoint: 'denoiseMain',
      },
    });

    this.texture = denoiseMeanTexture;
    this.module = denoiseMeanModule;
    this.bindGroupLayout = denoiseMeanBindGroupLayout;
    this.pipelineLayout = denoisePipelineLayout;
    this.pipeline = denoiseMeanPipeline;
    this.bindGroup = denoiseMeanBindGroup;
  }

  pass(encoder: GPUCommandEncoder) {
    const denoisePass = encoder.beginComputePass();
    denoisePass.setPipeline(this.pipeline);
    denoisePass.setBindGroup(0, this.bindGroup);
    denoisePass.dispatchWorkgroups(
      Math.ceil(this.inputTexWidth / 8),
      Math.ceil(this.inputTexHeight / 8),
    );
    denoisePass.end();
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
    try {
      this.texture.destroy();
    } catch {
      // Ignore texture destruction errors during teardown.
    }

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
}

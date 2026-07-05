import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { ComputeTexturePass } from '../../../../../core/gpu-passes/compute-texture-pass';
import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import luminationWGSL from './shaders/lumination.wgsl';
import deblurDoGXWGSL from './shaders/deblurDoGX.wgsl';
import deblurDoGYWGSL from './shaders/deblurDoGY.wgsl';
import deblurDoGApplyWGSL from './shaders/deblurDoGApply.wgsl';

const DEFAULT_STRENGTH = 0.6;

export class DoG implements Anime4KPipeline {
  readonly strengthBuffer: GPUBuffer;

  private readonly device: GPUDevice;

  private readonly passes: ComputeTexturePass[];

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.device = device;
    this.strengthBuffer = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });
    this.device.queue.writeBuffer(this.strengthBuffer, 0, new Float32Array([DEFAULT_STRENGTH]));

    const outputSize = {
      width: inputTexture.width,
      height: inputTexture.height,
    };

    const luminationPass = new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: luminationWGSL,
      name: 'Deblur DoG Lumination',
      cacheKeyPrefix: 'anime4k/deblur/DoG/lumination',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const deblurXPass = new ComputeTexturePass({
      device,
      inputTextures: [luminationPass.outputTexture],
      shaderWGSL: deblurDoGXWGSL,
      name: 'Deblur DoG X',
      cacheKeyPrefix: 'anime4k/deblur/DoG/deblur-x',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const deblurYPass = new ComputeTexturePass({
      device,
      inputTextures: [deblurXPass.outputTexture],
      shaderWGSL: deblurDoGYWGSL,
      name: 'Deblur DoG Y',
      cacheKeyPrefix: 'anime4k/deblur/DoG/deblur-y',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const applyPass = new ComputeTexturePass({
      device,
      inputTextures: [
        deblurYPass.outputTexture,
        luminationPass.outputTexture,
        inputTexture,
      ],
      shaderWGSL: deblurDoGApplyWGSL,
      name: 'Deblur DoG Apply',
      cacheKeyPrefix: 'anime4k/deblur/DoG/apply',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      extraLayoutKey: 'uniforms-4',
      extraLayoutEntries: [{
        binding: 4,
        visibility: GPUShaderStage.COMPUTE,
        buffer: { type: 'uniform' },
      }],
      extraBindGroupEntries: [{
        binding: 4,
        resource: {
          buffer: this.strengthBuffer,
        },
      }],
    });

    this.passes = [
      luminationPass,
      deblurXPass,
      deblurYPass,
      applyPass,
    ];
  }

  getOutputTexture(): GPUTexture {
    return this.passes[this.passes.length - 1].outputTexture;
  }

  updateParam(param: string, value: any): void {
    if (param !== 'strength') {
      throw new Error(`No param name as ${param}`);
    }
    if (typeof value !== 'number') {
      throw new Error('strength must be a number');
    }
    if (value < 0) {
      throw new Error(`negative strength (${value}) is not allowed`);
    }
    this.device.queue.writeBuffer(this.strengthBuffer, 0, new Float32Array([value]));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.passes.forEach(pass => pass.pass(encoder, profile));
  }

  destroy(): void {
    this.passes.forEach((pass) => {
      pass.destroy();
    });

    try {
      this.strengthBuffer.destroy();
    } catch {
      // Ignore buffer destruction errors during teardown.
    }
  }

  getProfileChildren(): PipelinePass[] {
    return this.passes;
  }
}

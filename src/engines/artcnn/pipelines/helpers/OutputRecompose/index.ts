import outputRecomposeWGSL from './shaders/outputRecompose.wgsl';
import type { PipelinePass } from '../../../../../core/effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../../../../../core/gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../../../../../core/texture-pool';

export interface ArtCNNOutputRecomposeDescriptor {
  device: GPUDevice;
  sourceTexture: GPUTexture;
  lumaTexture: GPUTexture;
  outputTextureSize: { width: number; height: number };
  workgroupSize?: { x: number; y: number };
  name: string;
}

export class ArtCNNOutputRecompose implements PipelinePass {
  outputTexture: GPUTexture;

  pipeline: GPUComputePipeline;

  bindGroup: GPUBindGroup;

  workgroupSize: { x: number; y: number };

  constructor({
    device,
    sourceTexture,
    lumaTexture,
    outputTextureSize,
    workgroupSize = { x: 12, y: 16 },
    name,
  }: ArtCNNOutputRecomposeDescriptor) {
    this.workgroupSize = workgroupSize;

    this.outputTexture = borrowTexture({
      device,
      width: outputTextureSize.width,
      height: outputTextureSize.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'artcnn/helper/OutputRecompose/output',
      label: `${name}: output texture`,
    });

    const shaderModule = getOrCreateShaderModule(device, 'artcnn/helper/OutputRecompose/shader/main', () => ({
      label: `${name}: shader`,
      code: outputRecomposeWGSL,
    }));

    const bindGroupLayout = getOrCreateBindGroupLayout(device, 'artcnn/helper/OutputRecompose/layout/main', () => ({
      label: `${name}: bind group layout`,
      entries: [
        {
          binding: 0,
          visibility: GPUShaderStage.COMPUTE,
          sampler: {
            type: 'filtering',
          },
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

    this.pipeline = getOrCreateComputePipeline(device, 'artcnn/helper/OutputRecompose/pipeline/main', () => ({
      label: `${name}: compute pipeline`,
      layout: device.createPipelineLayout({
        label: `${name}: pipeline layout`,
        bindGroupLayouts: [bindGroupLayout],
      }),
      compute: {
        module: shaderModule,
        entryPoint: 'computeMain',
      },
    }));

    const sampler = getOrCreateSampler(device, 'artcnn/helper/OutputRecompose/sampler/linear', () => ({
      magFilter: 'linear',
      minFilter: 'linear',
      addressModeU: 'clamp-to-edge',
      addressModeV: 'clamp-to-edge',
    }));

    this.bindGroup = createBindGroupChecked(device, `artcnn/helper/OutputRecompose/${name}/bind-group`, () => ({
      label: `${name}: bind group`,
      layout: bindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: sampler,
        },
        {
          binding: 1,
          resource: sourceTexture.createView(),
        },
        {
          binding: 2,
          resource: lumaTexture.createView(),
        },
        {
          binding: 3,
          resource: this.outputTexture.createView(),
        },
      ],
    }));
  }

  updateParam(): void {
    throw new Error('Method not implemented.');
  }

  pass(encoder: GPUCommandEncoder): void {
    const pass = encoder.beginComputePass();
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / this.workgroupSize.x),
      Math.ceil(this.outputTexture.height / this.workgroupSize.y),
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


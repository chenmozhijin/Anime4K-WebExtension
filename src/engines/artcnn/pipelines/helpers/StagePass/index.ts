import type { PipelinePass } from '../../../../../core/effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateShaderModule,
} from '../../../../../core/gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../../../../../core/texture-pool';

export interface ArtCNNStagePassDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  shaderWGSL: string;
  outputTextureSize: { width: number; height: number };
  dispatchDimensions: { width: number; height: number };
  workgroupSize?: { x: number; y: number };
  name: string;
}

function getShaderFingerprint(shaderWGSL: string): string {
  let hash = 2166136261;
  for (let i = 0; i < shaderWGSL.length; i += 1) {
    hash ^= shaderWGSL.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }

  return (hash >>> 0).toString(16);
}

export class ArtCNNStagePass implements PipelinePass {
  outputTexture: GPUTexture;

  pipeline: GPUComputePipeline;

  bindGroup: GPUBindGroup;

  dispatchDimensions: { width: number; height: number };

  workgroupSize: { x: number; y: number };

  constructor({
    device,
    inputTextures,
    shaderWGSL,
    outputTextureSize,
    dispatchDimensions,
    workgroupSize = { x: 12, y: 16 },
    name,
  }: ArtCNNStagePassDescriptor) {
    if (inputTextures.length === 0) {
      throw new Error(`${name}: no input textures provided`);
    }

    this.dispatchDimensions = dispatchDimensions;
    this.workgroupSize = workgroupSize;

    this.outputTexture = borrowTexture({
      device,
      width: outputTextureSize.width,
      height: outputTextureSize.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: `artcnn/helper/StagePass/output/${inputTextures.length}`,
      label: `${name}: output texture`,
    });

    const shaderFingerprint = getShaderFingerprint(shaderWGSL);
    const shaderModule = getOrCreateShaderModule(device, `artcnn/helper/StagePass/shader/${inputTextures.length}/${shaderFingerprint}`, () => ({
      label: `${name}: shader`,
      code: shaderWGSL,
    }));

    const bindGroupLayout = getOrCreateBindGroupLayout(device, `artcnn/helper/StagePass/layout/${inputTextures.length}`, () => ({
      label: `${name}: bind group layout`,
      entries: [
        ...inputTextures.map((_, index): GPUBindGroupLayoutEntry => ({
          binding: index,
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        })),
        {
          binding: inputTextures.length,
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    }));

    this.pipeline = getOrCreateComputePipeline(device, `artcnn/helper/StagePass/pipeline/${inputTextures.length}/${shaderFingerprint}`, () => ({
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

    this.bindGroup = createBindGroupChecked(device, `artcnn/helper/StagePass/${name}/bind-group`, () => ({
      label: `${name}: bind group`,
      layout: bindGroupLayout,
      entries: [
        ...inputTextures.map((texture, index): GPUBindGroupEntry => ({
          binding: index,
          resource: texture.createView(),
        })),
        {
          binding: inputTextures.length,
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
      Math.ceil(this.dispatchDimensions.width / this.workgroupSize.x),
      Math.ceil(this.dispatchDimensions.height / this.workgroupSize.y),
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


import { Anime4KPipeline, ClampHighlightsPipelineDescriptor } from '../../interfaces';
import luminationXWGSL from './shaders/luminationX.wgsl';
import luminationYWGSL from './shaders/luminationY.wgsl';
import clampWGSL from './shaders/clamp.wgsl';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateShaderModule,
} from '../../../../../core/gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../../../../../core/texture-pool';

export class ClampHighlights implements Anime4KPipeline {
  name: string;

  pipelines: {
    luminationXPipeline: GPUComputePipeline,
    luminationYPipeline: GPUComputePipeline,
    clampPipeline: GPUComputePipeline,
  };

  bindGroups: {
    luminationXBindGroup: GPUBindGroup,
    luminationYBindGroup: GPUBindGroup,
    clampBindGroup: GPUBindGroup,
  };

  outputTexture: GPUTexture;
  statsXTexture: GPUTexture;
  statsYTexture: GPUTexture;

  constructor({
    device,
    inputTexture,
    name = 'clamp highlights',
  }: ClampHighlightsPipelineDescriptor) {
    this.name = name;

    // textures
    this.outputTexture = borrowTexture({
      device,
      width: inputTexture.width,
      height: inputTexture.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'anime4k/helper/ClampHighlights/output',
      label: `${name}: clamp_highlights_texture`,
    });

    this.statsXTexture = borrowTexture({
      device,
      width: inputTexture.width,
      height: inputTexture.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'anime4k/helper/ClampHighlights/stats-x',
      label: `${name}: statsmax_texture`,
    });

    this.statsYTexture = borrowTexture({
      device,
      width: inputTexture.width,
      height: inputTexture.height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'anime4k/helper/ClampHighlights/stats-y',
      label: `${name}: statsmax_texture`,
    });

    // bindGroupLayouts
    const luminationBindGroupLayout = getOrCreateBindGroupLayout(device, 'anime4k/helper/ClampHighlights/layout/lumination', () => ({
      label: `${name} lumination bind group layout`,
      entries: [
        {
          binding: 0,
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
      ],
    }));

    const clampBindGroupLayout = getOrCreateBindGroupLayout(device, 'anime4k/helper/ClampHighlights/layout/clamp', () => ({
      label: `${name} clamp bind group layout`,
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
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    }));

    // modules
    const luminationXModule = getOrCreateShaderModule(device, 'anime4k/helper/ClampHighlights/shader/lumination-x', () => ({
      label: `${name}: luminationX Module`,
      code: luminationXWGSL,
    }));

    const luminationYModule = getOrCreateShaderModule(device, 'anime4k/helper/ClampHighlights/shader/lumination-y', () => ({
      label: `${name}: luminationY Module`,
      code: luminationYWGSL,
    }));

    const clampModule = getOrCreateShaderModule(device, 'anime4k/helper/ClampHighlights/shader/clamp', () => ({
      label: `${name}: clamp Module`,
      code: clampWGSL,
    }));

    const luminationXPipeline = getOrCreateComputePipeline(device, 'anime4k/helper/ClampHighlights/pipeline/lumination-x', () => ({
      label: `${name} luminationX pipeline`,
      layout: device.createPipelineLayout({
        label: `${name} lumination pipeline layout`,
        bindGroupLayouts: [luminationBindGroupLayout],
      }),
      compute: {
        module: luminationXModule,
        entryPoint: 'computeMain',
      },
    }));

    const luminationYPipeline = getOrCreateComputePipeline(device, 'anime4k/helper/ClampHighlights/pipeline/lumination-y', () => ({
      label: `${name} luminationY pipeline`,
      layout: device.createPipelineLayout({
        label: `${name} lumination pipeline layout`,
        bindGroupLayouts: [luminationBindGroupLayout],
      }),
      compute: {
        module: luminationYModule,
        entryPoint: 'computeMain',
      },
    }));

    const clampPipeline = getOrCreateComputePipeline(device, 'anime4k/helper/ClampHighlights/pipeline/clamp', () => ({
      label: `${name} clamp pipeline`,
      layout: device.createPipelineLayout({
        label: `${name} clamp pipeline layout`,
        bindGroupLayouts: [clampBindGroupLayout],
      }),
      compute: {
        module: clampModule,
        entryPoint: 'computeMain',
      },
    }));

    this.pipelines = {
      luminationXPipeline,
      luminationYPipeline,
      clampPipeline,
    };

    const luminationXBindGroup = createBindGroupChecked(device, `anime4k/helper/ClampHighlights/${name}/lumination-x`, () => ({
      label: `${name} luminationX bind group`,
      layout: luminationBindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: inputTexture.createView(),
        },
        {
          binding: 1,
          resource: this.statsXTexture.createView(),
        },
      ],
    }));

    const luminationYBindGroup = createBindGroupChecked(device, `anime4k/helper/ClampHighlights/${name}/lumination-y`, () => ({
      label: `${name} luminationY bind group`,
      layout: luminationBindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: this.statsXTexture.createView(),
        },
        {
          binding: 1,
          resource: this.statsYTexture.createView(),
        },
      ],
    }));

    const clampBindGroup = createBindGroupChecked(device, `anime4k/helper/ClampHighlights/${name}/clamp`, () => ({
      label: `${name} clamp bind group`,
      layout: clampBindGroupLayout,
      entries: [
        {
          binding: 0,
          resource: inputTexture.createView(),
        },
        {
          binding: 1,
          resource: this.statsYTexture.createView(),
        },
        {
          binding: 2,
          resource: this.outputTexture.createView(),
        },
      ],
    }));

    this.bindGroups = {
      luminationXBindGroup,
      luminationYBindGroup,
      clampBindGroup,
    };
  }

  updateParam(param: string, value: any): void {
    throw new Error(`${this.name} has no param.`);
  }

  pass(encoder: GPUCommandEncoder): void {
    const luminationXPass = encoder.beginComputePass();
    luminationXPass.setPipeline(this.pipelines.luminationXPipeline);
    luminationXPass.setBindGroup(0, this.bindGroups.luminationXBindGroup);
    luminationXPass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / 8),
      Math.ceil(this.outputTexture.height / 8),
    );
    luminationXPass.end();

    const luminationYPass = encoder.beginComputePass();
    luminationYPass.setPipeline(this.pipelines.luminationYPipeline);
    luminationYPass.setBindGroup(0, this.bindGroups.luminationYBindGroup);
    luminationYPass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / 8),
      Math.ceil(this.outputTexture.height / 8),
    );
    luminationYPass.end();

    const clampPass = encoder.beginComputePass();
    clampPass.setPipeline(this.pipelines.clampPipeline);
    clampPass.setBindGroup(0, this.bindGroups.clampBindGroup);
    clampPass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / 8),
      Math.ceil(this.outputTexture.height / 8),
    );
    clampPass.end();
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    releaseTexture(this.outputTexture);
    releaseTexture(this.statsXTexture);
    releaseTexture(this.statsYTexture);
  }
}


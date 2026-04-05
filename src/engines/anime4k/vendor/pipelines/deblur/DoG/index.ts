import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import luminationWGSL from './shaders/lumination.wgsl';
import deblurDoGXWGSL from './shaders/deblurDoGX.wgsl';
import deblurDoGYWGSL from './shaders/deblurDoGY.wgsl';
import deblurDoGApplyWGSL from './shaders/deblurDoGApply.wgsl';
import { createBindGroupChecked } from '../../../../../../core/gpu-resource-cache';

export class DoG implements Anime4KPipeline {
  textures: GPUTexture[];

  modules: GPUShaderModule[];

  bindGroupLayouts: GPUBindGroupLayout[];

  bindGroups: GPUBindGroup[];

  pipelineLayouts: GPUPipelineLayout[];

  pipelines: GPUComputePipeline[];

  strengthBuffer: GPUBuffer;

  inputTexWidth: number;

  inputTexHeight: number;

  inputTexture: GPUTexture;

  device: GPUDevice;

  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.device = device;
    this.inputTexWidth = inputTexture.width;
    this.inputTexHeight = inputTexture.height;
    this.inputTexture = inputTexture;

    // configure lumination pipeline
    const luminationBindGroupLayout = device.createBindGroupLayout({
      label: 'lumination Bind Group Layout',
      entries: [
        {
          binding: 0, // input frame as texture
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        },
        {
          binding: 1, // output texture
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    });

    const luminationModule = device.createShaderModule({
      label: 'lumination shader',
      code: luminationWGSL,
    });

    const luminationPipelineLayout = device.createPipelineLayout({
      label: 'lumination pipeline layout',
      bindGroupLayouts: [luminationBindGroupLayout],
    });

    const luminationPipeline = device.createComputePipeline({
      label: 'lumination pipeline',
      layout: luminationPipelineLayout,
      compute: {
        module: luminationModule,
        entryPoint: 'computeMain',
      },
    });

    // bind 1: output texture
    const luminationTexture = device.createTexture({
      size: [this.inputTexWidth, this.inputTexHeight, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    // configure deblurDoGX pipeline
    const deblurDoGXBindGroupLayout = device.createBindGroupLayout({
      label: 'deblurDoGX Bind Group Layout',
      entries: [
        {
          binding: 0, // input frame as texture
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        },
        {
          binding: 1, // output texture
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    });

    const deblurDoGXModule = device.createShaderModule({
      label: 'deblurDoGX shader',
      code: deblurDoGXWGSL,
    });

    const deblurDoGXPipelineLayout = device.createPipelineLayout({
      label: 'deblurDoGX pipeline layout',
      bindGroupLayouts: [deblurDoGXBindGroupLayout],
    });

    const deblurDoGXPipeline = device.createComputePipeline({
      label: 'deblurDoGX pipeline',
      layout: deblurDoGXPipelineLayout,
      compute: {
        module: deblurDoGXModule,
        entryPoint: 'computeMain',
      },
    });

    // bind 1: output texture
    const deblurDoGXTexture = device.createTexture({
      size: [this.inputTexWidth, this.inputTexHeight, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    // configure deblurDoGY pipeline
    const deblurDoGYBindGroupLayout = device.createBindGroupLayout({
      label: 'deblurDoGY Bind Group Layout',
      entries: [
        {
          binding: 0, // input frame as texture
          visibility: GPUShaderStage.COMPUTE,
          texture: {},
        },
        {
          binding: 1, // output texture
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
      ],
    });

    const deblurDoGYModule = device.createShaderModule({
      label: 'deblurDoGY shader',
      code: deblurDoGYWGSL,
    });

    const deblurDoGYPipelineLayout = device.createPipelineLayout({
      label: 'deblurDoGY pipeline layout',
      bindGroupLayouts: [deblurDoGYBindGroupLayout],
    });

    const deblurDoGYPipeline = device.createComputePipeline({
      label: 'deblurDoGY pipeline',
      layout: deblurDoGYPipelineLayout,
      compute: {
        module: deblurDoGYModule,
        entryPoint: 'computeMain',
      },
    });

    // bind 1: output texture
    const deblurDoGYTexture = device.createTexture({
      size: [this.inputTexWidth, this.inputTexHeight, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    // configure deblurDoGApply pipeline
    const deblurDoGApplyBindGroupLayout = device.createBindGroupLayout({
      label: 'deblurDoGApply Bind Group Layout',
      entries: [
        {
          binding: 0, // input frame as texture
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
          binding: 3, // output texture
          visibility: GPUShaderStage.COMPUTE,
          storageTexture: {
            access: 'write-only',
            format: 'rgba16float',
          },
        },
        {
          binding: 4,
          visibility: GPUShaderStage.COMPUTE,
          buffer: { type: 'uniform' },
        },
      ],
    });

    const deblurDoGApplyModule = device.createShaderModule({
      label: 'deblurDoGApply shader',
      code: deblurDoGApplyWGSL,
    });

    const deblurDoGApplyPipelineLayout = device.createPipelineLayout({
      label: 'deblurDoGApply pipeline layout',
      bindGroupLayouts: [deblurDoGApplyBindGroupLayout],
    });

    const deblurDoGApplyPipeline = device.createComputePipeline({
      label: 'deblurDoGApply pipeline',
      layout: deblurDoGApplyPipelineLayout,
      compute: {
        module: deblurDoGApplyModule,
        entryPoint: 'computeMain',
      },
    });

    // bind 1: output texture
    const deblurDoGApplyTexture = device.createTexture({
      size: [this.inputTexWidth, this.inputTexHeight, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    // gather all necessary information
    this.textures = [
      luminationTexture,
      deblurDoGXTexture,
      deblurDoGYTexture,
      deblurDoGApplyTexture,
    ];

    this.modules = [
      luminationModule,
      deblurDoGXModule,
      deblurDoGYModule,
      deblurDoGApplyModule,
    ];

    this.bindGroupLayouts = [
      luminationBindGroupLayout,
      deblurDoGXBindGroupLayout,
      deblurDoGYBindGroupLayout,
      deblurDoGApplyBindGroupLayout,
    ];

    this.pipelineLayouts = [
      luminationPipelineLayout,
      deblurDoGXPipelineLayout,
      deblurDoGYPipelineLayout,
      deblurDoGApplyPipelineLayout,
    ];

    this.pipelines = [
      luminationPipeline,
      deblurDoGXPipeline,
      deblurDoGYPipeline,
      deblurDoGApplyPipeline,
    ];

    // strength buffer
    this.strengthBuffer = device.createBuffer({
      size: 4,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    });

    // configure lumination pass
    const luminationBindGroup = createBindGroupChecked(this.device, 'anime4k/deblur/DoG/lumination-bind-group', () => ({
      layout: this.bindGroupLayouts[0],
      entries: [
        {
          binding: 0,
          resource: this.inputTexture.createView(),
        },
        {
          binding: 1,
          resource: this.textures[0].createView(),
        },
      ],
    }));

    // configure deblurDoGX pass
    const deblurDoGXBindGroup = createBindGroupChecked(this.device, 'anime4k/deblur/DoG/deblur-x-bind-group', () => ({
      layout: this.bindGroupLayouts[1],
      entries: [
        {
          binding: 0,
          resource: this.textures[0].createView(),
        },
        {
          binding: 1,
          resource: this.textures[1].createView(),
        },
      ],
    }));

    // configure deblurDoGY pass
    const deblurDoGYBindGroup = createBindGroupChecked(this.device, 'anime4k/deblur/DoG/deblur-y-bind-group', () => ({
      layout: this.bindGroupLayouts[2],
      entries: [
        {
          binding: 0,
          resource: this.textures[1].createView(),
        },
        {
          binding: 1,
          resource: this.textures[2].createView(),
        },
      ],
    }));

    // configure deblurDoGApply pass
    const deblurDoGApplyBindGroup = createBindGroupChecked(this.device, 'anime4k/deblur/DoG/apply-bind-group', () => ({
      layout: this.bindGroupLayouts[3],
      entries: [
        {
          binding: 0,
          resource: this.textures[2].createView(),
        },
        {
          binding: 1,
          resource: this.textures[0].createView(),
        },
        {
          binding: 2,
          resource: this.inputTexture.createView(),
        },
        {
          binding: 3,
          resource: this.textures[3].createView(),
        },
        {
          binding: 4,
          resource: {
            buffer: this.strengthBuffer,
          },
        },
      ],
    }));

    this.bindGroups = [
      luminationBindGroup,
      deblurDoGXBindGroup,
      deblurDoGYBindGroup,
      deblurDoGApplyBindGroup,
    ];
  }

  getOutputTexture() : GPUTexture {
    return this.textures[3];
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

  pass(encoder: GPUCommandEncoder) {
    // dispatch lumination pipeline
    const luminationPass = encoder.beginComputePass();
    luminationPass.setPipeline(this.pipelines[0]);
    luminationPass.setBindGroup(0, this.bindGroups[0]);
    luminationPass.dispatchWorkgroups(
      Math.ceil(this.inputTexWidth / 8),
      Math.ceil(this.inputTexHeight / 8),
    );
    luminationPass.end();

    // dispatch deblurDoGX pipeline
    const deblurDoGXPass = encoder.beginComputePass();
    deblurDoGXPass.setPipeline(this.pipelines[1]);
    deblurDoGXPass.setBindGroup(0, this.bindGroups[1]);
    deblurDoGXPass.dispatchWorkgroups(
      Math.ceil(this.inputTexWidth / 8),
      Math.ceil(this.inputTexHeight / 8),
    );
    deblurDoGXPass.end();

    // dispatch deblurDoGY pipeline
    const deblurDoGYPass = encoder.beginComputePass();
    deblurDoGYPass.setPipeline(this.pipelines[2]);
    deblurDoGYPass.setBindGroup(0, this.bindGroups[2]);
    deblurDoGYPass.dispatchWorkgroups(
      Math.ceil(this.inputTexWidth / 8),
      Math.ceil(this.inputTexHeight / 8),
    );
    deblurDoGYPass.end();

    // dispatch deblurDoGApply pipeline
    const deblurDoGApplyPass = encoder.beginComputePass();
    deblurDoGApplyPass.setPipeline(this.pipelines[3]);
    deblurDoGApplyPass.setBindGroup(0, this.bindGroups[3]);
    deblurDoGApplyPass.dispatchWorkgroups(
      Math.ceil(this.inputTexWidth / 8),
      Math.ceil(this.inputTexHeight / 8),
    );
    deblurDoGApplyPass.end();
  }

  destroy(): void {
    this.textures.forEach((texture) => {
      try {
        texture.destroy();
      } catch {
        // Ignore texture destruction errors during teardown.
      }
    });

    try {
      this.strengthBuffer.destroy();
    } catch {
      // Ignore buffer destruction errors during teardown.
    }
  }
}

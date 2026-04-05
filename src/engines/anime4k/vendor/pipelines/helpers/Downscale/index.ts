import { Anime4KPipeline, Anime4KPipelineDescriptor, DownscalePipelineDescriptor } from '../../interfaces';
import vertexWGSL from './shaders/vertex.wgsl';
import fragmentWGSL from './shaders/fragment.wgsl';
import { createBindGroupChecked } from '../../../../../../core/gpu-resource-cache';

export class Downscale implements Anime4KPipeline {
  outputTexture: GPUTexture;

  pipeline: GPURenderPipeline;

  bindGroup: GPUBindGroup;

  name: string;

  constructor({
    device,
    inputTexture,
    targetDimensions,
    name = 'downscale',
  }: DownscalePipelineDescriptor) {
    this.name = name;

    // output texture
    this.outputTexture = device.createTexture({
      label: `${name} output texture`,
      size: [targetDimensions.width, targetDimensions.height, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING
      | GPUTextureUsage.RENDER_ATTACHMENT
      | GPUTextureUsage.STORAGE_BINDING,
    });

    // modules
    const vertexModule = device.createShaderModule({
      label: 'vertex module',
      code: vertexWGSL,
    });

    const fragmentModule = device.createShaderModule({
      label: 'fragment module',
      code: fragmentWGSL,
    });

    const renderBindGroupLayout = device.createBindGroupLayout({
      label: 'Render Bind Group Layout',
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
    });

    const renderPipelineLayout = device.createPipelineLayout({
      label: `${name} pipeline layout`,
      bindGroupLayouts: [renderBindGroupLayout],
    });

    this.pipeline = device.createRenderPipeline({
      layout: renderPipelineLayout,
      vertex: {
        module: vertexModule,
        entryPoint: 'vert_main',
      },
      fragment: {
        module: fragmentModule,
        entryPoint: 'main',
        targets: [
          {
            format: 'rgba16float',
          },
        ],
      },
      primitive: {
        topology: 'triangle-list',
      },
    });

    const sampler = device.createSampler({
      magFilter: 'linear',
      minFilter: 'linear',
    });

    this.bindGroup = createBindGroupChecked(device, `anime4k/helper/Downscale/${name}/bind-group`, () => ({
      layout: renderBindGroupLayout,
      entries: [
        {
          binding: 1,
          resource: sampler,
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

  pass(encoder: GPUCommandEncoder): void {
    const pass = encoder.beginRenderPass({
      colorAttachments: [
        {
          view: this.outputTexture.createView(),
          clearValue: {
            r: 0.0, g: 0.0, b: 0.0, a: 1.0,
          },
          loadOp: 'clear' as GPULoadOp,
          storeOp: 'store' as GPUStoreOp,
        },
      ],
    });
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.draw(6);
    pass.end();
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

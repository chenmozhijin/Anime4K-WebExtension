import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateRenderPipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';

const compositeVertexWGSL = `
struct VertexOutput {
  @builtin(position) Position : vec4<f32>,
  @location(0) fragUV : vec2<f32>,
}

@vertex
fn vert_main(@builtin(vertex_index) VertexIndex : u32) -> VertexOutput {
  const pos = array(
    vec2( 1.0,  1.0),
    vec2( 1.0, -1.0),
    vec2(-1.0, -1.0),
    vec2( 1.0,  1.0),
    vec2(-1.0, -1.0),
    vec2(-1.0,  1.0),
  );

  const uv = array(
    vec2(1.0, 0.0),
    vec2(1.0, 1.0),
    vec2(0.0, 1.0),
    vec2(1.0, 0.0),
    vec2(0.0, 1.0),
    vec2(0.0, 0.0),
  );

  var output : VertexOutput;
  output.Position = vec4(pos[VertexIndex], 0.0, 1.0);
  output.fragUV = uv[VertexIndex];
  return output;
}
`;

export interface RenderCompositePassDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  outputSize: { width: number; height: number };
  fragmentWGSL: string;
  name?: string;
  cacheKeyPrefix?: string;
  samplerKey?: string;
  outputFormat?: GPUTextureFormat;
  outputUsage?: GPUTextureUsageFlags;
}

function hashString(value: string): string {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(16).padStart(8, '0');
}

export class RenderCompositePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  readonly outputTexture: GPUTexture;

  readonly pipeline: GPURenderPipeline;

  readonly bindGroup: GPUBindGroup;

  readonly name: string;

  constructor({
    device,
    inputTextures,
    outputSize,
    fragmentWGSL,
    name = 'render composite',
    cacheKeyPrefix = 'core/gpu-passes/RenderCompositePass',
    samplerKey = `${cacheKeyPrefix}/sampler/linear-linear`,
    outputFormat = 'rgba16float',
    outputUsage = GPUTextureUsage.TEXTURE_BINDING
      | GPUTextureUsage.RENDER_ATTACHMENT
      | GPUTextureUsage.STORAGE_BINDING,
  }: RenderCompositePassDescriptor) {
    if (!fragmentWGSL) {
      throw Error(`${name}: shader not defined.`);
    }
    this.name = name;
    this.profileLabel = name;
    const inputLength = inputTextures.length;
    const fragmentHash = hashString(fragmentWGSL);

    this.outputTexture = borrowTexture({
      device,
      width: outputSize.width,
      height: outputSize.height,
      format: outputFormat,
      usage: outputUsage,
      labelGroup: `${cacheKeyPrefix}/output/${inputLength}`,
      label: `${name}: output texture`,
    });

    const vertexModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/shader/vertex`, () => ({
      label: `${name}: vertex module`,
      code: compositeVertexWGSL,
    }));
    const fragmentModule = getOrCreateShaderModule(device, `${cacheKeyPrefix}/shader/fragment/${fragmentHash}`, () => ({
      label: `${name}: fragment module`,
      code: fragmentWGSL,
    }));

    const bindGroupLayoutEntries: GPUBindGroupLayoutEntry[] = [{
      binding: 0,
      visibility: GPUShaderStage.FRAGMENT,
      sampler: {},
    }];
    for (let i = 1; i <= inputLength; i += 1) {
      bindGroupLayoutEntries.push({
        binding: i,
        visibility: GPUShaderStage.FRAGMENT,
        texture: {},
      });
    }
    const bindGroupLayout = getOrCreateBindGroupLayout(device, `${cacheKeyPrefix}/layout/${inputLength}`, () => ({
      label: `${name}: bind group layout`,
      entries: bindGroupLayoutEntries,
    }));

    this.pipeline = getOrCreateRenderPipeline(device, `${cacheKeyPrefix}/pipeline/${fragmentHash}/${inputLength}/${outputFormat}`, () => ({
      layout: device.createPipelineLayout({
        label: `${name}: pipeline layout`,
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

    const sampler = getOrCreateSampler(device, samplerKey, () => ({
      magFilter: 'linear',
      minFilter: 'linear',
    }));

    const bindGroupEntries: GPUBindGroupEntry[] = [{
      binding: 0,
      resource: sampler,
    }];
    for (let i = 1; i <= inputLength; i += 1) {
      bindGroupEntries.push({
        binding: i,
        resource: inputTextures[i - 1].createView(),
      });
    }
    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/${name}/bind-group`, () => ({
      label: `${name}: bind group`,
      layout: bindGroupLayout,
      entries: bindGroupEntries,
    }));
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
      colorAttachments: [{
        view: this.outputTexture.createView(),
        clearValue: {
          r: 0.0,
          g: 0.0,
          b: 0.0,
          a: 1.0,
        },
        loadOp: 'clear',
        storeOp: 'store',
      }],
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

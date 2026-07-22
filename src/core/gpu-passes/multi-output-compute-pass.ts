import type { Dimensions } from '../../types';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { ComputeTexturePass } from './compute-texture-pass';

interface MultiOutputComputePassOptions {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  outputTextures: GPUTexture[];
  shaderWGSL: string;
  baselineShaders: string[];
  name: string;
  cacheKeyPrefix: string;
  outputSize: Dimensions;
  workgroupSize?: Dimensions;
  optimized: boolean;
}

function shaderFingerprint(shaderWGSL: string): string {
  let hash = 2166136261;
  for (let index = 0; index < shaderWGSL.length; index += 1) {
    hash ^= shaderWGSL.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return (hash >>> 0).toString(16);
}

class FusedMultiOutputComputePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  private readonly pipeline: GPUComputePipeline;
  private readonly bindGroup: GPUBindGroup;
  private readonly outputTextures: GPUTexture[];
  private readonly outputSize: Dimensions;
  private readonly workgroupSize: Dimensions;

  constructor(options: Omit<MultiOutputComputePassOptions, 'baselineShaders' | 'optimized'>) {
    const {
      device,
      inputTextures,
      outputTextures,
      shaderWGSL,
      name,
      cacheKeyPrefix,
      outputSize,
      workgroupSize = { width: 8, height: 8 },
    } = options;
    this.profileLabel = name;
    this.outputTextures = outputTextures;
    this.outputSize = outputSize;
    this.workgroupSize = workgroupSize;
    const fingerprint = shaderFingerprint(shaderWGSL);
    const includeSampler = shaderWGSL.includes('var anime4kLinearSampler: sampler;');
    const samplerBinding = inputTextures.length + outputTextures.length;
    const shaderModule = getOrCreateShaderModule(
      device,
      `${cacheKeyPrefix}/shader/${inputTextures.length}/${outputTextures.length}/${fingerprint}`,
      () => ({ label: `${name}: multi-output shader`, code: shaderWGSL }),
    );
    const layoutKey = `${inputTextures.length}/${outputTextures.length}/${includeSampler ? 'sampler' : 'no-sampler'}`;
    const bindGroupLayout = getOrCreateBindGroupLayout(
      device,
      `${cacheKeyPrefix}/layout/${layoutKey}`,
      () => ({
        label: `${name}: multi-output layout`,
        entries: [
          ...inputTextures.map((_, binding): GPUBindGroupLayoutEntry => ({
            binding,
            visibility: GPUShaderStage.COMPUTE,
            texture: {},
          })),
          ...outputTextures.map((_, index): GPUBindGroupLayoutEntry => ({
            binding: inputTextures.length + index,
            visibility: GPUShaderStage.COMPUTE,
            storageTexture: { access: 'write-only', format: 'rgba16float' },
          })),
          ...(includeSampler ? [{
            binding: samplerBinding,
            visibility: GPUShaderStage.COMPUTE,
            sampler: { type: 'filtering' },
          } satisfies GPUBindGroupLayoutEntry] : []),
        ],
      }),
    );
    this.pipeline = getOrCreateComputePipeline(
      device,
      `${cacheKeyPrefix}/pipeline/${layoutKey}/${fingerprint}`,
      () => ({
        label: `${name}: multi-output pipeline`,
        layout: device.createPipelineLayout({ bindGroupLayouts: [bindGroupLayout] }),
        compute: { module: shaderModule, entryPoint: 'computeMain' },
      }),
    );
    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/${name}/bind-group`, () => ({
      label: `${name}: multi-output bind group`,
      layout: bindGroupLayout,
      entries: [
        ...inputTextures.map((texture, binding): GPUBindGroupEntry => ({
          binding,
          resource: texture.createView(),
        })),
        ...outputTextures.map((texture, index): GPUBindGroupEntry => ({
          binding: inputTextures.length + index,
          resource: texture.createView(),
        })),
        ...(includeSampler ? [{
          binding: samplerBinding,
          resource: getOrCreateSampler(device, `${cacheKeyPrefix}/sampler/linear-clamp`, () => ({
            addressModeU: 'clamp-to-edge',
            addressModeV: 'clamp-to-edge',
            magFilter: 'linear',
            minFilter: 'linear',
          })),
        } satisfies GPUBindGroupEntry] : []),
      ],
    }));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    if (profile) {
      profile.recordPass(this, () => this.encode(encoder, profile));
      return;
    }
    this.encode(encoder);
  }

  getOutputTexture(): GPUTexture {
    return this.outputTextures[0];
  }

  private encode(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    const pass = encoder.beginComputePass(profile?.createComputePassDescriptor?.(this));
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.dispatchWorkgroups(
      Math.ceil(this.outputSize.width / this.workgroupSize.width),
      Math.ceil(this.outputSize.height / this.workgroupSize.height),
    );
    pass.end();
  }
}

export class MultiOutputComputePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  private readonly pipelines: PipelinePass[];
  private readonly outputTextures: GPUTexture[];

  constructor(options: MultiOutputComputePassOptions) {
    this.profileLabel = options.name;
    this.outputTextures = options.outputTextures;
    if (options.outputTextures.length !== options.baselineShaders.length) {
      throw new Error(`${options.name}: output and baseline shader counts differ.`);
    }
    // Fused and baseline paths write the same independent rgba16float outputs. This
    // preserves per-branch quantization while sharing input reads and dispatch setup.
    this.pipelines = options.optimized
      ? [new FusedMultiOutputComputePass(options)]
      : options.baselineShaders.map((shaderWGSL, index) => new ComputeTexturePass({
        device: options.device,
        inputTextures: options.inputTextures,
        outputTexture: options.outputTextures[index],
        shaderWGSL,
        name: `${options.name} branch ${index}`,
        cacheKeyPrefix: `${options.cacheKeyPrefix}/baseline`,
        outputSize: options.outputSize,
        includeSampler: true,
      }));
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.pipelines.forEach(pipeline => pipeline.pass(encoder, profile));
  }

  getOutputTexture(): GPUTexture {
    return this.outputTextures[0];
  }

  getProfileChildren(): PipelinePass[] {
    return this.pipelines;
  }

  destroy(): void {
    this.pipelines.forEach(pipeline => pipeline.destroy?.());
  }
}

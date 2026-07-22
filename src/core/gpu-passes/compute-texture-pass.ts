import type { Dimensions } from '../../types';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateComputePipelineAsync,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../texture-pool';

export interface ComputeTexturePassOptions {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  shaderWGSL: string;
  name: string;
  cacheKeyPrefix: string;
  outputSize?: Dimensions;
  outputFormat?: GPUTextureFormat;
  outputUsage?: GPUTextureUsageFlags;
  outputTexture?: GPUTexture;
  includeSampler?: boolean;
  samplerBindingOrder?: 'before-output' | 'after-output';
  samplerKey?: string;
  samplerDescriptor?: GPUSamplerDescriptor;
  workgroupSize?: Dimensions;
  dispatchSize?: Dimensions;
  entryPoint?: string;
  extraLayoutEntries?: GPUBindGroupLayoutEntry[];
  extraBindGroupEntries?: GPUBindGroupEntry[];
  extraLayoutKey?: string;
}

export interface ComputeTexturePipelinePreparationOptions {
  device: GPUDevice;
  inputTextureCount: number;
  shaderWGSL: string;
  name: string;
  cacheKeyPrefix: string;
  outputFormat?: GPUTextureFormat;
  includeSampler?: boolean;
  samplerBindingOrder?: 'before-output' | 'after-output';
  entryPoint?: string;
  extraLayoutEntries?: GPUBindGroupLayoutEntry[];
  extraLayoutKey?: string;
}

function getShaderFingerprint(shaderWGSL: string): string {
  let hash = 2166136261;
  for (let i = 0; i < shaderWGSL.length; i += 1) {
    hash ^= shaderWGSL.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }

  return (hash >>> 0).toString(16);
}

function createPipelineResources({
  device,
  inputTextureCount,
  shaderWGSL,
  name,
  cacheKeyPrefix,
  outputFormat = 'rgba16float',
  includeSampler = false,
  samplerBindingOrder = 'after-output',
  entryPoint = 'computeMain',
  extraLayoutEntries = [],
  extraLayoutKey,
}: ComputeTexturePipelinePreparationOptions): {
  bindGroupLayout: GPUBindGroupLayout;
  outputBinding: number;
  samplerBinding: number;
  pipelineKey: string;
  pipelineDescriptorFactory: () => GPUComputePipelineDescriptor;
} {
  if (inputTextureCount <= 0) {
    throw new Error(`${name}: no input textures.`);
  }
  if (!shaderWGSL) {
    throw new Error(`${name}: shader not defined.`);
  }

  const samplerBinding = samplerBindingOrder === 'before-output' ? inputTextureCount : inputTextureCount + 1;
  const outputBinding = samplerBindingOrder === 'before-output' ? inputTextureCount + 1 : inputTextureCount;
  const reservedBindings = new Set([
    ...Array.from({ length: inputTextureCount }, (_, index) => index),
    outputBinding,
    ...(includeSampler ? [samplerBinding] : []),
  ]);
  const duplicateExtraBinding = extraLayoutEntries.find(entry => reservedBindings.has(entry.binding));
  if (duplicateExtraBinding) {
    throw new Error(`${name}: extra layout binding ${duplicateExtraBinding.binding} conflicts with built-in bindings.`);
  }

  const shaderFingerprint = getShaderFingerprint(shaderWGSL);
  const resolvedExtraLayoutKey = extraLayoutEntries.length > 0
    ? extraLayoutKey ?? `extra-${extraLayoutEntries.map(entry => entry.binding).join('-')}`
    : 'no-extra';
  const shaderModule = getOrCreateShaderModule(
    device,
    `${cacheKeyPrefix}/shader/${inputTextureCount}/${shaderFingerprint}`,
    () => ({ label: `${name}: compute shader`, code: shaderWGSL }),
  );
  const layoutEntries: GPUBindGroupLayoutEntry[] = [
    ...Array.from({ length: inputTextureCount }, (_, index): GPUBindGroupLayoutEntry => ({
      binding: index,
      visibility: GPUShaderStage.COMPUTE,
      texture: {},
    })),
    {
      binding: outputBinding,
      visibility: GPUShaderStage.COMPUTE,
      storageTexture: { access: 'write-only', format: outputFormat },
    },
  ];
  if (includeSampler) {
    layoutEntries.push({
      binding: samplerBinding,
      visibility: GPUShaderStage.COMPUTE,
      sampler: { type: 'filtering' },
    });
  }
  layoutEntries.push(...extraLayoutEntries);
  const bindGroupLayout = getOrCreateBindGroupLayout(
    device,
    `${cacheKeyPrefix}/layout/${inputTextureCount}/${includeSampler ? samplerBindingOrder : 'no-sampler'}/${outputFormat}/${resolvedExtraLayoutKey}`,
    () => ({ label: `${name}: compute bind group layout`, entries: layoutEntries }),
  );
  const pipelineKey = `${cacheKeyPrefix}/pipeline/${inputTextureCount}/${includeSampler ? samplerBindingOrder : 'no-sampler'}/${shaderFingerprint}/${resolvedExtraLayoutKey}`;
  return {
    bindGroupLayout,
    outputBinding,
    samplerBinding,
    pipelineKey,
    pipelineDescriptorFactory: () => ({
      label: `${name}: compute pipeline`,
      layout: device.createPipelineLayout({
        label: `${name}: compute pipeline layout`,
        bindGroupLayouts: [bindGroupLayout],
      }),
      compute: { module: shaderModule, entryPoint },
    }),
  };
}

export class ComputeTexturePass implements PipelinePass {
  readonly profileLabel: string;

  profileGroup?: string;

  readonly outputTexture: GPUTexture;

  readonly pipeline: GPUComputePipeline;

  readonly bindGroup: GPUBindGroup;

  private readonly dispatchDimensions: Dimensions;

  private readonly workgroupSize: Dimensions;

  private readonly ownsOutputTexture: boolean;

  static async preparePipeline(options: ComputeTexturePipelinePreparationOptions): Promise<void> {
    const resources = createPipelineResources(options);
    await getOrCreateComputePipelineAsync(
      options.device,
      resources.pipelineKey,
      resources.pipelineDescriptorFactory,
    );
  }

  constructor({
    device,
    inputTextures,
    shaderWGSL,
    name,
    cacheKeyPrefix,
    outputSize,
    outputFormat = 'rgba16float',
    outputUsage = GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    outputTexture,
    includeSampler = false,
    samplerBindingOrder = 'after-output',
    samplerKey = `${cacheKeyPrefix}/sampler/linear-clamp`,
    samplerDescriptor = {
      addressModeU: 'clamp-to-edge',
      addressModeV: 'clamp-to-edge',
      magFilter: 'linear',
      minFilter: 'linear',
    },
    workgroupSize = { width: 8, height: 8 },
    dispatchSize,
    entryPoint = 'computeMain',
    extraLayoutEntries = [],
    extraBindGroupEntries = [],
    extraLayoutKey,
  }: ComputeTexturePassOptions) {
    this.profileLabel = name;

    const inputLength = inputTextures.length;
    const resolvedOutputSize = outputSize ?? {
      width: inputTextures[0].width,
      height: inputTextures[0].height,
    };
    this.dispatchDimensions = dispatchSize ?? resolvedOutputSize;
    this.workgroupSize = workgroupSize;

    this.ownsOutputTexture = !outputTexture;
    this.outputTexture = outputTexture ?? borrowTexture({
        device,
        width: resolvedOutputSize.width,
        height: resolvedOutputSize.height,
        format: outputFormat,
        usage: outputUsage,
        labelGroup: `${cacheKeyPrefix}/output/${inputLength}`,
        label: `${name}: output texture`,
      });
    if (outputTexture && (
      this.outputTexture.width !== resolvedOutputSize.width
      || this.outputTexture.height !== resolvedOutputSize.height
    )) {
      throw new Error(`${name}: preallocated output texture has incorrect dimensions.`);
    }

    const samplerBinding = samplerBindingOrder === 'before-output' ? inputLength : inputLength + 1;
    const outputBinding = samplerBindingOrder === 'before-output' ? inputLength + 1 : inputLength;
    const reservedBindings = new Set([
      ...inputTextures.map((_, index) => index),
      outputBinding,
      ...(includeSampler ? [samplerBinding] : []),
    ]);
    const duplicateExtraBinding = extraLayoutEntries.find(entry => reservedBindings.has(entry.binding));
    if (duplicateExtraBinding) {
      throw new Error(`${name}: extra layout binding ${duplicateExtraBinding.binding} conflicts with built-in bindings.`);
    }
    const extraResourceBindings = new Set(extraBindGroupEntries.map(entry => entry.binding));
    const missingExtraResource = extraLayoutEntries.find(entry => !extraResourceBindings.has(entry.binding));
    if (missingExtraResource) {
      throw new Error(`${name}: extra bind group entry missing for binding ${missingExtraResource.binding}.`);
    }
    const resources = createPipelineResources({
      device,
      inputTextureCount: inputLength,
      shaderWGSL,
      name,
      cacheKeyPrefix,
      outputFormat,
      includeSampler,
      samplerBindingOrder,
      entryPoint,
      extraLayoutEntries,
      extraLayoutKey,
    });

    this.pipeline = getOrCreateComputePipeline(
      device,
      resources.pipelineKey,
      resources.pipelineDescriptorFactory,
    );

    const bindGroupEntries: GPUBindGroupEntry[] = [
      ...inputTextures.map((texture, index): GPUBindGroupEntry => ({
        binding: index,
        resource: texture.createView(),
      })),
      {
        binding: resources.outputBinding,
        resource: this.outputTexture.createView(),
      },
    ];

    if (includeSampler) {
      bindGroupEntries.push({
        binding: resources.samplerBinding,
        resource: getOrCreateSampler(device, samplerKey, () => samplerDescriptor),
      });
    }
    bindGroupEntries.push(...extraBindGroupEntries);

    this.bindGroup = createBindGroupChecked(device, `${cacheKeyPrefix}/${name}/bind-group`, () => ({
      label: `${name}: compute bind group`,
      layout: resources.bindGroupLayout,
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
    const pass = encoder.beginComputePass(profile?.createComputePassDescriptor?.(this));
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.dispatchWorkgroups(
      Math.ceil(this.dispatchDimensions.width / this.workgroupSize.width),
      Math.ceil(this.dispatchDimensions.height / this.workgroupSize.height),
    );
    pass.end();
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    if (this.ownsOutputTexture) {
      releaseTexture(this.outputTexture);
    }
  }
}

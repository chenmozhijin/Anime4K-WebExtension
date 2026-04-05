import { Anime4KPipeline, Conv2dPipelineDescriptor } from '../../interfaces';
import {
  createBindGroupChecked,
  getOrCreateBindGroupLayout,
  getOrCreateComputePipeline,
  getOrCreateShaderModule,
} from '../../../../../../core/gpu-resource-cache';
import { borrowTexture, releaseTexture } from '../../../../../../core/texture-pool';

function getShaderFingerprint(shaderWGSL: string): string {
  let hash = 2166136261;
  for (let i = 0; i < shaderWGSL.length; i += 1) {
    hash ^= shaderWGSL.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }

  return (hash >>> 0).toString(16);
}

/**
 * Conv2d pipeline
 *    Takes in n input textures output texture. All input textures and output texture
 * have the same dimensions.
*/
export class Conv2d implements Anime4KPipeline {
  outputTexture: GPUTexture;

  pipeline: GPUComputePipeline;

  bindGroup: GPUBindGroup;

  name: string;

  /**
   * Creates an instance of Conv2d.
   *
   * @param {Object} options - The options for the Conv2d pipeline.
   * @param {GPUDevice} options.device - The GPU device to use for
   * creating textures and shader modules.
   * @param {GPUTexture[]} options.inputTextures - The input textures for the pipeline.
   * All input textures must have the same dimensions.
   * @param {string} options.shaderWGSL - The shader code in WGSL format.
   * @param {string} [options.name='conv2d'] - The name of the pipeline. Defaults to 'conv2d'.
   *
   * @throws {Error} Will throw an error if no input textures are provided.
   * @throws {Error} Will throw an error if the shader is not defined.
   */
  constructor({
    device,
    inputTextures,
    shaderWGSL,
    name = 'conv2d',
  }: Conv2dPipelineDescriptor) {
    this.name = name;
    const inputLength = inputTextures.length;
    if (inputLength === 0) {
      throw Error(`${name}: 0 input textures for conv2d.`);
    }

    if (shaderWGSL === undefined) {
      throw Error(`${name}: shader not defined.`);
    }

    const shaderFingerprint = getShaderFingerprint(shaderWGSL);

    // input textures and output texture must have the same dimensions,
    // so the output size are assigned the same dimension as the first input
    // texture.
    this.outputTexture = borrowTexture({
      device,
      width: inputTextures[0].width,
      height: inputTextures[0].height,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: `anime4k/helper/Conv2d/output/${inputLength}`,
      label: `${name}: conv2d_texture`,
    });
    const shaderModule = getOrCreateShaderModule(device, `anime4k/helper/Conv2d/shader/${inputLength}/${shaderFingerprint}`, () => ({
      label: `${name}: conv2dModule`,
      code: shaderWGSL,
    }));

    // BindGroupLayout
    const bindGroupLayoutEntries: GPUBindGroupLayoutEntry[] = [];
    for (let i = 0; i < inputLength; i += 1) {
      bindGroupLayoutEntries.push({
        binding: i,
        visibility: GPUShaderStage.COMPUTE,
        texture: {},
      });
    }
    bindGroupLayoutEntries.push({
      binding: inputLength,
      visibility: GPUShaderStage.COMPUTE,
      storageTexture: {
        access: 'write-only',
        format: 'rgba16float',
      },
    });
    const bindGroupLayout = getOrCreateBindGroupLayout(device, `anime4k/helper/Conv2d/layout/${inputLength}`, () => ({
      label: `${name}: ${inputLength} to 1 convolution bind group layout`,
      entries: bindGroupLayoutEntries,
    }));

    // BindGroup
    const bindGroupEntries: GPUBindGroupEntry[] = [];
    for (let i = 0; i < inputLength; i += 1) {
      bindGroupEntries.push({
        binding: i,
        resource: inputTextures[i].createView(),
      });
    }
    bindGroupEntries.push({
      binding: inputLength,
      resource: this.outputTexture.createView(),
    });
    this.bindGroup = createBindGroupChecked(device, `anime4k/helper/Conv2d/${name}/bind-group`, () => ({
      label: `${name}: bind group`,
      layout: bindGroupLayout,
      entries: bindGroupEntries,
    }));

    // Pipeline Layout
    // Pipeline
    this.pipeline = getOrCreateComputePipeline(device, `anime4k/helper/Conv2d/pipeline/${inputLength}/${shaderFingerprint}`, () => ({
      label: `${name}: pipeline`,
      layout: device.createPipelineLayout({
        label: `${name}: pipeline layout`,
        bindGroupLayouts: [bindGroupLayout],
      }),
      compute: {
        module: shaderModule,
        entryPoint: 'computeMain',
      },
    }));
  }

  updateParam(param: string, value: any): void {
    throw new Error('Method not implemented.');
  }

  pass(encoder: GPUCommandEncoder): void {
    const pass = encoder.beginComputePass();
    pass.setPipeline(this.pipeline);
    pass.setBindGroup(0, this.bindGroup);
    pass.dispatchWorkgroups(
      Math.ceil(this.outputTexture.width / 8),
      Math.ceil(this.outputTexture.height / 8),
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

import { describe, expect, it, vi } from 'vitest';
import { clearGpuResourceCache } from '../../src/core/gpu-resource-cache';
import { clearTexturePool } from '../../src/core/texture-pool';
import { Conv2d } from '../../src/engines/anime4k/vendor/pipelines/helpers/Conv2d';
import { createWebGpuMock } from '../support/webgpu';

const shaderVariantA = `
@group(0) @binding(0) var inputTex: texture_2d<f32>;
@group(0) @binding(1) var outputTex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dimensions = textureDimensions(outputTex);
  if (pixel.x >= dimensions.x || pixel.y >= dimensions.y) {
    return;
  }

  textureStore(outputTex, pixel.xy, vec4f(1.0));
}
`;

const shaderVariantB = `
@group(0) @binding(0) var inputTex: texture_2d<f32>;
@group(0) @binding(1) var outputTex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dimensions = textureDimensions(outputTex);
  if (pixel.x >= dimensions.x || pixel.y >= dimensions.y) {
    return;
  }

  textureStore(outputTex, pixel.xy, vec4f(0.5));
}
`;

describe('Conv2d cache keys', () => {
  it('does not reuse shader or pipeline cache entries for different WGSL with the same pass name', () => {
    const { device } = createWebGpuMock();
    const gpuDevice = device as unknown as GPUDevice;
    const createShaderModuleSpy = vi.spyOn(device, 'createShaderModule');
    const createComputePipelineSpy = vi.spyOn(device, 'createComputePipeline');

    const inputTexture = gpuDevice.createTexture({
      size: [64, 64, 1],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const pipelineA = new Conv2d({
      device: gpuDevice,
      inputTextures: [inputTexture],
      shaderWGSL: shaderVariantA,
      name: 'shared-pass-name',
    });

    const pipelineB = new Conv2d({
      device: gpuDevice,
      inputTextures: [inputTexture],
      shaderWGSL: shaderVariantB,
      name: 'shared-pass-name',
    });

    expect(createShaderModuleSpy).toHaveBeenCalledTimes(2);
    expect(createComputePipelineSpy).toHaveBeenCalledTimes(2);
    expect(pipelineA.pipeline).not.toBe(pipelineB.pipeline);

    pipelineA.destroy();
    pipelineB.destroy();
    clearTexturePool(gpuDevice);
    clearGpuResourceCache(gpuDevice);
  });
});

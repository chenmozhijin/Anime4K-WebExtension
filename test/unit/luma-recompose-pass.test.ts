import { beforeEach, describe, expect, it, vi } from 'vitest';

const { cacheCalls, borrowTextureMock, releaseTextureMock } = vi.hoisted(() => ({
  cacheCalls: {
    shaderModules: [] as string[],
    bindGroupLayouts: [] as string[],
    pipelines: [] as string[],
    samplers: [] as string[],
    bindGroups: [] as string[],
  },
  borrowTextureMock: vi.fn(),
  releaseTextureMock: vi.fn(),
}));

vi.mock('../../src/core/gpu-resource-cache', () => ({
  getOrCreateShaderModule: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.shaderModules.push(key);
    return create();
  }),
  getOrCreateBindGroupLayout: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.bindGroupLayouts.push(key);
    return create();
  }),
  getOrCreateComputePipeline: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.pipelines.push(key);
    return create();
  }),
  getOrCreateSampler: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.samplers.push(key);
    return create();
  }),
  createBindGroupChecked: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.bindGroups.push(key);
    return create();
  }),
}));

vi.mock('../../src/core/texture-pool', () => ({
  borrowTexture: borrowTextureMock,
  releaseTexture: releaseTextureMock,
}));

import { LumaRecomposePass } from '../../src/core/gpu-passes/luma-recompose-pass';

describe('LumaRecomposePass', () => {
  beforeEach(() => {
    cacheCalls.shaderModules.length = 0;
    cacheCalls.bindGroupLayouts.length = 0;
    cacheCalls.pipelines.length = 0;
    cacheCalls.samplers.length = 0;
    cacheCalls.bindGroups.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
  });

  it('builds cached compute resources, dispatches, and releases output texture', () => {
    const outputTexture = {
      width: 224,
      height: 96,
      createView: vi.fn(() => ({ label: 'output-view' })),
    } as unknown as GPUTexture;
    const sourceTexture = {
      createView: vi.fn(() => ({ label: 'source-view' })),
    } as unknown as GPUTexture;
    const lumaTexture = {
      createView: vi.fn(() => ({ label: 'luma-view' })),
    } as unknown as GPUTexture;
    const setPipeline = vi.fn();
    const setBindGroup = vi.fn();
    const dispatchWorkgroups = vi.fn();
    const end = vi.fn();
    const beginComputePass = vi.fn(() => ({
      setPipeline,
      setBindGroup,
      dispatchWorkgroups,
      end,
    }));
    const device = {
      createPipelineLayout: vi.fn(descriptor => descriptor),
    } as unknown as GPUDevice;

    borrowTextureMock.mockReturnValue(outputTexture);

    const pass = new LumaRecomposePass({
      device,
      sourceTexture,
      lumaTexture,
      outputSize: { width: 224, height: 96 },
      name: 'luma-test',
      cacheKeyPrefix: 'test/luma',
      shaderWGSL: '@compute @workgroup_size(1, 1) fn computeMain() {}',
      workgroupSize: { width: 12, height: 16 },
    });

    pass.pass({ beginComputePass } as unknown as GPUCommandEncoder);

    expect(cacheCalls.shaderModules).toEqual(['test/luma/output-recompose/shader/main']);
    expect(cacheCalls.bindGroupLayouts).toEqual(['test/luma/output-recompose/layout/main']);
    expect(cacheCalls.pipelines).toEqual(['test/luma/output-recompose/pipeline/main']);
    expect(cacheCalls.samplers).toEqual(['test/luma/output-recompose/sampler/linear']);
    expect(cacheCalls.bindGroups).toEqual(['test/luma/output-recompose/luma-test/bind-group']);
    expect(borrowTextureMock).toHaveBeenCalledWith(expect.objectContaining({
      width: 224,
      height: 96,
      labelGroup: 'test/luma/output-recompose/output',
    }));
    expect(sourceTexture.createView).toHaveBeenCalledTimes(1);
    expect(lumaTexture.createView).toHaveBeenCalledTimes(1);
    expect(outputTexture.createView).toHaveBeenCalledTimes(1);
    expect(dispatchWorkgroups).toHaveBeenCalledWith(19, 6);
    expect(pass.getOutputTexture()).toBe(outputTexture);

    pass.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });
});

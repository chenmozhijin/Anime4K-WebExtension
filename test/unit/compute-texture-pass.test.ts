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

import { ComputeTexturePass } from '../../src/core/gpu-passes/compute-texture-pass';

describe('ComputeTexturePass', () => {
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
      createView: vi.fn(() => ({ label: 'output-view' })),
    } as unknown as GPUTexture;
    const inputTexture = {
      width: 64,
      height: 32,
      createView: vi.fn(() => ({ label: 'input-view' })),
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

    const pipeline = new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: '@compute @workgroup_size(8, 8) fn computeMain() {}',
      name: 'test-compute',
      cacheKeyPrefix: 'test/compute',
      includeSampler: true,
      outputSize: { width: 32, height: 16 },
      dispatchSize: { width: 64, height: 32 },
    });

    pipeline.pass({ beginComputePass } as unknown as GPUCommandEncoder);

    expect(cacheCalls.shaderModules[0]).toMatch(/^test\/compute\/shader\/1\//);
    expect(cacheCalls.bindGroupLayouts).toEqual(['test/compute/layout/1/after-output/rgba16float/no-extra']);
    expect(cacheCalls.pipelines[0]).toMatch(/^test\/compute\/pipeline\/1\/after-output\/[0-9a-f]+\/no-extra$/);
    expect(cacheCalls.samplers).toEqual(['test/compute/sampler/linear-clamp']);
    expect(cacheCalls.bindGroups).toEqual(['test/compute/test-compute/bind-group']);
    expect(borrowTextureMock).toHaveBeenCalledWith(expect.objectContaining({
      width: 32,
      height: 16,
      labelGroup: 'test/compute/output/1',
    }));
    expect(inputTexture.createView).toHaveBeenCalledTimes(1);
    expect(outputTexture.createView).toHaveBeenCalledTimes(1);
    expect(dispatchWorkgroups).toHaveBeenCalledWith(8, 4);
    expect(pipeline.getOutputTexture()).toBe(outputTexture);

    pipeline.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });

  it('adds extra layout and bind group entries for uniform buffers', () => {
    const outputTexture = {
      createView: vi.fn(() => ({ label: 'output-view' })),
    } as unknown as GPUTexture;
    const inputTexture = {
      width: 16,
      height: 8,
      createView: vi.fn(() => ({ label: 'input-view' })),
    } as unknown as GPUTexture;
    const uniformBuffer = { label: 'uniform-buffer' } as unknown as GPUBuffer;
    const device = {
      createPipelineLayout: vi.fn(descriptor => descriptor),
    } as unknown as GPUDevice;

    borrowTextureMock.mockReturnValue(outputTexture);

    new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: '@compute @workgroup_size(8, 8) fn denoiseMain() {}',
      name: 'test-extra',
      cacheKeyPrefix: 'test/extra',
      entryPoint: 'denoiseMain',
      extraLayoutKey: 'uniforms-2',
      extraLayoutEntries: [{
        binding: 2,
        visibility: GPUShaderStage.COMPUTE,
        buffer: { type: 'uniform' },
      }],
      extraBindGroupEntries: [{
        binding: 2,
        resource: { buffer: uniformBuffer },
      }],
    });

    expect(cacheCalls.bindGroupLayouts).toEqual(['test/extra/layout/1/no-sampler/rgba16float/uniforms-2']);
    expect(cacheCalls.pipelines[0]).toMatch(/^test\/extra\/pipeline\/1\/no-sampler\/[0-9a-f]+\/uniforms-2$/);
  });

  it('rejects extra entries that collide with built-in bindings', () => {
    const inputTexture = {
      width: 16,
      height: 8,
      createView: vi.fn(),
    } as unknown as GPUTexture;
    const device = {} as GPUDevice;

    expect(() => new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: '@compute @workgroup_size(8, 8) fn computeMain() {}',
      name: 'bad-extra',
      cacheKeyPrefix: 'test/bad-extra',
      extraLayoutEntries: [{
        binding: 1,
        visibility: GPUShaderStage.COMPUTE,
        buffer: { type: 'uniform' },
      }],
    })).toThrow('bad-extra: extra layout binding 1 conflicts with built-in bindings.');
  });
});

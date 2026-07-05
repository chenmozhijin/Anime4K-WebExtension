import { beforeEach, describe, expect, it, vi } from 'vitest';

const { cacheCalls, borrowTextureMock, releaseTextureMock } = vi.hoisted(() => ({
  cacheCalls: {
    shaderModules: [] as string[],
    bindGroupLayouts: [] as string[],
    pipelines: [] as string[],
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
  createBindGroupChecked: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
    cacheCalls.bindGroups.push(key);
    return create();
  }),
}));

vi.mock('../../src/core/texture-pool', () => ({
  borrowTexture: borrowTextureMock,
  releaseTexture: releaseTextureMock,
}));

import { DepthToSpacePass } from '../../src/core/gpu-passes/depth-to-space-pass';

describe('DepthToSpacePass', () => {
  beforeEach(() => {
    cacheCalls.shaderModules.length = 0;
    cacheCalls.bindGroupLayouts.length = 0;
    cacheCalls.pipelines.length = 0;
    cacheCalls.bindGroups.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
  });

  function createPassHarness(outputSize = { width: 128, height: 64 }) {
    const outputTexture = {
      width: outputSize.width,
      height: outputSize.height,
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

    const pass = new DepthToSpacePass({
      device,
      inputTextures: [inputTexture, inputTexture, inputTexture],
      name: 'depth-test',
      cacheKeyPrefix: 'test/depth',
    });

    pass.pass({ beginComputePass } as unknown as GPUCommandEncoder);

    return {
      dispatchWorkgroups,
      inputTexture,
      outputTexture,
      pass,
    };
  }

  it('builds cached resources, dispatches, and releases output texture', () => {
    const {
      dispatchWorkgroups,
      inputTexture,
      outputTexture,
      pass,
    } = createPassHarness();

    expect(cacheCalls.shaderModules).toEqual(['test/depth/shader/main']);
    expect(cacheCalls.bindGroupLayouts).toEqual(['test/depth/layout/3in1out']);
    expect(cacheCalls.pipelines).toEqual(['test/depth/pipeline/main']);
    expect(cacheCalls.bindGroups).toEqual(['test/depth/depth-test/bind-group']);
    expect(borrowTextureMock).toHaveBeenCalledWith(expect.objectContaining({
      width: 128,
      height: 64,
      labelGroup: 'test/depth/output',
    }));
    expect(inputTexture.createView).toHaveBeenCalledTimes(3);
    expect(outputTexture.createView).toHaveBeenCalledTimes(1);
    expect(dispatchWorkgroups).toHaveBeenCalledWith(16, 8);
    expect(pass.getOutputTexture()).toBe(outputTexture);

    pass.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });

  it('rounds up non-divisible output dimensions to full workgroups', () => {
    const { dispatchWorkgroups } = createPassHarness({ width: 130, height: 66 });

    expect(dispatchWorkgroups).toHaveBeenCalledWith(17, 9);
  });

  it('requires exactly three input textures', () => {
    const device = {} as GPUDevice;
    const inputTexture = { width: 64, height: 32 } as GPUTexture;

    expect(() => new DepthToSpacePass({
      device,
      inputTextures: [inputTexture],
    })).toThrow('expect 3 textures for depth2Space, got 1');
  });
});

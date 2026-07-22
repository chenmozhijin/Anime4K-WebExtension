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
  getOrCreateRenderPipeline: vi.fn((_device: GPUDevice, key: string, create: () => unknown) => {
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

import { Downscale } from '../../src/core/shared-effects/downscale';

describe('Downscale', () => {
  beforeEach(() => {
    cacheCalls.shaderModules.length = 0;
    cacheCalls.bindGroupLayouts.length = 0;
    cacheCalls.pipelines.length = 0;
    cacheCalls.samplers.length = 0;
    cacheCalls.bindGroups.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
  });

  it('builds cached resources, renders a pass, and releases its texture', () => {
    const outputTexture = {
      createView: vi.fn(() => ({ label: 'output-view' })),
    } as unknown as GPUTexture;
    const inputTexture = {
      createView: vi.fn(() => ({ label: 'input-view' })),
    } as unknown as GPUTexture;
    const setPipeline = vi.fn();
    const setBindGroup = vi.fn();
    const draw = vi.fn();
    const end = vi.fn();
    const beginRenderPass = vi.fn(() => ({
      setPipeline,
      setBindGroup,
      draw,
      end,
    }));
    const device = {
      createPipelineLayout: vi.fn(descriptor => descriptor),
    } as unknown as GPUDevice;

    borrowTextureMock.mockReturnValue(outputTexture);

    const pipeline = new Downscale({
      device,
      inputTexture,
      targetDimensions: { width: 640, height: 360 },
      name: 'test-downscale',
    });

    pipeline.pass({ beginRenderPass } as unknown as GPUCommandEncoder);

    expect(cacheCalls.shaderModules).toEqual([
      'core/downscale/shader/vertex',
      'core/downscale/shader/fragment',
    ]);
    expect(cacheCalls.bindGroupLayouts).toEqual(['core/downscale/layout/render']);
    expect(cacheCalls.pipelines).toEqual(['core/downscale/pipeline/rgba16float']);
    expect(cacheCalls.samplers).toEqual(['core/downscale/sampler/linear-linear']);
    expect(cacheCalls.bindGroups).toEqual(['core/downscale/test-downscale']);
    expect(borrowTextureMock).toHaveBeenCalledWith(expect.objectContaining({
      width: 640,
      height: 360,
      label: 'test-downscale output texture',
    }));
    expect(inputTexture.createView).toHaveBeenCalledTimes(1);
    expect(beginRenderPass).toHaveBeenCalledTimes(1);
    expect(setPipeline).toHaveBeenCalledTimes(1);
    expect(setBindGroup).toHaveBeenCalledWith(0, expect.any(Object));
    expect(draw).toHaveBeenCalledWith(3);
    expect(end).toHaveBeenCalledTimes(1);
    expect(pipeline.getOutputTexture()).toBe(outputTexture);

    pipeline.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });

  it('throws when updating a non-existent parameter', () => {
    borrowTextureMock.mockReturnValue({
      createView: vi.fn(() => ({ label: 'output-view' })),
    } as unknown as GPUTexture);

    const pipeline = new Downscale({
      device: {
        createPipelineLayout: vi.fn(descriptor => descriptor),
      } as unknown as GPUDevice,
      inputTexture: {
        createView: vi.fn(() => ({ label: 'input-view' })),
      } as unknown as GPUTexture,
      targetDimensions: { width: 320, height: 180 },
    });

    expect(() => pipeline.updateParam('strength', 1)).toThrow('downscale has no param');
  });
});

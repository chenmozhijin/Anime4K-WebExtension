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

import { RenderCompositePass } from '../../src/core/gpu-passes/render-composite-pass';

describe('RenderCompositePass', () => {
  beforeEach(() => {
    cacheCalls.shaderModules.length = 0;
    cacheCalls.bindGroupLayouts.length = 0;
    cacheCalls.pipelines.length = 0;
    cacheCalls.samplers.length = 0;
    cacheCalls.bindGroups.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
  });

  it('builds cached render resources, draws, and releases output texture', () => {
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

    const pass = new RenderCompositePass({
      device,
      inputTextures: [inputTexture, inputTexture],
      outputSize: { width: 128, height: 64 },
      fragmentWGSL: '@fragment fn main() -> @location(0) vec4f { return vec4f(1.0); }',
      name: 'composite-test',
      cacheKeyPrefix: 'test/composite',
      samplerKey: 'test/composite/sampler',
    });

    pass.pass({ beginRenderPass } as unknown as GPUCommandEncoder);

    expect(cacheCalls.shaderModules[0]).toBe('test/composite/shader/vertex');
    expect(cacheCalls.shaderModules[1]).toMatch(/^test\/composite\/shader\/fragment\/[0-9a-f]{8}$/);
    expect(cacheCalls.bindGroupLayouts).toEqual(['test/composite/layout/2']);
    expect(cacheCalls.pipelines[0]).toMatch(/^test\/composite\/pipeline\/[0-9a-f]{8}\/2\/rgba16float$/);
    expect(cacheCalls.samplers).toEqual(['test/composite/sampler']);
    expect(cacheCalls.bindGroups).toEqual(['test/composite/composite-test/bind-group']);
    expect(borrowTextureMock).toHaveBeenCalledWith(expect.objectContaining({
      width: 128,
      height: 64,
      labelGroup: 'test/composite/output/2',
    }));
    expect(inputTexture.createView).toHaveBeenCalledTimes(2);
    expect(outputTexture.createView).toHaveBeenCalledTimes(1);
    expect(draw).toHaveBeenCalledWith(6);
    expect(pass.getOutputTexture()).toBe(outputTexture);

    pass.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });

  it('requires a fragment shader', () => {
    const device = {} as GPUDevice;
    expect(() => new RenderCompositePass({
      device,
      inputTextures: [],
      outputSize: { width: 1, height: 1 },
      fragmentWGSL: '',
      name: 'missing-fragment',
    })).toThrow('missing-fragment: shader not defined.');
  });
});

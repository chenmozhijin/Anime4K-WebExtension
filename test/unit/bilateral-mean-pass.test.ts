import { beforeEach, describe, expect, it, vi } from 'vitest';

const { computePassInstances, computePassOptions } = vi.hoisted(() => ({
  computePassInstances: [] as Array<{
    outputTexture: GPUTexture;
    pipeline: GPUComputePipeline;
    bindGroup: GPUBindGroup;
    pass: ReturnType<typeof vi.fn>;
    destroy: ReturnType<typeof vi.fn>;
  }>,
  computePassOptions: [] as any[],
}));

vi.mock('../../src/core/gpu-passes/compute-texture-pass', () => ({
  ComputeTexturePass: vi.fn((options: any) => {
    computePassOptions.push(options);
    const instance = {
      outputTexture: { label: 'bilateral-output' } as unknown as GPUTexture,
      pipeline: { label: 'bilateral-pipeline' } as unknown as GPUComputePipeline,
      bindGroup: { label: 'bilateral-bind-group' } as unknown as GPUBindGroup,
      pass: vi.fn(),
      destroy: vi.fn(),
    };
    computePassInstances.push(instance);
    return instance;
  }),
}));

import { BilateralMean } from '../../src/engines/anime4k/pipelines/denoise/BilateralMean';

describe('BilateralMean', () => {
  beforeEach(() => {
    computePassInstances.length = 0;
    computePassOptions.length = 0;
  });

  it('delegates GPU pass creation to ComputeTexturePass with uniform parameter bindings', () => {
    const strengthBuffer = { destroy: vi.fn() } as unknown as GPUBuffer;
    const strengthBuffer2 = { destroy: vi.fn() } as unknown as GPUBuffer;
    const createBuffer = vi.fn()
      .mockReturnValueOnce(strengthBuffer)
      .mockReturnValueOnce(strengthBuffer2);
    const writeBuffer = vi.fn();
    const device = {
      createBuffer,
      queue: { writeBuffer },
    } as unknown as GPUDevice;
    const inputTexture = {
      width: 64,
      height: 32,
      createView: vi.fn(),
    } as unknown as GPUTexture;

    const pass = new BilateralMean({ device, inputTexture });

    expect(computePassOptions).toHaveLength(1);
    expect(computePassOptions[0]).toMatchObject({
      device,
      inputTextures: [inputTexture],
      name: 'Denoise Bilateral Mean',
      cacheKeyPrefix: 'anime4k/denoise/BilateralMean',
      outputSize: { width: 64, height: 32 },
      entryPoint: 'denoiseMain',
      extraLayoutKey: 'uniforms-2-3',
    });
    expect(computePassOptions[0].extraLayoutEntries).toEqual([
      expect.objectContaining({ binding: 2, buffer: { type: 'uniform' } }),
      expect.objectContaining({ binding: 3, buffer: { type: 'uniform' } }),
    ]);
    expect(computePassOptions[0].extraBindGroupEntries).toEqual([
      { binding: 2, resource: { buffer: strengthBuffer } },
      { binding: 3, resource: { buffer: strengthBuffer2 } },
    ]);
    expect(writeBuffer).toHaveBeenCalledWith(strengthBuffer, 0, new Float32Array([0.1]));
    expect(writeBuffer).toHaveBeenCalledWith(strengthBuffer2, 0, new Float32Array([1.0]));
    expect(pass.getOutputTexture()).toBe(computePassInstances[0].outputTexture);

    const encoder = {} as GPUCommandEncoder;
    pass.pass(encoder);
    expect(computePassInstances[0].pass).toHaveBeenCalledWith(encoder, undefined);

    pass.updateParam('strength', 0.25);
    pass.updateParam('strength2', 2);
    expect(writeBuffer).toHaveBeenCalledWith(strengthBuffer, 0, new Float32Array([0.25]));
    expect(writeBuffer).toHaveBeenCalledWith(strengthBuffer2, 0, new Float32Array([2]));

    pass.destroy();
    expect(computePassInstances[0].destroy).toHaveBeenCalledTimes(1);
    expect(strengthBuffer.destroy).toHaveBeenCalledTimes(1);
    expect(strengthBuffer2.destroy).toHaveBeenCalledTimes(1);
  });

  it('validates parameter updates', () => {
    const device = {
      createBuffer: vi.fn(() => ({ destroy: vi.fn() })),
      queue: { writeBuffer: vi.fn() },
    } as unknown as GPUDevice;
    const inputTexture = {
      width: 64,
      height: 32,
    } as unknown as GPUTexture;

    const pass = new BilateralMean({ device, inputTexture });

    expect(() => pass.updateParam('unknown', 1)).toThrow('No param name as unknown');
    expect(() => pass.updateParam('strength', '1')).toThrow('strength must be a number');
    expect(() => pass.updateParam('strength', -1)).toThrow('negative strength (-1) is not allowed');
  });
});

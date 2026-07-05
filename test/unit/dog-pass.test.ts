import { beforeEach, describe, expect, it, vi } from 'vitest';

const { computePassInstances, computePassOptions } = vi.hoisted(() => ({
  computePassInstances: [] as Array<{
    outputTexture: GPUTexture;
    pass: ReturnType<typeof vi.fn>;
    destroy: ReturnType<typeof vi.fn>;
  }>,
  computePassOptions: [] as any[],
}));

vi.mock('../../src/core/gpu-passes/compute-texture-pass', () => ({
  ComputeTexturePass: vi.fn((options: any) => {
    computePassOptions.push(options);
    const instance = {
      outputTexture: { label: `dog-output-${computePassInstances.length}` } as unknown as GPUTexture,
      pass: vi.fn(),
      destroy: vi.fn(),
    };
    computePassInstances.push(instance);
    return instance;
  }),
}));

import { DoG } from '../../src/engines/anime4k/pipelines/deblur/DoG';

describe('DoG', () => {
  beforeEach(() => {
    computePassInstances.length = 0;
    computePassOptions.length = 0;
  });

  it('builds a four-stage ComputeTexturePass chain with the strength uniform on apply', () => {
    const strengthBuffer = { destroy: vi.fn() } as unknown as GPUBuffer;
    const device = {
      createBuffer: vi.fn(() => strengthBuffer),
      queue: { writeBuffer: vi.fn() },
    } as unknown as GPUDevice;
    const inputTexture = {
      width: 80,
      height: 45,
      createView: vi.fn(),
    } as unknown as GPUTexture;

    const pass = new DoG({ device, inputTexture });

    expect(computePassOptions).toHaveLength(4);
    expect(computePassOptions.map(option => option.cacheKeyPrefix)).toEqual([
      'anime4k/deblur/DoG/lumination',
      'anime4k/deblur/DoG/deblur-x',
      'anime4k/deblur/DoG/deblur-y',
      'anime4k/deblur/DoG/apply',
    ]);
    expect(computePassOptions.map(option => option.outputSize)).toEqual([
      { width: 80, height: 45 },
      { width: 80, height: 45 },
      { width: 80, height: 45 },
      { width: 80, height: 45 },
    ]);
    expect(computePassOptions[0].inputTextures).toEqual([inputTexture]);
    expect(computePassOptions[1].inputTextures).toEqual([computePassInstances[0].outputTexture]);
    expect(computePassOptions[2].inputTextures).toEqual([computePassInstances[1].outputTexture]);
    expect(computePassOptions[3].inputTextures).toEqual([
      computePassInstances[2].outputTexture,
      computePassInstances[0].outputTexture,
      inputTexture,
    ]);
    expect(computePassOptions[3].extraLayoutKey).toBe('uniforms-4');
    expect(computePassOptions[3].extraLayoutEntries).toEqual([
      expect.objectContaining({ binding: 4, buffer: { type: 'uniform' } }),
    ]);
    expect(computePassOptions[3].extraBindGroupEntries).toEqual([
      { binding: 4, resource: { buffer: strengthBuffer } },
    ]);
    expect(device.queue.writeBuffer).toHaveBeenCalledWith(strengthBuffer, 0, new Float32Array([0.6]));
    expect(pass.getOutputTexture()).toBe(computePassInstances[3].outputTexture);

    const encoder = {} as GPUCommandEncoder;
    pass.pass(encoder);
    computePassInstances.forEach(instance => expect(instance.pass).toHaveBeenCalledWith(encoder, undefined));

    pass.updateParam('strength', 0.8);
    expect(device.queue.writeBuffer).toHaveBeenCalledWith(strengthBuffer, 0, new Float32Array([0.8]));

    pass.destroy();
    computePassInstances.forEach(instance => expect(instance.destroy).toHaveBeenCalledTimes(1));
    expect(strengthBuffer.destroy).toHaveBeenCalledTimes(1);
  });

  it('validates strength updates', () => {
    const device = {
      createBuffer: vi.fn(() => ({ destroy: vi.fn() })),
      queue: { writeBuffer: vi.fn() },
    } as unknown as GPUDevice;
    const inputTexture = {
      width: 80,
      height: 45,
    } as unknown as GPUTexture;

    const pass = new DoG({ device, inputTexture });

    expect(() => pass.updateParam('unknown', 1)).toThrow('No param name as unknown');
    expect(() => pass.updateParam('strength', '1')).toThrow('strength must be a number');
    expect(() => pass.updateParam('strength', -1)).toThrow('negative strength (-1) is not allowed');
  });
});

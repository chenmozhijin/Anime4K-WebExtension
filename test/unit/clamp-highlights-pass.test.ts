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
      outputTexture: { label: `clamp-output-${computePassInstances.length}` } as unknown as GPUTexture,
      pass: vi.fn(),
      destroy: vi.fn(),
    };
    computePassInstances.push(instance);
    return instance;
  }),
}));

import { ClampHighlights } from '../../src/engines/anime4k/pipelines/helpers/ClampHighlights';

describe('ClampHighlights', () => {
  beforeEach(() => {
    computePassInstances.length = 0;
    computePassOptions.length = 0;
  });

  it('builds a three-stage ComputeTexturePass chain and exposes intermediate stats textures', () => {
    const device = {} as GPUDevice;
    const inputTexture = {
      width: 96,
      height: 54,
      createView: vi.fn(),
    } as unknown as GPUTexture;

    const pass = new ClampHighlights({ device, inputTexture, name: 'test clamp' });

    expect(computePassOptions).toHaveLength(3);
    expect(computePassOptions.map(option => option.cacheKeyPrefix)).toEqual([
      'anime4k/helper/ClampHighlights/lumination-x',
      'anime4k/helper/ClampHighlights/lumination-y',
      'anime4k/helper/ClampHighlights/clamp',
    ]);
    expect(computePassOptions.map(option => option.outputSize)).toEqual([
      { width: 96, height: 54 },
      { width: 96, height: 54 },
      { width: 96, height: 54 },
    ]);
    expect(computePassOptions[0].inputTextures).toEqual([inputTexture]);
    expect(computePassOptions[1].inputTextures).toEqual([computePassInstances[0].outputTexture]);
    expect(computePassOptions[2].inputTextures).toEqual([
      inputTexture,
      computePassInstances[1].outputTexture,
    ]);
    expect(pass.statsXTexture).toBe(computePassInstances[0].outputTexture);
    expect(pass.statsYTexture).toBe(computePassInstances[1].outputTexture);
    expect(pass.getOutputTexture()).toBe(computePassInstances[2].outputTexture);

    const encoder = {} as GPUCommandEncoder;
    pass.pass(encoder);
    computePassInstances.forEach(instance => expect(instance.pass).toHaveBeenCalledWith(encoder, undefined));
    expect(() => pass.updateParam('strength', 1)).toThrow('test clamp has no param.');

    pass.destroy();
    computePassInstances.forEach(instance => expect(instance.destroy).toHaveBeenCalledTimes(1));
  });
});

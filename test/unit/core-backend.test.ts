import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { EffectReference } from '../../src/types';
import { createEffectReference } from '../../src/core/effects/reference';
import { internalResizeDescriptor, resizeToTargetDescriptor } from '../../src/engines/core/catalog';

const { downscaleCalls, MockDownscale } = vi.hoisted(() => {
  const calls: any[] = [];
  const Downscale = class {
    private readonly outputTexture: GPUTexture;

    constructor(options: any) {
      calls.push(options);
      this.outputTexture = { label: `${options.name}-output` } as GPUTexture;
    }

    updateParam(): void {}

    pass(): void {}

    getOutputTexture(): GPUTexture {
      return this.outputTexture;
    }

    destroy(): void {}
  };

  return {
    downscaleCalls: calls,
    MockDownscale: Downscale,
  };
});

vi.mock('../../src/core/shared-effects/downscale', () => ({
  Downscale: MockDownscale,
}));

import { coreBackend } from '../../src/engines/core/backend';

describe('core backend', () => {
  const context = {
    device: { label: 'device' } as GPUDevice,
    inputTexture: { label: 'input' } as GPUTexture,
    sourceDimensions: { width: 320, height: 180 },
    currentDimensions: { width: 320, height: 180 },
    targetDimensions: { width: 1280, height: 720 },
  };

  beforeEach(() => {
    downscaleCalls.length = 0;
  });

  it('lists effects and exposes a benchmark profile', () => {
    expect(coreBackend.listEffects().map(effect => effect.key)).toEqual([
      'resize-to-target',
      'resize-linear-internal',
    ]);

    const profiles = coreBackend.getBenchmarkProfiles();
    expect(profiles).toHaveLength(1);
    expect(profiles[0]?.effects[0]?.key).toBe('resize-to-target');
  });

  it('compiles resize-to-target with a Downscale pipeline', async () => {
    const effect = createEffectReference(resizeToTargetDescriptor);

    const compiled = await coreBackend.compileEffect(effect, context);

    expect(downscaleCalls).toHaveLength(1);
    expect(downscaleCalls[0]).toMatchObject({
      device: context.device,
      inputTexture: context.inputTexture,
      targetDimensions: context.targetDimensions,
      name: 'resize-to-target',
    });
    expect(compiled.outputDimensions).toEqual(context.targetDimensions);
    expect(compiled.requiredModules).toEqual(['core:resize-to-target']);
    expect(compiled.warmupSteps).toBe(1);
  });

  it('compiles resize-linear-internal with the internal pipeline name', async () => {
    const effect = createEffectReference(internalResizeDescriptor);

    const compiled = await coreBackend.compileEffect(effect, context);

    expect(downscaleCalls).toHaveLength(1);
    expect(downscaleCalls[0]?.name).toBe('resize-linear-internal');
    expect(compiled.requiredModules).toEqual(['core:resize-linear-internal']);
  });

  it('throws for unsupported effects', async () => {
    const effect: EffectReference = {
      id: 'core/Unknown',
      backendId: 'core',
      key: 'unknown-effect',
    };

    await expect(coreBackend.compileEffect(effect, context)).rejects.toThrow(
      'Unsupported core effect: unknown-effect',
    );
  });
});

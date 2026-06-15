import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { EffectReference } from '../../src/types';
import { createEffectReference } from '../../src/core/effects/reference';
import { anime4kEffectDescriptors } from '../../src/engines/anime4k/catalog';

const { bilateralCalls, upscaleCalls } = vi.hoisted(() => ({
  bilateralCalls: [] as any[],
  upscaleCalls: [] as any[],
}));

class MockBilateralMean {
  private readonly outputTexture: GPUTexture;

  constructor(options: any) {
    bilateralCalls.push(options);
    this.outputTexture = { label: 'bilateral-output' } as GPUTexture;
  }

  updateParam(): void {}

  pass(): void {}

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

class MockCNNx2M {
  private readonly outputTexture: GPUTexture;

  constructor(options: any) {
    upscaleCalls.push(options);
    this.outputTexture = { label: 'upscale-output' } as GPUTexture;
  }

  updateParam(): void {}

  pass(): void {}

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

vi.mock('../../src/engines/anime4k/pipelines/denoise/BilateralMean', () => ({
  BilateralMean: MockBilateralMean,
}));

vi.mock('../../src/engines/anime4k/pipelines/upscale/CNNx2M', () => ({
  CNNx2M: MockCNNx2M,
}));

import { anime4kBackend } from '../../src/engines/anime4k/backend';

describe('anime4k backend', () => {
  const context = {
    device: { label: 'device' } as GPUDevice,
    inputTexture: { label: 'input' } as GPUTexture,
    sourceDimensions: { width: 320, height: 180 },
    currentDimensions: { width: 320, height: 180 },
    targetDimensions: { width: 1280, height: 720 },
  };

  beforeEach(() => {
    bilateralCalls.length = 0;
    upscaleCalls.length = 0;
  });

  it('lists effects, resolves presets, and exposes benchmark profiles', () => {
    expect(anime4kBackend.listEffects()).toBe(anime4kEffectDescriptors);
    expect(anime4kBackend.resolvePreset('A+A', 'performance').length).toBeGreaterThan(0);
    expect(anime4kBackend.getBenchmarkProfiles()[0]?.effects.length).toBeGreaterThan(0);
  });

  it('compiles same-dimension effects through the cached pipeline factory', async () => {
    const descriptor = anime4kEffectDescriptors.find(effect => effect.key === 'BilateralMean');
    const effect = createEffectReference(descriptor!);

    const compiled = await anime4kBackend.compileEffect(effect, context);

    expect(bilateralCalls).toHaveLength(1);
    expect(bilateralCalls[0]).toMatchObject({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      targetDimensions: context.targetDimensions,
    });
    expect(compiled.outputDimensions).toEqual(context.currentDimensions);
    expect(compiled.requiredModules).toEqual(['anime4k:BilateralMean']);
    expect(compiled.warmupSteps).toBe(1);
  });

  it('compiles scale effects with expanded output dimensions', async () => {
    const descriptor = anime4kEffectDescriptors.find(effect => effect.key === 'CNNx2M');
    const effect = createEffectReference(descriptor!);

    const compiled = await anime4kBackend.compileEffect(effect, context);

    expect(upscaleCalls).toHaveLength(1);
    expect(compiled.outputDimensions).toEqual({ width: 640, height: 360 });
    expect(compiled.requiredModules).toEqual(['anime4k:CNNx2M']);
  });

  it('throws for unknown effect keys', async () => {
    const effect: EffectReference = {
      id: 'anime4k/Unknown',
      backendId: 'anime4k',
      key: 'Unknown',
    };

    await expect(anime4kBackend.compileEffect(effect, context)).rejects.toThrow(
      'Unsupported Anime4K effect: Unknown',
    );
  });
});

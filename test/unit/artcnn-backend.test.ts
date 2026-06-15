import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { EffectReference } from '../../src/types';
import { createEffectReference } from '../../src/core/effects/reference';
import { artcnnEffectDescriptors } from '../../src/engines/artcnn/catalog';

const { c4f16Calls, c4f32Calls } = vi.hoisted(() => ({
  c4f16Calls: [] as any[],
  c4f32Calls: [] as any[],
}));

class MockArtCNNC4F16 {
  private readonly outputTexture: GPUTexture;

  constructor(options: any) {
    c4f16Calls.push(options);
    this.outputTexture = { label: 'artcnn-c4f16-output' } as GPUTexture;
  }

  updateParam(): void {}

  pass(): void {}

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

class MockArtCNNC4F32 {
  private readonly outputTexture: GPUTexture;

  constructor(options: any) {
    c4f32Calls.push(options);
    this.outputTexture = { label: 'artcnn-c4f32-output' } as GPUTexture;
  }

  updateParam(): void {}

  pass(): void {}

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

vi.mock('../../src/engines/artcnn/pipelines/upscale/C4F16', () => ({
  ArtCNNC4F16: MockArtCNNC4F16,
}));

vi.mock('../../src/engines/artcnn/pipelines/upscale/C4F32', () => ({
  ArtCNNC4F32: MockArtCNNC4F32,
}));

import { artcnnBackend } from '../../src/engines/artcnn/backend';

describe('artcnn backend', () => {
  const context = {
    device: { label: 'device' } as GPUDevice,
    inputTexture: { label: 'input' } as GPUTexture,
    sourceDimensions: { width: 320, height: 180 },
    currentDimensions: { width: 320, height: 180 },
    targetDimensions: { width: 1280, height: 720 },
  };

  beforeEach(() => {
    c4f16Calls.length = 0;
    c4f32Calls.length = 0;
  });

  it('lists effects and exposes no benchmark profiles', () => {
    expect(artcnnBackend.listEffects()).toBe(artcnnEffectDescriptors);
    expect(artcnnBackend.resolvePreset('any', 'performance')).toEqual([]);
    expect(artcnnBackend.getBenchmarkProfiles()).toEqual([]);
  });

  it('compiles C4F16 with x2 output dimensions', async () => {
    const descriptor = artcnnEffectDescriptors.find(effect => effect.key === 'C4F16');
    const effect = createEffectReference(descriptor!);

    const compiled = await artcnnBackend.compileEffect(effect, context);

    expect(c4f16Calls).toHaveLength(1);
    expect(c4f16Calls[0]).toMatchObject({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      targetDimensions: context.targetDimensions,
    });
    expect(compiled.outputDimensions).toEqual({ width: 640, height: 360 });
    expect(compiled.requiredModules).toEqual(['artcnn:C4F16']);
  });

  it('compiles C4F32 with x2 output dimensions', async () => {
    const descriptor = artcnnEffectDescriptors.find(effect => effect.key === 'C4F32');
    const effect = createEffectReference(descriptor!);

    const compiled = await artcnnBackend.compileEffect(effect, context);

    expect(c4f32Calls).toHaveLength(1);
    expect(compiled.outputDimensions).toEqual({ width: 640, height: 360 });
    expect(compiled.requiredModules).toEqual(['artcnn:C4F32']);
  });

  it('throws for unsupported effects', async () => {
    const effect: EffectReference = {
      id: 'artcnn/Unknown',
      backendId: 'artcnn',
      key: 'Unknown',
    };

    await expect(artcnnBackend.compileEffect(effect, context)).rejects.toThrow(
      'Unsupported ArtCNN effect: Unknown',
    );
  });
});


import { describe, expect, it } from 'vitest';
import { createEffectReference } from '../../src/core/effects/reference';
import { acnetBackend } from '../../src/engines/acnet/backend';
import { acnetEffectDescriptors, acnetEffectSourceMetas } from '../../src/engines/acnet/catalog';
import { acnetGeneratedModelMetas } from '../../src/engines/acnet/generated/models';
import { createWebGpuMock } from '../support/webgpu';

describe('acnet backend', () => {
  function createContext() {
    const { device } = createWebGpuMock();
    return {
      device: device as unknown as GPUDevice,
      inputTexture: device.createTexture({
        size: { width: 16, height: 9 },
        format: 'rgba16float',
        usage: GPUTextureUsage.TEXTURE_BINDING,
      }),
      sourceDimensions: { width: 16, height: 9 },
      currentDimensions: { width: 16, height: 9 },
      targetDimensions: { width: 32, height: 18 },
    };
  }

  it('lists all generated ACNetGLSL effects and exposes no presets', () => {
    expect(acnetBackend.listEffects()).toBe(acnetEffectDescriptors);
    expect(acnetEffectDescriptors).toHaveLength(33);
    expect(acnetBackend.resolvePreset('any', 'performance')).toEqual([]);
    expect(acnetBackend.getBenchmarkProfiles()).toEqual([]);
  });

  it('derives descriptors from generated effect source metadata', () => {
    expect(acnetEffectSourceMetas).toHaveLength(acnetGeneratedModelMetas.length);
    expect(acnetEffectDescriptors).toEqual(acnetEffectSourceMetas.map(meta => meta.descriptor));
    expect(acnetEffectSourceMetas.map(meta => meta.model)).toEqual(acnetGeneratedModelMetas);
    expect(acnetEffectSourceMetas.every(meta => meta.backendId === 'acnet')).toBe(true);
  });

  it.each([
    'ACNET_F8B4',
    'ACNET_LEGACY_GAN',
    'ARNET_F8B8',
  ])('compiles %s with x2 output dimensions', async (key) => {
    const descriptor = acnetEffectDescriptors.find(effect => effect.key === key);
    const effect = createEffectReference(descriptor!);
    const compiled = await acnetBackend.compileEffect(effect, createContext());

    expect(compiled.outputDimensions).toEqual({ width: 32, height: 18 });
    expect(compiled.requiredModules).toEqual([`acnet:${key}`]);
    expect(compiled.pipelines).toHaveLength(1);
    expect(compiled.outputTexture.width).toBe(32);
    expect(compiled.outputTexture.height).toBe(18);
  });

  it('throws for unsupported effects', async () => {
    await expect(acnetBackend.compileEffect({
      id: 'acnet/Unknown',
      backendId: 'acnet',
      key: 'Unknown',
    }, createContext())).rejects.toThrow('Unsupported ACNetGLSL effect: Unknown');
  });
});

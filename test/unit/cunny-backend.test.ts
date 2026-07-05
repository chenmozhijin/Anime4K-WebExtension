import { describe, expect, it } from 'vitest';
import { createEffectReference } from '../../src/core/effects/reference';
import { cunnyBackend } from '../../src/engines/cunny/backend';
import { cunnyEffectDescriptors, cunnyEffectSourceMetas } from '../../src/engines/cunny/catalog';
import { cunnyGeneratedModelMetas } from '../../src/engines/cunny/generated/models';
import { createWebGpuMock } from '../support/webgpu';

describe('cunny backend', () => {
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

  it('lists all generated CuNNy effects with LGPL metadata and exposes no presets', () => {
    expect(cunnyBackend.listEffects()).toBe(cunnyEffectDescriptors);
    expect(cunnyEffectDescriptors).toHaveLength(18);
    expect(cunnyBackend.resolvePreset('any', 'performance')).toEqual([]);
    expect(cunnyBackend.getBenchmarkProfiles()).toEqual([]);

    for (const descriptor of cunnyEffectDescriptors) {
      expect(descriptor.license, descriptor.id).toEqual({
        expression: 'LGPL-3.0-or-later',
        componentName: 'CuNNy',
        sourceUrl: 'https://github.com/funnyplanter/CuNNy',
      });
    }
  });

  it('derives descriptors and LGPL metadata from generated effect source metadata', () => {
    expect(cunnyEffectSourceMetas).toHaveLength(cunnyGeneratedModelMetas.length);
    expect(cunnyEffectDescriptors).toEqual(cunnyEffectSourceMetas.map(meta => meta.descriptor));
    expect(cunnyEffectSourceMetas.map(meta => meta.model)).toEqual(cunnyGeneratedModelMetas);
    expect(cunnyEffectSourceMetas.every(meta => meta.backendId === 'cunny')).toBe(true);
    expect(cunnyEffectSourceMetas.every(meta => meta.descriptor.license?.expression === 'LGPL-3.0-or-later')).toBe(true);
  });

  it.each([
    'CUNNY_FAST_DS',
    'CUNNY_4X32_SOFT',
    'CUNNY_8X32_DS',
  ])('compiles %s with x2 output dimensions', async (key) => {
    const descriptor = cunnyEffectDescriptors.find(effect => effect.key === key);
    const effect = createEffectReference(descriptor!);
    const compiled = await cunnyBackend.compileEffect(effect, createContext());

    expect(compiled.outputDimensions).toEqual({ width: 32, height: 18 });
    expect(compiled.requiredModules).toEqual([`cunny:${key}`]);
    expect(compiled.pipelines).toHaveLength(1);
    expect(compiled.outputTexture.width).toBe(32);
    expect(compiled.outputTexture.height).toBe(18);
  });

  it('throws for unsupported effects', async () => {
    await expect(cunnyBackend.compileEffect({
      id: 'cunny/Unknown',
      backendId: 'cunny',
      key: 'Unknown',
    }, createContext())).rejects.toThrow('Unsupported CuNNy effect: Unknown');
  });
});

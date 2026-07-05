import { describe, expect, it } from 'vitest';
import {
  getEffectDescriptorById,
  normalizeEffectReference,
  validateEffectChain,
} from '../../src/core/effects/registry';

describe('effects registry', () => {
  it('normalizes legacy anime4k className references', () => {
    const effect = normalizeEffectReference({
      className: 'CNNM',
      params: { strength: 1 },
    });

    expect(effect).not.toBeNull();
    expect(effect?.backendId).toBe('anime4k');
    expect(effect?.key).toBe('CNNM');
  });

  it('returns registered descriptors by id', () => {
    const descriptor = getEffectDescriptorById('core/Resize/ToTarget');
    expect(descriptor?.backendId).toBe('core');
  });

  it('returns ArtCNN descriptors by id', () => {
    const descriptor = getEffectDescriptorById('artcnn/Upscale/C4F16');
    expect(descriptor?.backendId).toBe('artcnn');
  });

  it('returns ACNetGLSL descriptors by id', () => {
    const descriptor = getEffectDescriptorById('acnet/Upscale/F8B4');
    expect(descriptor?.backendId).toBe('acnet');
  });

  it('returns CuNNy descriptors by id with license metadata', () => {
    const descriptor = getEffectDescriptorById('cunny/Upscale/DS/Fast');
    expect(descriptor?.backendId).toBe('cunny');
    expect(descriptor?.license?.expression).toBe('LGPL-3.0-or-later');
  });

  it('normalizes ACNetGLSL custom-mode references', () => {
    const effect = normalizeEffectReference({
      id: 'acnet/Upscale/F8B4',
      backendId: 'acnet',
      key: 'ACNET_F8B4',
    });

    expect(effect).toEqual({
      id: 'acnet/Upscale/F8B4',
      backendId: 'acnet',
      key: 'ACNET_F8B4',
    });
  });

  it('normalizes ArtCNN custom-mode references', () => {
    const effect = normalizeEffectReference({
      id: 'artcnn/Upscale/C4F16',
      backendId: 'artcnn',
      key: 'C4F16',
    });

    expect(effect).toEqual({
      id: 'artcnn/Upscale/C4F16',
      backendId: 'artcnn',
      key: 'C4F16',
    });
  });

  it('normalizes CuNNy custom-mode references', () => {
    const effect = normalizeEffectReference({
      id: 'cunny/Upscale/DS/Fast',
      backendId: 'cunny',
      key: 'CUNNY_FAST_DS',
    });

    expect(effect).toEqual({
      id: 'cunny/Upscale/DS/Fast',
      backendId: 'cunny',
      key: 'CUNNY_FAST_DS',
    });
  });

  it('validates unknown effect chains', () => {
    const validation = validateEffectChain([
      {
        id: 'unknown',
        backendId: 'unknown',
        key: 'unknown',
      },
    ]);

    expect(validation.valid).toBe(false);
    expect(validation.errors[0]).toContain('not registered');
  });
});

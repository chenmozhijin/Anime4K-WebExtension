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

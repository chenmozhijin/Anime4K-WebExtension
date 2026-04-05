import { describe, expect, it } from 'vitest';
import { createEffectSignature } from '../../src/utils/effect-signature';

describe('createEffectSignature', () => {
  it('is stable for logically identical params', () => {
    const left = createEffectSignature([
      {
        id: 'anime4k/CNNM',
        backendId: 'anime4k',
        key: 'CNNM',
        params: { threshold: 1, nested: { beta: 2, alpha: 1 } },
      },
    ]);
    const right = createEffectSignature([
      {
        id: 'anime4k/CNNM',
        backendId: 'anime4k',
        key: 'CNNM',
        params: { nested: { alpha: 1, beta: 2 }, threshold: 1 },
      },
    ]);

    expect(left).toBe(right);
  });

  it('changes when effect params change', () => {
    const first = createEffectSignature([
      { id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM', params: { strength: 1 } },
    ]);
    const second = createEffectSignature([
      { id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM', params: { strength: 2 } },
    ]);

    expect(first).not.toBe(second);
  });
});

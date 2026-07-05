import { describe, expect, it } from 'vitest';
import { getRuntimeBackend } from '../../src/core/effects/runtime-registry';

describe('runtime registry', () => {
  it('loads and caches runtime backends', async () => {
    const first = await getRuntimeBackend('core');
    const second = await getRuntimeBackend('core');

    expect(first).toBe(second);
    expect(first.backendId).toBe('core');
  });

  it('loads the ArtCNN backend', async () => {
    const backend = await getRuntimeBackend('artcnn');
    expect(backend.backendId).toBe('artcnn');
  });

  it('loads the ACNetGLSL backend', async () => {
    const backend = await getRuntimeBackend('acnet');
    expect(backend.backendId).toBe('acnet');
  });

  it('loads the CuNNy backend', async () => {
    const backend = await getRuntimeBackend('cunny');
    expect(backend.backendId).toBe('cunny');
  });

  it('throws for unknown runtime backends', async () => {
    await expect(getRuntimeBackend('missing')).rejects.toThrow('Unknown runtime backend');
  });
});

import { describe, expect, it } from 'vitest';
import {
  borrowTexture,
  clearTexturePool,
  getTexturePoolStats,
  releaseTexture,
  setTexturePoolBudgetForDevice,
} from '../../src/core/texture-pool';
import { createWebGpuMock } from '../support/webgpu';

describe('texture pool', () => {
  it('reuses textures after release', () => {
    const { device } = createWebGpuMock();

    const first = borrowTexture({
      device: device as unknown as GPUDevice,
      width: 1920,
      height: 1080,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'test/output',
    });
    releaseTexture(first);

    const second = borrowTexture({
      device: device as unknown as GPUDevice,
      width: 1920,
      height: 1080,
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
      labelGroup: 'test/output',
    });

    const stats = getTexturePoolStats(device as unknown as GPUDevice);
    expect(second).toBe(first);
    expect(stats.hits).toBe(1);

    clearTexturePool(device as unknown as GPUDevice);
  });

  it('evicts least-recently released textures when the cached byte budget is exceeded', () => {
    const { device } = createWebGpuMock();
    const gpuDevice = device as unknown as GPUDevice;
    setTexturePoolBudgetForDevice(gpuDevice, 4);

    const first = borrowTexture({
      device: gpuDevice,
      width: 2,
      height: 2,
      format: 'rgba8unorm',
      usage: GPUTextureUsage.TEXTURE_BINDING,
      labelGroup: 'test/evict/a',
    });
    const second = borrowTexture({
      device: gpuDevice,
      width: 2,
      height: 2,
      format: 'rgba8unorm',
      usage: GPUTextureUsage.TEXTURE_BINDING,
      labelGroup: 'test/evict/b',
    });

    releaseTexture(first);
    releaseTexture(second);

    const stats = getTexturePoolStats(gpuDevice);
    expect(stats.evictions).toBeGreaterThan(0);
    expect(stats.cachedBytes).toBeLessThanOrEqual(stats.budgetBytes);
    expect((first as unknown as { destroyed: boolean }).destroyed).toBe(true);

    clearTexturePool(gpuDevice);
  });
});

import { describe, expect, it, vi } from 'vitest';
import { selectKernelVariant } from '../../src/core/kernel-variant-tuner';
import type { GpuCapabilities, KernelVariant } from '../../src/core/gpu-capabilities';

const capabilities = {
  adapter: { vendor: 'v', architecture: 'a', device: 'd', description: '' },
  browser: { name: 'chrome', version: '1', userAgent: '' },
  knownFeatures: new Set<GPUFeatureName>(),
  knownEnabledFeatures: new Set<GPUFeatureName>(),
  timestampQuery: false,
  shaderF16: false,
  bgra8UnormStorage: false,
  externalTexture: false,
  canvasStorage: true,
  limits: {
    maxComputeInvocationsPerWorkgroup: 256,
    maxComputeWorkgroupSizeX: 256,
    maxComputeWorkgroupSizeY: 256,
    maxComputeWorkgroupStorageSize: 32768,
    maxStorageTexturesPerShaderStage: 8,
    maxSampledTexturesPerShaderStage: 16,
  },
} as GpuCapabilities;

const variants: KernelVariant[] = [{
  id: 'baseline',
  correctness: 'exact',
  wgsl: '',
  workgroup: { width: 8, height: 8 },
  benchmarkCacheVersion: 1,
}, {
  id: 'fast',
  correctness: 'exact',
  wgsl: '',
  workgroup: { width: 16, height: 8 },
  benchmarkCacheVersion: 1,
}, {
  id: 'f16',
  correctness: 'perceptual',
  wgsl: '',
  workgroup: { width: 8, height: 8 },
  benchmarkCacheVersion: 1,
}];

describe('kernel variant tuner', () => {
  it('selects a certified variant only when it clears the gain threshold', async () => {
    const benchmark = vi.fn(async (variant: KernelVariant) => variant.id === 'fast' ? 0.8 : 1);
    const selection = await selectKernelVariant({
      capabilities,
      variants,
      baselineId: 'baseline',
      shaderHash: 'hash',
      cacheNamespace: 'test',
      benchmark,
      storage: { getItem: () => null, setItem: vi.fn() },
    });

    expect(selection.variant.id).toBe('fast');
    expect(benchmark).toHaveBeenCalledTimes(2);
  });

  it('keeps the stable baseline for gains below three percent', async () => {
    const selection = await selectKernelVariant({
      capabilities,
      variants,
      baselineId: 'baseline',
      shaderHash: 'hash',
      cacheNamespace: 'test',
      benchmark: async variant => variant.id === 'fast' ? 0.98 : 1,
      storage: { getItem: () => null, setItem: vi.fn() },
    });

    expect(selection.variant.id).toBe('baseline');
  });
});

import { describe, expect, it } from 'vitest';
import {
  KNOWN_GPU_FEATURES,
  collectGpuCapabilities,
  isKernelVariantSupported,
  type KernelVariant,
} from '../../src/core/gpu-capabilities';

function createHasOnlyFeatureSet(features: readonly GPUFeatureName[]): GPUSupportedFeatures {
  const supported = new Set(features);
  return {
    has: (feature: string) => supported.has(feature as GPUFeatureName),
    forEach: () => {
      throw new Error('GPUSupportedFeatures.forEach must not be called.');
    },
    [Symbol.iterator]: () => {
      throw new Error('GPUSupportedFeatures iterator must not be called.');
    },
  } as unknown as GPUSupportedFeatures;
}

describe('GPU capability model', () => {
  it('captures browser, adapter, feature, and limit identities', () => {
    const adapter = {
      features: new Set<GPUFeatureName>(['timestamp-query', 'shader-f16', 'bgra8unorm-storage']),
      info: {
        vendor: 'Vendor',
        architecture: 'Architecture',
        device: 'Device',
        description: 'Description',
      },
      limits: {},
    } as unknown as GPUAdapter;
    const device = {
      features: new Set<GPUFeatureName>(['timestamp-query', 'shader-f16', 'bgra8unorm-storage']),
      importExternalTexture: () => ({}),
      limits: {
        maxComputeInvocationsPerWorkgroup: 256,
        maxComputeWorkgroupSizeX: 256,
        maxComputeWorkgroupSizeY: 256,
        maxComputeWorkgroupStorageSize: 32768,
        maxStorageTexturesPerShaderStage: 8,
        maxSampledTexturesPerShaderStage: 16,
      },
    } as unknown as GPUDevice;

    const capabilities = collectGpuCapabilities({
      adapter,
      device,
      presentationFormat: 'bgra8unorm',
      userAgent: 'Mozilla/5.0 Edg/140.0.0.0',
    });

    expect(capabilities.browser).toMatchObject({ name: 'edge', version: '140.0.0.0' });
    expect(capabilities.adapter.description).toBe('Description');
    expect(capabilities.timestampQuery).toBe(true);
    expect(capabilities.shaderF16).toBe(true);
    expect(capabilities.externalTexture).toBe(true);
    expect(capabilities.canvasStorage).toBe(true);
  });

  it('collects feature snapshots without Xray-unsafe callbacks or iterators', () => {
    const capabilities = collectGpuCapabilities({
      adapter: {
        features: createHasOnlyFeatureSet(['timestamp-query', 'shader-f16']),
        info: {},
        limits: {},
      } as unknown as GPUAdapter,
      device: {
        features: createHasOnlyFeatureSet(['timestamp-query']),
        limits: {
          maxComputeInvocationsPerWorkgroup: 256,
          maxComputeWorkgroupSizeX: 256,
          maxComputeWorkgroupSizeY: 256,
          maxComputeWorkgroupStorageSize: 32768,
          maxStorageTexturesPerShaderStage: 8,
          maxSampledTexturesPerShaderStage: 16,
        },
      } as unknown as GPUDevice,
      presentationFormat: 'rgba8unorm',
    });

    expect(capabilities.knownFeatures).toEqual(new Set(['timestamp-query', 'shader-f16']));
    expect(capabilities.knownEnabledFeatures).toEqual(new Set(['timestamp-query']));
  });

  it('keeps runtime feature dependencies in the Xray-safe probe registry', () => {
    expect(KNOWN_GPU_FEATURES).toEqual(expect.arrayContaining([
      'timestamp-query',
      'shader-f16',
      'bgra8unorm-storage',
    ]));
  });

  it('rejects kernel variants that exceed workgroup limits or require missing features', () => {
    const capabilities = collectGpuCapabilities({
      adapter: {
        features: new Set<GPUFeatureName>(),
        info: {},
        limits: {},
      } as unknown as GPUAdapter,
      device: {
        features: new Set<GPUFeatureName>(),
        limits: {
          maxComputeInvocationsPerWorkgroup: 64,
          maxComputeWorkgroupSizeX: 8,
          maxComputeWorkgroupSizeY: 8,
          maxComputeWorkgroupStorageSize: 16384,
          maxStorageTexturesPerShaderStage: 4,
          maxSampledTexturesPerShaderStage: 8,
        },
      } as unknown as GPUDevice,
      presentationFormat: 'rgba8unorm',
      userAgent: 'Firefox/140.0',
    });
    const variant: KernelVariant = {
      id: 'f16-16x8',
      correctness: 'perceptual',
      wgsl: '',
      workgroup: { width: 16, height: 8 },
      requiredFeatures: ['shader-f16'],
      benchmarkCacheVersion: 1,
    };

    expect(isKernelVariantSupported(variant, capabilities)).toBe(false);
  });

  it('does not select a feature that the adapter supports but the device did not enable', () => {
    const capabilities = collectGpuCapabilities({
      adapter: {
        features: new Set<GPUFeatureName>(['shader-f16']),
        info: {},
        limits: {},
      } as unknown as GPUAdapter,
      device: {
        features: new Set<GPUFeatureName>(),
        limits: {
          maxComputeInvocationsPerWorkgroup: 256,
          maxComputeWorkgroupSizeX: 16,
          maxComputeWorkgroupSizeY: 16,
          maxComputeWorkgroupStorageSize: 32768,
          maxStorageTexturesPerShaderStage: 8,
          maxSampledTexturesPerShaderStage: 16,
        },
      } as unknown as GPUDevice,
      presentationFormat: 'rgba8unorm',
      userAgent: 'Chrome/140.0',
    });
    const variant: KernelVariant = {
      id: 'f16',
      correctness: 'perceptual',
      wgsl: '',
      workgroup: { width: 8, height: 8 },
      requiredFeatures: ['shader-f16'],
      benchmarkCacheVersion: 1,
    };

    expect(capabilities.knownFeatures.has('shader-f16')).toBe(true);
    expect(capabilities.knownEnabledFeatures.has('shader-f16')).toBe(false);
    expect(isKernelVariantSupported(variant, capabilities)).toBe(false);
  });
});

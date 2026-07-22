export type KernelCorrectnessClass = 'exact' | 'quantized-equivalent' | 'perceptual';

export interface GpuAdapterIdentity {
  vendor: string;
  architecture: string;
  device: string;
  description: string;
}

export interface BrowserIdentity {
  name: 'chrome' | 'edge' | 'firefox' | 'unknown';
  version: string;
  userAgent: string;
}

export interface GpuCapabilities {
  adapter: GpuAdapterIdentity;
  browser: BrowserIdentity;
  // Optional features supported by the adapter, useful for diagnostics and deciding
  // what a future device descriptor may request.
  features: ReadonlySet<GPUFeatureName>;
  // Features actually enabled on this GPUDevice. Kernel selection must use this set.
  enabledFeatures: ReadonlySet<GPUFeatureName>;
  timestampQuery: boolean;
  shaderF16: boolean;
  bgra8UnormStorage: boolean;
  externalTexture: boolean;
  canvasStorage: boolean;
  limits: {
    maxComputeInvocationsPerWorkgroup: number;
    maxComputeWorkgroupSizeX: number;
    maxComputeWorkgroupSizeY: number;
    maxComputeWorkgroupStorageSize: number;
    maxStorageTexturesPerShaderStage: number;
    maxSampledTexturesPerShaderStage: number;
  };
}

export interface KernelVariant {
  id: string;
  correctness: KernelCorrectnessClass;
  wgsl: string;
  workgroup: { width: number; height: number };
  requiredFeatures?: readonly GPUFeatureName[];
  requiredWorkgroupStorageBytes?: number;
  requiredStorageTexturesPerShaderStage?: number;
  requiredSampledTexturesPerShaderStage?: number;
  // Bump whenever WGSL, resource layout, benchmark workload, or selection semantics
  // change; otherwise an old cached winner may be applied to a different kernel.
  benchmarkCacheVersion: number;
}

function detectBrowser(userAgent: string): BrowserIdentity {
  const edge = /Edg\/([\d.]+)/.exec(userAgent);
  if (edge) {
    return { name: 'edge', version: edge[1], userAgent };
  }

  const firefox = /Firefox\/([\d.]+)/.exec(userAgent);
  if (firefox) {
    return { name: 'firefox', version: firefox[1], userAgent };
  }

  const chrome = /(?:Chrome|Chromium)\/([\d.]+)/.exec(userAgent);
  if (chrome) {
    return { name: 'chrome', version: chrome[1], userAgent };
  }

  return { name: 'unknown', version: '', userAgent };
}

export function collectGpuCapabilities(options: {
  adapter: GPUAdapter;
  device: GPUDevice;
  presentationFormat: GPUTextureFormat;
  userAgent?: string;
}): GpuCapabilities {
  const { adapter, device, presentationFormat } = options;
  const features = new Set<GPUFeatureName>();
  adapter.features.forEach(feature => features.add(feature as GPUFeatureName));
  const enabledFeatures = new Set<GPUFeatureName>();
  device.features.forEach(feature => enabledFeatures.add(feature as GPUFeatureName));
  const info = adapter.info;
  const bgra8UnormStorage = enabledFeatures.has('bgra8unorm-storage');
  const limits = device.limits;
  const adapterLimits = adapter.limits;

  return {
    adapter: {
      vendor: info?.vendor ?? '',
      architecture: info?.architecture ?? '',
      device: info?.device ?? '',
      description: info?.description ?? '',
    },
    browser: detectBrowser(options.userAgent ?? navigator.userAgent),
    features,
    enabledFeatures,
    timestampQuery: enabledFeatures.has('timestamp-query'),
    shaderF16: enabledFeatures.has('shader-f16'),
    bgra8UnormStorage,
    externalTexture: typeof device.importExternalTexture === 'function',
    // bgra8unorm canvas storage needs the optional feature; other preferred formats
    // are core storage formats. Render-attachment terminal presenters do not depend on it.
    canvasStorage: presentationFormat !== 'bgra8unorm' || bgra8UnormStorage,
    limits: {
      maxComputeInvocationsPerWorkgroup: limits.maxComputeInvocationsPerWorkgroup
        ?? adapterLimits.maxComputeInvocationsPerWorkgroup ?? 0,
      maxComputeWorkgroupSizeX: limits.maxComputeWorkgroupSizeX
        ?? adapterLimits.maxComputeWorkgroupSizeX ?? 0,
      maxComputeWorkgroupSizeY: limits.maxComputeWorkgroupSizeY
        ?? adapterLimits.maxComputeWorkgroupSizeY ?? 0,
      maxComputeWorkgroupStorageSize: limits.maxComputeWorkgroupStorageSize
        ?? adapterLimits.maxComputeWorkgroupStorageSize ?? 0,
      maxStorageTexturesPerShaderStage: limits.maxStorageTexturesPerShaderStage
        ?? adapterLimits.maxStorageTexturesPerShaderStage ?? 0,
      maxSampledTexturesPerShaderStage: limits.maxSampledTexturesPerShaderStage
        ?? adapterLimits.maxSampledTexturesPerShaderStage ?? 0,
    },
  };
}

export function isKernelVariantSupported(
  variant: KernelVariant,
  capabilities: GpuCapabilities,
): boolean {
  if (variant.workgroup.width > capabilities.limits.maxComputeWorkgroupSizeX
    || variant.workgroup.height > capabilities.limits.maxComputeWorkgroupSizeY
    || variant.workgroup.width * variant.workgroup.height
      > capabilities.limits.maxComputeInvocationsPerWorkgroup) {
    return false;
  }

  if ((variant.requiredWorkgroupStorageBytes ?? 0)
      > capabilities.limits.maxComputeWorkgroupStorageSize
    || (variant.requiredStorageTexturesPerShaderStage ?? 0)
      > capabilities.limits.maxStorageTexturesPerShaderStage
    || (variant.requiredSampledTexturesPerShaderStage ?? 0)
      > capabilities.limits.maxSampledTexturesPerShaderStage) {
    return false;
  }

  // Adapter support alone is insufficient: createShaderModule/pipeline validation
  // requires the feature to have been requested in this device's descriptor.
  return (variant.requiredFeatures ?? []).every(feature => capabilities.enabledFeatures.has(feature));
}

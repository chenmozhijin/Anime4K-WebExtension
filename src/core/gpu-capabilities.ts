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
  // Finite snapshot of feature names known by this project, not an exhaustive runtime set.
  knownFeatures: ReadonlySet<KnownGpuFeatureName>;
  // Finite snapshot of known features enabled on this GPUDevice.
  knownEnabledFeatures: ReadonlySet<KnownGpuFeatureName>;
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
  // Restrict feature requirements to the probe registry so new dependencies cannot be
  // added without also becoming Xray-safe capability probes.
  requiredFeatures?: readonly KnownGpuFeatureName[];
  requiredWorkgroupStorageBytes?: number;
  requiredStorageTexturesPerShaderStage?: number;
  requiredSampledTexturesPerShaderStage?: number;
  // Bump whenever WGSL, resource layout, benchmark workload, or selection semantics
  // change; otherwise an old cached winner may be applied to a different kernel.
  benchmarkCacheVersion: number;
}

// Firefox content-script Xray wrappers reject callback and iterator access on
// GPUSupportedFeatures. Probe the feature names used by the current API surface instead.
// Keep this list in sync when feature-dependent code is added.
export const KNOWN_GPU_FEATURES = [
  'core-features-and-limits',
  'depth-clip-control',
  'depth32float-stencil8',
  'texture-compression-bc',
  'texture-compression-bc-sliced-3d',
  'texture-compression-etc2',
  'texture-compression-astc',
  'texture-compression-astc-sliced-3d',
  'timestamp-query',
  'indirect-first-instance',
  'shader-f16',
  'rg11b10ufloat-renderable',
  'bgra8unorm-storage',
  'float32-filterable',
  'float32-blendable',
  'clip-distances',
  'dual-source-blending',
  'subgroups',
  'texture-formats-tier1',
  'primitive-index',
] as const satisfies readonly GPUFeatureName[];

export type KnownGpuFeatureName = (typeof KNOWN_GPU_FEATURES)[number];

function snapshotFeatures(features: GPUSupportedFeatures): Set<KnownGpuFeatureName> {
  const snapshot = new Set<KnownGpuFeatureName>();
  for (const feature of KNOWN_GPU_FEATURES) {
    if (features.has(feature)) {
      snapshot.add(feature);
    }
  }
  return snapshot;
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
  const knownFeatures = snapshotFeatures(adapter.features);
  const knownEnabledFeatures = snapshotFeatures(device.features);
  const info = adapter.info;
  const bgra8UnormStorage = knownEnabledFeatures.has('bgra8unorm-storage');
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
    knownFeatures,
    knownEnabledFeatures,
    timestampQuery: knownEnabledFeatures.has('timestamp-query'),
    shaderF16: knownEnabledFeatures.has('shader-f16'),
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
  return (variant.requiredFeatures ?? []).every(feature => capabilities.knownEnabledFeatures.has(feature));
}

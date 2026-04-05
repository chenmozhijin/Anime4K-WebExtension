type SamplerKey = string;
type ShaderModuleKey = string;
type BindGroupLayoutKey = string;
type PipelineKey = string;

export interface GpuResourceError {
  source: string;
  message: string;
  kind: 'validation' | 'internal' | 'out-of-memory' | 'unknown';
}

interface DeviceCacheStats {
  shaderHits: number;
  shaderMisses: number;
  pipelineHits: number;
  pipelineMisses: number;
}

interface DeviceResourceCache {
  shaderModules: Map<ShaderModuleKey, GPUShaderModule>;
  bindGroupLayouts: Map<BindGroupLayoutKey, GPUBindGroupLayout>;
  renderPipelines: Map<PipelineKey, GPURenderPipeline>;
  computePipelines: Map<PipelineKey, GPUComputePipeline>;
  samplers: Map<SamplerKey, GPUSampler>;
  errorListeners: Set<(error: GpuResourceError) => void>;
  pendingErrorScopes: Set<Promise<void>>;
  stats: DeviceCacheStats;
}

const cacheByDevice = new WeakMap<GPUDevice, DeviceResourceCache>();

function createDeviceCache(): DeviceResourceCache {
  return {
    shaderModules: new Map(),
    bindGroupLayouts: new Map(),
    renderPipelines: new Map(),
    computePipelines: new Map(),
    samplers: new Map(),
    errorListeners: new Set(),
    pendingErrorScopes: new Set(),
    stats: {
      shaderHits: 0,
      shaderMisses: 0,
      pipelineHits: 0,
      pipelineMisses: 0,
    },
  };
}

function getDeviceCache(device: GPUDevice): DeviceResourceCache {
  let deviceCache = cacheByDevice.get(device);
  if (!deviceCache) {
    deviceCache = createDeviceCache();
    cacheByDevice.set(device, deviceCache);
  }
  return deviceCache;
}

function trackPendingErrorScope(device: GPUDevice, pendingScope: Promise<void>): void {
  const deviceCache = getDeviceCache(device);
  deviceCache.pendingErrorScopes.add(pendingScope);
  pendingScope.finally(() => {
    deviceCache.pendingErrorScopes.delete(pendingScope);
  });
}

function inferGpuErrorKind(error: unknown): GpuResourceError['kind'] {
  const errorName = typeof error === 'object' && error && 'name' in error
    ? (error as { name?: string }).name
    : undefined;

  if (!errorName) {
    return 'unknown';
  }

  switch (errorName) {
    case 'GPUValidationError':
      return 'validation';
    case 'GPUInternalError':
      return 'internal';
    case 'GPUOutOfMemoryError':
      return 'out-of-memory';
    default:
      return 'unknown';
  }
}

function reportGpuResourceError(device: GPUDevice, error: GpuResourceError): void {
  const deviceCache = getDeviceCache(device);
  deviceCache.errorListeners.forEach(listener => listener(error));
}

function createWithValidationScope<T>(
  device: GPUDevice,
  source: string,
  factory: () => T,
): T {
  const errorScopedDevice = device as GPUDevice & {
    pushErrorScope?: (filter: GPUErrorFilter) => void;
    popErrorScope?: () => Promise<{ name?: string; message?: string } | null>;
  };

  if (typeof errorScopedDevice.pushErrorScope !== 'function' || typeof errorScopedDevice.popErrorScope !== 'function') {
    return factory();
  }

  errorScopedDevice.pushErrorScope('validation');
  const resource = factory();
  const pendingScope = errorScopedDevice.popErrorScope()
    .then((error) => {
      if (!error) {
        return;
      }

      reportGpuResourceError(device, {
        source,
        message: error.message ?? 'Unknown GPU validation error',
        kind: inferGpuErrorKind(error),
      });
    })
    .catch((error) => {
      reportGpuResourceError(device, {
        source,
        message: error instanceof Error ? error.message : String(error),
        kind: 'unknown',
      });
    });

  trackPendingErrorScope(device, pendingScope);
  return resource;
}

export function getOrCreateShaderModule(
  device: GPUDevice,
  key: ShaderModuleKey,
  descriptorFactory: () => GPUShaderModuleDescriptor,
): GPUShaderModule {
  const deviceCache = getDeviceCache(device);
  const cached = deviceCache.shaderModules.get(key);
  if (cached) {
    deviceCache.stats.shaderHits += 1;
    return cached;
  }

  deviceCache.stats.shaderMisses += 1;
  const shaderModule = createWithValidationScope(device, `shader:${key}`, () => device.createShaderModule(descriptorFactory()));
  deviceCache.shaderModules.set(key, shaderModule);
  return shaderModule;
}

export function getOrCreateBindGroupLayout(
  device: GPUDevice,
  key: BindGroupLayoutKey,
  descriptorFactory: () => GPUBindGroupLayoutDescriptor,
): GPUBindGroupLayout {
  const deviceCache = getDeviceCache(device);
  const cached = deviceCache.bindGroupLayouts.get(key);
  if (cached) {
    return cached;
  }

  const bindGroupLayout = createWithValidationScope(
    device,
    `bind-group-layout:${key}`,
    () => device.createBindGroupLayout(descriptorFactory()),
  );
  deviceCache.bindGroupLayouts.set(key, bindGroupLayout);
  return bindGroupLayout;
}

export function getOrCreateRenderPipeline(
  device: GPUDevice,
  key: PipelineKey,
  descriptorFactory: () => GPURenderPipelineDescriptor,
): GPURenderPipeline {
  const deviceCache = getDeviceCache(device);
  const cached = deviceCache.renderPipelines.get(key);
  if (cached) {
    deviceCache.stats.pipelineHits += 1;
    return cached;
  }

  deviceCache.stats.pipelineMisses += 1;
  const pipeline = createWithValidationScope(device, `render-pipeline:${key}`, () => device.createRenderPipeline(descriptorFactory()));
  deviceCache.renderPipelines.set(key, pipeline);
  return pipeline;
}

export function getOrCreateComputePipeline(
  device: GPUDevice,
  key: PipelineKey,
  descriptorFactory: () => GPUComputePipelineDescriptor,
): GPUComputePipeline {
  const deviceCache = getDeviceCache(device);
  const cached = deviceCache.computePipelines.get(key);
  if (cached) {
    deviceCache.stats.pipelineHits += 1;
    return cached;
  }

  deviceCache.stats.pipelineMisses += 1;
  const pipeline = createWithValidationScope(device, `compute-pipeline:${key}`, () => device.createComputePipeline(descriptorFactory()));
  deviceCache.computePipelines.set(key, pipeline);
  return pipeline;
}

export function getOrCreateSampler(
  device: GPUDevice,
  key: SamplerKey,
  descriptorFactory: () => GPUSamplerDescriptor,
): GPUSampler {
  const deviceCache = getDeviceCache(device);
  const cached = deviceCache.samplers.get(key);
  if (cached) {
    return cached;
  }

  const sampler = createWithValidationScope(device, `sampler:${key}`, () => device.createSampler(descriptorFactory()));
  deviceCache.samplers.set(key, sampler);
  return sampler;
}

export function createBindGroupChecked(
  device: GPUDevice,
  source: string,
  descriptorFactory: () => GPUBindGroupDescriptor,
): GPUBindGroup {
  return createWithValidationScope(device, `bind-group:${source}`, () => device.createBindGroup(descriptorFactory()));
}

export function getGpuResourceCacheStats(device: GPUDevice): DeviceCacheStats {
  const deviceCache = getDeviceCache(device);
  return { ...deviceCache.stats };
}

export function subscribeGpuResourceErrors(
  device: GPUDevice,
  listener: (error: GpuResourceError) => void,
): () => void {
  const deviceCache = getDeviceCache(device);
  deviceCache.errorListeners.add(listener);
  return () => {
    deviceCache.errorListeners.delete(listener);
  };
}

export async function flushGpuResourceErrors(device: GPUDevice): Promise<void> {
  const deviceCache = cacheByDevice.get(device);
  if (!deviceCache || deviceCache.pendingErrorScopes.size === 0) {
    return;
  }

  await Promise.allSettled([...deviceCache.pendingErrorScopes]);
}

export function clearGpuResourceCache(device: GPUDevice): void {
  cacheByDevice.delete(device);
}

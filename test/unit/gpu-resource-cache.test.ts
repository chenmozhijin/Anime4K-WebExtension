import { describe, expect, it, vi } from 'vitest';
import {
  createBindGroupChecked,
  clearGpuResourceCache,
  flushGpuResourceErrors,
  getGpuResourceCacheStats,
  getOrCreateComputePipeline,
  getOrCreateComputePipelineAsync,
  getOrCreateRenderPipeline,
  getOrCreateShaderModule,
  subscribeGpuResourceErrors,
} from '../../src/core/gpu-resource-cache';
import { createWebGpuMock } from '../support/webgpu';

describe('gpu resource cache', () => {
  it('reuses shader and pipeline objects for stable keys', () => {
    const { device } = createWebGpuMock();

    const shaderA = getOrCreateShaderModule(device as unknown as GPUDevice, 'shader/a', () => ({
      code: 'shader-a',
    }));
    const shaderB = getOrCreateShaderModule(device as unknown as GPUDevice, 'shader/a', () => ({
      code: 'shader-b',
    }));

    const computeA = getOrCreateComputePipeline(device as unknown as GPUDevice, 'compute/a', () => ({
      layout: 'auto',
      compute: {
        module: shaderA,
        entryPoint: 'main',
      },
    }));
    const computeB = getOrCreateComputePipeline(device as unknown as GPUDevice, 'compute/a', () => ({
      layout: 'auto',
      compute: {
        module: shaderB,
        entryPoint: 'main',
      },
    }));

    const renderA = getOrCreateRenderPipeline(device as unknown as GPUDevice, 'render/a', () => ({
      layout: 'auto',
      vertex: {
        module: shaderA,
        entryPoint: 'main',
      },
      fragment: {
        module: shaderA,
        entryPoint: 'main',
        targets: [{ format: 'rgba8unorm' }],
      },
    }));
    const renderB = getOrCreateRenderPipeline(device as unknown as GPUDevice, 'render/a', () => ({
      layout: 'auto',
      vertex: {
        module: shaderA,
        entryPoint: 'main',
      },
      fragment: {
        module: shaderA,
        entryPoint: 'main',
        targets: [{ format: 'rgba8unorm' }],
      },
    }));

    const stats = getGpuResourceCacheStats(device as unknown as GPUDevice);
    expect(shaderA).toBe(shaderB);
    expect(computeA).toBe(computeB);
    expect(renderA).toBe(renderB);
    expect(stats.shaderHits).toBeGreaterThan(0);
    expect(stats.pipelineHits).toBeGreaterThan(0);

    clearGpuResourceCache(device as unknown as GPUDevice);
  });

  it('captures bind group validation errors through the shared wrapper', async () => {
    const { device } = createWebGpuMock();
    const errors: string[] = [];
    const unsubscribe = subscribeGpuResourceErrors(device as unknown as GPUDevice, (error) => {
      errors.push(`${error.source}:${error.message}`);
    });

    (device as unknown as { queueScopedError: (error: { name?: string; message?: string } | null) => void }).queueScopedError({
      name: 'GPUValidationError',
      message: 'mock bind group mismatch',
    });

    createBindGroupChecked(device as unknown as GPUDevice, 'test/bind-group', () => ({
      layout: {} as GPUBindGroupLayout,
      entries: [],
    }));
    await flushGpuResourceErrors(device as unknown as GPUDevice);

    expect(errors).toEqual(['bind-group:test/bind-group:mock bind group mismatch']);

    unsubscribe();
    clearGpuResourceCache(device as unknown as GPUDevice);
  });

  it('deduplicates pending asynchronous compute pipeline compilation', async () => {
    const { device } = createWebGpuMock();
    const gpuDevice = device as unknown as GPUDevice & {
      createComputePipelineAsync: (descriptor: GPUComputePipelineDescriptor) => Promise<GPUComputePipeline>;
    };
    const createAsync = vi.fn(async (descriptor: GPUComputePipelineDescriptor) =>
      device.createComputePipeline(descriptor));
    gpuDevice.createComputePipelineAsync = createAsync;
    const shader = gpuDevice.createShaderModule({ code: '@compute @workgroup_size(1) fn main() {}' });
    const descriptor = () => ({
      layout: 'auto' as const,
      compute: { module: shader, entryPoint: 'main' },
    });

    const [first, second] = await Promise.all([
      getOrCreateComputePipelineAsync(gpuDevice, 'compute/async', descriptor),
      getOrCreateComputePipelineAsync(gpuDevice, 'compute/async', descriptor),
    ]);

    expect(first).toBe(second);
    expect(createAsync).toHaveBeenCalledOnce();
    expect(getOrCreateComputePipeline(gpuDevice, 'compute/async', descriptor)).toBe(first);
    clearGpuResourceCache(gpuDevice);
  });

  it('evicts cached resources that later report async validation errors', async () => {
    const { device } = createWebGpuMock();
    const gpuDevice = device as unknown as GPUDevice;

    (device as unknown as { queueScopedError: (error: { name?: string; message?: string } | null) => void }).queueScopedError({
      name: 'GPUValidationError',
      message: 'bad shader',
    });

    const first = getOrCreateShaderModule(gpuDevice, 'shader/evict', () => ({
      code: 'bad shader',
    }));
    await flushGpuResourceErrors(gpuDevice);

    const second = getOrCreateShaderModule(gpuDevice, 'shader/evict', () => ({
      code: 'replacement shader',
    }));

    expect(second).not.toBe(first);
    clearGpuResourceCache(gpuDevice);
  });
});

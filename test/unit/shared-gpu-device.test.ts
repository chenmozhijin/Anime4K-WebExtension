import { describe, expect, it, vi } from 'vitest';
import { acquireSharedGpuDevice } from '../../src/core/shared-gpu-device';

function createHarness() {
  const generations: Array<{
    adapter: GPUAdapter;
    device: GPUDevice;
    resolveLost: (info: GPUDeviceLostInfo) => void;
  }> = [];
  const requestDevice = vi.fn();

  function createGeneration() {
    let resolveLost!: (info: GPUDeviceLostInfo) => void;
    let consumed = false;
    const lost = new Promise<GPUDeviceLostInfo>(resolve => {
      resolveLost = resolve;
    });
    const device = { lost, destroy: vi.fn() } as unknown as GPUDevice;
    const adapter = {
      requestDevice: vi.fn(async (descriptor?: GPUDeviceDescriptor) => {
        requestDevice(descriptor);
        if (consumed) {
          const error = new Error('adapter is consumed');
          error.name = 'OperationError';
          throw error;
        }
        consumed = true;
        return device;
      }),
    } as unknown as GPUAdapter;
    const generation = { adapter, device, resolveLost };
    generations.push(generation);
    return generation;
  }

  const initial = createGeneration();
  let firstAdapterRequest = true;
  const requestAdapter = vi.fn(async () => {
    if (firstAdapterRequest) {
      firstAdapterRequest = false;
      return initial.adapter;
    }
    return createGeneration().adapter;
  });
  const gpu = { requestAdapter } as unknown as GPU;
  return {
    gpu,
    adapter: initial.adapter,
    device: initial.device,
    requestAdapter,
    requestDevice,
    resolveLost: initial.resolveLost,
    generations,
  };
}

describe('shared GPU device', () => {
  it('shares identical profile requests until the final lease is released', async () => {
    const harness = createHarness();
    const acquire = () => acquireSharedGpuDevice({
      gpu: harness.gpu,
      adapterOptions: { powerPreference: 'high-performance' },
      deviceProfileKey: 'renderer',
      descriptorFactory: () => ({ requiredLimits: { maxComputeWorkgroupStorageSize: 32768 } }),
    });

    const [first, second] = await Promise.all([acquire(), acquire()]);

    expect(first.device).toBe(second.device);
    expect(harness.requestAdapter).toHaveBeenCalledOnce();
    expect(harness.requestDevice).toHaveBeenCalledOnce();
    expect(first.release()).toBe(false);
    expect(second.release()).toBe(true);
  });

  it('does not reuse an adapter across different profiles and requests a fresh generation after release', async () => {
    const harness = createHarness();
    const baseline = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'baseline',
      descriptorFactory: () => ({}),
    });
    const timestamp = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'timestamp',
      descriptorFactory: () => ({ requiredFeatures: ['timestamp-query'] }),
    });

    expect(harness.requestAdapter).toHaveBeenCalledTimes(2);
    expect(harness.requestDevice).toHaveBeenCalledTimes(2);
    expect(timestamp.adapter).not.toBe(baseline.adapter);

    baseline.release();
    const recovered = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'baseline',
      descriptorFactory: () => ({}),
    });
    expect(harness.requestAdapter).toHaveBeenCalledTimes(3);
    expect(harness.requestDevice).toHaveBeenCalledTimes(3);
    expect(recovered.adapter).not.toBe(baseline.adapter);

    timestamp.release();
    recovered.release();
  });

  it('rejects a descriptor mismatch within one profile instead of creating a second device', async () => {
    const harness = createHarness();
    const first = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'renderer',
      descriptorFactory: () => ({}),
    });

    await expect(acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'renderer',
      descriptorFactory: () => ({ requiredFeatures: ['timestamp-query'] }),
    })).rejects.toThrow(/different device descriptor/);

    expect(harness.requestAdapter).toHaveBeenCalledOnce();
    expect(harness.requestDevice).toHaveBeenCalledOnce();
    first.release();
  });

  it('evicts a lost device slot and acquires a new adapter/device generation', async () => {
    const harness = createHarness();
    const first = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'renderer',
      descriptorFactory: () => ({}),
    });

    harness.resolveLost({ reason: 'unknown', message: 'lost' } as GPUDeviceLostInfo);
    await Promise.resolve();

    const second = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      deviceProfileKey: 'renderer',
      descriptorFactory: () => ({}),
    });

    expect(second.device).not.toBe(first.device);
    expect(harness.requestAdapter).toHaveBeenCalledTimes(2);
    expect(harness.requestDevice).toHaveBeenCalledTimes(2);
    first.release();
    second.release();
  });
});

import { describe, expect, it, vi } from 'vitest';
import { acquireSharedGpuDevice } from '../../src/core/shared-gpu-device';

function createHarness() {
  let resolveLost!: (info: GPUDeviceLostInfo) => void;
  const lost = new Promise<GPUDeviceLostInfo>(resolve => {
    resolveLost = resolve;
  });
  const device = { lost, destroy: vi.fn() } as unknown as GPUDevice;
  const requestDevice = vi.fn(async () => device);
  const adapter = {
    requestDevice,
  } as unknown as GPUAdapter;
  const requestAdapter = vi.fn(async () => adapter);
  const gpu = { requestAdapter } as unknown as GPU;
  return { gpu, adapter, device, requestAdapter, requestDevice, resolveLost };
}

describe('shared GPU device', () => {
  it('shares identical adapter/device requests until the final lease is released', async () => {
    const harness = createHarness();
    const acquire = () => acquireSharedGpuDevice({
      gpu: harness.gpu,
      adapterOptions: { powerPreference: 'high-performance' },
      descriptorFactory: () => ({ requiredLimits: { maxComputeWorkgroupStorageSize: 32768 } }),
    });

    const [first, second] = await Promise.all([acquire(), acquire()]);

    expect(first.device).toBe(second.device);
    expect(harness.requestAdapter).toHaveBeenCalledOnce();
    expect(harness.requestDevice).toHaveBeenCalledOnce();
    expect(first.release()).toBe(false);
    expect(second.release()).toBe(true);
  });

  it('isolates descriptors and creates a new generation after invalidation', async () => {
    const harness = createHarness();
    const baseline = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      descriptorFactory: () => ({}),
    });
    const timestamp = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      descriptorFactory: () => ({ requiredFeatures: ['timestamp-query'] }),
    });

    expect(harness.requestDevice).toHaveBeenCalledTimes(2);
    baseline.invalidate();
    baseline.release();

    const recovered = await acquireSharedGpuDevice({
      gpu: harness.gpu,
      descriptorFactory: () => ({}),
    });
    expect(harness.requestAdapter).toHaveBeenCalledTimes(2);
    expect(harness.requestDevice).toHaveBeenCalledTimes(3);

    timestamp.release();
    recovered.release();
  });
});

export interface SharedGpuDeviceLease {
  readonly adapter: GPUAdapter;
  readonly device: GPUDevice;
  invalidate(): void;
  release(): boolean;
}

export interface AcquireSharedGpuDeviceOptions {
  gpu: GPU;
  adapterOptions?: GPURequestAdapterOptions;
  /** Identifies the complete device configuration owned by this slot. */
  deviceProfileKey: string;
  descriptorFactory(adapter: GPUAdapter): GPUDeviceDescriptor;
}

interface DevicePool {
  devices: Map<string, DeviceSlot>;
}

interface DeviceSlot {
  key: string;
  adapterKey: string;
  adapterPromise: Promise<GPUAdapter | null>;
  descriptorReady: Promise<string>;
  descriptorKey?: string;
  promise: Promise<DeviceEntry>;
  entry?: DeviceEntry;
}

interface DeviceEntry {
  pool: DevicePool;
  slot: DeviceSlot;
  adapter: GPUAdapter;
  device: GPUDevice;
  references: number;
  invalidated: boolean;
}

const poolsByGpu = new WeakMap<object, DevicePool>();

function getPool(gpu: GPU): DevicePool {
  let pool = poolsByGpu.get(gpu as object);
  if (!pool) {
    pool = { devices: new Map() };
    poolsByGpu.set(gpu as object, pool);
  }
  return pool;
}

function stableObjectKey(value: object | undefined): string {
  if (!value) {
    return '{}';
  }
  return JSON.stringify(Object.entries(value).sort(([left], [right]) => left.localeCompare(right)));
}

function deviceDescriptorKey(descriptor: GPUDeviceDescriptor): string {
  // Device sharing is valid only when every requested feature/limit is identical.
  // Keep descriptorFactory deterministic; labels are intentionally excluded.
  const features = [...(descriptor.requiredFeatures ?? [])].map(String).sort();
  const limits = Object.entries(descriptor.requiredLimits ?? {})
    .sort(([left], [right]) => left.localeCompare(right));
  return JSON.stringify({ features, limits });
}

function invalidateEntry(entry: DeviceEntry): void {
  if (entry.invalidated) {
    return;
  }
  entry.invalidated = true;
  const { pool, slot } = entry;
  if (pool.devices.get(slot.key) === slot) {
    pool.devices.delete(slot.key);
  }
}

function createDescriptorReady(): {
  promise: Promise<string>;
  resolve: (key: string) => void;
  reject: (reason?: unknown) => void;
} {
  let resolve!: (key: string) => void;
  let reject!: (reason?: unknown) => void;
  const promise = new Promise<string>((resolvePromise, rejectPromise) => {
    resolve = resolvePromise;
    reject = rejectPromise;
  });

  // Keep the validation promise observed even when device creation fails before
  // a second acquirer starts waiting on the slot.
  void promise.catch(() => undefined);
  return { promise, resolve, reject };
}

export async function acquireSharedGpuDevice({
  gpu,
  adapterOptions,
  deviceProfileKey,
  descriptorFactory,
}: AcquireSharedGpuDeviceOptions): Promise<SharedGpuDeviceLease> {
  const pool = getPool(gpu);
  const adapterKey = stableObjectKey(adapterOptions);
  const key = `${adapterKey}|${deviceProfileKey}`;
  let slot = pool.devices.get(key);

  if (!slot) {
    const adapterPromise = gpu.requestAdapter(adapterOptions);
    const descriptorReady = createDescriptorReady();
    slot = {
      key,
      adapterKey,
      adapterPromise,
      descriptorReady: descriptorReady.promise,
      promise: null as unknown as Promise<DeviceEntry>,
    };
    const createdSlot = slot;

    createdSlot.promise = (async () => {
      const adapter = await adapterPromise;
      if (!adapter) {
        throw new Error('WebGPU not supported: No adapter found.');
      }

      const descriptor = descriptorFactory(adapter);
      const descriptorKey = deviceDescriptorKey(descriptor);
      createdSlot.descriptorKey = descriptorKey;
      descriptorReady.resolve(descriptorKey);

      const device = await adapter.requestDevice(descriptor);
      const entry: DeviceEntry = {
        pool,
        slot: createdSlot,
        adapter,
        device,
        references: 0,
        invalidated: false,
      };
      createdSlot.entry = entry;
      device.lost.then(() => invalidateEntry(entry));
      return entry;
    })().catch(error => {
      descriptorReady.reject(error);
      if (pool.devices.get(key) === createdSlot) {
        pool.devices.delete(key);
      }
      throw error;
    });
    pool.devices.set(key, createdSlot);
  } else {
    const adapter = slot.entry?.adapter ?? await slot.adapterPromise;
    if (!adapter) {
      throw new Error('WebGPU not supported: No adapter found.');
    }

    const requestedDescriptorKey = deviceDescriptorKey(descriptorFactory(adapter));
    const existingDescriptorKey = await slot.descriptorReady;
    if (requestedDescriptorKey !== existingDescriptorKey) {
      throw new Error(
        `WebGPU device profile "${deviceProfileKey}" was requested with a different device descriptor.`,
      );
    }
  }

  const entry = await slot.promise;
  if (entry.invalidated) {
    throw new Error('WebGPU device is no longer available.');
  }
  entry.references += 1;
  let released = false;
  return {
    adapter: entry.adapter,
    device: entry.device,
    invalidate: () => invalidateEntry(entry),
    release: () => {
      if (released) {
        return false;
      }
      released = true;
      entry.references = Math.max(0, entry.references - 1);
      if (entry.references !== 0) {
        return false;
      }
      if (entry.pool.devices.get(entry.slot.key) === entry.slot) {
        entry.pool.devices.delete(entry.slot.key);
      }
      // true transfers final-owner responsibility to the caller, which must clear
      // device-scoped caches before optionally destroying the device.
      return true;
    },
  };
}

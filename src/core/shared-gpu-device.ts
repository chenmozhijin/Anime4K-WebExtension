export interface SharedGpuDeviceLease {
  readonly adapter: GPUAdapter;
  readonly device: GPUDevice;
  invalidate(): void;
  release(): boolean;
}

export interface AcquireSharedGpuDeviceOptions {
  gpu: GPU;
  adapterOptions?: GPURequestAdapterOptions;
  descriptorFactory(adapter: GPUAdapter): GPUDeviceDescriptor;
}

interface DevicePool {
  adapters: Map<string, Promise<GPUAdapter | null>>;
  devices: Map<string, DeviceSlot>;
}

interface DeviceSlot {
  key: string;
  adapterKey: string;
  adapterPromise: Promise<GPUAdapter | null>;
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
    pool = { adapters: new Map(), devices: new Map() };
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
  if (pool.adapters.get(slot.adapterKey) === slot.adapterPromise) {
    // Re-request the adapter after device loss instead of assuming the old adapter
    // remains usable across browser/GPU resets.
    pool.adapters.delete(slot.adapterKey);
  }
}

export async function acquireSharedGpuDevice({
  gpu,
  adapterOptions,
  descriptorFactory,
}: AcquireSharedGpuDeviceOptions): Promise<SharedGpuDeviceLease> {
  const pool = getPool(gpu);
  const adapterKey = stableObjectKey(adapterOptions);
  let adapterPromise = pool.adapters.get(adapterKey);
  if (!adapterPromise) {
    adapterPromise = gpu.requestAdapter(adapterOptions);
    pool.adapters.set(adapterKey, adapterPromise);
  }

  const adapter = await adapterPromise;
  if (!adapter) {
    if (pool.adapters.get(adapterKey) === adapterPromise) {
      pool.adapters.delete(adapterKey);
    }
    throw new Error('WebGPU not supported: No adapter found.');
  }

  const descriptor = descriptorFactory(adapter);
  const key = `${adapterKey}|${deviceDescriptorKey(descriptor)}`;
  let slot = pool.devices.get(key);
  if (!slot) {
    slot = {
      key,
      adapterKey,
      adapterPromise,
      promise: null as unknown as Promise<DeviceEntry>,
    };
    slot.promise = adapter.requestDevice(descriptor).then(device => {
      const entry: DeviceEntry = {
        pool,
        slot: slot!,
        adapter,
        device,
        references: 0,
        invalidated: false,
      };
      slot!.entry = entry;
      device.lost.then(() => invalidateEntry(entry));
      return entry;
    }).catch(error => {
      if (pool.devices.get(key) === slot) {
        pool.devices.delete(key);
      }
      throw error;
    });
    pool.devices.set(key, slot);
  }

  const entry = await slot.promise;
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

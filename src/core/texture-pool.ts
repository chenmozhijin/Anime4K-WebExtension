interface BorrowTextureOptions {
  device: GPUDevice;
  width: number;
  height: number;
  format: GPUTextureFormat;
  usage: GPUTextureUsageFlags;
  labelGroup: string;
  label?: string;
}

interface TextureMetadata {
  device: GPUDevice;
  key: string;
  labelGroup: string;
  byteSize: number;
  lastUsed: number;
}

interface DeviceTexturePool {
  available: Map<string, GPUTexture[]>;
  borrowed: Set<GPUTexture>;
  metadata: Map<GPUTexture, TextureMetadata>;
  cachedBytes: number;
  budgetBytes: number;
  stats: {
    hits: number;
    misses: number;
    evictions: number;
  };
}

const poolByDevice = new WeakMap<GPUDevice, DeviceTexturePool>();
const metadataByTexture = new Map<GPUTexture, TextureMetadata>();
const DEFAULT_POOL_BUDGET_BYTES = 256 * 1024 * 1024;

function getPool(device: GPUDevice): DeviceTexturePool {
  let pool = poolByDevice.get(device);
  if (!pool) {
    pool = {
      available: new Map(),
      borrowed: new Set(),
      metadata: new Map(),
      cachedBytes: 0,
      budgetBytes: DEFAULT_POOL_BUDGET_BYTES,
      stats: {
        hits: 0,
        misses: 0,
        evictions: 0,
      },
    };
    poolByDevice.set(device, pool);
  }
  return pool;
}

function estimateBytesPerPixel(format: GPUTextureFormat): number {
  if (format.includes('16float') || format.includes('16uint') || format.includes('16sint')) {
    return 8;
  }

  if (format.includes('32float') || format.includes('32uint') || format.includes('32sint')) {
    return 16;
  }

  if (format.includes('rg8')) {
    return 2;
  }

  if (format.includes('r8')) {
    return 1;
  }

  return 4;
}

function estimateTextureByteSize(options: Pick<BorrowTextureOptions, 'width' | 'height' | 'format'>): number {
  return options.width * options.height * estimateBytesPerPixel(options.format);
}

function createTextureKey(options: Omit<BorrowTextureOptions, 'device' | 'label'>): string {
  return [
    options.width,
    options.height,
    options.format,
    options.usage,
    options.labelGroup,
  ].join('|');
}

export function borrowTexture(options: BorrowTextureOptions): GPUTexture {
  const { device, label, labelGroup, ...rest } = options;
  const pool = getPool(device);
  const key = createTextureKey({ labelGroup, ...rest });
  const availableTextures = pool.available.get(key);
  const texture = availableTextures?.pop();

  if (texture) {
    const metadata = pool.metadata.get(texture);
    if (metadata) {
      pool.cachedBytes = Math.max(0, pool.cachedBytes - metadata.byteSize);
      metadata.lastUsed = performance.now();
    }
    pool.stats.hits += 1;
    pool.borrowed.add(texture);
    return texture;
  }

  pool.stats.misses += 1;
  const createdTexture = device.createTexture({
    label,
    size: [options.width, options.height, 1],
    format: options.format,
    usage: options.usage,
  });
  pool.borrowed.add(createdTexture);
  const metadata = {
    device,
    key,
    labelGroup,
    byteSize: estimateTextureByteSize(options),
    lastUsed: performance.now(),
  };
  pool.metadata.set(createdTexture, metadata);
  metadataByTexture.set(createdTexture, metadata);
  return createdTexture;
}

export function releaseTexture(texture: GPUTexture): void {
  const metadata = metadataByTexture.get(texture);
  if (!metadata) {
    texture.destroy();
    return;
  }

  const pool = poolByDevice.get(metadata.device);
  if (!pool) {
    texture.destroy();
    return;
  }

  if (!pool.borrowed.has(texture)) {
    return;
  }

  pool.borrowed.delete(texture);
  metadata.lastUsed = performance.now();
  const availableTextures = pool.available.get(metadata.key);
  if (availableTextures) {
    availableTextures.push(texture);
  } else {
    pool.available.set(metadata.key, [texture]);
  }
  pool.cachedBytes += metadata.byteSize;
  evictAvailableTexturesIfNeeded(pool);
}

function evictAvailableTexturesIfNeeded(pool: DeviceTexturePool): void {
  while (pool.cachedBytes > pool.budgetBytes) {
    let oldest: {
      texture: GPUTexture;
      metadata: TextureMetadata;
      key: string;
    } | null = null;

    for (const [key, textures] of pool.available) {
      for (const texture of textures) {
        const metadata = pool.metadata.get(texture);
        if (!metadata) {
          continue;
        }

        if (!oldest || metadata.lastUsed < oldest.metadata.lastUsed) {
          oldest = { texture, metadata, key };
        }
      }
    }

    if (!oldest) {
      pool.cachedBytes = 0;
      return;
    }

    const textures = pool.available.get(oldest.key);
    const nextTextures = textures?.filter(texture => texture !== oldest.texture) ?? [];
    if (nextTextures.length === 0) {
      pool.available.delete(oldest.key);
    } else {
      pool.available.set(oldest.key, nextTextures);
    }

    try {
      oldest.texture.destroy();
    } catch {
      // Ignore texture destruction errors during eviction.
    }
    pool.cachedBytes = Math.max(0, pool.cachedBytes - oldest.metadata.byteSize);
    pool.metadata.delete(oldest.texture);
    metadataByTexture.delete(oldest.texture);
    pool.stats.evictions += 1;
  }
}

export function clearTexturePool(device: GPUDevice): void {
  const pool = poolByDevice.get(device);
  if (!pool) {
    return;
  }

  pool.metadata.forEach((_, texture) => {
    try {
      texture.destroy();
    } catch {
      // Ignore texture destruction errors during pool clear.
    }
    metadataByTexture.delete(texture);
  });
  pool.available.clear();
  pool.metadata.clear();
  pool.borrowed.clear();
  pool.cachedBytes = 0;
  poolByDevice.delete(device);
}

export function getTexturePoolStats(device: GPUDevice): {
  hits: number;
  misses: number;
  evictions: number;
  active: number;
  available: number;
  cachedBytes: number;
  budgetBytes: number;
} {
  const pool = getPool(device);
  let available = 0;
  pool.available.forEach((textures) => {
    available += textures.length;
  });

  return {
    hits: pool.stats.hits,
    misses: pool.stats.misses,
    evictions: pool.stats.evictions,
    active: pool.borrowed.size,
    available,
    cachedBytes: pool.cachedBytes,
    budgetBytes: pool.budgetBytes,
  };
}

export function setTexturePoolBudgetForDevice(device: GPUDevice, budgetBytes: number): void {
  const pool = getPool(device);
  pool.budgetBytes = Math.max(0, budgetBytes);
  evictAvailableTexturesIfNeeded(pool);
}

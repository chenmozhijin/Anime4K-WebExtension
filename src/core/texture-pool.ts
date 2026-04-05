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
}

interface DeviceTexturePool {
  available: Map<string, GPUTexture[]>;
  borrowed: Set<GPUTexture>;
  metadata: Map<GPUTexture, TextureMetadata>;
  stats: {
    hits: number;
    misses: number;
  };
}

const poolByDevice = new WeakMap<GPUDevice, DeviceTexturePool>();
const metadataByTexture = new Map<GPUTexture, TextureMetadata>();

function getPool(device: GPUDevice): DeviceTexturePool {
  let pool = poolByDevice.get(device);
  if (!pool) {
    pool = {
      available: new Map(),
      borrowed: new Set(),
      metadata: new Map(),
      stats: {
        hits: 0,
        misses: 0,
      },
    };
    poolByDevice.set(device, pool);
  }
  return pool;
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
  const availableTextures = pool.available.get(metadata.key);
  if (availableTextures) {
    availableTextures.push(texture);
  } else {
    pool.available.set(metadata.key, [texture]);
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
  poolByDevice.delete(device);
}

export function getTexturePoolStats(device: GPUDevice): {
  hits: number;
  misses: number;
  active: number;
  available: number;
} {
  const pool = getPool(device);
  let available = 0;
  pool.available.forEach((textures) => {
    available += textures.length;
  });

  return {
    hits: pool.stats.hits,
    misses: pool.stats.misses,
    active: pool.borrowed.size,
    available,
  };
}

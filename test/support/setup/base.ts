import { afterEach, beforeEach, vi } from 'vitest';

globalThis.__NIJILUCID_DISABLE_AUTO_BOOTSTRAP__ = true;

beforeEach(() => {
  globalThis.__NIJILUCID_DISABLE_AUTO_BOOTSTRAP__ = true;
  Object.assign(globalThis, {
    GPUTextureUsage: globalThis.GPUTextureUsage ?? {
      COPY_SRC: 1,
      COPY_DST: 2,
      TEXTURE_BINDING: 4,
      STORAGE_BINDING: 8,
      RENDER_ATTACHMENT: 16,
    },
    GPUBufferUsage: globalThis.GPUBufferUsage ?? {
      MAP_READ: 1,
      MAP_WRITE: 2,
      COPY_SRC: 4,
      COPY_DST: 8,
      INDEX: 16,
      VERTEX: 32,
      UNIFORM: 64,
      STORAGE: 128,
      INDIRECT: 256,
      QUERY_RESOLVE: 512,
    },
    GPUShaderStage: globalThis.GPUShaderStage ?? {
      VERTEX: 1,
      FRAGMENT: 2,
      COMPUTE: 4,
    },
    GPUMapMode: globalThis.GPUMapMode ?? {
      READ: 1,
      WRITE: 2,
    },
  });
});

afterEach(() => {
  vi.restoreAllMocks();
  vi.clearAllMocks();
  vi.resetModules();
  Reflect.deleteProperty(globalThis, '__NIJILUCID_DISABLE_AUTO_BOOTSTRAP__');
  Reflect.deleteProperty(globalThis as typeof globalThis & { chrome?: typeof chrome }, 'chrome');
});

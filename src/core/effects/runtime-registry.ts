import type { AlgorithmBackend } from './backend-types';

const runtimeBackendLoaders: Record<string, () => Promise<AlgorithmBackend>> = {
  anime4k: async () => (await import('../../engines/anime4k/backend')).anime4kBackend,
  artcnn: async () => (await import('../../engines/artcnn/backend')).artcnnBackend,
  acnet: async () => (await import('../../engines/acnet/backend')).acnetBackend,
  cunny: async () => (await import('../../engines/cunny/backend')).cunnyBackend,
  core: async () => (await import('../../engines/core/backend')).coreBackend,
};

const runtimeBackendCache = new Map<string, Promise<AlgorithmBackend>>();

export async function getRuntimeBackend(backendId: string): Promise<AlgorithmBackend> {
  const loader = runtimeBackendLoaders[backendId];
  if (!loader) {
    throw new Error(`Unknown runtime backend: ${backendId}`);
  }

  let backendPromise = runtimeBackendCache.get(backendId);
  if (!backendPromise) {
    backendPromise = loader();
    runtimeBackendCache.set(backendId, backendPromise);
  }

  return backendPromise;
}

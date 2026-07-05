import { describe, expect, it } from 'vitest';
import { createEffectBackend, createPipelineConstructorLoader } from '../../src/core/effects/backend-factory';
import type { EffectDescriptor } from '../../src/types';

class MockPipeline {
  constructor(private readonly outputTexture: GPUTexture) {}

  updateParam(): void {}

  pass(): void {}

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }
}

describe('effect backend factory', () => {
  const descriptors: EffectDescriptor[] = [
    {
      id: 'mock/Same/A',
      backendId: 'mock',
      key: 'A',
      name: 'A',
      category: 'custom',
      dimensionBehavior: { kind: 'same' },
      supportsVideoRealtime: true,
    },
    {
      id: 'mock/Upscale/B',
      backendId: 'mock',
      key: 'B',
      name: 'B',
      category: 'upscale',
      dimensionBehavior: { kind: 'scale', scale: 2 },
      supportsVideoRealtime: true,
    },
    {
      id: 'mock/Resize/C',
      backendId: 'mock',
      key: 'C',
      name: 'C',
      category: 'resize',
      dimensionBehavior: { kind: 'target' },
      supportsVideoRealtime: true,
    },
  ];

  const context = {
    device: { label: 'device' } as GPUDevice,
    inputTexture: { label: 'input' } as GPUTexture,
    sourceDimensions: { width: 160, height: 90 },
    currentDimensions: { width: 160, height: 90 },
    targetDimensions: { width: 640, height: 360 },
  };

  it('caches lazy payloads by backend and effect key', async () => {
    let aLoads = 0;
    let bLoads = 0;
    const backend = createEffectBackend({
      backendId: 'mock',
      backendDisplayName: 'Mock',
      descriptors,
      loaders: {
        A: async () => {
          aLoads += 1;
          return 'a-payload';
        },
        B: async () => {
          bLoads += 1;
          return 'b-payload';
        },
        C: async () => 'c-payload',
      },
      createPipeline(payload) {
        return new MockPipeline({ label: payload } as GPUTexture);
      },
    });

    const firstA = await backend.compileEffect({ id: 'mock/Same/A', backendId: 'mock', key: 'A' }, context);
    const secondA = await backend.compileEffect({ id: 'mock/Same/A', backendId: 'mock', key: 'A' }, context);
    const firstB = await backend.compileEffect({ id: 'mock/Upscale/B', backendId: 'mock', key: 'B' }, context);

    expect(aLoads).toBe(1);
    expect(bLoads).toBe(1);
    expect(firstA.outputTexture.label).toBe('a-payload');
    expect(secondA.outputTexture.label).toBe('a-payload');
    expect(firstB.outputTexture.label).toBe('b-payload');
  });

  it('uses descriptor dimension behavior and module ids consistently', async () => {
    const backend = createEffectBackend({
      backendId: 'mock',
      backendDisplayName: 'Mock',
      descriptors,
      loaders: {
        A: async () => 'a-payload',
        B: async () => 'b-payload',
        C: async () => 'c-payload',
      },
      createPipeline(payload) {
        return new MockPipeline({ label: payload } as GPUTexture);
      },
    });

    const same = await backend.compileEffect({ id: 'mock/Same/A', backendId: 'mock', key: 'A' }, context);
    const scaled = await backend.compileEffect({ id: 'mock/Upscale/B', backendId: 'mock', key: 'B' }, context);
    const target = await backend.compileEffect({ id: 'mock/Resize/C', backendId: 'mock', key: 'C' }, context);

    expect(same.outputDimensions).toEqual(context.currentDimensions);
    expect(same.requiredModules).toEqual(['mock:A']);
    expect(scaled.outputDimensions).toEqual({ width: 320, height: 180 });
    expect(scaled.requiredModules).toEqual(['mock:B']);
    expect(target.outputDimensions).toEqual(context.targetDimensions);
    expect(target.requiredModules).toEqual(['mock:C']);
  });

  it('throws a backend-specific error for unsupported effect keys', async () => {
    const backend = createEffectBackend({
      backendId: 'mock',
      backendDisplayName: 'Mock',
      descriptors,
      loaders: {
        A: async () => 'a-payload',
        B: async () => 'b-payload',
        C: async () => 'c-payload',
      },
      createPipeline(payload) {
        return new MockPipeline({ label: payload } as GPUTexture);
      },
    });

    await expect(
      backend.compileEffect({ id: 'mock/Missing', backendId: 'mock', key: 'Missing' }, context),
    ).rejects.toThrow('Unsupported Mock effect: Missing');
  });

  it('throws a clear error when a dynamic module is missing the requested pipeline export', async () => {
    const loadPipeline = createPipelineConstructorLoader(
      async (): Promise<Record<string, typeof MockPipeline>> => ({ OtherPipeline: MockPipeline }),
      'ExpectedPipeline',
    );

    await expect(loadPipeline()).rejects.toThrow('Pipeline export not found: ExpectedPipeline');
  });
});

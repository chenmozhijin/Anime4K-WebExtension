import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { EffectDescriptor, EffectReference } from '../../src/types';
import { internalResizeDescriptor, internalResizeEffectReference } from '../../src/engines/core/catalog';

const { mockGetEffectDescriptor, mockGetRuntimeBackend } = vi.hoisted(() => ({
  mockGetEffectDescriptor: vi.fn(),
  mockGetRuntimeBackend: vi.fn(),
}));

vi.mock('../../src/core/effects/registry', () => ({
  getEffectDescriptor: mockGetEffectDescriptor,
}));

vi.mock('../../src/core/effects/runtime-registry', () => ({
  getRuntimeBackend: mockGetRuntimeBackend,
}));

import { compileEffectChain } from '../../src/core/effects/chain-compiler';

function createDescriptor(
  overrides: Partial<EffectDescriptor> & Pick<EffectDescriptor, 'id' | 'backendId' | 'key'>,
): EffectDescriptor {
  return {
    name: overrides.key,
    category: 'custom',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
    ...overrides,
  };
}

describe('compileEffectChain', () => {
  const inputTexture = { label: 'input' } as GPUTexture;
  const device = {} as GPUDevice;

  beforeEach(() => {
    mockGetEffectDescriptor.mockReset();
    mockGetRuntimeBackend.mockReset();
  });

  it('returns a passthrough plan when there are no effects', async () => {
    const plan = await compileEffectChain({
      device,
      inputTexture,
      effects: [],
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 1280, height: 720 },
    });

    expect(plan.outputTexture).toBe(inputTexture);
    expect(plan.outputDimensions).toEqual({ width: 320, height: 180 });
    expect(plan.requiredModules).toEqual([]);
    expect(plan.warmupSteps).toBe(0);
    expect(plan.pipelines).toHaveLength(1);
    expect(mockGetRuntimeBackend).not.toHaveBeenCalled();
  });

  it('throws when an effect descriptor is missing', async () => {
    const missingEffect: EffectReference = {
      id: 'missing-effect',
      backendId: 'mock-backend',
      key: 'missing-effect',
    };

    mockGetEffectDescriptor.mockReturnValue(null);

    await expect(compileEffectChain({
      device,
      inputTexture,
      effects: [missingEffect],
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 1280, height: 720 },
    })).rejects.toThrow('Effect not found: missing-effect');
  });

  it('destroys already compiled passes when a later effect fails to compile', async () => {
    const firstEffect: EffectReference = {
      id: 'effect-a',
      backendId: 'backend-a',
      key: 'effect-a',
    };
    const failingEffect: EffectReference = {
      id: 'effect-b',
      backendId: 'backend-b',
      key: 'effect-b',
    };
    const destroyFirst = vi.fn();
    const descriptors = new Map<string, EffectDescriptor>([
      [firstEffect.id, createDescriptor({ ...firstEffect })],
      [failingEffect.id, createDescriptor({ ...failingEffect })],
    ]);

    mockGetEffectDescriptor.mockImplementation((effect: EffectReference) => descriptors.get(effect.id) ?? null);
    mockGetRuntimeBackend.mockImplementation(async (backendId: string) => {
      if (backendId === 'backend-a') {
        return {
          compileEffect: async () => ({
            pipelines: [{
              pass: vi.fn(),
              getOutputTexture: () => ({ label: 'first-output' } as GPUTexture),
              updateParam: vi.fn(),
              destroy: destroyFirst,
            }],
            outputTexture: { label: 'first-output' } as GPUTexture,
            outputDimensions: { width: 640, height: 360 },
            requiredModules: ['module-a'],
            warmupSteps: 1,
          }),
        };
      }

      return {
        compileEffect: async () => {
          throw new Error('backend compile failed');
        },
      };
    });

    await expect(compileEffectChain({
      device,
      inputTexture,
      effects: [firstEffect, failingEffect],
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 1280, height: 720 },
    })).rejects.toThrow('backend compile failed');

    expect(destroyFirst).toHaveBeenCalledOnce();
  });

  it('aggregates modules, warmup steps, and pipelines across multiple effects', async () => {
    const firstEffect: EffectReference = {
      id: 'effect-a',
      backendId: 'backend-a',
      key: 'effect-a',
    };
    const secondEffect: EffectReference = {
      id: 'effect-b',
      backendId: 'backend-b',
      key: 'effect-b',
    };
    const descriptors = new Map<string, EffectDescriptor>([
      [firstEffect.id, createDescriptor({ ...firstEffect })],
      [secondEffect.id, createDescriptor({ ...secondEffect })],
    ]);
    const firstPipeline = {
      pass: vi.fn(),
      getOutputTexture: vi.fn(),
      updateParam: vi.fn(),
    };
    const secondPipeline = {
      pass: vi.fn(),
      getOutputTexture: vi.fn(),
      updateParam: vi.fn(),
    };
    const firstOutputTexture = { label: 'first-output' } as GPUTexture;
    const secondOutputTexture = { label: 'second-output' } as GPUTexture;
    const compileCalls: Array<{ effect: EffectReference; context: any }> = [];

    mockGetEffectDescriptor.mockImplementation((effect: EffectReference) => descriptors.get(effect.id) ?? null);
    mockGetRuntimeBackend.mockImplementation(async (backendId: string) => {
      if (backendId === 'backend-a') {
        return {
          compileEffect: async (effect: EffectReference, context: any) => {
            compileCalls.push({ effect, context });
            return {
              pipelines: [firstPipeline],
              outputTexture: firstOutputTexture,
              outputDimensions: { width: 640, height: 360 },
              requiredModules: ['module-a', 'shared-module'],
              warmupSteps: 1,
            };
          },
        };
      }

      return {
        compileEffect: async (effect: EffectReference, context: any) => {
          compileCalls.push({ effect, context });
          return {
            pipelines: [secondPipeline],
            outputTexture: secondOutputTexture,
            outputDimensions: { width: 1280, height: 720 },
            requiredModules: ['shared-module', 'module-b'],
            warmupSteps: 2,
          };
        },
      };
    });

    const plan = await compileEffectChain({
      device,
      inputTexture,
      effects: [firstEffect, secondEffect],
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 1280, height: 720 },
    });

    expect(plan.pipelines).toEqual([firstPipeline, secondPipeline]);
    expect(plan.outputTexture).toBe(secondOutputTexture);
    expect(plan.outputDimensions).toEqual({ width: 1280, height: 720 });
    expect(plan.requiredModules).toEqual(['module-a', 'shared-module', 'module-b']);
    expect(plan.warmupSteps).toBe(3);
    expect(compileCalls).toHaveLength(2);
    expect(compileCalls[1].context.inputTexture).toBe(firstOutputTexture);
    expect(compileCalls[1].context.currentDimensions).toEqual({ width: 640, height: 360 });
  });

  it('inserts an internal resize between oversized upscale stages', async () => {
    const firstUpscale: EffectReference = {
      id: 'upscale-a',
      backendId: 'anime4k',
      key: 'upscale-a',
    };
    const secondUpscale: EffectReference = {
      id: 'upscale-b',
      backendId: 'anime4k',
      key: 'upscale-b',
    };
    const descriptors = new Map<string, EffectDescriptor>([
      [firstUpscale.id, createDescriptor({ ...firstUpscale, dimensionBehavior: { kind: 'scale', scale: 2 } })],
      [secondUpscale.id, createDescriptor({ ...secondUpscale, dimensionBehavior: { kind: 'scale', scale: 2 } })],
      [internalResizeEffectReference.id, internalResizeDescriptor],
    ]);
    const resizeOutputTexture = { label: 'resize-output' } as GPUTexture;
    const finalOutputTexture = { label: 'final-output' } as GPUTexture;
    const compileOrder: Array<{ effect: EffectReference; context: any }> = [];

    mockGetEffectDescriptor.mockImplementation((effect: EffectReference) => descriptors.get(effect.id) ?? null);
    mockGetRuntimeBackend.mockImplementation(async (backendId: string) => {
      if (backendId === internalResizeEffectReference.backendId) {
        return {
          compileEffect: async (effect: EffectReference, context: any) => {
            compileOrder.push({ effect, context });
            return {
              pipelines: [{
                pass: vi.fn(),
                getOutputTexture: () => resizeOutputTexture,
                updateParam: vi.fn(),
              }],
              outputTexture: resizeOutputTexture,
              outputDimensions: { width: 50, height: 50 },
              requiredModules: ['core:resize-linear-internal'],
              warmupSteps: 1,
            };
          },
        };
      }

      return {
        compileEffect: async (effect: EffectReference, context: any) => {
          compileOrder.push({ effect, context });
          if (effect.id === firstUpscale.id) {
            return {
              pipelines: [{
                pass: vi.fn(),
                getOutputTexture: () => ({ label: 'first-upscale-output' } as GPUTexture),
                updateParam: vi.fn(),
              }],
              outputTexture: { label: 'first-upscale-output' } as GPUTexture,
              outputDimensions: { width: 120, height: 120 },
              requiredModules: ['anime4k:upscale-a'],
              warmupSteps: 2,
            };
          }

          return {
            pipelines: [{
              pass: vi.fn(),
              getOutputTexture: () => finalOutputTexture,
              updateParam: vi.fn(),
            }],
            outputTexture: finalOutputTexture,
            outputDimensions: { width: 100, height: 100 },
            requiredModules: ['anime4k:upscale-b'],
            warmupSteps: 3,
          };
        },
      };
    });

    const plan = await compileEffectChain({
      device,
      inputTexture,
      effects: [firstUpscale, secondUpscale],
      sourceDimensions: { width: 25, height: 25 },
      targetDimensions: { width: 100, height: 100 },
    });

    expect(compileOrder.map(entry => entry.effect.id)).toEqual([
      firstUpscale.id,
      internalResizeEffectReference.id,
      secondUpscale.id,
    ]);
    expect(compileOrder[1].context.targetDimensions).toEqual({ width: 50, height: 50 });
    expect(compileOrder[2].context.inputTexture).toBe(resizeOutputTexture);
    expect(compileOrder[2].context.currentDimensions).toEqual({ width: 50, height: 50 });
    expect(plan.outputTexture).toBe(finalOutputTexture);
    expect(plan.requiredModules).toEqual([
      'anime4k:upscale-a',
      'core:resize-linear-internal',
      'anime4k:upscale-b',
    ]);
    expect(plan.warmupSteps).toBe(6);
  });
});

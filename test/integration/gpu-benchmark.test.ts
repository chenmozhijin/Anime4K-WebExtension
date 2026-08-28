import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { installWebGpuMock } from '../support/webgpu';

const compileEffectChain = vi.fn();

vi.mock('../../src/core/effects/chain-compiler', () => ({
  compileEffectChain,
}));

describe('gpu benchmark', () => {
  beforeEach(() => {
    compileEffectChain.mockReset();
  });

  it('keeps benchmark flow intact and cleans up temporary state', async () => {
    const chromeMock = installChromeMock();
    const webgpu = installWebGpuMock();
    const destroySpy = vi.fn();
    const outputTexture = webgpu.device.createTexture({
      size: [3840, 2160],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT,
    });

    compileEffectChain.mockResolvedValue({
      pipelines: [
        {
          pass: vi.fn(),
          getOutputTexture: () => outputTexture,
          updateParam: vi.fn(),
          destroy: destroySpy,
        },
      ],
      outputTexture,
      outputDimensions: { width: 3840, height: 2160 },
      warmupSteps: 1,
      requiredModules: ['test:benchmark'],
    });

    const { BENCHMARK_EFFECT_IDS, runGPUBenchmark } = await import('../../src/core/gpu-benchmark');
    const result = await runGPUBenchmark();

    expect(result.tier).toBeDefined();
    expect(compileEffectChain).toHaveBeenCalled();
    expect(destroySpy).toHaveBeenCalled();
    expect(chromeMock.__mock.localState._benchmarkInProgress).toBeUndefined();

    expect(BENCHMARK_EFFECT_IDS).toEqual({
      performance: 'acnet/Upscale/ARNet/F8B8_BOX_HDN',
      balanced: 'acnet/Upscale/ARNet/F8B16_BOX_HDN',
      quality: 'acnet/Upscale/ARNet/F8B32_BOX_HDN',
      ultra: 'acnet/Upscale/ARNet/F8B64_BOX_HDN',
    });
    expect(compileEffectChain.mock.calls.slice(0, 5).map(([options]) => (
      (options as { effects: Array<{ id: string }> }).effects.map(effect => effect.id)
    ))).toEqual([
      ['acnet/Upscale/ARNet/F8B8_BOX_HDN'],
      ['acnet/Upscale/ARNet/F8B8_BOX_HDN'],
      ['acnet/Upscale/ARNet/F8B16_BOX_HDN'],
      ['acnet/Upscale/ARNet/F8B32_BOX_HDN'],
      ['acnet/Upscale/ARNet/F8B64_BOX_HDN'],
    ]);
  });

  it('fails explicitly when GPU validation errors are captured during benchmark compilation', async () => {
    const chromeMock = installChromeMock();
    const webgpu = installWebGpuMock();
    const outputTexture = webgpu.device.createTexture({
      size: [3840, 2160],
      format: 'rgba16float',
      usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT,
    });

    compileEffectChain.mockImplementation(async ({ device }: { device: GPUDevice }) => {
      (device as unknown as { emitUncapturedError: (error: { name?: string; message?: string }) => void }).emitUncapturedError({
        name: 'GPUValidationError',
        message: 'benchmark validation failure',
      });

      return {
        pipelines: [
          {
            pass: vi.fn(),
            getOutputTexture: () => outputTexture,
            updateParam: vi.fn(),
            destroy: vi.fn(),
          },
        ],
        outputTexture,
        outputDimensions: { width: 3840, height: 2160 },
        warmupSteps: 1,
        requiredModules: ['test:benchmark-validation'],
      };
    });

    const { runGPUBenchmark } = await import('../../src/core/gpu-benchmark');

    await expect(runGPUBenchmark()).rejects.toThrow(/benchmark validation failure/);
    expect(chromeMock.__mock.localState._benchmarkInProgress).toBeUndefined();
  });
});

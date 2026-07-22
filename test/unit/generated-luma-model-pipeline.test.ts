import { beforeEach, describe, expect, it, vi } from 'vitest';

const { computePasses, fusedPasses, recomposePasses, borrowTextureMock, releaseTextureMock } = vi.hoisted(() => ({
  computePasses: [] as any[],
  fusedPasses: [] as any[],
  recomposePasses: [] as any[],
  borrowTextureMock: vi.fn(),
  releaseTextureMock: vi.fn(),
}));

vi.mock('../../src/core/gpu-passes/pixel-shuffle-recompose-pass', () => ({
  PixelShuffleRecomposePass: class MockPixelShuffleRecomposePass {
    readonly outputTexture: GPUTexture;
    readonly destroy = vi.fn();
    readonly pass = vi.fn();

    constructor(readonly options: any) {
      this.outputTexture = { label: `${options.name}: fused rgba output` } as GPUTexture;
      fusedPasses.push(this);
    }

    getOutputTexture(): GPUTexture {
      return this.outputTexture;
    }
  },
}));

vi.mock('../../src/core/gpu-passes/compute-texture-pass', () => ({
  ComputeTexturePass: class MockComputeTexturePass {
    readonly outputTexture: GPUTexture;
    readonly destroy = vi.fn();
    readonly pass = vi.fn();

    constructor(readonly options: any) {
      this.outputTexture = options.outputTexture ?? ({ label: `${options.name}: output` } as GPUTexture);
      computePasses.push(this);
    }

    getOutputTexture(): GPUTexture {
      return this.outputTexture;
    }
  },
}));

vi.mock('../../src/core/texture-pool', () => ({
  borrowTexture: borrowTextureMock,
  releaseTexture: releaseTextureMock,
  getTextureAllocationInfo: vi.fn(() => ({ byteSize: 1024, labelGroup: 'test' })),
}));

vi.mock('../../src/core/gpu-passes/luma-recompose-pass', () => ({
  defaultLumaRecomposeWGSL: 'default-luma-recompose',
  defaultLumaRecomposeTerminalWGSL: 'default-luma-recompose-terminal',
  LumaRecomposePass: class MockLumaRecomposePass {
    readonly outputTexture: GPUTexture;
    readonly destroy = vi.fn();
    readonly pass = vi.fn();

    constructor(readonly options: any) {
      this.outputTexture = { label: `${options.name}: rgba output` } as GPUTexture;
      recomposePasses.push(this);
    }

    getOutputTexture(): GPUTexture {
      return this.outputTexture;
    }
  },
}));

import { GeneratedLumaModelPipeline } from '../../src/core/generated-models/luma-model-pipeline';
import { ACNetGeneratedPipeline } from '../../src/engines/acnet/pipeline';
import { ArtCNNUpscalePipeline } from '../../src/engines/artcnn/pipelines/upscale/shared';
import { CuNNyGeneratedPipeline } from '../../src/engines/cunny/pipeline';
import { resolveOptimizationFeatureFlags } from '../../src/core/optimization-flags';

describe('GeneratedLumaModelPipeline', () => {
  const device = { label: 'device' } as GPUDevice;
  const inputTexture = { label: 'input' } as GPUTexture;
  const nativeDimensions = { width: 16, height: 9 };

  beforeEach(() => {
    computePasses.length = 0;
    fusedPasses.length = 0;
    recomposePasses.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
    borrowTextureMock.mockImplementation((options: any) => ({
      label: options.label,
      width: options.width,
      height: options.height,
    } as GPUTexture));
  });

  it('builds stages in manifest order and exposes final luma plus recomposed RGBA output', () => {
    const pipeline = new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'test-model',
      model: {
        key: 'TEST',
        name: 'Test Model',
        stages: [{
          name: 'stage 0',
          shaderWGSL: 'stage0',
          bindings: ['LUMA'],
          outputName: 'TMP',
          outputScale: 1,
          final: false,
        }, {
          name: 'stage 1',
          shaderWGSL: 'stage1',
          bindings: ['TMP'],
          outputName: 'OUT',
          outputScale: 2,
          final: true,
        }],
      },
    });

    expect(computePasses).toHaveLength(2);
    expect(computePasses[0].options.inputTextures).toEqual([inputTexture]);
    expect(computePasses[0].options.outputSize).toEqual({ width: 16, height: 9 });
    expect(computePasses[1].options.inputTextures).toEqual([computePasses[0].outputTexture]);
    expect(computePasses[1].options.outputSize).toEqual({ width: 32, height: 18 });
    expect(recomposePasses).toHaveLength(1);
    expect(recomposePasses[0].options.lumaTexture).toBe(computePasses[1].outputTexture);
    expect(recomposePasses[0].options.outputSize).toEqual({ width: 32, height: 18 });
    expect(pipeline.getLumaOutputTexture()).toBe(computePasses[1].outputTexture);
    expect(pipeline.getOutputTexture()).toBe(recomposePasses[0].outputTexture);

    pipeline.destroy();
    expect(computePasses[0].destroy).toHaveBeenCalledTimes(1);
    expect(computePasses[1].destroy).toHaveBeenCalledTimes(1);
    expect(recomposePasses[0].destroy).toHaveBeenCalledTimes(1);
  });

  it('fails fast for missing stage bindings and missing final luma output', () => {
    expect(() => new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'broken-model',
      model: {
        key: 'BROKEN',
        name: 'Broken Model',
        stages: [{
          name: 'stage 0',
          shaderWGSL: 'stage0',
          bindings: ['MISSING'],
          outputName: 'TMP',
          outputScale: 1,
          final: true,
        }],
      },
    })).toThrow('Broken Model: missing texture binding MISSING for stage 0.');

    expect(() => new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'no-final-model',
      model: {
        key: 'NO_FINAL',
        name: 'No Final Model',
        stages: [{
          name: 'stage 0',
          shaderWGSL: 'stage0',
          bindings: ['LUMA'],
          outputName: 'TMP',
          outputScale: 1,
          final: false,
        }],
      },
    })).toThrow('No Final Model: no final luma output stage generated.');
  });

  it('keeps ACNet and CuNNy wrapper differences declarative', () => {
    new ACNetGeneratedPipeline({
      device,
      inputTexture,
      nativeDimensions,
      model: {
        key: 'ACNET_TEST',
        name: 'ACNet Test',
        sourceFamily: 'acnet',
        stages: [{
          name: 'final',
          shaderWGSL: 'final',
          bindings: ['LUMA'],
          outputName: 'OUT',
          outputScale: 2,
          final: true,
        }],
      },
    });

    expect(computePasses[0].options.cacheKeyPrefix).toBe('acnet/stage');
    expect(computePasses[0].options.includeSampler).toBe(false);
    expect(computePasses[0].options.samplerBindingOrder).toBe('after-output');
    expect(computePasses[0].options.dispatchSize).toEqual({ width: 32, height: 18 });

    computePasses.length = 0;
    recomposePasses.length = 0;

    new CuNNyGeneratedPipeline({
      device,
      inputTexture,
      nativeDimensions,
      model: {
        key: 'CUNNY_TEST',
        name: 'CuNNy Test',
        variant: 'ds',
        stages: [{
          name: 'final',
          shaderWGSL: 'final',
          bindings: ['LUMA'],
          outputName: 'OUT',
          outputScale: { x: 3, y: 1 },
          final: true,
        }],
      },
    });

    expect(computePasses[0].options.cacheKeyPrefix).toBe('cunny/stage');
    expect(computePasses[0].options.includeSampler).toBe(true);
    expect(computePasses[0].options.samplerBindingOrder).toBe('before-output');
    expect(computePasses[0].options.dispatchSize).toEqual(nativeDimensions);
    expect(computePasses[0].options.outputSize).toEqual({ width: 48, height: 9 });
  });

  it('keeps legacy ACNet deconvolution on the non-terminal output path', () => {
    const terminalTarget = {
      width: 32,
      height: 18,
      format: 'bgra8unorm' as const,
      getCurrentView: vi.fn(),
    };

    new ACNetGeneratedPipeline({
      device,
      inputTexture,
      nativeDimensions,
      terminalTarget,
      model: {
        key: 'ACNET_LEGACY_TEST',
        name: 'ACNet Legacy Test',
        sourceFamily: 'acnet-legacy',
        stages: [{
          name: 'legacy deconv',
          shaderWGSL: 'legacy-deconv',
          bindings: ['LUMA'],
          outputName: 'OUT',
          outputScale: 2,
          final: true,
        }],
      },
    });

    expect(recomposePasses[0].options.terminalTarget).toBeUndefined();
  });

  it('keeps CuNNy on the non-terminal output path until its luma presenter is certified', () => {
    const terminalTarget = {
      width: 32,
      height: 18,
      format: 'bgra8unorm' as const,
      getCurrentView: vi.fn(),
    };

    new CuNNyGeneratedPipeline({
      device,
      inputTexture,
      nativeDimensions,
      terminalTarget,
      model: {
        key: 'CUNNY_TERMINAL_TEST',
        name: 'CuNNy Terminal Test',
        variant: 'ds',
        stages: [{
          name: 'final',
          shaderWGSL: 'final',
          bindings: ['LUMA'],
          outputName: 'OUT',
          outputScale: { x: 2, y: 2 },
          final: true,
        }],
      },
    });

    expect(recomposePasses[0].options.terminalTarget).toBeUndefined();
  });

  it('adapts ArtCNN variants to the shared generated LUMA runner', () => {
    new ArtCNNUpscalePipeline({
      device,
      inputTexture,
      nativeDimensions,
      targetDimensions: { width: 64, height: 36 },
    }, {
      name: 'ArtCNN Test',
      packedScale: { x: 3, y: 1 },
      shaders: {
        stage0: 'stage0',
        stage1: 'stage1',
        stage2: 'stage2',
        stage3: 'stage3',
        stage4: 'stage4',
        stage5: 'stage5',
        stage6: 'stage6',
      },
    });

    expect(computePasses).toHaveLength(7);
    expect(computePasses[0].options.cacheKeyPrefix).toBe('artcnn/stage');
    expect(computePasses[0].options.outputSize).toEqual({ width: 48, height: 9 });
    expect(computePasses[0].options.dispatchSize).toEqual(nativeDimensions);
    expect(computePasses[0].options.workgroupSize).toEqual({ width: 12, height: 16 });
    expect(computePasses[1].options.inputTextures).toEqual([computePasses[0].outputTexture]);
    expect(computePasses[5].options.inputTextures).toEqual([computePasses[4].outputTexture]);
    expect(computePasses[6].options.inputTextures).toEqual([
      computePasses[0].outputTexture,
      computePasses[5].outputTexture,
    ]);
    expect(computePasses[6].options.outputSize).toEqual({ width: 16, height: 9 });
    expect(recomposePasses[0].options.cacheKeyPrefix).toBe('artcnn');
    expect(recomposePasses[0].options.workgroupSize).toEqual({ width: 12, height: 16 });
  });

  it('selects certified optimized shaders independently from the baseline', () => {
    const model = {
      key: 'VARIANT',
      name: 'Variant Model',
      stages: [{
        name: 'pixel shuffle',
        shaderWGSL: 'baseline-shader',
        optimizedShaderWGSL: 'optimized-shader',
        optimizationFlag: 'vectorizedPixelShuffle' as const,
        optimizedDispatchScale: 1,
        bindings: ['LUMA'],
        outputName: 'OUT',
        outputScale: 2,
        final: true,
      }],
    };

    new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'variant',
      model,
      optimizationFlags: resolveOptimizationFeatureFlags(),
    });
    expect(computePasses[0].options.shaderWGSL).toBe('optimized-shader');
    expect(computePasses[0].options.dispatchSize).toEqual(nativeDimensions);

    computePasses.length = 0;
    recomposePasses.length = 0;
    new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'variant',
      model,
      optimizationFlags: resolveOptimizationFeatureFlags({ vectorizedPixelShuffle: false }),
    });
    expect(computePasses[0].options.shaderWGSL).toBe('baseline-shader');
    expect(computePasses[0].options.dispatchSize).toEqual({ width: 32, height: 18 });
  });

  it('fuses a generated 2x pixel shuffle with luma recomposition without allocating the 2x luma texture', () => {
    const model = {
      key: 'FUSED_PIXEL_SHUFFLE',
      name: 'Fused Pixel Shuffle',
      stages: [{
        name: 'packed luma',
        shaderWGSL: 'packed-luma',
        bindings: ['LUMA'],
        outputName: 'PACKED',
        outputScale: 1,
        final: false,
      }, {
        name: 'pixel shuffle',
        shaderWGSL: 'pixel-shuffle',
        bindings: ['PACKED'],
        outputName: 'OUT',
        outputScale: 2,
        finalOperation: 'pixel-shuffle-2x' as const,
        final: true,
      }],
    };

    const pipeline = new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'fused-pixel-shuffle',
      model,
    });

    expect(computePasses).toHaveLength(1);
    expect(fusedPasses).toHaveLength(1);
    expect(recomposePasses).toHaveLength(0);
    expect(fusedPasses[0].options.packedLumaTexture).toBe(computePasses[0].outputTexture);
    expect(fusedPasses[0].options.outputSize).toEqual({ width: 32, height: 18 });
    expect(pipeline.getLumaOutputTexture()).toBeUndefined();
    expect(borrowTextureMock).toHaveBeenCalledTimes(1);

    pipeline.destroy();
    expect(fusedPasses[0].destroy).toHaveBeenCalledOnce();

    computePasses.length = 0;
    fusedPasses.length = 0;
    recomposePasses.length = 0;
    borrowTextureMock.mockClear();

    new GeneratedLumaModelPipeline({
      device,
      inputTexture,
      nativeDimensions,
      cacheKeyPrefix: 'fused-pixel-shuffle',
      model,
      optimizationFlags: resolveOptimizationFeatureFlags({ fusedPixelShuffleRecompose: false }),
    });

    expect(computePasses).toHaveLength(2);
    expect(fusedPasses).toHaveLength(0);
    expect(recomposePasses).toHaveLength(1);
    expect(borrowTextureMock).toHaveBeenCalledTimes(2);
  });
});

import { describe, expect, it } from 'vitest';
import { buildErrorPresentation } from '../../src/core/error-presentation';
import { RendererRuntimeError } from '../../src/core/errors';

const baseOptions = {
  phase: 'render' as const,
  enableCrossOriginFix: false,
  genericEnhanceMessage: 'Enhancement failed. Please try again.',
  genericRenderMessage: 'A rendering error occurred.',
  crossOriginHintMessage: 'Enhancement failed due to cross-origin restrictions. Please enable Compatibility Mode in the options.',
  knownMessages: {
    gpuUnsupported: 'This browser or GPU environment does not support WebGPU enhancement.',
    gpuOutOfMemory: 'GPU memory was exhausted while processing this video.',
    gpuDeviceLost: 'The GPU device was lost and could not be recovered.',
    textureDimensionExceeded: 'The selected upscaler needs an internal texture of {requiredWidth}x{requiredHeight}, which exceeds the current WebGPU device limit of {maxWidth}x{maxHeight}. Lower the processing resolution or try a different preset.',
    textureDimensionExceededWithAdapterLimit: 'The selected upscaler needs an internal texture of {requiredWidth}x{requiredHeight}, which exceeds the current WebGPU device limit of {maxWidth}x{maxHeight}. The adapter supports {adapterLimit}; reload the extension and try again. If it still fails, lower the processing resolution or try a different preset.',
    effectCompilationValidationFailed: 'GPU pipeline validation failed while preparing the effect chain.',
    effectCompilationFailed: 'Failed to prepare the GPU effect chain for this video.',
    effectWarmupValidationFailed: 'GPU pipeline validation failed while warming up the effect chain.',
    effectWarmupFailed: 'Failed to warm up the GPU effect chain for this video.',
    frameSubmissionValidationFailed: 'GPU pipeline validation failed while rendering video frames.',
    frameSubmissionFailed: 'The GPU failed while rendering video frames.',
  },
};

describe('error presentation', () => {
  it('maps cross-origin taint errors to the compatibility hint', () => {
    const error = new Error('Canvas has been tainted by cross-origin data.');
    error.name = 'SecurityError';

    const presentation = buildErrorPresentation(error, baseOptions);

    expect(presentation.summary).toContain('cross-origin');
    expect(presentation.showOptionsLink).toBe(true);
  });

  it('maps wrapped cross-origin taint errors to the compatibility hint', () => {
    const cause = new Error('Canvas has been tainted by cross-origin data.');
    cause.name = 'SecurityError';
    const error = new RendererRuntimeError('Frame processing failed: ' + cause.message, { cause });

    const presentation = buildErrorPresentation(error, baseOptions);

    expect(presentation.summary).toContain('cross-origin');
    expect(presentation.showOptionsLink).toBe(true);
  });

  it('summarizes WebGPU validation failures with stage-aware messaging', () => {
    const rootCause = new Error('WebGPU failed during effect compilation: [validation] bind-group:test: mock mismatch');
    rootCause.name = 'RendererRuntimeError';

    const presentation = buildErrorPresentation(rootCause, baseOptions);

    expect(presentation.summary).toBe('GPU pipeline validation failed while preparing the effect chain.');
    expect(presentation.details).toContain('bind-group:test');
  });

  it('keeps stage-aware summaries when effect names are appended to GPU stage context', () => {
    const rootCause = new Error(
      'WebGPU failed during effect compilation (Upscale ArtCNN x2 (C4F16)): [validation] mock mismatch',
    );
    rootCause.name = 'RendererRuntimeError';

    const presentation = buildErrorPresentation(rootCause, baseOptions);

    expect(presentation.summary).toBe('GPU pipeline validation failed while preparing the effect chain.');
    expect(presentation.details).toContain('Upscale ArtCNN x2 (C4F16)');
  });

  it('explains oversized WebGPU intermediate textures with actionable limits', () => {
    const error = new Error(
      'WebGPU failed during effect compilation (Upscale CuNNy 4x32 DS x2): [unknown] uncapturederror: Texture size ([Extent3D width:10240, height:2880, depthOrArrayLayers:1]) exceeded maximum texture size ([Extent3D width:8192, height:8192, depthOrArrayLayers:256]). This adapter supports a higher maxTextureDimension2D of 16384, which can be specified in requiredLimits when calling requestDevice(). | [unknown] uncapturederror: [Invalid Texture "cunny SSA stage slot 0"] is invalid due to a previous error. | WebGPU failed during effect compilation (Upscale CuNNy 4x32 DS x2): [unknown] uncapturederror: [Invalid Texture "cunny SSA stage slot 1"] is invalid due to a previous error.',
    );
    error.name = 'RendererRuntimeError';

    const presentation = buildErrorPresentation(error, baseOptions);

    expect(presentation.summary).toBe(
      'The selected upscaler needs an internal texture of 10240x2880, which exceeds the current WebGPU device limit of 8192x8192. The adapter supports 16384; reload the extension and try again. If it still fails, lower the processing resolution or try a different preset.',
    );
    expect(presentation.details).toContain('Texture size ([Extent3D width:10240, height:2880');
    expect(presentation.details).toContain('This adapter supports a higher maxTextureDimension2D of 16384');
    expect(presentation.details).not.toContain('Invalid Texture');
  });

  it('surfaces device loss as a user-readable summary', () => {
    const error = new Error('Failed to recover from device loss');

    const presentation = buildErrorPresentation(error, baseOptions);

    expect(presentation.summary).toBe('The GPU device was lost and could not be recovered.');
  });

  it('preserves short non-technical messages as summaries', () => {
    const error = new Error('Failed to reload video with cross-origin attribute.');

    const presentation = buildErrorPresentation(error, {
      ...baseOptions,
      phase: 'enhance',
    });

    expect(presentation.summary).toBe('Failed to reload video with cross-origin attribute.');
  });
});

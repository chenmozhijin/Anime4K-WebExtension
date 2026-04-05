import { describe, expect, it } from 'vitest';
import { buildErrorPresentation } from '../../src/core/error-presentation';

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

  it('summarizes WebGPU validation failures with stage-aware messaging', () => {
    const rootCause = new Error('WebGPU failed during effect compilation: [validation] bind-group:test: mock mismatch');
    rootCause.name = 'RendererRuntimeError';

    const presentation = buildErrorPresentation(rootCause, baseOptions);

    expect(presentation.summary).toBe('GPU pipeline validation failed while preparing the effect chain.');
    expect(presentation.details).toContain('bind-group:test');
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

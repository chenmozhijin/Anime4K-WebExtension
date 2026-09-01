import { describe, expect, it } from 'vitest';
import {
  normalizeError,
  RendererInitializationError,
  RendererRuntimeError,
} from '../../src/core/errors';

describe('renderer errors', () => {
  it('does not emit an undefined cause property when no cause is supplied', () => {
    const error = new RendererInitializationError('initialization failed');

    expect(Object.prototype.hasOwnProperty.call(error, 'cause')).toBe(false);
    expect(error.cause).toBeUndefined();
  });

  it('removes an explicitly undefined cause instead of exposing it', () => {
    const error = new RendererRuntimeError('runtime failed', { cause: undefined });

    expect(Object.prototype.hasOwnProperty.call(error, 'cause')).toBe(false);
  });

  it('normalizes non-Error causes and preserves their message and name', () => {
    const error = new RendererRuntimeError('runtime failed', {
      cause: { name: 'OperationError', message: 'GPU operation rejected' },
    });

    expect(error.cause).toBeInstanceOf(Error);
    expect(error.cause).toMatchObject({
      name: 'OperationError',
      message: 'GPU operation rejected',
    });
  });

  it('uses a diagnostic fallback for an undefined thrown value', () => {
    const normalized = normalizeError(undefined, 'Renderer initialization produced no error detail.');

    expect(normalized).toBeInstanceOf(Error);
    expect(normalized.message).toBe('Renderer initialization produced no error detail.');
  });
});

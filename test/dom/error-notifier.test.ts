import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { EnhancerErrorNotifier } from '../../src/core/video-enhancer/error-notifier';

describe('EnhancerErrorNotifier', () => {
  it('renders notifications with technical details and dismiss controls', () => {
    installChromeMock();
    vi.useFakeTimers();
    const notifier = new EnhancerErrorNotifier();
    const validationError = new Error('WebGPU failed during effect compilation: [validation] bad bind group');
    validationError.name = 'RendererRuntimeError';

    notifier.present(validationError, 'render', {
      enableCrossOriginFix: false,
    });

    const notification = document.querySelector('[data-nijilucid-error-notification]');
    expect(notification).not.toBeNull();
    expect(notification?.textContent).toContain('extensionName');
    expect(notification?.textContent).toContain('gpuEffectCompilationValidationFailed');
    expect(notification?.querySelector('details')).not.toBeNull();

    notification?.querySelector('button')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(document.querySelector('[data-nijilucid-error-notification]')).toBeNull();

    vi.useRealTimers();
  });

  it('opens the options page for cross-origin guidance and clears existing notifications', () => {
    const chromeMock = installChromeMock();
    const notifier = new EnhancerErrorNotifier();
    const error = new Error('Canvas has been tainted by cross-origin data.');
    error.name = 'SecurityError';

    notifier.present(error, 'enhance', {
      enableCrossOriginFix: false,
    });

    const link = document.querySelector('[data-nijilucid-error-notification] a');
    expect(link).not.toBeNull();
    link?.dispatchEvent(new MouseEvent('click', { bubbles: true }));

    expect(chromeMock.__mock.runtimeMessages).toContainEqual({ type: 'OPEN_OPTIONS_PAGE' });

    notifier.clear();
    expect(document.querySelector('[data-nijilucid-error-notification]')).toBeNull();
  });

  it('clears only notifications owned by the same notifier instance', () => {
    installChromeMock();
    const first = new EnhancerErrorNotifier();
    const second = new EnhancerErrorNotifier();

    first.present(new Error('first failure'), 'render', {
      enableCrossOriginFix: false,
    });
    second.present(new Error('second failure'), 'render', {
      enableCrossOriginFix: false,
    });

    expect(document.querySelectorAll('[data-nijilucid-error-notification]')).toHaveLength(2);

    first.clear();

    const remaining = document.querySelectorAll('[data-nijilucid-error-notification]');
    expect(remaining).toHaveLength(1);
    expect(remaining[0].textContent).toContain('second failure');

    second.clear();
  });
});

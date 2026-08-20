import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { PointerRevealCoordinator } from '../../src/core/pointer-reveal-coordinator';

const zone = { left: 10, right: 114, top: 20, bottom: 116 };

function dispatchPointerMove(
  x: number,
  y: number,
  options: { pointerType?: string; buttons?: number } = {},
): void {
  const event = new Event('pointermove');
  Object.defineProperties(event, {
    clientX: { value: x },
    clientY: { value: y },
    pointerType: { value: options.pointerType ?? 'mouse' },
    buttons: { value: options.buttons ?? 0 },
  });
  window.dispatchEvent(event);
}

function dispatchTouchPointerDown(x: number, y: number): Event {
  const event = new Event('pointerdown', { cancelable: true });
  Object.defineProperties(event, {
    clientX: { value: x },
    clientY: { value: y },
    pointerType: { value: 'touch' },
    buttons: { value: 1 },
  });
  window.dispatchEvent(event);
  return event;
}

describe('PointerRevealCoordinator', () => {
  let frameCallbacks: FrameRequestCallback[];

  beforeEach(() => {
    vi.useFakeTimers();
    frameCallbacks = [];
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation(callback => {
      frameCallbacks.push(callback);
      return frameCallbacks.length;
    });
    vi.spyOn(window, 'cancelAnimationFrame').mockImplementation(() => undefined);
    Object.defineProperty(document, 'visibilityState', {
      configurable: true,
      value: 'visible',
    });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  function flushFrame(): void {
    const callbacks = frameCallbacks.splice(0);
    callbacks.forEach(callback => callback(16));
  }

  it('coalesces pointer events into one non-recurring animation frame', () => {
    const coordinator = new PointerRevealCoordinator(window, document);
    const registration = coordinator.register({
      onReveal: vi.fn(),
      onPresenceChange: vi.fn(),
    });
    registration.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    dispatchPointerMove(20, 30);
    dispatchPointerMove(30, 40);
    dispatchPointerMove(40, 50);

    expect(window.requestAnimationFrame).toHaveBeenCalledOnce();
    flushFrame();
    expect(frameCallbacks).toHaveLength(0);

    registration.dispose();
  });

  it('keeps the original dwell deadline while the pointer moves inside the zone', () => {
    const onReveal = vi.fn();
    const onPresenceChange = vi.fn();
    const coordinator = new PointerRevealCoordinator(window, document, 220);
    const registration = coordinator.register({ onReveal, onPresenceChange });
    registration.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    dispatchPointerMove(20, 30);
    flushFrame();
    vi.advanceTimersByTime(120);
    dispatchPointerMove(90, 90);
    flushFrame();
    vi.advanceTimersByTime(100);

    expect(onPresenceChange).toHaveBeenCalledTimes(1);
    expect(onPresenceChange).toHaveBeenCalledWith(true);
    expect(onReveal).toHaveBeenCalledOnce();

    registration.dispose();
  });

  it('cancels dwell after exit and requires exit before rearming a disarmed target', () => {
    const onReveal = vi.fn();
    const coordinator = new PointerRevealCoordinator(window, document, 220);
    const registration = coordinator.register({
      onReveal,
      onPresenceChange: vi.fn(),
    });
    registration.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    dispatchPointerMove(20, 30);
    flushFrame();
    registration.disarmUntilExit();
    vi.advanceTimersByTime(220);
    expect(onReveal).not.toHaveBeenCalled();

    dispatchPointerMove(200, 200);
    flushFrame();
    dispatchPointerMove(30, 40);
    flushFrame();
    vi.advanceTimersByTime(220);
    expect(onReveal).toHaveBeenCalledOnce();

    registration.dispose();
  });

  it('reveals immediately for touch without consuming the page event', () => {
    const onReveal = vi.fn();
    const coordinator = new PointerRevealCoordinator(window, document, 220);
    const registration = coordinator.register({
      onReveal,
      onPresenceChange: vi.fn(),
    });
    registration.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    const event = dispatchTouchPointerDown(20, 30);

    expect(onReveal).toHaveBeenCalledOnce();
    expect(onReveal).toHaveBeenCalledWith('touch');
    expect(event.defaultPrevented).toBe(false);
    expect(window.requestAnimationFrame).not.toHaveBeenCalled();

    registration.dispose();
  });

  it('ignores touch movement, dragging, hidden documents, and disposed targets', () => {
    const onReveal = vi.fn();
    const coordinator = new PointerRevealCoordinator(window, document, 220);
    const registration = coordinator.register({
      onReveal,
      onPresenceChange: vi.fn(),
    });
    registration.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    dispatchPointerMove(20, 30, { pointerType: 'touch' });
    flushFrame();
    dispatchPointerMove(20, 30, { buttons: 1 });
    flushFrame();
    vi.advanceTimersByTime(500);
    expect(onReveal).not.toHaveBeenCalled();

    Object.defineProperty(document, 'visibilityState', {
      configurable: true,
      value: 'hidden',
    });
    document.dispatchEvent(new Event('visibilitychange'));
    registration.dispose();
    dispatchPointerMove(20, 30);
    vi.advanceTimersByTime(500);
    expect(onReveal).not.toHaveBeenCalled();
  });

  it('prefers a playing target and removes pointer listeners after the last target is disposed', () => {
    const removeEventListener = vi.spyOn(window, 'removeEventListener');
    const playingReveal = vi.fn();
    const pausedReveal = vi.fn();
    const coordinator = new PointerRevealCoordinator(window, document, 220);
    const paused = coordinator.register({ onReveal: pausedReveal, onPresenceChange: vi.fn() });
    const playing = coordinator.register({ onReveal: playingReveal, onPresenceChange: vi.fn() });
    paused.update({ zone, enabled: true, revealable: true, playing: false, visibleArea: 1000 });
    playing.update({ zone, enabled: true, revealable: true, playing: true, visibleArea: 100 });

    dispatchPointerMove(20, 30);
    flushFrame();
    vi.advanceTimersByTime(220);

    expect(playingReveal).toHaveBeenCalledOnce();
    expect(pausedReveal).not.toHaveBeenCalled();

    paused.dispose();
    playing.dispose();
    expect(removeEventListener).toHaveBeenCalledWith('pointermove', expect.any(Function), true);
    expect(removeEventListener).toHaveBeenCalledWith('pointerdown', expect.any(Function), true);
  });
});

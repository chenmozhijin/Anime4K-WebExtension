import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { OverlayManager } from '../../src/core/overlay-manager';
import type { FramePerformanceSnapshot } from '../../src/types';

class MockResizeObserver {
  public readonly observe = vi.fn();
  public readonly disconnect = vi.fn();

  constructor(public readonly callback: ResizeObserverCallback) {
    resizeObservers.push(this);
  }
}

class MockMutationObserver {
  public readonly observe = vi.fn();
  public readonly disconnect = vi.fn();

  constructor(public readonly callback: MutationCallback) {
    mutationObservers.push(this);
  }
}

let nextFrameId = 1;
const rafCallbacks = new Map<number, FrameRequestCallback>();
const resizeObservers: MockResizeObserver[] = [];
const mutationObservers: MockMutationObserver[] = [];

function flushAnimationFrames(times = 1): void {
  for (let index = 0; index < times; index += 1) {
    const pending = [...rafCallbacks.values()];
    rafCallbacks.clear();
    pending.forEach(callback => callback(16));
  }
}

function createVideo(parent: Element | ShadowRoot, slotId?: string): HTMLVideoElement {
  const video = document.createElement('video');
  if (slotId) {
    video.setAttribute('data-nijilucid-overlay-slot', slotId);
  }

  Object.defineProperties(video, {
    offsetTop: { configurable: true, get: () => 12 },
    offsetLeft: { configurable: true, get: () => 24 },
    offsetWidth: { configurable: true, get: () => 320 },
    offsetHeight: { configurable: true, get: () => 180 },
    videoWidth: { configurable: true, value: 320 },
    videoHeight: { configurable: true, value: 180 },
  });
  vi.spyOn(video, 'getBoundingClientRect').mockReturnValue({
    top: 12,
    left: 24,
    width: 320,
    height: 180,
    bottom: 192,
    right: 344,
    x: 24,
    y: 12,
    toJSON: () => ({}),
  } as DOMRect);
  parent.appendChild(video);
  return video;
}

function createResizableVideo(parent: Element): {
  video: HTMLVideoElement;
  setSize(width: number, height: number): void;
} {
  let width = 0;
  let height = 0;
  const video = document.createElement('video');
  Object.defineProperties(video, {
    offsetTop: { configurable: true, get: () => 12 },
    offsetLeft: { configurable: true, get: () => 24 },
    offsetWidth: { configurable: true, get: () => width },
    offsetHeight: { configurable: true, get: () => height },
    videoWidth: { configurable: true, get: () => width },
    videoHeight: { configurable: true, get: () => height },
  });
  vi.spyOn(video, 'getBoundingClientRect').mockImplementation(() => ({
    top: 12,
    left: 24,
    width,
    height,
    bottom: 12 + height,
    right: 24 + width,
    x: 24,
    y: 12,
    toJSON: () => ({}),
  } as DOMRect));
  parent.appendChild(video);
  return {
    video,
    setSize(nextWidth, nextHeight) {
      width = nextWidth;
      height = nextHeight;
    },
  };
}

function dispatchPointerMove(x: number, y: number): void {
  const event = new Event('pointermove');
  Object.defineProperties(event, {
    clientX: { value: x },
    clientY: { value: y },
    pointerType: { value: 'mouse' },
    buttons: { value: 0 },
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

function createPerformanceSnapshot(overrides: Partial<FramePerformanceSnapshot> = {}): FramePerformanceSnapshot {
  return {
    mode: 'gpu',
    timingSource: 'mixed',
    gpuName: 'Mock GPU',
    uploadMethod: 'VideoFrame direct',
    modeName: 'Mode A',
    tier: 'balanced',
    sourceDimensions: { width: 1280, height: 720 },
    targetDimensions: { width: 2560, height: 1440 },
    fps: 60,
    droppedFrameRate: 0,
    frameMs: 16,
    uploadMs: 0.2,
    encodeMs: 2,
    submitMs: 0.1,
    passEntries: [],
    groupEntries: [],
    budgetMs: 1000 / 60,
    timestampAvailable: true,
    ...overrides,
  };
}

function installHudI18nMessages(): void {
  vi.spyOn(chrome.i18n, 'getMessage').mockImplementation((key: string) => ({
    hudLabelCpu: 'CPU',
    hudLabelGpu: 'GPU',
    hudLabelFps: 'FPS',
    hudLabelDrop: 'Drop',
    hudLabelRenderTime: 'Render time',
    hudLabelTotal: 'Total',
  }[key] ?? ''));
}

describe('OverlayManager', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    installChromeMock();
    nextFrameId = 1;
    rafCallbacks.clear();
    resizeObservers.length = 0;
    mutationObservers.length = 0;

    Object.assign(globalThis, {
      ResizeObserver: MockResizeObserver,
      MutationObserver: MockMutationObserver,
      requestAnimationFrame: (callback: FrameRequestCallback) => {
        const id = nextFrameId++;
        rafCallbacks.set(id, callback);
        return id;
      },
      cancelAnimationFrame: (id: number) => {
        rafCallbacks.delete(id);
      },
    });
    vi.spyOn(window, 'getComputedStyle').mockImplementation(() => ({
      transform: 'none',
      transformOrigin: 'center center',
      borderRadius: '8px',
      objectFit: 'contain',
      objectPosition: 'center',
      zIndex: '10',
    } as CSSStyleDeclaration));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('cleans orphaned artifacts, manages canvas visibility, and destroys idempotently', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container, 'slot-a');

    const orphanHost = document.createElement('div');
    orphanHost.setAttribute('data-nijilucid-overlay-host', '');
    orphanHost.setAttribute('data-nijilucid-overlay-slot', 'slot-a');
    container.insertBefore(orphanHost, video);

    const orphanCanvasHost = document.createElement('div');
    orphanCanvasHost.setAttribute('data-nijilucid-overlay-canvas-host', '');
    orphanCanvasHost.setAttribute('data-nijilucid-overlay-slot', 'slot-a');
    container.insertBefore(orphanCanvasHost, video);

    const orphanBodyHost = document.createElement('div');
    orphanBodyHost.setAttribute('data-nijilucid-overlay-host', '');
    orphanBodyHost.setAttribute('data-nijilucid-overlay-slot', 'slot-a');
    document.body.appendChild(orphanBodyHost);

    const manager = OverlayManager.create(video);
    const button = manager.getButton();
    Object.defineProperty(document, 'elementFromPoint', {
      configurable: true,
      value: vi.fn(() => button),
    });

    flushAnimationFrames(2);

    expect(container.querySelectorAll('[data-nijilucid-overlay-host]')).toHaveLength(1);
    expect(container.querySelectorAll('[data-nijilucid-overlay-canvas-host]')).toHaveLength(0);
    expect(document.body.contains(orphanBodyHost)).toBe(false);

    video.style.opacity = '0.42';
    const canvas = manager.getCanvas();
    manager.showCanvas();
    flushAnimationFrames(2);

    expect(canvas.width).toBe(320);
    expect(canvas.height).toBe(180);
    expect(canvas.style.visibility).toBe('visible');
    expect(video.style.opacity).toBe('0');

    manager.hideCanvas();
    expect(container.querySelector('[data-nijilucid-overlay-canvas-host]')).toBeNull();
    expect(video.style.opacity).toBe('0.42');

    manager.destroy();
    manager.destroy();

    expect(container.querySelector('[data-nijilucid-overlay-host]')).toBeNull();
    expect(video.hasAttribute('data-nijilucid-overlay-slot')).toBe(false);
  });

  it('waits for a renderable video before starting the complete initial reveal window', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const { video, setSize } = createResizableVideo(container);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');

    flushAnimationFrames(2);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('unrenderable');
    vi.advanceTimersByTime(5000);

    setSize(320, 180);
    resizeObservers[0].callback([], resizeObservers[0] as unknown as ResizeObserver);
    flushAnimationFrames(2);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');

    vi.advanceTimersByTime(2999);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    vi.advanceTimersByTime(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');
    expect(manager.getButton().tabIndex).toBe(0);

    manager.destroy();
  });

  it('pauses the initial reveal window while the document is hidden', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');

    flushAnimationFrames(2);
    vi.advanceTimersByTime(1000);
    Object.defineProperty(document, 'visibilityState', {
      configurable: true,
      value: 'hidden',
    });
    document.dispatchEvent(new Event('visibilitychange'));
    flushAnimationFrames(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('unrenderable');

    vi.advanceTimersByTime(5000);
    Object.defineProperty(document, 'visibilityState', {
      configurable: true,
      value: 'visible',
    });
    document.dispatchEvent(new Event('visibilitychange'));
    flushAnimationFrames(2);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');

    vi.advanceTimersByTime(1999);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    vi.advanceTimersByTime(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    manager.destroy();
  });

  it('reveals a hidden button after dwelling in the logical region', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');

    flushAnimationFrames(2);
    vi.advanceTimersByTime(3000);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    // This point is outside the old 104x96 region but inside the 160x120 minimum.
    dispatchPointerMove(174, 157);
    flushAnimationFrames(1);
    vi.advanceTimersByTime(219);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');
    vi.advanceTimersByTime(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    expect(manager.getButton().tabIndex).toBe(0);

    manager.destroy();
  });

  it('reveals a hidden button on keyboard focus and keeps it visible until focus leaves', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');
    const button = manager.getButton();
    vi.spyOn(button, 'matches').mockImplementation(selector => selector === ':focus-visible');

    flushAnimationFrames(2);
    vi.advanceTimersByTime(3000);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    button.focus();
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    vi.advanceTimersByTime(5000);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');

    button.blur();
    vi.advanceTimersByTime(499);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    vi.advanceTimersByTime(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    manager.destroy();
  });

  it('reveals temporarily for touch without preventing the original page event', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');

    flushAnimationFrames(2);
    vi.advanceTimersByTime(3000);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    const event = dispatchTouchPointerDown(30, 100);
    expect(event.defaultPrevented).toBe(false);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');

    vi.advanceTimersByTime(2999);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');
    vi.advanceTimersByTime(1);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    manager.destroy();
  });

  it('scales the logical reveal region for large video players', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const { video, setSize } = createResizableVideo(container);
    setSize(1280, 720);
    const manager = OverlayManager.create(video);
    const host = container.querySelector('[data-nijilucid-overlay-host]');

    flushAnimationFrames(2);
    vi.advanceTimersByTime(3000);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('hidden');

    // The 22%/34% scaling reaches this point; the minimum-size region does not.
    dispatchPointerMove(274, 482);
    flushAnimationFrames(1);
    vi.advanceTimersByTime(220);
    expect(host?.getAttribute('data-nijilucid-button-state')).toBe('visible');

    manager.destroy();
  });

  it('switches to body strategy when obscured and reattaches to a new video', () => {
    const firstContainer = document.createElement('div');
    const secondContainer = document.createElement('div');
    document.body.append(firstContainer, secondContainer);
    const firstVideo = createVideo(firstContainer);
    const secondVideo = createVideo(secondContainer);

    const manager = OverlayManager.create(firstVideo);
    vi.spyOn(manager.getButton(), 'getBoundingClientRect').mockReturnValue({
      top: 20,
      left: 20,
      width: 40,
      height: 20,
      bottom: 40,
      right: 60,
      x: 20,
      y: 20,
      toJSON: () => ({}),
    } as DOMRect);
    Object.defineProperty(document, 'elementFromPoint', {
      configurable: true,
      value: vi.fn(() => document.body),
    });

    const canvas = manager.getCanvas();
    manager.showCanvas();
    flushAnimationFrames(5);

    const host = document.querySelector('[data-nijilucid-overlay-host]');
    expect(host?.parentElement).toBe(document.body);
    expect(canvas.parentElement?.hasAttribute('data-nijilucid-overlay-canvas-host')).toBe(true);

    manager.reattach(secondVideo);
    flushAnimationFrames(2);

    expect(secondVideo.hasAttribute('data-nijilucid-overlay-slot')).toBe(true);
    expect(document.querySelector('[data-nijilucid-overlay-host]')?.parentElement).toBe(document.body);
    expect(secondContainer.querySelector('[data-nijilucid-overlay-canvas-host]')).not.toBeNull();

    manager.detach();
    expect(document.querySelector('[data-nijilucid-overlay-host]')).toBeNull();
    expect(secondContainer.querySelector('[data-nijilucid-overlay-canvas-host]')).toBeNull();
    expect(secondVideo.style.opacity).toBe('');

    manager.destroy();
  });

  it('attaches overlays inside open shadow roots without switching to body strategy', () => {
    const host = document.createElement('div');
    document.body.appendChild(host);
    const shadowRoot = host.attachShadow({ mode: 'open' });
    const video = createVideo(shadowRoot);

    const manager = OverlayManager.create(video);
    Object.defineProperty(document, 'elementFromPoint', {
      configurable: true,
      value: vi.fn(() => document.body),
    });

    flushAnimationFrames(3);

    const overlayHost = shadowRoot.querySelector('[data-nijilucid-overlay-host]');
    expect(overlayHost).not.toBeNull();
    expect(overlayHost?.parentNode).toBe(shadowRoot);

    manager.destroy();
  });

  it('reattaches sibling overlay artifacts when the video moves to a new parent', () => {
    const firstContainer = document.createElement('div');
    const secondContainer = document.createElement('div');
    document.body.append(firstContainer, secondContainer);
    const video = createVideo(firstContainer);

    const manager = OverlayManager.create(video);
    const canvas = manager.getCanvas();
    manager.showCanvas();
    flushAnimationFrames(2);

    secondContainer.appendChild(video);
    mutationObservers.forEach(observer => observer.callback([], observer as unknown as MutationObserver));
    flushAnimationFrames(2);

    expect(secondContainer.querySelector('[data-nijilucid-overlay-host]')).not.toBeNull();
    expect(secondContainer.querySelector('[data-nijilucid-overlay-canvas-host]')).not.toBeNull();
    expect(canvas.parentElement?.parentElement).toBe(secondContainer);

    manager.destroy();
  });

  it('uses displayed pass timings for the performance HUD total', () => {
    installHudI18nMessages();
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const renderFullHud = (manager as unknown as {
      renderPerformanceHudFull(snapshot: FramePerformanceSnapshot): string;
    }).renderPerformanceHudFull.bind(manager);

    const html = renderFullHud(createPerformanceSnapshot({
      frameMs: 99,
      groupEntries: [
        { label: 'Upload', group: 'Upload', cpuMs: 10, gpuMs: 1.25, source: 'mixed' },
        { label: 'Final Blit', group: 'Final Blit', cpuMs: 20, gpuMs: 1.75, source: 'mixed' },
      ],
    }));
    const root = document.createElement('div');
    root.innerHTML = html;

    expect(root.querySelector('.hud-total .hud-ms')?.textContent).toBe('CPU+GPU 33.00 ms');
    expect(root.querySelector('.hud-stack')?.getAttribute('title')).toContain('CPU+GPU 33.00 ms');
    expect([...root.querySelectorAll('.hud-row .hud-ms')].map(row => row.textContent)).toContain('CPU 10.00 ms / GPU 1.25 ms');
    manager.destroy();
  });

  it('shows CPU-labeled pass timings outside GPU diagnostics', () => {
    installHudI18nMessages();
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container);
    const manager = OverlayManager.create(video);
    const renderers = manager as unknown as {
      renderPerformanceHudFull(snapshot: FramePerformanceSnapshot): string;
      renderPerformanceHudMini(snapshot: FramePerformanceSnapshot): string;
    };
    const snapshot = createPerformanceSnapshot({
      mode: 'lite',
      timingSource: 'cpu',
      timestampAvailable: false,
      frameMs: 8,
      groupEntries: [
        { label: 'Upload', group: 'Upload', cpuMs: 1.5, source: 'cpu' },
        { label: 'Final Blit', group: 'Final Blit', cpuMs: 2.5, source: 'cpu' },
      ],
    });
    const fullRoot = document.createElement('div');
    fullRoot.innerHTML = renderers.renderPerformanceHudFull.call(manager, snapshot);
    const miniRoot = document.createElement('div');
    miniRoot.innerHTML = renderers.renderPerformanceHudMini.call(manager, snapshot);

    expect(fullRoot.querySelector('.hud-total .hud-ms')?.textContent).toBe('CPU 4.00 ms');
    expect([...fullRoot.querySelectorAll('.hud-row .hud-ms')].map(row => row.textContent)).toContain('CPU 1.50 ms');
    expect(fullRoot.querySelector('.hud-hint')).toBeNull();
    expect(miniRoot.textContent).toContain('CPU 8.00 ms');
    manager.destroy();
  });
});

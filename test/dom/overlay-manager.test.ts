import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { OverlayManager } from '../../src/core/overlay-manager';

class MockResizeObserver {
  public readonly observe = vi.fn();
  public readonly disconnect = vi.fn();

  constructor(public readonly callback: ResizeObserverCallback) {}
}

class MockMutationObserver {
  public readonly observe = vi.fn();
  public readonly disconnect = vi.fn();

  constructor(public readonly callback: MutationCallback) {}
}

let nextFrameId = 1;
const rafCallbacks = new Map<number, FrameRequestCallback>();

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
    video.setAttribute('data-anime4k-overlay-slot', slotId);
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

describe('OverlayManager', () => {
  beforeEach(() => {
    installChromeMock();
    nextFrameId = 1;
    rafCallbacks.clear();

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

  it('cleans orphaned artifacts, manages canvas visibility, and destroys idempotently', () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    const video = createVideo(container, 'slot-a');

    const orphanHost = document.createElement('div');
    orphanHost.setAttribute('data-anime4k-overlay-host', '');
    orphanHost.setAttribute('data-anime4k-overlay-slot', 'slot-a');
    container.insertBefore(orphanHost, video);

    const orphanCanvasHost = document.createElement('div');
    orphanCanvasHost.setAttribute('data-anime4k-overlay-canvas-host', '');
    orphanCanvasHost.setAttribute('data-anime4k-overlay-slot', 'slot-a');
    container.insertBefore(orphanCanvasHost, video);

    const orphanBodyHost = document.createElement('div');
    orphanBodyHost.setAttribute('data-anime4k-overlay-host', '');
    orphanBodyHost.setAttribute('data-anime4k-overlay-slot', 'slot-a');
    document.body.appendChild(orphanBodyHost);

    const manager = OverlayManager.create(video);
    const button = manager.getButton();
    Object.defineProperty(document, 'elementFromPoint', {
      configurable: true,
      value: vi.fn(() => button),
    });

    flushAnimationFrames(2);

    expect(container.querySelectorAll('[data-anime4k-overlay-host]')).toHaveLength(1);
    expect(container.querySelectorAll('[data-anime4k-overlay-canvas-host]')).toHaveLength(0);
    expect(document.body.contains(orphanBodyHost)).toBe(false);

    const canvas = manager.getCanvas();
    manager.showCanvas();
    flushAnimationFrames(2);

    expect(canvas.width).toBe(320);
    expect(canvas.height).toBe(180);
    expect(canvas.style.visibility).toBe('visible');
    expect(video.style.opacity).toBe('0');

    manager.hideCanvas();
    expect(container.querySelector('[data-anime4k-overlay-canvas-host]')).toBeNull();
    expect(video.style.opacity).toBe('');

    manager.destroy();
    manager.destroy();

    expect(container.querySelector('[data-anime4k-overlay-host]')).toBeNull();
    expect(video.hasAttribute('data-anime4k-overlay-slot')).toBe(false);
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

    const host = document.querySelector('[data-anime4k-overlay-host]');
    expect(host?.parentElement).toBe(document.body);
    expect(canvas.parentElement?.hasAttribute('data-anime4k-overlay-canvas-host')).toBe(true);

    manager.reattach(secondVideo);
    flushAnimationFrames(2);

    expect(secondVideo.hasAttribute('data-anime4k-overlay-slot')).toBe(true);
    expect(document.querySelector('[data-anime4k-overlay-host]')?.parentElement).toBe(document.body);
    expect(secondContainer.querySelector('[data-anime4k-overlay-canvas-host]')).not.toBeNull();

    manager.detach();
    expect(document.querySelector('[data-anime4k-overlay-host]')).toBeNull();
    expect(secondContainer.querySelector('[data-anime4k-overlay-canvas-host]')).toBeNull();

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

    const overlayHost = shadowRoot.querySelector('[data-anime4k-overlay-host]');
    expect(overlayHost).not.toBeNull();
    expect(overlayHost?.parentNode).toBe(shadowRoot);

    manager.destroy();
  });
});

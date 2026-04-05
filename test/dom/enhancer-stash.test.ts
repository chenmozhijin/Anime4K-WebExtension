import { afterEach, describe, expect, it, vi } from 'vitest';

type MockEnhancer = {
  detach: ReturnType<typeof vi.fn>;
  destroy: ReturnType<typeof vi.fn>;
  getVideoElement: () => HTMLVideoElement;
};

function createVideo(url: string, width: number, height: number): HTMLVideoElement {
  const video = document.createElement('video');
  video.src = url;
  Object.defineProperty(video, 'videoWidth', { configurable: true, value: width });
  Object.defineProperty(video, 'videoHeight', { configurable: true, value: height });
  return video;
}

function createEnhancer(video: HTMLVideoElement): MockEnhancer {
  return {
    detach: vi.fn(),
    destroy: vi.fn(),
    getVideoElement: () => video,
  };
}

describe('enhancer stash', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('reuses a stashed enhancer even when the replacement video has no metadata yet', async () => {
    vi.useFakeTimers();
    vi.resetModules();

    const { stashEnhancer, findAndunstashEnhancer } = await import('../../src/core/enhancer-stash');
    const originalVideo = createVideo('https://example.com/reuse.mp4', 1920, 1080);
    const replacementVideo = createVideo('https://example.com/reuse.mp4', 0, 0);
    const enhancer = createEnhancer(originalVideo);

    stashEnhancer(enhancer as never);
    const reusedEnhancer = findAndunstashEnhancer(replacementVideo);

    expect(enhancer.detach).toHaveBeenCalledTimes(1);
    expect(reusedEnhancer).toBe(enhancer);

    vi.advanceTimersByTime(2500);
    expect(enhancer.destroy).not.toHaveBeenCalled();
  });
});

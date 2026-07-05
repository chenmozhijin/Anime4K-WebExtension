import { describe, expect, it, vi } from 'vitest';
import { waitForMediaReady } from '../../src/core/media-wait';

function setReadyState(video: HTMLVideoElement, readyState: number): void {
  Object.defineProperty(video, 'readyState', {
    configurable: true,
    value: readyState,
  });
}

describe('waitForMediaReady', () => {
  it('waits for the requested readyState instead of resolving on the first readiness event', async () => {
    const video = document.createElement('video');
    const onResolved = vi.fn();

    setReadyState(video, video.HAVE_CURRENT_DATA);
    const promise = waitForMediaReady(video, video.HAVE_FUTURE_DATA, {
      readinessEvents: ['loadeddata', 'canplay'],
    }).then(onResolved);

    video.dispatchEvent(new Event('loadeddata'));
    await Promise.resolve();

    expect(onResolved).not.toHaveBeenCalled();

    setReadyState(video, video.HAVE_FUTURE_DATA);
    video.dispatchEvent(new Event('canplay'));
    await promise;

    expect(onResolved).toHaveBeenCalledTimes(1);
  });
});

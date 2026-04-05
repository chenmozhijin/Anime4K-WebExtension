import { describe, expect, it, vi } from 'vitest';
import {
  attemptCrossOriginRecovery,
  shouldAttemptCrossOriginRecovery,
} from '../../src/core/video-enhancer/cross-origin-recovery';

describe('cross-origin recovery', () => {
  it('detects when recovery should be attempted', () => {
    const video = document.createElement('video');

    video.src = 'https://cdn.example.com/video.mp4';
    expect(shouldAttemptCrossOriginRecovery(video)).toBe(true);

    video.crossOrigin = 'anonymous';
    expect(shouldAttemptCrossOriginRecovery(video)).toBe(false);

    video.crossOrigin = '';
    video.src = '/relative.mp4';
    expect(shouldAttemptCrossOriginRecovery(video)).toBe(false);
  });

  it('skips recovery for non-http or same-origin media', async () => {
    const localVideo = document.createElement('video');
    localVideo.src = 'data:video/mp4;base64,AAAA';

    await expect(attemptCrossOriginRecovery(localVideo, {
      isDestroyed: () => false,
    })).resolves.toEqual({ status: 'skipped', reason: 'not-http' });

    const sameOriginVideo = document.createElement('video');
    sameOriginVideo.src = `${window.location.origin}/video.mp4`;

    await expect(attemptCrossOriginRecovery(sameOriginVideo, {
      isDestroyed: () => false,
    })).resolves.toEqual({ status: 'skipped', reason: 'same-origin' });
  });

  it('reloads the video and restores playback state on success', async () => {
    const video = document.createElement('video');
    const play = vi.fn().mockResolvedValue(undefined);
    const load = vi.fn();
    const originalOnCanPlay = vi.fn();
    const originalOnError = vi.fn();
    Object.defineProperties(video, {
      currentTime: {
        configurable: true,
        writable: true,
        value: 42,
      },
      paused: {
        configurable: true,
        writable: true,
        value: false,
      },
      play: {
        configurable: true,
        value: play,
      },
      load: {
        configurable: true,
        value: load,
      },
    });
    video.src = 'https://cdn.example.com/video.mp4';
    video.oncanplay = originalOnCanPlay;
    video.onerror = originalOnError;

    const recoveryPromise = attemptCrossOriginRecovery(video, {
      isDestroyed: () => false,
    });

    expect(video.crossOrigin).toBe('anonymous');
    expect(load).toHaveBeenCalledTimes(1);
    video.dispatchEvent(new Event('canplay'));

    await expect(recoveryPromise).resolves.toEqual({ status: 'recovered' });
    expect(video.currentTime).toBe(42);
    expect(play).toHaveBeenCalledTimes(1);
    expect(video.oncanplay).toBe(originalOnCanPlay);
    expect(video.onerror).toBe(originalOnError);
  });

  it('reloads using currentSrc when the video element src is empty', async () => {
    const video = document.createElement('video');
    const load = vi.fn();
    Object.defineProperties(video, {
      currentSrc: {
        configurable: true,
        value: 'https://cdn.example.com/stream.m3u8',
      },
      load: {
        configurable: true,
        value: load,
      },
      paused: {
        configurable: true,
        writable: true,
        value: true,
      },
      currentTime: {
        configurable: true,
        writable: true,
        value: 0,
      },
    });
    video.src = '';

    const recoveryPromise = attemptCrossOriginRecovery(video, {
      isDestroyed: () => false,
    });

    expect(video.src).toBe('https://cdn.example.com/stream.m3u8');
    expect(load).toHaveBeenCalledTimes(1);
    video.dispatchEvent(new Event('canplay'));

    await expect(recoveryPromise).resolves.toEqual({ status: 'recovered' });
  });

  it('reports reload failures or destruction', async () => {
    const failureVideo = document.createElement('video');
    const originalOnCanPlay = vi.fn();
    const originalOnError = vi.fn();
    Object.defineProperty(failureVideo, 'load', {
      configurable: true,
      value: vi.fn(),
    });
    failureVideo.src = 'https://cdn.example.com/video.mp4';
    failureVideo.oncanplay = originalOnCanPlay;
    failureVideo.onerror = originalOnError;

    const failurePromise = attemptCrossOriginRecovery(failureVideo, {
      isDestroyed: () => false,
    });
    failureVideo.dispatchEvent(new Event('error'));

    await expect(failurePromise).resolves.toEqual({ status: 'failed', reason: 'reload-failed' });
    expect(failureVideo.oncanplay).toBe(originalOnCanPlay);
    expect(failureVideo.onerror).toBe(originalOnError);

    const destroyedVideo = document.createElement('video');
    destroyedVideo.src = 'https://cdn.example.com/video.mp4';
    await expect(attemptCrossOriginRecovery(destroyedVideo, {
      isDestroyed: () => true,
    })).resolves.toEqual({ status: 'failed', reason: 'destroyed' });
  });
});

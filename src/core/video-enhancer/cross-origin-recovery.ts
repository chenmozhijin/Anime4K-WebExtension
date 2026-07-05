import { waitForMediaReady } from '../media-wait';

export type CrossOriginRecoveryReason = 'not-http' | 'same-origin' | 'already-configured' | 'destroyed' | 'reload-failed';
export type CrossOriginRecoveryStatus = 'recovered' | 'skipped' | 'failed';

export interface CrossOriginRecoveryResult {
  status: CrossOriginRecoveryStatus;
  reason?: CrossOriginRecoveryReason;
}

export function shouldAttemptCrossOriginRecovery(video: HTMLVideoElement): boolean {
  const videoUrl = video.currentSrc || video.src;
  if (!videoUrl || !videoUrl.startsWith('http')) {
    return false;
  }

  if (video.crossOrigin) {
    return false;
  }

  try {
    return new URL(videoUrl).origin !== window.location.origin;
  } catch {
    return false;
  }
}

export async function attemptCrossOriginRecovery(
  video: HTMLVideoElement,
  options: {
    isDestroyed: () => boolean;
    signal?: AbortSignal;
  },
): Promise<CrossOriginRecoveryResult> {
  if (options.isDestroyed()) {
    return { status: 'failed', reason: 'destroyed' };
  }

  const currentSrc = video.currentSrc || video.src;
  if (!currentSrc || !currentSrc.startsWith('http')) {
    return { status: 'skipped', reason: 'not-http' };
  }

  if (video.crossOrigin) {
    return { status: 'skipped', reason: 'already-configured' };
  }

  let parsedUrl: URL;
  try {
    parsedUrl = new URL(currentSrc);
  } catch {
    return { status: 'skipped', reason: 'not-http' };
  }

  if (parsedUrl.origin === window.location.origin) {
    return { status: 'skipped', reason: 'same-origin' };
  }

  video.crossOrigin = 'anonymous';

  const currentTime = video.currentTime;
  const originalSrc = currentSrc;
  const isPaused = video.paused;

  video.src = '';
  video.src = originalSrc;
  video.load();

  try {
    await waitForMediaReady(video, video.HAVE_FUTURE_DATA, {
      signal: options.signal,
      readinessEvents: ['canplay', 'loadeddata'],
      interruptionEvents: ['error', 'abort', 'emptied'],
      isReady: () => options.isDestroyed(),
    });
  } catch {
    return {
      status: 'failed',
      reason: options.isDestroyed() ? 'destroyed' : 'reload-failed',
    };
  }

  if (options.isDestroyed()) {
    return { status: 'failed', reason: 'destroyed' };
  }

  video.currentTime = currentTime;
  if (!isPaused) {
    void video.play().catch(() => undefined);
  }
  return { status: 'recovered' };
}

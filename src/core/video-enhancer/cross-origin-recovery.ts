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

  return new Promise<CrossOriginRecoveryResult>((resolve) => {
    const handleCanPlay = () => {
      cleanup();
      if (options.isDestroyed()) {
        resolve({ status: 'failed', reason: 'destroyed' });
        return;
      }

      video.currentTime = currentTime;
      if (!isPaused) {
        void video.play().catch(() => undefined);
      }
      resolve({ status: 'recovered' });
    };

    const handleError = () => {
      cleanup();
      resolve({ status: 'failed', reason: 'reload-failed' });
    };

    const cleanup = () => {
      video.removeEventListener('canplay', handleCanPlay);
      video.removeEventListener('error', handleError);
    };

    video.addEventListener('canplay', handleCanPlay, { once: true });
    video.addEventListener('error', handleError, { once: true });

    video.src = '';
    video.src = originalSrc;
    video.load();
  });
}

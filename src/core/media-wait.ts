export interface WaitForMediaReadyOptions {
  signal?: AbortSignal;
  readinessEvents?: readonly string[];
  interruptionEvents?: readonly string[];
  isReady?: () => boolean;
}

export class MediaWaitInterruptedError extends Error {
  public constructor(eventType: string) {
    super(`Media loading was interrupted by "${eventType}".`);
    this.name = 'MediaWaitInterruptedError';
  }
}

function createAbortError(): Error {
  if (typeof DOMException !== 'undefined') {
    return new DOMException('Media wait was aborted.', 'AbortError');
  }

  const error = new Error('Media wait was aborted.');
  error.name = 'AbortError';
  return error;
}

export function waitForMediaReady(
  video: HTMLVideoElement,
  readyState: number,
  options: WaitForMediaReadyOptions = {},
): Promise<void> {
  if ((options.isReady?.() ?? false) || video.readyState >= readyState) {
    return Promise.resolve();
  }

  if (options.signal?.aborted) {
    return Promise.reject(createAbortError());
  }

  const readinessEvents = options.readinessEvents ?? ['loadedmetadata', 'loadeddata', 'canplay'];
  const interruptionEvents = options.interruptionEvents ?? ['error', 'abort', 'emptied'];

  return new Promise<void>((resolve, reject) => {
    const cleanup = () => {
      readinessEvents.forEach(eventName => video.removeEventListener(eventName, handleReady));
      interruptionEvents.forEach(eventName => video.removeEventListener(eventName, handleInterrupted));
      options.signal?.removeEventListener('abort', handleAbort);
    };

    const resolveIfReady = (): boolean => {
      if ((options.isReady?.() ?? false) || video.readyState >= readyState) {
        cleanup();
        resolve();
        return true;
      }
      return false;
    };

    const handleReady = () => {
      resolveIfReady();
    };

    const handleInterrupted = (event: Event) => {
      if (resolveIfReady()) {
        return;
      }
      cleanup();
      reject(new MediaWaitInterruptedError(event.type));
    };

    const handleAbort = () => {
      cleanup();
      reject(createAbortError());
    };

    readinessEvents.forEach(eventName => video.addEventListener(eventName, handleReady));
    interruptionEvents.forEach(eventName => video.addEventListener(eventName, handleInterrupted));
    options.signal?.addEventListener('abort', handleAbort, { once: true });
  });
}

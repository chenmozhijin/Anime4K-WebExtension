import { showNotice } from './notice';

type LoggerLike = {
  error(message: string, error?: unknown): void;
};

export type SaveActionOptions<T> = {
  action(): Promise<T>;
  controls?: HTMLButtonElement[];
  logger?: LoggerLike;
  errorMessage?: string;
  logMessage?: string;
  onError?(error: unknown): void | Promise<void>;
};

export async function runSaveAction<T>({
  action,
  controls = [],
  logger,
  errorMessage,
  logMessage = 'Failed to save UI state.',
  onError,
}: SaveActionOptions<T>): Promise<T | null> {
  const previousDisabled = controls.map(control => control.disabled);
  controls.forEach(control => {
    control.disabled = true;
  });

  try {
    return await action();
  } catch (error) {
    logger?.error(logMessage, error);
    await onError?.(error);
    showNotice({
      kind: 'error',
      message: errorMessage ?? chrome.i18n.getMessage('saveFailed'),
    });
    return null;
  } finally {
    controls.forEach((control, index) => {
      control.disabled = previousDisabled[index] ?? false;
    });
  }
}

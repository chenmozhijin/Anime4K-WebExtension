import { describe, expect, it, vi } from 'vitest';

describe('options helpers', () => {
  it('settles and removes the temporary input when file selection is cancelled', async () => {
    const { openFile } = await import('../../src/ui/options/modules/helpers');
    const filePromise = openFile();
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;

    expect(input).not.toBeNull();
    input.dispatchEvent(new Event('cancel'));

    await expect(filePromise).rejects.toThrow('No file selected');
    expect(document.querySelector('input[type="file"]')).toBeNull();
  });

  it('settles and removes the temporary input when change fires without a file', async () => {
    const { openFile } = await import('../../src/ui/options/modules/helpers');
    const filePromise = openFile();
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;

    input.dispatchEvent(new Event('change'));

    await expect(filePromise).rejects.toThrow('No file selected');
    expect(document.querySelector('input[type="file"]')).toBeNull();
  });

  it('reads the selected file and removes the temporary input', async () => {
    const { openFile } = await import('../../src/ui/options/modules/helpers');
    const filePromise = openFile();
    const input = document.querySelector('input[type="file"]') as HTMLInputElement;
    const file = new File(['{"ok":true}'], 'settings.json', { type: 'application/json' });

    Object.defineProperty(input, 'files', {
      configurable: true,
      value: [file],
    });
    input.dispatchEvent(new Event('change'));

    await expect(filePromise).resolves.toBe('{"ok":true}');
    expect(document.querySelector('input[type="file"]')).toBeNull();
  });

  it('rejects reader errors and removes the temporary input', async () => {
    const originalFileReader = globalThis.FileReader;
    class FailingFileReader extends EventTarget {
      public error = new Error('reader failed');
      public onload: ((event: ProgressEvent<FileReader>) => void) | null = null;
      public onerror: ((event: ProgressEvent<FileReader>) => void) | null = null;

      readAsText(): void {
        this.onerror?.(new ProgressEvent('error') as ProgressEvent<FileReader>);
      }
    }
    Object.defineProperty(globalThis, 'FileReader', {
      configurable: true,
      value: FailingFileReader,
    });

    try {
      const { openFile } = await import('../../src/ui/options/modules/helpers');
      const filePromise = openFile();
      const input = document.querySelector('input[type="file"]') as HTMLInputElement;

      Object.defineProperty(input, 'files', {
        configurable: true,
        value: [new File(['bad'], 'settings.json', { type: 'application/json' })],
      });
      input.dispatchEvent(new Event('change'));

      await expect(filePromise).rejects.toThrow('reader failed');
      expect(document.querySelector('input[type="file"]')).toBeNull();
    } finally {
      Object.defineProperty(globalThis, 'FileReader', {
        configurable: true,
        value: originalFileReader,
      });
      vi.restoreAllMocks();
    }
  });
});

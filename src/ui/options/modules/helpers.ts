import type { PerformanceTier } from '../../../types';

export function downloadJSON(data: unknown, filename: string): void {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  URL.revokeObjectURL(url);
}

export function openFile(): Promise<string> {
  return new Promise((resolve, reject) => {
    const input = document.createElement('input');
    let settled = false;
    let focusCheckTimer: number | undefined;

    const cleanup = () => {
      if (focusCheckTimer !== undefined) {
        window.clearTimeout(focusCheckTimer);
        focusCheckTimer = undefined;
      }
      window.removeEventListener('focus', handleWindowFocus);
      input.removeEventListener('change', handleChange);
      input.removeEventListener('cancel', handleCancel);
      input.remove();
    };

    const settle = (callback: () => void) => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      callback();
    };

    const rejectNoFileSelected = () => {
      settle(() => reject(new Error('No file selected')));
    };

    function handleCancel(): void {
      rejectNoFileSelected();
    }

    function handleWindowFocus(): void {
      focusCheckTimer = window.setTimeout(() => {
        if (!input.files || input.files.length === 0) {
          rejectNoFileSelected();
        }
      }, 0);
    }

    function handleChange(): void {
      const file = input.files?.[0];
      if (!file) {
        rejectNoFileSelected();
        return;
      }

      const reader = new FileReader();
      reader.onload = loadEvent => {
        settle(() => resolve(loadEvent.target?.result as string));
      };
      reader.onerror = () => {
        settle(() => reject(reader.error ?? new Error('Failed to read file')));
      };
      reader.readAsText(file);
    }

    input.type = 'file';
    input.accept = '.json,application/json';
    input.hidden = true;
    input.addEventListener('change', handleChange);
    input.addEventListener('cancel', handleCancel);
    window.addEventListener('focus', handleWindowFocus);
    document.body.appendChild(input);
    input.click();
  });
}

export function setupInternationalization(): void {
  document.querySelectorAll<HTMLElement>('[data-i18n-aria-label]').forEach(element => {
    const key = element.getAttribute('data-i18n-aria-label');
    if (!key) {
      return;
    }

    const message = chrome.i18n.getMessage(key);
    if (message) {
      element.setAttribute('aria-label', message);
    }
  });

  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (!key) {
      return;
    }

    const message = chrome.i18n.getMessage(key);
    if (!message) {
      return;
    }

    if (element.tagName === 'TITLE') {
      document.title = message;
      return;
    }

    element.textContent = message;
  });
}

export function getTierDisplayName(tier: PerformanceTier): string {
  const tierKey = `tier${tier.charAt(0).toUpperCase()}${tier.slice(1)}` as const;
  return chrome.i18n.getMessage(tierKey);
}

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
    input.type = 'file';
    input.accept = '.json,application/json';
    input.onchange = event => {
      const file = (event.target as HTMLInputElement).files?.[0];
      if (!file) {
        reject(new Error('No file selected'));
        return;
      }

      const reader = new FileReader();
      reader.onload = loadEvent => {
        resolve(loadEvent.target?.result as string);
      };
      reader.onerror = error => {
        reject(error);
      };
      reader.readAsText(file);
    };
    input.click();
  });
}

export function setupInternationalization(): void {
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

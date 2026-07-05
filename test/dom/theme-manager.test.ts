import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';

describe('theme manager', () => {
  beforeEach(() => {
    document.documentElement.className = '';
  });

  it('loads persisted themes, saves updates, and reacts to system changes in auto mode', async () => {
    const chromeMock = installChromeMock({
      sync: { theme: 'dark' },
    });
    let prefersDark = true;
    let changeListener: ((event: Event) => void) | null = null;

    Object.defineProperty(window, 'matchMedia', {
      configurable: true,
      writable: true,
      value: vi.fn(() => ({
        get matches() {
          return prefersDark;
        },
        addEventListener: (_type: string, listener: (event: Event) => void) => {
          changeListener = listener;
        },
        removeEventListener: vi.fn(),
      })),
    });

    const { themeManager } = await import('../../src/ui/theme-manager');
    await themeManager.ready();

    expect(themeManager.getTheme()).toBe('dark');
    expect(document.documentElement.classList.contains('dark')).toBe(true);

    themeManager.setTheme('light');
    await Promise.resolve();
    expect(document.documentElement.classList.contains('light')).toBe(true);
    expect(chromeMock.__mock.syncState.theme).toBe('light');

    themeManager.setTheme('auto');
    prefersDark = false;
    if (changeListener) {
      (changeListener as (event: Event) => void)(new Event('change'));
    }

    expect(themeManager.getEffectiveTheme()).toBe('light');
    expect(document.documentElement.classList.contains('light')).toBe(true);
  });
});

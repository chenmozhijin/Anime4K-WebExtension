import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';

function installGeneralSectionDom(): void {
  document.body.innerHTML = `
    <input id="cross-origin-fix-toggle" type="checkbox" />
    <select id="theme-select"><option value="auto">auto</option></select>
    <span id="version-number"></span>
    <button id="run-benchmark-btn"></button>
    <span id="gpu-tier-display"></span>
    <div id="performance-monitor-mode">
      <button data-monitor-mode="off"></button>
      <button data-monitor-mode="lite"></button>
      <button data-monitor-mode="gpu"></button>
    </div>
  `;
}

describe('general options section', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.restoreAllMocks();
    document.body.innerHTML = '';
  });

  it('rolls back the cross-origin toggle when saving fails', async () => {
    installGeneralSectionDom();
    installChromeMock({ manifestVersion: '1.2.3' });
    const saveSettings = vi.fn().mockRejectedValue(new Error('sync write failed'));
    const showNotice = vi.fn(() => document.createElement('div'));
    let crossOriginEnabled = false;
    let performanceMonitorMode: 'off' | 'lite' | 'gpu' = 'off';

    vi.doMock('../../src/utils/settings', () => ({
      saveSettings,
      saveLocalSettings: vi.fn(),
    }));
    vi.doMock('../../src/ui/theme-manager', () => ({
      themeManager: {
        getTheme: vi.fn(() => 'auto'),
        setTheme: vi.fn(),
      },
    }));
    vi.doMock('../../src/ui/shared/notice', () => ({
      showNotice,
    }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        info: vi.fn(),
        warn: vi.fn(),
        error: vi.fn(),
      }),
    }));

    const { createGeneralSection } = await import('../../src/ui/options/modules/general-section');
    const section = createGeneralSection({
      getCrossOriginFixEnabled: () => crossOriginEnabled,
      setCrossOriginFixEnabled: enabled => {
        crossOriginEnabled = enabled;
      },
      getCurrentTier: () => 'balanced',
      setCurrentTier: vi.fn(),
      setBenchmarkResult: vi.fn(),
      getPerformanceMonitorMode: () => performanceMonitorMode,
      setPerformanceMonitorMode: mode => {
        performanceMonitorMode = mode;
      },
      notifyUpdate: vi.fn(),
      renderModes: vi.fn(),
    });
    await section.render();
    section.bindEvents();

    const toggle = document.getElementById('cross-origin-fix-toggle') as HTMLInputElement;
    toggle.checked = true;
    toggle.dispatchEvent(new Event('change', { bubbles: true }));
    await Promise.resolve();
    await Promise.resolve();

    expect(saveSettings).toHaveBeenCalledWith({ enableCrossOriginFix: true });
    expect(crossOriginEnabled).toBe(false);
    expect(toggle.checked).toBe(false);
    expect(showNotice).toHaveBeenCalledWith({
      kind: 'error',
      message: 'saveFailed',
    });
  });
});

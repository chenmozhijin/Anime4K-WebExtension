import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { flushPromises } from '../support/async';
import { installChromeMock } from '../support/chrome';

const popupHtml = readFileSync(resolve(process.cwd(), 'src/ui/popup/popup.html'), 'utf8');

function setDocumentFromHtml(html: string): void {
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] ?? html;
  document.body.innerHTML = body;
}

describe('popup UI', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.restoreAllMocks();
    document.body.innerHTML = '';
  });

  it('initializes, saves settings, and handles whitelist/options actions', async () => {
    vi.useFakeTimers();
    setDocumentFromHtml(popupHtml);
    const chromeMock = installChromeMock({
      manifestVersion: '9.9.9',
    });
    const saveSettings = vi.fn().mockResolvedValue(undefined);
    const saveLocalSettings = vi.fn().mockResolvedValue(undefined);
    const addWhitelistRule = vi.fn().mockResolvedValue(undefined);
    const setDefaultWhitelist = vi.fn().mockResolvedValue(undefined);
    const showNotice = vi.fn(() => document.createElement('div'));

    (chrome.tabs as any).query = vi.fn((_queryInfo: unknown, callback?: (tabs: chrome.tabs.Tab[]) => void) => {
      const tabs = [{ id: 7, url: 'https://example.com/show/episode' } as chrome.tabs.Tab];
      callback?.(tabs);
      return Promise.resolve(tabs);
    });
    (chrome.tabs as any).sendMessage = vi.fn((_tabId: number, _message: unknown, callback?: (response?: any) => void) => {
      const response = { status: 'SUCCESS', message: 'Applied now' };
      callback?.(response);
      return Promise.resolve(response);
    });
    const closeSpy = vi.spyOn(window, 'close').mockImplementation(() => undefined);

    vi.doMock('../../src/utils/settings', () => ({
      SettingsSaveError: class SettingsSaveError extends Error {
        constructor(public readonly failures: any[], public readonly succeededAreas: string[]) {
          super('settings save failed');
        }
      },
      BUILTIN_MODES: [
        { id: 'builtin-mode-a', name: 'Mode A', backendId: 'anime4k' },
        { id: 'builtin-mode-b', name: 'Mode B', backendId: 'anime4k' },
      ],
      RECOMMENDED_PRESET_MODES: [
        { id: 'recommended-detail-preserving', presetId: 'detail-preserving', name: 'Detail Preserving', nameKey: 'recommendedDetailPreserving', effectFamily: 'CuNNy' },
        { id: 'recommended-compression-cleanup', presetId: 'compression-cleanup', name: 'Compression Cleanup', nameKey: 'recommendedCompressionCleanup', effectFamily: 'ARNet' },
        { id: 'recommended-soft-style', presetId: 'soft-style', name: 'Soft Style', nameKey: 'recommendedSoftStyle', effectFamily: 'ArtCNN' },
      ],
      DEFAULT_RECOMMENDED_PRESET_MODE_ID: 'recommended-detail-preserving',
      getSettings: vi.fn().mockResolvedValue({
        enhancementModes: [{ id: 'builtin-mode-a', name: 'Mode A' }],
        customModes: [{ id: 'custom-artcnn', name: 'ArtCNN Custom Mode' }],
        selectedModeId: 'builtin-mode-a',
        targetResolutionSetting: 'x2',
        whitelistEnabled: false,
        whitelist: [{ pattern: 'example.com/*', enabled: true }],
      }),
      getLocalSettings: vi.fn().mockResolvedValue({
        performanceTier: 'quality',
        benchmarkRunState: { status: 'interrupted' },
      }),
      saveSettings,
      saveLocalSettings,
    }));
    vi.doMock('../../src/utils/whitelist', () => ({
      addWhitelistRule,
      setDefaultWhitelist,
    }));
    vi.doMock('../../src/ui/theme-manager', () => ({
      themeManager: {
        getTheme: vi.fn(),
        ready: vi.fn().mockResolvedValue(undefined),
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

    await import('../../src/ui/popup/popup');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises(6);

    expect(document.getElementById('version-info')?.textContent).toBe('9.9.9');
    expect(document.querySelectorAll('#mode-select option')).toHaveLength(6);
    const modeGroups = Array.from(document.querySelectorAll('#mode-select optgroup'));
    expect(modeGroups).toHaveLength(3);
    expect(modeGroups[0].querySelectorAll('option')).toHaveLength(3);
    expect(modeGroups[1].querySelectorAll('option')).toHaveLength(2);
    expect(modeGroups[1].textContent).not.toContain('ArtCNN');
    expect(modeGroups[2].textContent).toContain('ArtCNN Custom Mode');
    expect(Array.from(modeGroups[0].querySelectorAll('option')).map(option => option.textContent)).toEqual([
      'recommendedDetailPreserving (CuNNy)',
      'recommendedCompressionCleanup (ARNet)',
      'recommendedSoftStyle (ArtCNN)',
    ]);
    expect(document.querySelector('.tier-btn.active')?.getAttribute('data-tier')).toBe('quality');
    expect(showNotice).toHaveBeenCalledWith(expect.objectContaining({
      kind: 'warning',
    }));

    const modeSelect = document.getElementById('mode-select') as HTMLSelectElement;
    const resolutionSelect = document.getElementById('resolution-select') as HTMLSelectElement;
    modeSelect.value = 'builtin-mode-b';
    resolutionSelect.value = '4k';

    document.getElementById('save-settings')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({
      selectedModeId: 'builtin-mode-b',
      targetResolutionSetting: '4k',
      performanceTier: 'quality',
    });
    expect(saveLocalSettings).not.toHaveBeenCalled();
    expect((chrome.tabs.sendMessage as any)).toHaveBeenCalledWith(
      7,
      { type: 'SETTINGS_UPDATED' },
      expect.any(Function),
    );
    expect(document.querySelector('.save-status')?.textContent).toBe('Applied now');

    document.getElementById('add-current-domain')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);
    expect(addWhitelistRule).toHaveBeenCalledWith('example.com/*');

    document.getElementById('open-settings')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(chromeMock.__mock.openOptionsPageCalls).toHaveLength(1);

    vi.runAllTimers();
    expect(closeSpy).toHaveBeenCalledTimes(1);
    vi.useRealTimers();
  });

  it('refreshes controls and reports partial save failures', async () => {
    setDocumentFromHtml(popupHtml);
    installChromeMock();
    class MockSettingsSaveError extends Error {
      constructor(public readonly failures: any[], public readonly succeededAreas: string[]) {
        super('settings save failed');
      }
    }
    const saveSettings = vi.fn().mockRejectedValue(new MockSettingsSaveError(
      [{ area: 'sync', error: new Error('sync failed') }],
      ['local'],
    ));
    const showNotice = vi.fn(() => document.createElement('div'));
    const getSettings = vi.fn()
      .mockResolvedValueOnce({
        enhancementModes: [{ id: 'builtin-mode-a', name: 'Mode A' }],
        customModes: [],
        selectedModeId: 'builtin-mode-a',
        targetResolutionSetting: 'x2',
        whitelistEnabled: false,
        whitelist: [{ pattern: 'example.com/*', enabled: true }],
      })
      .mockResolvedValueOnce({
        enhancementModes: [{ id: 'builtin-mode-b', name: 'Mode B' }],
        customModes: [],
        selectedModeId: 'builtin-mode-b',
        targetResolutionSetting: '4k',
        whitelistEnabled: true,
        whitelist: [{ pattern: 'example.com/*', enabled: true }],
      });
    const getLocalSettings = vi.fn()
      .mockResolvedValueOnce({
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'idle' },
      })
      .mockResolvedValueOnce({
        performanceTier: 'ultra',
        benchmarkRunState: { status: 'idle' },
      });

    vi.doMock('../../src/utils/settings', () => ({
      SettingsSaveError: MockSettingsSaveError,
      BUILTIN_MODES: [
        { id: 'builtin-mode-a', name: 'Mode A', backendId: 'anime4k' },
        { id: 'builtin-mode-b', name: 'Mode B', backendId: 'anime4k' },
      ],
      RECOMMENDED_PRESET_MODES: [
        { id: 'recommended-detail-preserving', presetId: 'detail-preserving', name: 'Detail Preserving', nameKey: 'recommendedDetailPreserving', effectFamily: 'CuNNy' },
        { id: 'recommended-compression-cleanup', presetId: 'compression-cleanup', name: 'Compression Cleanup', nameKey: 'recommendedCompressionCleanup', effectFamily: 'ARNet' },
        { id: 'recommended-soft-style', presetId: 'soft-style', name: 'Soft Style', nameKey: 'recommendedSoftStyle', effectFamily: 'ArtCNN' },
      ],
      DEFAULT_RECOMMENDED_PRESET_MODE_ID: 'recommended-detail-preserving',
      getSettings,
      getLocalSettings,
      saveSettings,
    }));
    vi.doMock('../../src/utils/whitelist', () => ({
      addWhitelistRule: vi.fn(),
      setDefaultWhitelist: vi.fn(),
    }));
    vi.doMock('../../src/ui/theme-manager', () => ({
      themeManager: {
        getTheme: vi.fn(),
        ready: vi.fn().mockResolvedValue(undefined),
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

    await import('../../src/ui/popup/popup');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises(6);

    const modeSelect = document.getElementById('mode-select') as HTMLSelectElement;
    const resolutionSelect = document.getElementById('resolution-select') as HTMLSelectElement;
    modeSelect.value = 'builtin-mode-b';
    resolutionSelect.value = '4k';
    document.querySelector<HTMLButtonElement>('[data-tier="ultra"]')?.click();

    document.getElementById('save-settings')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveSettings).toHaveBeenCalledWith({
      selectedModeId: 'builtin-mode-b',
      targetResolutionSetting: '4k',
      performanceTier: 'ultra',
    });
    expect(getSettings).toHaveBeenCalledTimes(2);
    expect(getLocalSettings).toHaveBeenCalledTimes(2);
    expect(modeSelect.value).toBe('builtin-mode-b');
    expect(resolutionSelect.value).toBe('4k');
    expect(document.querySelector('.tier-btn.active')?.getAttribute('data-tier')).toBe('ultra');
    expect(showNotice).toHaveBeenCalledWith({
      kind: 'warning',
      message: 'saveFailed: sync',
    });
  });
});

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it, vi } from 'vitest';
import { flushPromises } from '../support/async';
import { installChromeMock } from '../support/chrome';

const optionsHtml = readFileSync(resolve(process.cwd(), 'src/ui/options/options.html'), 'utf8');

function setDocumentFromHtml(html: string): void {
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] ?? html;
  document.body.innerHTML = body;
}

describe('options UI', () => {
  it('renders settings, handles mode/general actions, and reacts to benchmark/message updates', async () => {
    setDocumentFromHtml(optionsHtml);
    const chromeMock = installChromeMock({
      manifestVersion: '1.2.3',
    });
    vi.spyOn(chromeMock.i18n, 'getMessage').mockImplementation((key: string) => ({
      recommendedDetailPreserving: '细节保留',
      recommendedCompressionCleanup: '重压缩清理',
      recommendedSoftStyle: '柔和风格',
    }[key] ?? key));
    const saveSettings = vi.fn().mockResolvedValue(undefined);
    const saveLocalSettings = vi.fn().mockResolvedValue(undefined);
    const addWhitelistRule = vi.fn().mockResolvedValue(undefined);
    const showNotice = vi.fn(() => document.createElement('div'));

    const builtInMode = {
      id: 'builtin-mode-a',
      name: 'Mode A',
      isBuiltIn: true,
      backendId: 'anime4k',
      presetKey: 'A',
      baseMode: 'A',
    };
    const recommendedModes = [
      {
        id: 'recommended-detail-preserving',
        presetId: 'detail-preserving',
        name: 'Detail Preserving',
        nameKey: 'recommendedDetailPreserving',
        effectFamily: 'CuNNy',
        isBuiltIn: true,
        isRecommended: true,
      },
      {
        id: 'recommended-compression-cleanup',
        presetId: 'compression-cleanup',
        name: 'Compression Cleanup',
        nameKey: 'recommendedCompressionCleanup',
        effectFamily: 'ARNet',
        isBuiltIn: true,
        isRecommended: true,
      },
      {
        id: 'recommended-soft-style',
        presetId: 'soft-style',
        name: 'Soft Style',
        nameKey: 'recommendedSoftStyle',
        effectFamily: 'ArtCNN',
        isBuiltIn: true,
        isRecommended: true,
      },
    ];
    const customMode = {
      id: 'custom-1',
      name: 'Custom 1',
      isBuiltIn: false,
      effects: [{ id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM' }],
    };
    const getSettings = vi.fn().mockResolvedValue({
      selectedModeId: 'builtin-mode-a',
      targetResolutionSetting: 'x2',
      whitelistEnabled: true,
      whitelist: [{ pattern: 'example.com/*', enabled: true }],
      customModes: [customMode],
      enhancementModes: [...recommendedModes, builtInMode, customMode],
      enableCrossOriginFix: false,
    });
    const getLocalSettings = vi.fn().mockResolvedValue({
      performanceTier: 'balanced',
      benchmarkRunState: { status: 'interrupted' },
      gpuBenchmarkResult: null,
    });

    vi.doMock('../../src/utils/settings', () => ({
      BUILTIN_MODES: [builtInMode],
      buildEnhancementModes: vi.fn((customModes: any[]) => [...recommendedModes, builtInMode, ...customModes]),
      DEFAULT_RECOMMENDED_PRESET_MODE_ID: 'recommended-detail-preserving',
      getSettings,
      saveSettings,
      synchronizeEffectsForCustomModes: vi.fn((modes: unknown) => modes),
      getEffectsForMode: vi.fn((mode: any) => mode.isBuiltIn ? [{ id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM' }] : mode.effects),
      getLocalSettings,
      saveLocalSettings,
    }));
    vi.doMock('../../src/utils/whitelist', () => ({
      validateRulePattern: vi.fn(() => true),
      removeWhitelistRule: vi.fn().mockResolvedValue(undefined),
      updateWhitelistRule: vi.fn().mockResolvedValue(undefined),
      addWhitelistRule,
    }));
    vi.doMock('../../src/utils/effects-map', () => ({
      AVAILABLE_EFFECTS: [
        {
          id: 'anime4k/CNNM',
          backendId: 'anime4k',
          key: 'CNNM',
          name: 'CNNM',
          category: 'restore',
          dimensionBehavior: { kind: 'same' },
          supportsVideoRealtime: true,
        },
        {
          id: 'artcnn/Upscale/C4F16',
          backendId: 'artcnn',
          key: 'C4F16',
          name: 'Upscale ArtCNN x2 (C4F16)',
          category: 'upscale',
          dimensionBehavior: { kind: 'scale', scale: 2 },
          supportsVideoRealtime: true,
        },
        {
          id: 'acnet/Upscale/F8B4',
          backendId: 'acnet',
          key: 'ACNET_F8B4',
          name: 'Upscale ACNet F8B4 x2',
          category: 'upscale',
          dimensionBehavior: { kind: 'scale', scale: 2 },
          supportsVideoRealtime: true,
        },
        {
          id: 'cunny/Upscale/DS/Fast',
          backendId: 'cunny',
          key: 'CUNNY_FAST_DS',
          name: 'Upscale CuNNy fast DS x2',
          category: 'upscale',
          dimensionBehavior: { kind: 'scale', scale: 2 },
          supportsVideoRealtime: true,
          license: {
            expression: 'LGPL-3.0-or-later',
            componentName: 'CuNNy',
            sourceUrl: 'https://github.com/funnyplanter/CuNNy',
          },
        },
      ],
    }));
    vi.doMock('../../src/ui/theme-manager', () => ({
      themeManager: {
        getTheme: vi.fn().mockReturnValue('auto'),
        ready: vi.fn().mockResolvedValue(undefined),
        setTheme: vi.fn(),
      },
    }));
    vi.doMock('../../src/ui/options/Sidebar', () => ({
      Sidebar: class {
        public readonly initialize = vi.fn();
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
    vi.doMock('../../src/core/effects/reference', () => ({
      createEffectReference: vi.fn((descriptor: any) => ({
        id: descriptor.id,
        backendId: descriptor.backendId,
        key: descriptor.key,
      })),
    }));
    vi.doMock('../../src/core/effects/registry', () => ({
      getEffectDescriptor: vi.fn((effect: any) => ({
        ...effect,
        name: effect.key,
      })),
      getEffectDescriptorById: vi.fn((id: string) => ({
        id,
        name: id,
      })),
      validateEffectChain: vi.fn(() => ({
        valid: true,
        errors: [],
      })),
    }));
    await import('../../src/ui/options/options');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises();

    expect(document.querySelectorAll('#modes-container .mode-card')).toHaveLength(5);
    expect(Array.from(document.querySelectorAll('#modes-container [data-mode-group]'))
      .map(group => group.getAttribute('data-mode-group')))
      .toEqual(['custom', 'recommended', 'compatibility']);
    expect(document.querySelector('[data-mode-group="custom"] [data-mode-id="custom-1"]')).not.toBeNull();
    expect(document.querySelector('[data-mode-group="recommended"] [data-mode-id="recommended-detail-preserving"]')).not.toBeNull();
    expect(document.querySelector('[data-mode-group="compatibility"] [data-mode-id="builtin-mode-a"]')).not.toBeNull();
    expect(document.querySelector('[data-mode-id="recommended-detail-preserving"]')?.textContent)
      .toContain('细节保留');
    expect(document.querySelector('[data-mode-id="recommended-detail-preserving"]')?.textContent)
      .not.toContain('Detail Preserving');
    expect(document.querySelector('[data-mode-id="recommended-detail-preserving"] .effect-browser')).toBeNull();
    expect((document.querySelector('[data-mode-id="recommended-detail-preserving"] h2') as HTMLElement).contentEditable)
      .toBe('false');
    expect(document.querySelectorAll('#rules-container tr')).toHaveLength(1);
    expect(document.getElementById('version-number')?.textContent).toBe('1.2.3');
    expect(document.getElementById('about-section')?.textContent).toContain('MIT core');
    expect(document.getElementById('about-section')?.textContent).toContain('CuNNy LGPL components');
    expect(document.querySelector('[data-mode-id="builtin-mode-a"]')?.textContent).not.toContain('ArtCNN');

    let customModeCard = document.querySelector('[data-mode-id="custom-1"]') as HTMLElement;
    expect(customModeCard.querySelector('.effect-browser')).toBeNull();

    const toggleEffectBrowserBtn = customModeCard.querySelector('.btn-toggle-effect-browser') as HTMLButtonElement;
    expect(toggleEffectBrowserBtn.textContent).toBe('+ addEffect');
    toggleEffectBrowserBtn.click();
    await flushPromises();
    customModeCard = document.querySelector('[data-mode-id="custom-1"]') as HTMLElement;
    expect(customModeCard.querySelector('.effect-browser')).not.toBeNull();
    expect(customModeCard.querySelector('.btn-toggle-effect-browser')?.textContent).toBe('effectBrowserDone');
    expect((customModeCard.querySelector('.effect-search-input') as HTMLInputElement).placeholder)
      .toBe('effectSearchPlaceholder');
    expect(customModeCard.textContent).toContain('Upscale ACNet F8B4 x2');
    expect(customModeCard.textContent).toContain('Upscale CuNNy fast DS x2');
    expect(customModeCard.querySelector('.effect-browser')?.textContent).not.toContain('LGPL');

    const acnetTab = Array.from(customModeCard.querySelectorAll('.effect-backend-tab'))
      .find(button => button.textContent === 'ACNet') as HTMLButtonElement;
    acnetTab.click();
    expect(customModeCard.querySelector('.effect-browser')?.textContent).toContain('Upscale ACNet F8B4 x2');
    expect(customModeCard.querySelector('.effect-browser')?.textContent).not.toContain('Upscale ArtCNN x2 (C4F16)');

    const cunnyTab = Array.from(customModeCard.querySelectorAll('.effect-backend-tab'))
      .find(button => button.textContent === 'CuNNy') as HTMLButtonElement;
    cunnyTab.click();
    expect(customModeCard.querySelector('.effect-browser')?.textContent).toContain('Upscale CuNNy fast DS x2');
    expect(customModeCard.querySelector('.effect-browser')?.textContent).not.toContain('Upscale ACNet F8B4 x2');

    const artcnnTab = Array.from(customModeCard.querySelectorAll('.effect-backend-tab'))
      .find(button => button.textContent === 'ArtCNN') as HTMLButtonElement;
    artcnnTab.click();
    const artcnnRow = Array.from(customModeCard.querySelectorAll('.effect-result-row'))
      .find(row => row.textContent?.includes('Upscale ArtCNN x2 (C4F16)')) as HTMLElement;
    (artcnnRow.querySelector('.effect-result-add') as HTMLButtonElement).click();
    await flushPromises();
    customModeCard = document.querySelector('[data-mode-id="custom-1"]') as HTMLElement;
    expect(saveSettings).toHaveBeenCalledWith(expect.objectContaining({
      customModes: [expect.objectContaining({
        id: 'custom-1',
        effects: expect.arrayContaining([
          expect.objectContaining({
            id: 'artcnn/Upscale/C4F16',
            backendId: 'artcnn',
            key: 'C4F16',
          }),
        ]),
      })],
    }));
    expect(document.querySelector('[data-mode-id="custom-1"] .effect-browser')).not.toBeNull();

    const doneBtn = document.querySelector('[data-mode-id="custom-1"] .btn-toggle-effect-browser') as HTMLButtonElement;
    doneBtn.click();
    await flushPromises();
    expect(document.querySelector('[data-mode-id="custom-1"] .effect-browser')).toBeNull();

    document.getElementById('add-mode-btn')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();
    expect(saveSettings).toHaveBeenCalledWith(expect.objectContaining({
      customModes: expect.any(Array),
    }));
    expect(chromeMock.__mock.runtimeMessages).toContainEqual({ type: 'SETTINGS_UPDATED', modifiedModeId: expect.any(String) });

    const toggle = document.getElementById('cross-origin-fix-toggle') as HTMLInputElement;
    toggle.checked = true;
    toggle.dispatchEvent(new Event('change', { bubbles: true }));
    await flushPromises();
    expect(saveSettings).toHaveBeenCalledWith({ enableCrossOriginFix: true });

    const themeSelect = document.getElementById('theme-select') as HTMLSelectElement;
    themeSelect.value = 'dark';
    themeSelect.dispatchEvent(new Event('change', { bubbles: true }));

    document.getElementById('add-rule')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();
    expect(addWhitelistRule).toHaveBeenCalledWith('*.example.com/*', true);

    document.getElementById('run-benchmark-btn')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);

    await chromeMock.__mock.runtimeOnMessage.trigger({ type: 'SETTINGS_UPDATED' }, {} as chrome.runtime.MessageSender, vi.fn());
    await flushPromises();
    expect(getSettings.mock.calls.length).toBeGreaterThanOrEqual(3);
    expect(showNotice).toHaveBeenCalledWith(expect.objectContaining({
      kind: 'warning',
    }));
  });
});

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';

const optionsHtml = readFileSync(resolve(process.cwd(), 'src/ui/options/options.html'), 'utf8');

function setDocumentFromHtml(html: string): void {
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] ?? html;
  document.body.innerHTML = body;
}

async function flushPromises(times = 4): Promise<void> {
  for (let index = 0; index < times; index += 1) {
    await Promise.resolve();
  }
}

describe('options UI', () => {
  it('renders settings, handles mode/general actions, and reacts to benchmark/message updates', async () => {
    setDocumentFromHtml(optionsHtml);
    const chromeMock = installChromeMock({
      manifestVersion: '1.2.3',
    });
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
      enhancementModes: [builtInMode, customMode],
      enableCrossOriginFix: false,
    });
    const getLocalSettings = vi.fn().mockResolvedValue({
      performanceTier: 'balanced',
      benchmarkRunState: { status: 'interrupted' },
      gpuBenchmarkResult: null,
    });

    vi.doMock('../../src/utils/settings', () => ({
      BUILTIN_MODES: [builtInMode],
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
        },
        {
          id: 'artcnn/Upscale/C4F16',
          backendId: 'artcnn',
          key: 'C4F16',
          name: 'Upscale ArtCNN x2 (C4F16)',
        },
      ],
    }));
    vi.doMock('../../src/ui/theme-manager', () => ({
      themeManager: {
        getTheme: vi.fn().mockReturnValue('auto'),
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
      validateEffectChain: vi.fn(() => ({
        valid: true,
        errors: [],
      })),
    }));
    await import('../../src/ui/options/options');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises();

    expect(document.querySelectorAll('#modes-container .mode-card')).toHaveLength(2);
    expect(document.querySelectorAll('#rules-container tr')).toHaveLength(1);
    expect(document.getElementById('version-number')?.textContent).toBe('1.2.3');
    expect(document.querySelector('[data-mode-id="builtin-mode-a"]')?.textContent).not.toContain('ArtCNN');

    const artcnnEffectSelect = document.querySelector(
      '[data-mode-id="custom-1"] .add-effect-container select',
    ) as HTMLSelectElement;
    expect(Array.from(artcnnEffectSelect.options).map(option => option.value)).toContain('artcnn/Upscale/C4F16');
    artcnnEffectSelect.value = 'artcnn/Upscale/C4F16';
    artcnnEffectSelect.dispatchEvent(new Event('change', { bubbles: true }));
    await flushPromises();
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

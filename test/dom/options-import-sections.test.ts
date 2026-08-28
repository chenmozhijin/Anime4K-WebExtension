import type { NijiLucidSettings, CustomMode, WhitelistRule } from '../../src/types';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { flushPromises } from '../support/async';
import { installChromeMock } from '../support/chrome';

describe('options import sections', () => {
  beforeEach(() => {
    installChromeMock();
  });

  it('imports whitelist rules only after storage save succeeds', async () => {
    document.body.innerHTML = `
      <button id="add-rule"></button>
      <button id="import-btn"></button>
      <button id="export-btn"></button>
      <table><tbody id="rules-container"></tbody></table>
    `;
    const saveSettings = vi.fn().mockResolvedValue(undefined);
    const showNotice = vi.fn();
    const importedRules: WhitelistRule[] = [{ pattern: 'example.com/watch/*', enabled: true }];
    let rules: WhitelistRule[] = [{ pattern: 'old.example.com/*', enabled: false }];

    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn().mockResolvedValue(JSON.stringify(importedRules)),
    }));
    vi.doMock('../../src/utils/settings', () => ({ saveSettings }));
    vi.doMock('../../src/utils/whitelist', () => ({
      addWhitelistRule: vi.fn(),
      removeWhitelistRule: vi.fn(),
      updateWhitelistRule: vi.fn(),
      validateRulePattern: vi.fn((pattern: string) => pattern.length > 0),
    }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createWhitelistSection } = await import('../../src/ui/options/modules/whitelist-section');
    const section = createWhitelistSection({
      getWhitelistRules: () => rules,
      setWhitelistRules: nextRules => {
        rules = nextRules;
      },
      refreshAll: vi.fn(),
    });
    section.render();
    section.bindEvents();

    document.getElementById('import-btn')?.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({ whitelist: importedRules });
    expect(rules).toEqual(importedRules);
    expect(document.querySelectorAll('#rules-container tr')).toHaveLength(1);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'success', message: 'importSuccess' });
  });

  it('keeps whitelist state unchanged when import JSON or storage save fails', async () => {
    document.body.innerHTML = `
      <button id="add-rule"></button>
      <button id="import-btn"></button>
      <button id="export-btn"></button>
      <table><tbody id="rules-container"></tbody></table>
    `;
    const saveSettings = vi.fn().mockRejectedValue(new Error('sync failed'));
    const showNotice = vi.fn();
    let openFileResult = 'not json';
    let rules: WhitelistRule[] = [{ pattern: 'old.example.com/*', enabled: false }];
    const setWhitelistRules = vi.fn((nextRules: WhitelistRule[]) => {
      rules = nextRules;
    });

    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn(() => Promise.resolve(openFileResult)),
    }));
    vi.doMock('../../src/utils/settings', () => ({ saveSettings }));
    vi.doMock('../../src/utils/whitelist', () => ({
      addWhitelistRule: vi.fn(),
      removeWhitelistRule: vi.fn(),
      updateWhitelistRule: vi.fn(),
      validateRulePattern: vi.fn((pattern: string) => pattern.length > 0),
    }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createWhitelistSection } = await import('../../src/ui/options/modules/whitelist-section');
    const section = createWhitelistSection({
      getWhitelistRules: () => rules,
      setWhitelistRules,
      refreshAll: vi.fn(),
    });
    section.render();
    section.bindEvents();

    document.getElementById('import-btn')?.click();
    await flushPromises();

    expect(saveSettings).not.toHaveBeenCalled();
    expect(setWhitelistRules).not.toHaveBeenCalled();
    expect(rules).toEqual([{ pattern: 'old.example.com/*', enabled: false }]);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'importError' });

    showNotice.mockClear();
    openFileResult = JSON.stringify([{ pattern: 'new.example.com/*', enabled: true }]);
    document.getElementById('import-btn')?.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({ whitelist: [{ pattern: 'new.example.com/*', enabled: true }] });
    expect(setWhitelistRules).not.toHaveBeenCalled();
    expect(rules).toEqual([{ pattern: 'old.example.com/*', enabled: false }]);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'importError' });
  });

  it('rolls back whitelist inline edits when storage save fails', async () => {
    document.body.innerHTML = `
      <button id="add-rule"></button>
      <button id="import-btn"></button>
      <button id="export-btn"></button>
      <table><tbody id="rules-container"></tbody></table>
    `;
    const showNotice = vi.fn();
    const updateWhitelistRule = vi.fn().mockRejectedValue(new Error('sync failed'));
    const rules: WhitelistRule[] = [{ pattern: 'old.example.com/*', enabled: true }];

    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn(),
    }));
    vi.doMock('../../src/utils/settings', () => ({ saveSettings: vi.fn() }));
    vi.doMock('../../src/utils/whitelist', () => ({
      addWhitelistRule: vi.fn(),
      removeWhitelistRule: vi.fn(),
      updateWhitelistRule,
      validateRulePattern: vi.fn((pattern: string) => pattern.length > 0),
    }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createWhitelistSection } = await import('../../src/ui/options/modules/whitelist-section');
    const section = createWhitelistSection({
      getWhitelistRules: () => rules,
      setWhitelistRules: vi.fn(),
      refreshAll: vi.fn(),
    });
    section.render();
    section.bindEvents();

    const patternInput = document.querySelector('.pattern-input') as HTMLInputElement;
    patternInput.value = 'new.example.com/*';
    patternInput.dispatchEvent(new Event('change', { bubbles: true }));
    await flushPromises();

    expect(updateWhitelistRule).toHaveBeenCalledWith('old.example.com/*', 'new.example.com/*');
    expect(rules).toEqual([{ pattern: 'old.example.com/*', enabled: true }]);
    expect(patternInput.value).toBe('old.example.com/*');
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });
  });

  it('imports modes only after storage save succeeds', async () => {
    document.body.innerHTML = `
      <button id="add-mode-btn"></button>
      <button id="import-modes-btn"></button>
      <button id="export-modes-btn"></button>
      <div id="modes-container"></div>
    `;
    const importedMode = {
      name: 'Imported mode',
      effects: [{ id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM' }],
    };
    const saveSettings = vi.fn().mockResolvedValue(undefined);
    const showNotice = vi.fn();
    const notifyUpdate = vi.fn();
    const existingMode: CustomMode = {
      id: 'custom-existing',
      name: 'Existing mode',
      isBuiltIn: false,
      effects: [],
    };
    const settingsState = {
      selectedModeId: 'custom-existing',
      targetResolutionSetting: 'x2',
      whitelistEnabled: false,
      whitelist: [],
      customModes: [existingMode],
      enhancementModes: [existingMode],
      enableCrossOriginFix: false,
      performanceTier: 'balanced',
      performanceMonitorMode: 'off',
      performanceMonitorHudCollapsed: false,
      performanceMonitorHudPosition: 'top-left',
      performanceMonitorHudWidth: null,
    } as NijiLucidSettings;

    vi.spyOn(Date, 'now').mockReturnValue(1234);
    vi.spyOn(Math, 'random').mockReturnValue(0.123456);
    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn().mockResolvedValue(JSON.stringify([importedMode])),
    }));
    vi.doMock('../../src/utils/settings', () => ({
      BUILTIN_MODES: [],
      buildEnhancementModes: vi.fn((customModes: CustomMode[]) => customModes),
      getEffectsForMode: vi.fn((mode: CustomMode) => mode.effects),
      saveSettings,
      synchronizeEffectsForCustomModes: vi.fn((modes: CustomMode[]) => modes),
    }));
    vi.doMock('../../src/utils/effects-map', () => ({ AVAILABLE_EFFECTS: [] }));
    vi.doMock('../../src/core/effects/registry', () => ({
      getEffectDescriptor: vi.fn(),
      validateEffectChain: vi.fn(() => ({ valid: true, errors: [] })),
    }));
    vi.doMock('../../src/core/effects/reference', () => ({ createEffectReference: vi.fn() }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createModesSection } = await import('../../src/ui/options/modules/modes-section');
    const section = createModesSection({
      getSettingsState: () => settingsState,
      getCurrentTier: () => 'balanced',
      notifyUpdate,
    });
    section.render();
    section.bindEvents();

    document.getElementById('import-modes-btn')?.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({
      customModes: [
        existingMode,
        expect.objectContaining({
          id: expect.stringMatching(/^custom-1234-/),
          name: 'Imported mode',
          isBuiltIn: false,
          effects: importedMode.effects,
        }),
      ],
    });
    expect(settingsState.customModes).toHaveLength(2);
    expect(settingsState.customModes[1]).toMatchObject({ name: 'Imported mode' });
    expect(notifyUpdate).toHaveBeenCalledWith();
    expect(showNotice).toHaveBeenCalledWith({ kind: 'success', message: 'importSuccess' });
  });

  it('keeps mode state unchanged when import JSON, validation, openFile, or storage save fails', async () => {
    document.body.innerHTML = `
      <button id="add-mode-btn"></button>
      <button id="import-modes-btn"></button>
      <button id="export-modes-btn"></button>
      <div id="modes-container"></div>
    `;
    const saveSettings = vi.fn().mockRejectedValue(new Error('sync failed'));
    const showNotice = vi.fn();
    const notifyUpdate = vi.fn();
    let openFileResult: Promise<string> = Promise.resolve('not json');
    const existingMode: CustomMode = {
      id: 'custom-existing',
      name: 'Existing mode',
      isBuiltIn: false,
      effects: [],
    };
    const settingsState = {
      selectedModeId: 'custom-existing',
      targetResolutionSetting: 'x2',
      whitelistEnabled: false,
      whitelist: [],
      customModes: [existingMode],
      enhancementModes: [existingMode],
      enableCrossOriginFix: false,
      performanceTier: 'balanced',
      performanceMonitorMode: 'off',
      performanceMonitorHudCollapsed: false,
      performanceMonitorHudPosition: 'top-left',
      performanceMonitorHudWidth: null,
    } as NijiLucidSettings;

    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn(() => openFileResult),
    }));
    vi.doMock('../../src/utils/settings', () => ({
      BUILTIN_MODES: [],
      buildEnhancementModes: vi.fn((customModes: CustomMode[]) => customModes),
      getEffectsForMode: vi.fn((mode: CustomMode) => mode.effects),
      saveSettings,
      synchronizeEffectsForCustomModes: vi.fn((modes: CustomMode[]) => modes),
    }));
    vi.doMock('../../src/utils/effects-map', () => ({ AVAILABLE_EFFECTS: [] }));
    vi.doMock('../../src/core/effects/registry', () => ({
      getEffectDescriptor: vi.fn(),
      validateEffectChain: vi.fn(() => ({ valid: true, errors: [] })),
    }));
    vi.doMock('../../src/core/effects/reference', () => ({ createEffectReference: vi.fn() }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createModesSection } = await import('../../src/ui/options/modules/modes-section');
    const section = createModesSection({
      getSettingsState: () => settingsState,
      getCurrentTier: () => 'balanced',
      notifyUpdate,
    });
    section.render();
    section.bindEvents();

    document.getElementById('import-modes-btn')?.click();
    await flushPromises();

    expect(saveSettings).not.toHaveBeenCalled();
    expect(settingsState.customModes).toEqual([existingMode]);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'importError' });

    showNotice.mockClear();
    openFileResult = Promise.reject(new Error('reader failed'));
    document.getElementById('import-modes-btn')?.click();
    await flushPromises();

    expect(saveSettings).not.toHaveBeenCalled();
    expect(settingsState.customModes).toEqual([existingMode]);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'importError' });

    showNotice.mockClear();
    openFileResult = Promise.resolve(JSON.stringify([{ name: 'Imported mode', effects: [] }]));
    document.getElementById('import-modes-btn')?.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({
      customModes: [existingMode, expect.objectContaining({ name: 'Imported mode' })],
    });
    expect(settingsState.customModes).toEqual([existingMode]);
    expect(notifyUpdate).not.toHaveBeenCalled();
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'importError' });
  });

  it('rolls back custom mode additions, renames, and reorders when storage save fails', async () => {
    document.body.innerHTML = `
      <button id="add-mode-btn"></button>
      <button id="import-modes-btn"></button>
      <button id="export-modes-btn"></button>
      <div id="modes-container"></div>
    `;
    const saveSettings = vi.fn().mockRejectedValue(new Error('sync failed'));
    const showNotice = vi.fn();
    const notifyUpdate = vi.fn();
    const existingMode: CustomMode = {
      id: 'custom-existing',
      name: 'Existing mode',
      isBuiltIn: false,
      effects: [
        { id: 'effect-a', backendId: 'anime4k', key: 'A' },
        { id: 'effect-b', backendId: 'anime4k', key: 'B' },
      ],
    };
    const settingsState = {
      selectedModeId: 'custom-existing',
      targetResolutionSetting: 'x2',
      whitelistEnabled: false,
      whitelist: [],
      customModes: [existingMode],
      enhancementModes: [existingMode],
      enableCrossOriginFix: false,
      performanceTier: 'balanced',
      performanceMonitorMode: 'off',
      performanceMonitorHudCollapsed: false,
      performanceMonitorHudPosition: 'top-left',
      performanceMonitorHudWidth: null,
    } as NijiLucidSettings;

    vi.doMock('../../src/ui/options/modules/helpers', () => ({
      downloadJSON: vi.fn(),
      openFile: vi.fn(),
    }));
    vi.doMock('../../src/utils/settings', () => ({
      BUILTIN_MODES: [],
      buildEnhancementModes: vi.fn((customModes: CustomMode[]) => customModes),
      getEffectsForMode: vi.fn((mode: CustomMode) => mode.effects),
      saveSettings,
      synchronizeEffectsForCustomModes: vi.fn((modes: CustomMode[]) => modes),
    }));
    vi.doMock('../../src/utils/effects-map', () => ({ AVAILABLE_EFFECTS: [] }));
    vi.doMock('../../src/core/effects/registry', () => ({
      getEffectDescriptor: vi.fn(),
      validateEffectChain: vi.fn(() => ({ valid: true, errors: [] })),
    }));
    vi.doMock('../../src/core/effects/reference', () => ({ createEffectReference: vi.fn() }));
    vi.doMock('../../src/ui/shared/notice', () => ({ showNotice }));
    vi.doMock('../../src/utils/logger', () => ({
      createLogger: () => ({
        debug: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
      }),
    }));

    const { createModesSection } = await import('../../src/ui/options/modules/modes-section');
    const section = createModesSection({
      getSettingsState: () => settingsState,
      getCurrentTier: () => 'balanced',
      notifyUpdate,
    });
    section.render();
    section.bindEvents();

    document.getElementById('add-mode-btn')?.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({ customModes: [expect.objectContaining({ name: 'newCustomModeName' }), existingMode] });
    expect(settingsState.customModes).toEqual([existingMode]);
    expect(settingsState.enhancementModes).toEqual([existingMode]);
    expect(notifyUpdate).not.toHaveBeenCalled();
    expect(document.querySelectorAll('.mode-card')).toHaveLength(1);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });

    saveSettings.mockClear();
    showNotice.mockClear();
    const modeName = document.querySelector('.mode-card h2') as HTMLElement;
    modeName.textContent = 'Renamed mode';
    modeName.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({
      customModes: [expect.objectContaining({ name: 'Renamed mode' })],
    });
    expect(settingsState.customModes[0].name).toBe('Existing mode');
    expect((document.querySelector('.mode-card h2') as HTMLElement).textContent).toBe('Existing mode');
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });

    saveSettings.mockClear();
    showNotice.mockClear();
    const moveDownButton = document.querySelector('button[title="moveDown"]:not(:disabled)') as HTMLButtonElement;
    moveDownButton.click();
    await flushPromises();

    expect(saveSettings).toHaveBeenCalledWith({
      customModes: [expect.objectContaining({
        effects: [
          { id: 'effect-b', backendId: 'anime4k', key: 'B' },
          { id: 'effect-a', backendId: 'anime4k', key: 'A' },
        ],
      })],
    });
    expect(settingsState.customModes[0].effects).toEqual([
      { id: 'effect-a', backendId: 'anime4k', key: 'A' },
      { id: 'effect-b', backendId: 'anime4k', key: 'B' },
    ]);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });
  });
});

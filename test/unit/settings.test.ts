import { beforeEach, describe, expect, it } from 'vitest';
import { installChromeMock } from '../support/chrome';

describe('settings utilities', () => {
  beforeEach(() => {
    installChromeMock({
      sync: {
        selectedModeId: 'builtin-mode-aa',
        targetResolutionSetting: '4k',
        whitelistEnabled: true,
        whitelist: [{ pattern: 'example.com/*', enabled: true }],
        customModes: [],
        enableCrossOriginFix: true,
      },
      local: {
        performanceTier: 'quality',
        gpuBenchmarkResult: null,
        hasCompletedOnboarding: true,
        performanceMonitorMode: 'lite',
        performanceMonitorHudCollapsed: true,
        performanceMonitorHudPosition: 'bottom-right',
        performanceMonitorHudWidth: 420,
      },
    });
  });

  it('merges sync and local settings', async () => {
    const { getSettings } = await import('../../src/utils/settings');
    const settings = await getSettings();

    expect(settings.selectedModeId).toBe('builtin-mode-aa');
    expect(settings.performanceTier).toBe('quality');
    expect(settings.performanceMonitorMode).toBe('lite');
    expect(settings.performanceMonitorHudCollapsed).toBe(true);
    expect(settings.performanceMonitorHudPosition).toBe('bottom-right');
    expect(settings.performanceMonitorHudWidth).toBe(420);
    expect(settings.enhancementModes.length).toBeGreaterThan(0);
  });

  it('splits saveSettings into sync and local stores', async () => {
    const chromeMock = installChromeMock();
    const { saveSettings } = await import('../../src/utils/settings');

    await saveSettings({
      selectedModeId: 'builtin-mode-bb',
      performanceTier: 'ultra',
      enableCrossOriginFix: true,
      performanceMonitorMode: 'gpu',
      performanceMonitorHudWidth: 380,
    });

    expect(chromeMock.__mock.syncState.selectedModeId).toBe('builtin-mode-bb');
    expect(chromeMock.__mock.syncState.enableCrossOriginFix).toBe(true);
    expect(chromeMock.__mock.syncState.performanceMonitorMode).toBeUndefined();
    expect(chromeMock.__mock.localState.performanceTier).toBe('ultra');
    expect(chromeMock.__mock.localState.performanceMonitorMode).toBe('gpu');
    expect(chromeMock.__mock.localState.performanceMonitorHudWidth).toBe(380);
  });

  it('reports partial failures when one settings storage area fails', async () => {
    const chromeMock = installChromeMock();
    const { saveSettings, SettingsSaveError } = await import('../../src/utils/settings');
    const syncFailure = new Error('sync quota exceeded');

    chromeMock.__mock.queueStorageSetError('sync', syncFailure);

    await expect(saveSettings({
      selectedModeId: 'builtin-mode-bb',
      performanceTier: 'ultra',
    })).rejects.toMatchObject({
      name: 'SettingsSaveError',
      failures: [{ area: 'sync', error: syncFailure }],
      succeededAreas: ['local'],
    });

    expect(chromeMock.__mock.localState.performanceTier).toBe('ultra');

    try {
      await saveSettings({
        selectedModeId: 'builtin-mode-bb',
        performanceTier: 'quality',
      });
    } catch (error) {
      expect(error).toBeInstanceOf(SettingsSaveError);
      expect((error as InstanceType<typeof SettingsSaveError>).message).toBe('Failed to save settings to sync.');
    }
  });

  it('saves and restores recommended, compatibility, and custom mode selections', async () => {
    const chromeMock = installChromeMock({
      sync: {
        selectedModeId: 'recommended-detail-preserving',
        customModes: [{
          id: 'custom-settings',
          name: 'Settings Custom',
          isBuiltIn: false,
          effects: [],
        }],
      },
    });
    const { getSettings, saveSettings } = await import('../../src/utils/settings');

    expect((await getSettings()).selectedModeId).toBe('recommended-detail-preserving');

    await saveSettings({ selectedModeId: 'builtin-mode-aa' });
    expect((await getSettings()).selectedModeId).toBe('builtin-mode-aa');

    await saveSettings({ selectedModeId: 'custom-settings' });
    expect((await getSettings()).selectedModeId).toBe('custom-settings');
    expect(chromeMock.__mock.syncState.selectedModeId).toBe('custom-settings');
  });
});

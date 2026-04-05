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
      },
    });
  });

  it('merges sync and local settings', async () => {
    const { getSettings } = await import('../../src/utils/settings');
    const settings = await getSettings();

    expect(settings.selectedModeId).toBe('builtin-mode-aa');
    expect(settings.performanceTier).toBe('quality');
    expect(settings.enhancementModes.length).toBeGreaterThan(0);
  });

  it('splits saveSettings into sync and local stores', async () => {
    const chromeMock = installChromeMock();
    const { saveSettings } = await import('../../src/utils/settings');

    await saveSettings({
      selectedModeId: 'builtin-mode-bb',
      performanceTier: 'ultra',
      enableCrossOriginFix: true,
    });

    expect(chromeMock.__mock.syncState.selectedModeId).toBe('builtin-mode-bb');
    expect(chromeMock.__mock.syncState.enableCrossOriginFix).toBe(true);
    expect(chromeMock.__mock.localState.performanceTier).toBe('ultra');
  });
});

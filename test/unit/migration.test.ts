import { beforeEach, describe, expect, it } from 'vitest';
import { installChromeMock } from '../support/chrome';

describe('migration utilities', () => {
  beforeEach(() => {
    installChromeMock({
      sync: {
        _configVersion: 2,
        enhancementModes: [
          {
            id: 'legacy-custom',
            name: 'Legacy Custom',
            isBuiltIn: false,
            effects: [{ className: 'CNNM' }],
          },
        ],
        selectedModeId: 'legacy-custom',
      },
      local: {
        performanceTier: 'balanced',
        hasCompletedOnboarding: false,
      },
    });
  });

  it('migrates legacy enhancementModes to customModes', async () => {
    const chromeMock = installChromeMock({
      sync: {
        _configVersion: 2,
        enhancementModes: [
          {
            id: 'legacy-custom',
            name: 'Legacy Custom',
            isBuiltIn: false,
            effects: [{ className: 'CNNM' }],
          },
        ],
        selectedModeId: 'legacy-custom',
      },
      local: {
        performanceTier: 'balanced',
      },
    });
    const { migrateToLatest } = await import('../../src/utils/migration');

    await migrateToLatest();

    expect(chromeMock.__mock.syncState._configVersion).toBe(4);
    expect(chromeMock.__mock.syncState.customModes).toHaveLength(1);
    expect(chromeMock.__mock.syncState.customModes[0].effects[0].backendId).toBe('anime4k');
    expect(chromeMock.__mock.syncState.enhancementModes).toBeUndefined();
  });

  it('initializes defaults when config is missing', async () => {
    const chromeMock = installChromeMock();
    const { ensureLatestConfig } = await import('../../src/utils/migration');

    await ensureLatestConfig();

    expect(chromeMock.__mock.syncState._configVersion).toBe(4);
    expect(chromeMock.__mock.syncState.selectedModeId).toBe('recommended-detail-preserving');
    expect(chromeMock.__mock.localState.performanceTier).toBe('balanced');
  });

  it('preserves valid compatibility and custom selections during migration', async () => {
    const chromeMock = installChromeMock({
      sync: {
        _configVersion: 3,
        selectedModeId: 'custom-keep',
        customModes: [{
          id: 'custom-keep',
          name: 'Keep me',
          isBuiltIn: false,
          effects: [],
        }],
      },
    });
    const { migrateToLatest } = await import('../../src/utils/migration');

    await migrateToLatest();
    expect(chromeMock.__mock.syncState.selectedModeId).toBe('custom-keep');

    const compatibilityMock = installChromeMock({
      sync: {
        _configVersion: 3,
        selectedModeId: 'builtin-mode-ca',
      },
    });
    await migrateToLatest();
    expect(compatibilityMock.__mock.syncState.selectedModeId).toBe('builtin-mode-ca');
  });

  it('falls back to detail-preserving when the selected mode is invalid', async () => {
    const chromeMock = installChromeMock({
      sync: {
        _configVersion: 3,
        selectedModeId: 'missing-mode',
      },
    });
    const { migrateToLatest } = await import('../../src/utils/migration');

    await migrateToLatest();
    expect(chromeMock.__mock.syncState.selectedModeId).toBe('recommended-detail-preserving');
  });
});

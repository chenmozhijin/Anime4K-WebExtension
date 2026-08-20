import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';

function installDefaultChrome() {
  return installChromeMock({
    sync: {
      selectedModeId: 'builtin-mode-aa',
      targetResolutionSetting: '4k',
      whitelistEnabled: true,
      whitelist: [{ pattern: 'example.com/*', enabled: true }],
      customModes: [],
      enableCrossOriginFix: true,
    },
    local: {
      performanceTier: 'balanced',
      gpuBenchmarkResult: null,
      hasCompletedOnboarding: false,
    },
  });
}

async function waitForRevision(
  getRevision: () => number,
  expectedRevision: number,
): Promise<void> {
  for (let attempt = 0; attempt < 20; attempt += 1) {
    if (getRevision() === expectedRevision) {
      return;
    }

    await new Promise(resolve => setTimeout(resolve, 0));
  }

  throw new Error(`Timed out waiting for revision ${expectedRevision}`);
}

function createDeferred<T>(): {
  promise: Promise<T>;
  resolve(value: T): void;
} {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(resolvePromise => {
    resolve = resolvePromise;
  });
  return { promise, resolve };
}

describe('settings snapshot', () => {
  it('initializes snapshots and increments revisions on refresh', async () => {
    installDefaultChrome();
    const snapshotModule = await import('../../src/utils/settings-snapshot');

    const initial = await snapshotModule.initSettingsSnapshot();
    expect(initial.revision).toBe(1);
    expect(initial.compiledWhitelist).toHaveLength(1);
    expect(snapshotModule.getSettingsSnapshot()).toEqual(initial);

    await chrome.storage.sync.set({ selectedModeId: 'builtin-mode-bb' });
    const refreshed = await snapshotModule.refreshSettingsSnapshot();

    expect(refreshed.revision).toBe(2);
    expect(refreshed.settings.selectedModeId).toBe('builtin-mode-bb');
    expect(snapshotModule.getSettingsSnapshot()).toEqual(refreshed);
  });

  it('installs the storage listener once and refreshes only on relevant keys', async () => {
    const chromeMock = installDefaultChrome();
    const snapshotModule = await import('../../src/utils/settings-snapshot');

    await snapshotModule.initSettingsSnapshot();
    expect((chromeMock.storage.onChanged as unknown as { listenerCount(): number }).listenerCount()).toBe(1);

    await snapshotModule.refreshSettingsSnapshot();
    expect((chromeMock.storage.onChanged as unknown as { listenerCount(): number }).listenerCount()).toBe(1);

    await chrome.storage.sync.set({ theme: 'dark' });
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(snapshotModule.getSettingsSnapshot().revision).toBe(2);

    await chrome.storage.sync.set({ selectedModeId: 'builtin-mode-c' });
    await waitForRevision(() => snapshotModule.getSettingsSnapshot().revision, 3);
    expect(snapshotModule.getSettingsSnapshot().settings.selectedModeId).toBe('builtin-mode-c');

    await chrome.storage.local.set({ hasCompletedOnboarding: true });
    await waitForRevision(() => snapshotModule.getSettingsSnapshot().revision, 4);
    expect(snapshotModule.getSettingsSnapshot().revision).toBe(4);
  });

  it('notifies subscribers and supports unsubscription', async () => {
    installDefaultChrome();
    const snapshotModule = await import('../../src/utils/settings-snapshot');
    const revisions: number[] = [];

    const unsubscribe = snapshotModule.subscribeSettingsSnapshot(snapshot => {
      revisions.push(snapshot.revision);
    });

    await snapshotModule.initSettingsSnapshot();
    await chrome.storage.local.set({ performanceTier: 'quality' });
    await waitForRevision(() => snapshotModule.getSettingsSnapshot().revision, 2);

    unsubscribe();

    await snapshotModule.refreshSettingsSnapshot();

    expect(revisions).toEqual([1, 2]);
    expect(snapshotModule.getSettingsSnapshot().settings.performanceTier).toBe('quality');
  });

  it('discards an invalidated read and resolves concurrent callers with the latest snapshot', async () => {
    installDefaultChrome();
    const settingsModule = await import('../../src/utils/settings');
    const initialSettings = await settingsModule.getSettings();
    const staleRead = createDeferred<typeof initialSettings>();
    const latestRead = createDeferred<typeof initialSettings>();
    const getSettings = vi.spyOn(settingsModule, 'getSettings')
      .mockImplementationOnce(() => staleRead.promise)
      .mockImplementationOnce(() => latestRead.promise);
    const snapshotModule = await import('../../src/utils/settings-snapshot');
    const publishedModes: string[] = [];
    snapshotModule.subscribeSettingsSnapshot(snapshot => {
      publishedModes.push(snapshot.settings.selectedModeId);
    });

    const firstCaller = snapshotModule.refreshSettingsSnapshot();
    const secondCaller = snapshotModule.refreshSettingsSnapshot();
    expect(firstCaller).toBe(secondCaller);

    staleRead.resolve(initialSettings);
    await vi.waitFor(() => expect(getSettings).toHaveBeenCalledTimes(2));

    const latestSettings = {
      ...initialSettings,
      selectedModeId: 'builtin-mode-latest',
    };
    latestRead.resolve(latestSettings);
    const [firstResult, secondResult] = await Promise.all([firstCaller, secondCaller]);

    expect(firstResult).toBe(secondResult);
    expect(firstResult.revision).toBe(1);
    expect(firstResult.settings.selectedModeId).toBe('builtin-mode-latest');
    expect(publishedModes).toEqual(['builtin-mode-latest']);
  });
});

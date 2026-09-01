import { beforeEach, describe, expect, it, vi } from 'vitest';
import { createBackgroundHarness } from '../support/bootstrap';

const ensureLatestConfig = vi.fn();
const getSettings = vi.fn();
const getLocalSettings = vi.fn();

describe('background bootstrap', () => {
  beforeEach(() => {
    ensureLatestConfig.mockReset();
    getSettings.mockReset();
    getLocalSettings.mockReset();
    getSettings.mockResolvedValue({ enableCrossOriginFix: false });
    getLocalSettings.mockResolvedValue({
      hasCompletedOnboarding: true,
      benchmarkRunState: { status: 'idle' },
    });
  });

  it('handles install flow and opens onboarding when needed', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      local: { _benchmarkInProgress: true },
    });
    getSettings.mockResolvedValue({ enableCrossOriginFix: true });
    getLocalSettings.mockResolvedValue({ hasCompletedOnboarding: false });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({ reason: 'install' } as chrome.runtime.InstalledDetails);

    expect(ensureLatestConfig).toHaveBeenCalledOnce();
    expect(chromeMock.__mock.dnrUpdates[0]).toEqual({ enableRulesetIds: ['ruleset_1'] });
    expect(chromeMock.__mock.tabsCreated[0]?.url).toContain('onboarding.html');
    expect(chromeMock.__mock.localState.performanceTier).toBe('performance');
  });

  it('opens upgrade onboarding for an update from before 0.5.0', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings: getLocalSettings.mockResolvedValue({
        performanceTier: 'quality',
        hasCompletedOnboarding: true,
        benchmarkRunState: { status: 'idle' },
      }),
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.10',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated).toEqual([
      { url: 'chrome-extension://test-extension/onboarding.html?mode=upgrade' },
    ]);
  });

  it('opens upgrade onboarding when an older version jumps to a later release', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '1.0.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html?mode=upgrade',
    );
  });

  it.each([
    ['completed', false],
    ['failed', false],
    ['running', true],
    ['interrupted', false],
  ] as const)('resets legacy benchmark state during an upgrade from %s', async (status, inProgress) => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
      local: {
        performanceTier: 'quality',
        hasCompletedOnboarding: true,
        gpuBenchmarkResult: { tier: 'ultra' },
        benchmarkRunState: { status },
        ...(inProgress ? { _benchmarkInProgress: true } : {}),
      },
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.localState.performanceTier).toBe('quality');
    expect(chromeMock.__mock.localState.hasCompletedOnboarding).toBe(true);
    expect(chromeMock.__mock.localState.gpuBenchmarkResult).toBeNull();
    expect(chromeMock.__mock.localState.benchmarkRunState).toEqual({
      status: 'idle',
      fallbackTierApplied: null,
    });
    expect(chromeMock.__mock.localState._benchmarkInProgress).toBeUndefined();
  });

  it('resets benchmark data after migration so migrated legacy results cannot return', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
      local: {
        performanceTier: 'ultra',
        gpuBenchmarkResult: { tier: 'quality' },
        benchmarkRunState: { status: 'completed' },
      },
    });
    ensureLatestConfig.mockImplementationOnce(async () => {
      chromeMock.__mock.localState.gpuBenchmarkResult = { tier: 'performance' };
      chromeMock.__mock.localState.benchmarkRunState = { status: 'completed' };
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.localState.gpuBenchmarkResult).toBeNull();
    expect(chromeMock.__mock.localState.benchmarkRunState).toEqual({
      status: 'idle',
      fallbackTierApplied: null,
    });
  });

  it('still opens upgrade onboarding when legacy benchmark cleanup fails', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });
    chromeMock.__mock.queueStorageSetError('local', 'upgrade cleanup failed');

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html?mode=upgrade',
    );
  });

  it('does not open upgrade onboarding after the boundary version', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.1',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.5.0',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated).toHaveLength(0);
  });

  it('recognizes a prerelease previous version as being before the boundary', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.5.0-rc.1',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html?mode=upgrade',
    );
  });

  it('does not reopen onboarding for a browser update reason', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'chrome_update',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated).toHaveLength(0);
  });

  it('keeps first-install onboarding on the ordinary URL', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings: getLocalSettings.mockResolvedValue({
        hasCompletedOnboarding: false,
        benchmarkRunState: { status: 'idle' },
      }),
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({ reason: 'install' } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html',
    );
  });

  it('still opens upgrade onboarding when maintenance work fails', async () => {
    ensureLatestConfig.mockRejectedValueOnce(new Error('migration failed'));
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html?mode=upgrade',
    );
  });

  it('fails closed for missing or invalid previous versions', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: 'not-a-version',
    } as chrome.runtime.InstalledDetails);
    await chromeMock.__mock.runtimeOnInstalled.trigger({ reason: 'update' } as chrome.runtime.InstalledDetails);

    expect(chromeMock.__mock.tabsCreated).toHaveLength(0);
  });

  it('does not reopen onboarding on browser startup after an upgrade', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      manifestVersion: '0.5.0',
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.runtimeOnInstalled.trigger({
      reason: 'update',
      previousVersion: '0.4.9',
    } as chrome.runtime.InstalledDetails);
    await chromeMock.__mock.runtimeOnStartup.trigger();

    expect(chromeMock.__mock.tabsCreated).toHaveLength(1);
  });

  it('runs crash checks and DNR updates on startup', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    }, {
      local: { _benchmarkInProgress: true },
    });
    getSettings.mockResolvedValue({ enableCrossOriginFix: true });

    bootstrap.registerListeners();
    await chromeMock.__mock.runtimeOnStartup.trigger();

    expect(ensureLatestConfig).not.toHaveBeenCalled();
    expect(chromeMock.__mock.localState.performanceTier).toBe('performance');
    expect(chromeMock.__mock.dnrUpdates).toContainEqual({ enableRulesetIds: ['ruleset_1'] });
  });

  it('updates DNR rulesets for both enabled and disabled states', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });

    getSettings.mockResolvedValueOnce({ enableCrossOriginFix: true });
    await bootstrap.updateDNRuleset();

    getSettings.mockResolvedValueOnce({ enableCrossOriginFix: false });
    await bootstrap.updateDNRuleset();

    expect(chromeMock.__mock.dnrUpdates).toEqual([
      { enableRulesetIds: ['ruleset_1'] },
      { disableRulesetIds: ['ruleset_1'] },
    ]);
  });

  it('marks interrupted benchmarks when persisted local settings still show running', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });
    getLocalSettings.mockResolvedValue({
      hasCompletedOnboarding: true,
      benchmarkRunState: {
        status: 'running',
        startedAt: 123,
      },
    });

    await bootstrap.checkBenchmarkCrash();

    expect(chromeMock.__mock.localState.performanceTier).toBe('performance');
    expect(chromeMock.__mock.localState.benchmarkRunState).toMatchObject({
      status: 'interrupted',
      failureReason: 'crash',
      fallbackTierApplied: 'performance',
      startedAt: 123,
    });
  });

  it('handles runtime messages for settings, options, and onboarding', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });
    getSettings.mockResolvedValue({ enableCrossOriginFix: true });

    bootstrap.registerListeners();

    await chromeMock.runtime.sendMessage({ type: 'SETTINGS_UPDATED' });
    await chromeMock.runtime.sendMessage({ type: 'OPEN_OPTIONS_PAGE' });
    await chromeMock.runtime.sendMessage({ type: 'OPEN_ONBOARDING' });

    expect(chromeMock.__mock.dnrUpdates).toContainEqual({ enableRulesetIds: ['ruleset_1'] });
    expect(chromeMock.__mock.openOptionsPageCalls).toHaveLength(1);
    expect(chromeMock.__mock.tabsCreated[0]?.url).toBe(
      'chrome-extension://test-extension/onboarding.html',
    );
  });

  it('forwards URL update messages to active tabs', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.tabsOnUpdated.trigger(
      5,
      { status: 'complete' },
      { id: 5, url: 'https://example.com/video' } as chrome.tabs.Tab,
    );

    expect(chromeMock.__mock.sentTabMessages[0]).toEqual({
      tabId: 5,
      message: {
        type: 'URL_UPDATED',
        url: 'https://example.com/video',
      },
    });
  });

  it('ignores tab updates when the load is incomplete or the URL is missing', async () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });

    bootstrap.registerListeners();

    await chromeMock.__mock.tabsOnUpdated.trigger(
      5,
      { status: 'loading' },
      { id: 5, url: 'https://example.com/video' } as chrome.tabs.Tab,
    );
    await chromeMock.__mock.tabsOnUpdated.trigger(
      5,
      { status: 'complete' },
      { id: 5 } as chrome.tabs.Tab,
    );

    expect(chromeMock.__mock.sentTabMessages).toHaveLength(0);
  });

  it('suppresses receiving-end errors but logs unexpected tab message failures', async () => {
    const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });

    bootstrap.registerListeners();

    chromeMock.__mock.queueTabSendMessageError('Could not establish connection. Receiving end does not exist.');
    await chromeMock.__mock.tabsOnUpdated.trigger(
      5,
      { status: 'complete' },
      { id: 5, url: 'https://example.com/video' } as chrome.tabs.Tab,
    );

    chromeMock.__mock.queueTabSendMessageError('Unexpected failure');
    await chromeMock.__mock.tabsOnUpdated.trigger(
      6,
      { status: 'complete' },
      { id: 6, url: 'https://example.com/video-2' } as chrome.tabs.Tab,
    );

    expect(errorSpy).toHaveBeenCalledTimes(1);
    expect(errorSpy.mock.calls[0]?.[1]).toContain('Unexpected failure');
  });

  it('registers and disposes listeners idempotently', () => {
    const { bootstrap, chromeMock } = createBackgroundHarness({
      ensureLatestConfig,
      getSettings,
      getLocalSettings,
    });

    bootstrap.registerListeners();
    bootstrap.registerListeners();

    expect(chromeMock.__mock.runtimeOnStartup.listenerCount()).toBe(1);
    expect(chromeMock.__mock.runtimeOnInstalled.listenerCount()).toBe(1);
    expect(chromeMock.__mock.runtimeOnMessage.listenerCount()).toBe(1);
    expect(chromeMock.__mock.tabsOnUpdated.listenerCount()).toBe(1);

    bootstrap.dispose();
    bootstrap.dispose();

    expect(chromeMock.__mock.runtimeOnStartup.listenerCount()).toBe(0);
    expect(chromeMock.__mock.runtimeOnInstalled.listenerCount()).toBe(0);
    expect(chromeMock.__mock.runtimeOnMessage.listenerCount()).toBe(0);
    expect(chromeMock.__mock.tabsOnUpdated.listenerCount()).toBe(0);
  });
});

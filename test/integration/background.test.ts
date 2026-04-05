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
    expect(chromeMock.__mock.tabsCreated[0]?.url).toContain('onboarding.html');
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

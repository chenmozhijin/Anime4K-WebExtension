import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { createContentHarness } from '../support/bootstrap';
import type { ContentBootstrap, SettingsUpdateResponse } from '../../src/content';

const initSettingsSnapshot = vi.fn();
const refreshSettingsSnapshot = vi.fn();
const subscribeSettingsSnapshot = vi.fn();
const getSettingsSnapshot = vi.fn();
const isUrlWhitelisted = vi.fn();

function createVideo(id: string): HTMLVideoElement {
  const video = document.createElement('video');
  video.id = id;
  document.body.appendChild(video);
  return video;
}

function createVideoManagerModule() {
  return {
    initializeOnPage: vi.fn(),
    processVideoElement: vi.fn(),
    handleSettingsUpdate: vi.fn().mockResolvedValue({
      status: 'SUCCESS',
      message: 'ok',
    }),
    deinitializeOnPage: vi.fn(),
  };
}

describe('content bootstrap', () => {
  let bootstrap: ContentBootstrap | null = null;
  let settingsSubscriber: (() => void) | null = null;

  beforeEach(() => {
    document.body.innerHTML = '';
    createVideo('target-video');
    settingsSubscriber = null;
    initSettingsSnapshot.mockReset();
    refreshSettingsSnapshot.mockReset();
    subscribeSettingsSnapshot.mockReset();
    getSettingsSnapshot.mockReset();
    isUrlWhitelisted.mockReset();

    initSettingsSnapshot.mockResolvedValue(undefined);
    refreshSettingsSnapshot.mockResolvedValue(undefined);
    subscribeSettingsSnapshot.mockImplementation(callback => {
      settingsSubscriber = callback;
      return () => undefined;
    });
    getSettingsSnapshot.mockReturnValue({
      settings: {
        whitelistEnabled: false,
      },
      compiledWhitelist: [],
    });
    isUrlWhitelisted.mockReturnValue(true);
    window.history.replaceState({}, '', '/initial');
  });

  afterEach(() => {
    bootstrap?.dispose();
    bootstrap = null;
  });

  it('bootstraps and loads the heavy video manager for discovered videos', async () => {
    const module = createVideoManagerModule();

    ({ bootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    }));

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    expect(initSettingsSnapshot).toHaveBeenCalled();
    expect(subscribeSettingsSnapshot).toHaveBeenCalledOnce();
    expect(module.initializeOnPage).toHaveBeenCalledOnce();
    expect(module.processVideoElement).toHaveBeenCalledWith(
      document.getElementById('target-video'),
      expect.stringContaining('discovery:initial-scan'),
    );
  });

  it('registers runtime listeners, patches history, and restores cleanup on dispose', async () => {
    const module = createVideoManagerModule();
    const unsubscribe = vi.fn();
    subscribeSettingsSnapshot.mockImplementation(callback => {
      settingsSubscriber = callback;
      return unsubscribe;
    });
    const originalPushState = window.history.pushState;
    const originalReplaceState = window.history.replaceState;

    const { chromeMock, bootstrap: contentBootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    });
    bootstrap = contentBootstrap;

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    expect(chromeMock.__mock.runtimeOnMessage.listenerCount()).toBe(1);
    expect(settingsSubscriber).toBeTypeOf('function');
    expect(window.history.pushState).not.toBe(originalPushState);
    expect(window.history.replaceState).not.toBe(originalReplaceState);

    bootstrap.dispose();

    expect(chromeMock.__mock.runtimeOnMessage.listenerCount()).toBe(0);
    expect(unsubscribe).toHaveBeenCalledOnce();
    expect(window.history.pushState).toBe(originalPushState);
    expect(window.history.replaceState).toBe(originalReplaceState);
  });

  it('discovers videos rendered inside open shadow roots before loading the heavy manager', async () => {
    document.body.innerHTML = '<div id="shadow-host"></div>';
    const host = document.getElementById('shadow-host') as HTMLDivElement;
    const shadow = host.attachShadow({ mode: 'open' });
    const shadowVideo = document.createElement('video');
    shadowVideo.id = 'shadow-video';
    shadow.appendChild(shadowVideo);
    const module = createVideoManagerModule();

    ({ bootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    }));

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    expect(module.initializeOnPage).toHaveBeenCalledOnce();
    expect(module.processVideoElement).toHaveBeenCalledWith(
      shadowVideo,
      expect.stringContaining('discovery:initial-scan'),
    );
  });

  it('returns async SETTINGS_UPDATED responses after refreshing the snapshot', async () => {
    const module = createVideoManagerModule();
    const response = {
      status: 'PARTIAL_SUCCESS',
      message: 'updated',
      updatedCount: 1,
      failedCount: 1,
    } satisfies SettingsUpdateResponse;
    module.handleSettingsUpdate.mockResolvedValue(response);
    const { chromeMock, bootstrap: contentBootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    });
    bootstrap = contentBootstrap;

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    const result = await chromeMock.runtime.sendMessage({
      type: 'SETTINGS_UPDATED',
      modifiedModeId: 'custom-mode',
    });
    await bootstrap.whenIdle();

    expect(refreshSettingsSnapshot).toHaveBeenCalledOnce();
    expect(module.handleSettingsUpdate).toHaveBeenLastCalledWith(
      { type: 'SETTINGS_UPDATED', modifiedModeId: 'custom-mode' },
      getSettingsSnapshot.mock.results.at(-1)?.value.settings,
    );
    expect(result).toEqual(response);
  });

  it('re-evaluates URL_UPDATED without triggering renderer updates', async () => {
    getSettingsSnapshot.mockReturnValue({
      settings: {
        whitelistEnabled: true,
      },
      compiledWhitelist: [{ pattern: 'allowed/*', enabled: true }],
    });
    isUrlWhitelisted.mockReturnValue(true);
    const module = createVideoManagerModule();
    const { chromeMock, bootstrap: contentBootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    });
    bootstrap = contentBootstrap;

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    refreshSettingsSnapshot.mockClear();
    isUrlWhitelisted.mockClear();
    module.handleSettingsUpdate.mockClear();

    await chromeMock.runtime.sendMessage({
      type: 'URL_UPDATED',
      url: 'https://example.com/updated',
    });
    await bootstrap.whenIdle();

    expect(refreshSettingsSnapshot).not.toHaveBeenCalled();
    expect(isUrlWhitelisted).toHaveBeenCalledOnce();
    expect(module.handleSettingsUpdate).not.toHaveBeenCalled();
  });

  it('deactivates and reactivates the heavy manager when whitelist state changes', async () => {
    const module = createVideoManagerModule();
    const snapshots = [
      {
        settings: { whitelistEnabled: false },
        compiledWhitelist: [],
      },
      {
        settings: { whitelistEnabled: true },
        compiledWhitelist: [{ pattern: 'allowed/*', enabled: true }],
      },
      {
        settings: { whitelistEnabled: false },
        compiledWhitelist: [],
      },
    ];
    let snapshotIndex = 0;
    getSettingsSnapshot.mockImplementation(() => snapshots[snapshotIndex]);
    isUrlWhitelisted.mockReturnValue(false);

    ({ bootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    }));

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();
    expect(module.initializeOnPage).toHaveBeenCalledTimes(1);

    snapshotIndex = 1;
    settingsSubscriber?.();
    await bootstrap.whenIdle();

    expect(module.deinitializeOnPage).toHaveBeenCalledTimes(1);

    const inactiveVideo = createVideo('inactive-video');
    inactiveVideo.dispatchEvent(new Event('play', { bubbles: true }));
    await bootstrap.whenIdle();
    expect(module.processVideoElement).not.toHaveBeenCalledWith(
      inactiveVideo,
      expect.any(String),
    );

    snapshotIndex = 2;
    settingsSubscriber?.();
    await bootstrap.whenIdle();

    expect(module.initializeOnPage).toHaveBeenCalledTimes(2);
    expect(module.processVideoElement).not.toHaveBeenCalledWith(
      inactiveVideo,
      expect.any(String),
    );
    expect(module.processVideoElement).toHaveBeenCalledWith(
      document.getElementById('target-video'),
      expect.stringContaining('discovery:initial-scan'),
    );
  });

  it('queues reevaluation on pushState, replaceState, popstate, and hashchange', async () => {
    getSettingsSnapshot.mockReturnValue({
      settings: {
        whitelistEnabled: true,
      },
      compiledWhitelist: [{ pattern: 'allowed/*', enabled: true }],
    });
    isUrlWhitelisted.mockReturnValue(true);
    const module = createVideoManagerModule();

    ({ bootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    }));

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    isUrlWhitelisted.mockClear();

    window.history.pushState({}, '', '/push-state');
    await bootstrap.whenIdle();
    expect(isUrlWhitelisted).toHaveBeenLastCalledWith(
      expect.stringContaining('/push-state'),
      expect.any(Array),
    );

    isUrlWhitelisted.mockClear();
    window.history.replaceState({}, '', '/replace-state');
    await bootstrap.whenIdle();
    expect(isUrlWhitelisted).toHaveBeenLastCalledWith(
      expect.stringContaining('/replace-state'),
      expect.any(Array),
    );

    isUrlWhitelisted.mockClear();
    window.dispatchEvent(new PopStateEvent('popstate'));
    await bootstrap.whenIdle();
    expect(isUrlWhitelisted).toHaveBeenCalledOnce();

    isUrlWhitelisted.mockClear();
    window.location.hash = '#next';
    window.dispatchEvent(new HashChangeEvent('hashchange'));
    await bootstrap.whenIdle();
    expect(isUrlWhitelisted).toHaveBeenCalled();
  });

  it('keeps the heavy manager inactive when URL is not whitelisted', async () => {
    getSettingsSnapshot.mockReturnValue({
      settings: {
        whitelistEnabled: true,
      },
      compiledWhitelist: [{ pattern: 'allowed/*', enabled: true }],
    });
    isUrlWhitelisted.mockReturnValue(false);
    const module = createVideoManagerModule();

    ({ bootstrap } = createContentHarness({
      initSettingsSnapshot,
      refreshSettingsSnapshot,
      subscribeSettingsSnapshot,
      getSettingsSnapshot,
      isUrlWhitelisted,
      loadVideoManagerModule: async () => module as any,
    }));

    await bootstrap.bootstrapContentScript();
    await bootstrap.whenIdle();

    expect(module.initializeOnPage).not.toHaveBeenCalled();
    expect(module.processVideoElement).not.toHaveBeenCalled();

    const inactiveVideo = createVideo('inactive-whitelist-video');
    inactiveVideo.dispatchEvent(new Event('play', { bubbles: true }));
    await bootstrap.whenIdle();

    expect(module.processVideoElement).not.toHaveBeenCalledWith(
      inactiveVideo,
      expect.any(String),
    );
  });
});

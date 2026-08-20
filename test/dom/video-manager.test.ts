import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { ANIME4K_APPLIED_ATTR } from '../../src/constants';

type MockEnhancer = {
  destroy: ReturnType<typeof vi.fn>;
  detach: ReturnType<typeof vi.fn>;
  reattach: ReturnType<typeof vi.fn>;
  updateSettings: ReturnType<typeof vi.fn>;
  getCurrentModeId: () => string;
  getVideoElement: () => HTMLVideoElement;
};

const managedVideos: HTMLVideoElement[] = [];
const enhancerByVideo = new Map<HTMLVideoElement, MockEnhancer>();
const associateEnhancerMock = vi.fn((video: HTMLVideoElement, enhancer: MockEnhancer) => {
  enhancerByVideo.set(video, enhancer);
});
const dissociateEnhancerMock = vi.fn((video: HTMLVideoElement) => {
  enhancerByVideo.delete(video);
});
const stashEnhancerMock = vi.fn();
const findAndunstashEnhancerMock = vi.fn();
const createEnhancerMock = vi.fn<(video: HTMLVideoElement) => MockEnhancer>();

let lastMutationCallback: ((records: Array<{
  addedNodes: Node[];
  removedNodes: Node[];
}>) => void) | null = null;

function createMockEnhancer(video: HTMLVideoElement, modeId = 'mode-a'): MockEnhancer {
  return {
    destroy: vi.fn(),
    detach: vi.fn(),
    reattach: vi.fn().mockResolvedValue(undefined),
    updateSettings: vi.fn().mockResolvedValue(undefined),
    getCurrentModeId: () => modeId,
    getVideoElement: () => video,
  };
}

function createVideoStub(applied = false): HTMLVideoElement {
  const attrs = new Map<string, string>();
  if (applied) {
    attrs.set(ANIME4K_APPLIED_ATTR, 'true');
  }

  return {
    getAttribute: (name: string) => attrs.get(name) ?? null,
    setAttribute: (name: string, value: string) => {
      attrs.set(name, value);
    },
  } as HTMLVideoElement;
}

function createDomVideo(url = 'https://example.com/video.mp4', width = 1920, height = 1080): HTMLVideoElement {
  const video = document.createElement('video');
  video.src = url;
  Object.defineProperty(video, 'videoWidth', { configurable: true, value: width });
  Object.defineProperty(video, 'videoHeight', { configurable: true, value: height });
  return video;
}

class FakeMutationObserver {
  constructor(
    callback: (records: Array<{ addedNodes: Node[]; removedNodes: Node[] }>) => void,
  ) {
    lastMutationCallback = callback;
  }

  observe = vi.fn();

  disconnect = vi.fn();
}

vi.mock('../../src/core/video-enhancer', () => ({
  VideoEnhancer: {
    create: createEnhancerMock,
  },
}));

vi.mock('../../src/core/enhancer-stash', () => ({
  stashEnhancer: stashEnhancerMock,
  findAndunstashEnhancer: findAndunstashEnhancerMock,
}));

vi.mock('../../src/core/enhancer-map', () => ({
  associateEnhancer: associateEnhancerMock,
  getEnhancer: (video: HTMLVideoElement) => enhancerByVideo.get(video),
  hasEnhancer: (video: HTMLVideoElement) => enhancerByVideo.has(video),
  dissociateEnhancer: dissociateEnhancerMock,
  getAllManagedVideos: () => [...managedVideos],
}));

describe('video manager', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.clearAllMocks();
    managedVideos.length = 0;
    enhancerByVideo.clear();
    lastMutationCallback = null;
    stashEnhancerMock.mockImplementation(() => undefined);
    findAndunstashEnhancerMock.mockImplementation(() => null);
    createEnhancerMock.mockImplementation((video: HTMLVideoElement) => createMockEnhancer(video));
    (globalThis as typeof globalThis & { MutationObserver: typeof MutationObserver }).MutationObserver = FakeMutationObserver as unknown as typeof MutationObserver;
    document.body.innerHTML = '';
  });

  afterEach(async () => {
    const module = await import('../../src/core/video-manager');
    module.deinitializeOnPage();
  });

  it('returns partial success when some active videos fail to update', async () => {
    const updatedVideo = createVideoStub(true);
    const failedVideo = createVideoStub(true);
    const skippedVideo = createVideoStub(false);

    managedVideos.push(updatedVideo, failedVideo, skippedVideo);
    enhancerByVideo.set(updatedVideo, {
      ...createMockEnhancer(updatedVideo),
      updateSettings: vi.fn().mockResolvedValue(undefined),
    });
    enhancerByVideo.set(failedVideo, {
      ...createMockEnhancer(failedVideo),
      updateSettings: vi.fn().mockRejectedValue(new Error('mock update failure')),
    });
    enhancerByVideo.set(skippedVideo, {
      ...createMockEnhancer(skippedVideo),
      updateSettings: vi.fn().mockResolvedValue(undefined),
    });

    const { handleSettingsUpdate } = await import('../../src/core/video-manager');
    const response = await handleSettingsUpdate(
      { type: 'SETTINGS_UPDATED' },
      {} as never,
    );

    expect(response).toMatchObject({
      status: 'PARTIAL_SUCCESS',
      updatedCount: 1,
      failedCount: 1,
      skippedCount: 1,
    });
    expect(response.message).toContain('Updated 1 videos, but 1 failed.');
    expect(response.failedReasons).toEqual(['mock update failure']);
  });

  it('returns no action when all managed videos are skipped', async () => {
    const skippedVideo = createVideoStub(false);
    managedVideos.push(skippedVideo);
    enhancerByVideo.set(skippedVideo, createMockEnhancer(skippedVideo, 'mode-a'));

    const { handleSettingsUpdate } = await import('../../src/core/video-manager');
    const response = await handleSettingsUpdate(
      { type: 'SETTINGS_UPDATED', modifiedModeId: 'mode-b' },
      {} as never,
    );

    expect(response).toMatchObject({
      status: 'NO_ACTION',
      updatedCount: 0,
      failedCount: 0,
      skippedCount: 1,
    });
  });

  it('applies global updates across modes while keeping custom-mode updates targeted', async () => {
    const modeAVideo = createVideoStub(true);
    const modeBVideo = createVideoStub(true);
    const modeAEnhancer = createMockEnhancer(modeAVideo, 'mode-a');
    const modeBEnhancer = createMockEnhancer(modeBVideo, 'mode-b');
    managedVideos.push(modeAVideo, modeBVideo);
    enhancerByVideo.set(modeAVideo, modeAEnhancer);
    enhancerByVideo.set(modeBVideo, modeBEnhancer);

    const { handleSettingsUpdate } = await import('../../src/core/video-manager');
    await handleSettingsUpdate({ type: 'SETTINGS_UPDATED' }, {} as never);

    expect(modeAEnhancer.updateSettings).toHaveBeenCalledOnce();
    expect(modeBEnhancer.updateSettings).toHaveBeenCalledOnce();

    vi.mocked(modeAEnhancer.updateSettings).mockClear();
    vi.mocked(modeBEnhancer.updateSettings).mockClear();
    await handleSettingsUpdate(
      { type: 'SETTINGS_UPDATED', modifiedModeId: 'mode-b' },
      {} as never,
    );

    expect(modeAEnhancer.updateSettings).not.toHaveBeenCalled();
    expect(modeBEnhancer.updateSettings).toHaveBeenCalledOnce();
  });

  it('does not clean up an enhancer when the same video element is reconnected in one mutation batch', async () => {
    const video = createDomVideo();
    video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
    document.body.appendChild(video);

    const enhancer = createMockEnhancer(video);
    enhancerByVideo.set(video, enhancer);

    const { setupDOMObserver } = await import('../../src/core/video-manager');
    setupDOMObserver();

    expect(lastMutationCallback).not.toBeNull();
    lastMutationCallback?.([{
      addedNodes: [video],
      removedNodes: [video],
    }]);

    expect(stashEnhancerMock).not.toHaveBeenCalled();
    expect(enhancer.destroy).not.toHaveBeenCalled();
    expect(dissociateEnhancerMock).not.toHaveBeenCalledWith(video);
  });

  it('discovers videos inside open shadow roots during the initial scan', async () => {
    const host = document.createElement('div');
    const shadow = host.attachShadow({ mode: 'open' });
    const video = createDomVideo('https://example.com/shadow.mp4');
    shadow.appendChild(video);
    document.body.appendChild(host);

    const { initializeOnPage } = await import('../../src/core/video-manager');
    initializeOnPage();

    expect(createEnhancerMock).toHaveBeenCalledWith(video);
  });

  it('discovers delayed videos inserted inside open shadow roots', async () => {
    const host = document.createElement('div');
    const shadow = host.attachShadow({ mode: 'open' });
    const video = createDomVideo('https://example.com/shadow-delayed.mp4');
    shadow.appendChild(video);
    document.body.appendChild(host);

    const { setupDOMObserver } = await import('../../src/core/video-manager');
    setupDOMObserver();

    lastMutationCallback?.([{
      addedNodes: [host],
      removedNodes: [],
    }]);

    expect(createEnhancerMock).toHaveBeenCalledWith(video);
  });

  it('does not create enhancers for clearly hidden preload videos', async () => {
    const video = createDomVideo('https://example.com/preload.mp4');
    video.hidden = true;
    document.body.appendChild(video);

    const { initializeOnPage } = await import('../../src/core/video-manager');
    initializeOnPage();

    expect(createEnhancerMock).not.toHaveBeenCalledWith(video);
  });

  it('stashes removed videos before processing replacements so reattach can reuse the old enhancer', async () => {
    const oldVideo = createDomVideo('https://example.com/reuse.mp4');
    oldVideo.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
    const newVideo = createDomVideo('https://example.com/reuse.mp4');
    document.body.appendChild(newVideo);

    const stashedEnhancer = createMockEnhancer(oldVideo);
    enhancerByVideo.set(oldVideo, stashedEnhancer);

    let hasBeenStashed = false;
    stashEnhancerMock.mockImplementation((enhancer: MockEnhancer) => {
      if (enhancer === stashedEnhancer) {
        hasBeenStashed = true;
      }
    });
    findAndunstashEnhancerMock.mockImplementation((video: HTMLVideoElement) => {
      if (video === newVideo && hasBeenStashed) {
        return stashedEnhancer;
      }
      return null;
    });

    const { setupDOMObserver } = await import('../../src/core/video-manager');
    setupDOMObserver();

    lastMutationCallback?.([{
      addedNodes: [newVideo],
      removedNodes: [oldVideo],
    }]);

    expect(stashEnhancerMock).toHaveBeenCalledWith(stashedEnhancer);
    expect(findAndunstashEnhancerMock).toHaveBeenCalledWith(newVideo);
    expect(stashedEnhancer.reattach).toHaveBeenCalledWith(newVideo);
    expect(createEnhancerMock).not.toHaveBeenCalled();
    expect(enhancerByVideo.get(newVideo)).toBe(stashedEnhancer);
  });

  it('reuses stashed enhancers when the replacement video is rendered inside an open shadow root', async () => {
    const oldHost = document.createElement('div');
    const oldShadow = oldHost.attachShadow({ mode: 'open' });
    const oldVideo = createDomVideo('https://example.com/shadow-reuse.mp4');
    oldVideo.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
    oldShadow.appendChild(oldVideo);
    document.body.appendChild(oldHost);

    const newHost = document.createElement('div');
    const newShadow = newHost.attachShadow({ mode: 'open' });
    const newVideo = createDomVideo('https://example.com/shadow-reuse.mp4');
    newShadow.appendChild(newVideo);
    document.body.appendChild(newHost);

    const stashedEnhancer = createMockEnhancer(oldVideo);
    enhancerByVideo.set(oldVideo, stashedEnhancer);

    let hasBeenStashed = false;
    stashEnhancerMock.mockImplementation((enhancer: MockEnhancer) => {
      if (enhancer === stashedEnhancer) {
        hasBeenStashed = true;
      }
    });
    findAndunstashEnhancerMock.mockImplementation((video: HTMLVideoElement) => {
      if (video === newVideo && hasBeenStashed) {
        return stashedEnhancer;
      }
      return null;
    });

    const { setupDOMObserver } = await import('../../src/core/video-manager');
    setupDOMObserver();

    lastMutationCallback?.([{
      addedNodes: [newHost],
      removedNodes: [oldHost],
    }]);

    expect(stashEnhancerMock).toHaveBeenCalledWith(stashedEnhancer);
    expect(findAndunstashEnhancerMock).toHaveBeenCalledWith(newVideo);
    expect(stashedEnhancer.reattach).toHaveBeenCalledWith(newVideo);
    expect(createEnhancerMock).not.toHaveBeenCalled();
    expect(enhancerByVideo.get(newVideo)).toBe(stashedEnhancer);
  });

  it('discards a newly created enhancer if another enhancer was associated for the same element during creation', async () => {
    const video = createDomVideo('https://example.com/race.mp4');
    document.body.appendChild(video);

    const existingEnhancer = createMockEnhancer(video, 'mode-existing');
    const newEnhancer = createMockEnhancer(video, 'mode-new');
    createEnhancerMock.mockImplementation((targetVideo: HTMLVideoElement) => {
      enhancerByVideo.set(targetVideo, existingEnhancer);
      return newEnhancer;
    });

    const { processVideoElement } = await import('../../src/core/video-manager');
    processVideoElement(video, 'test-race');

    expect(newEnhancer.destroy).toHaveBeenCalledTimes(1);
    expect(associateEnhancerMock).not.toHaveBeenCalledWith(video, newEnhancer);
    expect(enhancerByVideo.get(video)).toBe(existingEnhancer);
  });
});

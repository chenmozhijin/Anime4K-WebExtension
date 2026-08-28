/**
 * 内容脚本轻启动器。
 * 常驻逻辑只负责发现候选视频、维护设置快照，并在需要时按需加载视频管理器。
 */
import { initSettingsSnapshot, refreshSettingsSnapshot, getSettingsSnapshot, subscribeSettingsSnapshot } from './utils/settings-snapshot';
import { isUrlWhitelisted } from './utils/whitelist';
import { createLogger } from './utils/logger';
import { hasRenderableParent, walkVisibleVideos } from './core/video-discovery';

type VideoManagerModule = typeof import('./core/video-manager');

export type SettingsUpdateResponse = {
  status: 'SUCCESS' | 'NO_ACTION' | 'PARTIAL_SUCCESS' | 'ERROR';
  message: string;
  updatedCount?: number;
  failedCount?: number;
  skippedCount?: number;
  failedReasons?: string[];
};

export type EvaluationTrigger = {
  reason: string;
  refreshSnapshot?: boolean;
  triggerRendererUpdate?: boolean;
  modifiedModeId?: string;
};

export type ContentBootstrapDeps = {
  chromeApi: typeof chrome;
  initSettingsSnapshot: typeof initSettingsSnapshot;
  refreshSettingsSnapshot: typeof refreshSettingsSnapshot;
  getSettingsSnapshot: typeof getSettingsSnapshot;
  subscribeSettingsSnapshot: typeof subscribeSettingsSnapshot;
  isUrlWhitelisted: typeof isUrlWhitelisted;
  loadVideoManagerModule: () => Promise<VideoManagerModule>;
};

export interface ContentBootstrap {
  bootstrapContentScript(): Promise<void>;
  dispose(): void;
  whenIdle(): Promise<void>;
}

const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];
const HISTORY_PATCH_FLAG = '__nijilucidHistoryPatched__';
const logger = createLogger('content');

function hasVideoAttachmentParent(video: HTMLVideoElement): boolean {
  return hasRenderableParent(video);
}

function resolveContentBootstrapDeps(
  overrides: Partial<ContentBootstrapDeps> = {},
): ContentBootstrapDeps {
  return {
    chromeApi: chrome,
    initSettingsSnapshot,
    refreshSettingsSnapshot,
    getSettingsSnapshot,
    subscribeSettingsSnapshot,
    isUrlWhitelisted,
    loadVideoManagerModule: () => import('./core/video-manager'),
    ...overrides,
  };
}

export function createContentBootstrap(
  overrides: Partial<ContentBootstrapDeps> = {},
): ContentBootstrap {
  const deps = resolveContentBootstrapDeps(overrides);

  let isCurrentlyActive = false;
  let discoveryObserver: MutationObserver | null = null;
  let videoManagerModule: VideoManagerModule | null = null;
  let videoManagerModulePromise: Promise<VideoManagerModule> | null = null;
  let videoManagerInitialized = false;
  let evaluationQueue: Promise<void> = Promise.resolve();
  let settingsUnsubscribe: (() => void) | null = null;
  let runtimeMessageListenerRegistered = false;
  let contentBootstrapStarted = false;
  let restoreHistoryMethods: (() => void) | null = null;
  const processedDiscoveryRoots = new Set<Document | ShadowRoot>();
  const pendingCandidates = new Set<HTMLVideoElement>();

  function shouldActivateCurrentUrl(): boolean {
    const snapshot = deps.getSettingsSnapshot();
    if (!snapshot.settings.whitelistEnabled) {
      return true;
    }

    return deps.isUrlWhitelisted(window.location.href, snapshot.compiledWhitelist);
  }

  function processDiscoveryRoot(root: Document | ShadowRoot): void {
    if (processedDiscoveryRoots.has(root)) {
      return;
    }

    for (const eventName of mediaEventsToWatch) {
      root.addEventListener(eventName, handleDiscoveryMediaEvent, { capture: true, passive: true });
    }

    processedDiscoveryRoots.add(root);
  }

  function scanForCandidateVideo(root: ParentNode): HTMLVideoElement | null {
    let candidate: HTMLVideoElement | null = null;
    walkVisibleVideos(root, {
      onRoot: processDiscoveryRoot,
      onVideo: video => {
        candidate = video;
        return false;
      },
    });
    return candidate;
  }

  function handleDiscoveryMediaEvent(event: Event): void {
    if (!isCurrentlyActive || videoManagerInitialized) {
      return;
    }

    if (event.target instanceof HTMLVideoElement) {
      queueCandidateVideo(event.target, `discovery-media:${event.type}`);
    }
  }

  function startDiscovery(): void {
    if (discoveryObserver) {
      return;
    }

    processDiscoveryRoot(document);
    const initialCandidate = scanForCandidateVideo(document);
    if (initialCandidate) {
      queueCandidateVideo(initialCandidate, 'discovery:initial-scan');
    }

    discoveryObserver = new MutationObserver((mutations) => {
      if (!isCurrentlyActive || videoManagerInitialized) {
        return;
      }

      for (const mutation of mutations) {
        for (let index = 0; index < mutation.addedNodes.length; index += 1) {
          const node = mutation.addedNodes[index];
          if (node.nodeType !== Node.ELEMENT_NODE) {
            continue;
          }

          const candidate = scanForCandidateVideo(node as Element);
          if (candidate) {
            queueCandidateVideo(candidate, 'discovery:mutation');
            return;
          }
        }
      }
    });

    discoveryObserver.observe(document.documentElement ?? document, {
      childList: true,
      subtree: true,
    });
  }

  function stopDiscovery(): void {
    discoveryObserver?.disconnect();
    discoveryObserver = null;

    processedDiscoveryRoots.forEach(root => {
      for (const eventName of mediaEventsToWatch) {
        root.removeEventListener(eventName, handleDiscoveryMediaEvent, { capture: true });
      }
    });
    processedDiscoveryRoots.clear();
  }

  async function ensureVideoManagerLoaded(): Promise<VideoManagerModule> {
    if (videoManagerModule) {
      return videoManagerModule;
    }

    if (!videoManagerModulePromise) {
      videoManagerModulePromise = deps.loadVideoManagerModule().then(module => {
        videoManagerModule = module;
        return module;
      });
    }

    return videoManagerModulePromise;
  }

  async function activateHeavyManager(source: string): Promise<void> {
    if (!isCurrentlyActive) {
      pendingCandidates.clear();
      return;
    }

    const module = await ensureVideoManagerLoaded();
    if (!isCurrentlyActive) {
      return;
    }

    if (!videoManagerInitialized) {
      stopDiscovery();
      module.initializeOnPage();
      videoManagerInitialized = true;
    }

    if (pendingCandidates.size === 0) {
      return;
    }

    const candidates = Array.from(pendingCandidates);
    pendingCandidates.clear();
    candidates.forEach(video => {
      if (video.isConnected && hasVideoAttachmentParent(video)) {
        module.processVideoElement(video, `${source}:replay`);
      }
    });
  }

  function queueCandidateVideo(video: HTMLVideoElement, source: string): void {
    if (!isCurrentlyActive) {
      return;
    }

    pendingCandidates.add(video);
    void activateHeavyManager(source);
  }

  function patchHistoryForSpaUpdates(): void {
    const historyWindow = window as typeof window & Record<string, boolean>;
    if (historyWindow[HISTORY_PATCH_FLAG]) {
      return;
    }

    const originalPushState = history.pushState;
    const originalReplaceState = history.replaceState;
    const onPopState = () => queueEvaluation({ reason: 'history:popstate' });
    const onHashChange = () => queueEvaluation({ reason: 'history:hashchange' });

    history.pushState = function patchedPushState(...args) {
      const result = originalPushState.apply(this, args);
      queueEvaluation({ reason: 'history:pushState' });
      return result;
    };
    history.replaceState = function patchedReplaceState(...args) {
      const result = originalReplaceState.apply(this, args);
      queueEvaluation({ reason: 'history:replaceState' });
      return result;
    };

    window.addEventListener('popstate', onPopState);
    window.addEventListener('hashchange', onHashChange);
    historyWindow[HISTORY_PATCH_FLAG] = true;
    restoreHistoryMethods = () => {
      history.pushState = originalPushState;
      history.replaceState = originalReplaceState;
      window.removeEventListener('popstate', onPopState);
      window.removeEventListener('hashchange', onHashChange);
      delete historyWindow[HISTORY_PATCH_FLAG];
    };
  }

  async function evaluateAndApplyState(trigger: EvaluationTrigger): Promise<SettingsUpdateResponse | null> {
    if (trigger.refreshSnapshot) {
      await deps.refreshSettingsSnapshot();
    }

    const shouldBeActive = shouldActivateCurrentUrl();

    if (shouldBeActive && !isCurrentlyActive) {
      logger.info(`Activating content flow. Trigger: ${trigger.reason}`);
      isCurrentlyActive = true;
      startDiscovery();

      const initialCandidate = scanForCandidateVideo(document);
      if (initialCandidate) {
        pendingCandidates.add(initialCandidate);
        await activateHeavyManager(trigger.reason);
      }
    } else if (!shouldBeActive && isCurrentlyActive) {
      logger.info(`De-activating content flow. Trigger: ${trigger.reason}`);
      isCurrentlyActive = false;
      stopDiscovery();
      pendingCandidates.clear();

      if (videoManagerInitialized) {
        const module = await ensureVideoManagerLoaded();
        module.deinitializeOnPage();
        videoManagerInitialized = false;
      }
    } else if (shouldBeActive && !videoManagerInitialized) {
      startDiscovery();
    } else {
      stopDiscovery();
    }

    if (!shouldBeActive) {
      return {
        status: 'NO_ACTION',
        message: 'Current URL is not active under the whitelist configuration.',
      };
    }

    if (!trigger.triggerRendererUpdate || !videoManagerInitialized) {
      return {
        status: 'NO_ACTION',
        message: 'State re-evaluated without active renderer updates.',
      };
    }

    const module = await ensureVideoManagerLoaded();
    return module.handleSettingsUpdate(
      { type: 'SETTINGS_UPDATED', modifiedModeId: trigger.modifiedModeId },
      deps.getSettingsSnapshot().settings,
    );
  }

  function queueEvaluation(
    trigger: EvaluationTrigger,
    onComplete?: (response: SettingsUpdateResponse | null) => void,
  ): void {
    evaluationQueue = evaluationQueue.then(async () => {
      const response = await evaluateAndApplyState(trigger);
      onComplete?.(response);
    }).catch(error => {
      logger.error('Failed to evaluate frame state.', error);
      onComplete?.({
        status: 'ERROR',
        message: error instanceof Error ? error.message : String(error),
      });
    });
  }

  function handleRuntimeMessage(request: any, _sender: chrome.runtime.MessageSender, sendResponse: (response?: any) => void): boolean {
    if (request.type === 'SETTINGS_UPDATED') {
      queueEvaluation({
        reason: 'runtime-message:SETTINGS_UPDATED',
        refreshSnapshot: true,
        triggerRendererUpdate: true,
        modifiedModeId: request.modifiedModeId,
      }, response => {
        sendResponse(response ?? {
          status: 'NO_ACTION',
          message: 'No active renderer required an update.',
        });
      });

      return true;
    }

    if (request.type === 'URL_UPDATED') {
      logger.debug('URL changed, re-evaluating whitelist.');
      queueEvaluation({ reason: 'runtime-message:URL_UPDATED' });
    }

    return false;
  }

  function ensureRuntimeMessageListener(): void {
    if (runtimeMessageListenerRegistered) {
      return;
    }

    deps.chromeApi.runtime.onMessage.addListener(handleRuntimeMessage);
    runtimeMessageListenerRegistered = true;
  }

  async function bootstrapContentScript(): Promise<void> {
    if (contentBootstrapStarted) {
      return;
    }

    contentBootstrapStarted = true;
    await deps.initSettingsSnapshot();
    patchHistoryForSpaUpdates();
    settingsUnsubscribe = deps.subscribeSettingsSnapshot(() => {
      queueEvaluation({
        reason: 'settings-snapshot-changed',
        triggerRendererUpdate: true,
      });
    });

    ensureRuntimeMessageListener();
    queueEvaluation({ reason: 'initial-load' });
  }

  function dispose(): void {
    stopDiscovery();
    settingsUnsubscribe?.();
    settingsUnsubscribe = null;
    if (runtimeMessageListenerRegistered) {
      deps.chromeApi.runtime.onMessage.removeListener(handleRuntimeMessage);
    }
    pendingCandidates.clear();
    isCurrentlyActive = false;
    if (videoManagerInitialized && videoManagerModule) {
      videoManagerModule.deinitializeOnPage();
    }
    videoManagerModule = null;
    videoManagerModulePromise = null;
    videoManagerInitialized = false;
    runtimeMessageListenerRegistered = false;
    contentBootstrapStarted = false;
    restoreHistoryMethods?.();
    restoreHistoryMethods = null;
    evaluationQueue = Promise.resolve();
  }

  return {
    bootstrapContentScript,
    dispose,
    whenIdle: () => evaluationQueue,
  };
}

let defaultContentBootstrap: ContentBootstrap | null = null;

function getDefaultContentBootstrap(): ContentBootstrap {
  defaultContentBootstrap ??= createContentBootstrap();
  return defaultContentBootstrap;
}

export async function bootstrapContentScript(): Promise<void> {
  await getDefaultContentBootstrap().bootstrapContentScript();
}

export function __setVideoManagerLoaderForTests(loader: () => Promise<VideoManagerModule>): void {
  defaultContentBootstrap?.dispose();
  defaultContentBootstrap = createContentBootstrap({
    loadVideoManagerModule: loader,
  });
}

export function resetContentBootstrapForTests(): void {
  defaultContentBootstrap?.dispose();
  defaultContentBootstrap = null;
}

if (!globalThis.__NIJILUCID_DISABLE_AUTO_BOOTSTRAP__) {
  void bootstrapContentScript().catch(error => {
    logger.error('Failed to bootstrap content script.', error);
  });
}

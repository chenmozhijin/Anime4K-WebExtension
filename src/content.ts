/**
 * 内容脚本轻启动器。
 * 常驻逻辑只负责发现候选视频、维护设置快照，并在需要时按需加载视频管理器。
 */
import { initSettingsSnapshot, refreshSettingsSnapshot, getSettingsSnapshot, subscribeSettingsSnapshot } from './utils/settings-snapshot';
import { isUrlWhitelisted } from './utils/whitelist';

type VideoManagerModule = typeof import('./core/video-manager');
type SettingsUpdateResponse = {
  status: 'SUCCESS' | 'NO_ACTION' | 'ERROR';
  message: string;
};

type EvaluationTrigger = {
  reason: string;
  refreshSnapshot?: boolean;
  triggerRendererUpdate?: boolean;
  modifiedModeId?: string;
};

const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];
const HISTORY_PATCH_FLAG = '__anime4kHistoryPatched__';

let isCurrentlyActive = false;
let discoveryObserver: MutationObserver | null = null;
let videoManagerModule: VideoManagerModule | null = null;
let videoManagerModulePromise: Promise<VideoManagerModule> | null = null;
let videoManagerInitialized = false;
let evaluationQueue: Promise<void> = Promise.resolve();
const processedDiscoveryRoots = new Set<Document | ShadowRoot>();
const pendingCandidates = new Set<HTMLVideoElement>();

function shouldActivateCurrentUrl(): boolean {
  const snapshot = getSettingsSnapshot();
  if (!snapshot.settings.whitelistEnabled) {
    return true;
  }

  return isUrlWhitelisted(window.location.href, snapshot.compiledWhitelist);
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
  const visitElement = (element: Element): HTMLVideoElement | null => {
    if (element.tagName === 'VIDEO') {
      return element as HTMLVideoElement;
    }

    if (element.shadowRoot) {
      processDiscoveryRoot(element.shadowRoot);
      const shadowCandidate = scanForCandidateVideo(element.shadowRoot);
      if (shadowCandidate) {
        return shadowCandidate;
      }
    }

    return null;
  };

  if (root instanceof Element) {
    const directCandidate = visitElement(root);
    if (directCandidate) {
      return directCandidate;
    }
  }

  const walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
  let currentNode: Node | null;
  while ((currentNode = walker.nextNode())) {
    const candidate = visitElement(currentNode as Element);
    if (candidate) {
      return candidate;
    }
  }

  return null;
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
      for (let index = 0; index < mutation.addedNodes.length; index++) {
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
    videoManagerModulePromise = import('./core/video-manager').then(module => {
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
    if (video.isConnected && video.parentElement) {
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

  const wrapHistoryMethod = (methodName: 'pushState' | 'replaceState') => {
    const originalMethod = history[methodName];
    history[methodName] = function patchedHistoryMethod(...args) {
      const result = originalMethod.apply(this, args);
      queueEvaluation({ reason: `history:${methodName}` });
      return result;
    };
  };

  wrapHistoryMethod('pushState');
  wrapHistoryMethod('replaceState');
  window.addEventListener('popstate', () => queueEvaluation({ reason: 'history:popstate' }));
  window.addEventListener('hashchange', () => queueEvaluation({ reason: 'history:hashchange' }));
  historyWindow[HISTORY_PATCH_FLAG] = true;
}

async function evaluateAndApplyState(trigger: EvaluationTrigger): Promise<SettingsUpdateResponse | null> {
  if (trigger.refreshSnapshot) {
    await refreshSettingsSnapshot();
  }

  const shouldBeActive = shouldActivateCurrentUrl();

  if (shouldBeActive && !isCurrentlyActive) {
    console.log(`[Anime4KWebExt] Activating content flow. Trigger: ${trigger.reason}`);
    isCurrentlyActive = true;
    startDiscovery();

    const initialCandidate = scanForCandidateVideo(document);
    if (initialCandidate) {
      pendingCandidates.add(initialCandidate);
      await activateHeavyManager(trigger.reason);
    }
  } else if (!shouldBeActive && isCurrentlyActive) {
    console.log(`[Anime4KWebExt] De-activating content flow. Trigger: ${trigger.reason}`);
    isCurrentlyActive = false;
    pendingCandidates.clear();

    if (videoManagerInitialized) {
      const module = await ensureVideoManagerLoaded();
      module.deinitializeOnPage();
      videoManagerInitialized = false;
    }

    startDiscovery();
  } else if (shouldBeActive) {
    startDiscovery();
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
    getSettingsSnapshot().settings,
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
    console.error('[Anime4KWebExt] Failed to evaluate frame state:', error);
    onComplete?.({
      status: 'ERROR',
      message: error instanceof Error ? error.message : String(error),
    });
  });
}

async function bootstrap(): Promise<void> {
  await initSettingsSnapshot();
  patchHistoryForSpaUpdates();
  subscribeSettingsSnapshot(() => {
    queueEvaluation({
      reason: 'settings-snapshot-changed',
      triggerRendererUpdate: true,
    });
  });

  startDiscovery();
  queueEvaluation({ reason: 'initial-load' });
}

void bootstrap().catch(error => {
  console.error('[Anime4KWebExt] Failed to bootstrap content script:', error);
});

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
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
    console.log('[Anime4KWebExt] URL changed, re-evaluating whitelist...');
    queueEvaluation({ reason: 'runtime-message:URL_UPDATED' });
  }

  return false;
});

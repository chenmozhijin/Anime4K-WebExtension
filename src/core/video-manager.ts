import { VideoEnhancer } from './video-enhancer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import type { Anime4KWebExtSettings } from '../types';
import { stashEnhancer, findAndunstashEnhancer } from './enhancer-stash';
import * as EnhancerMap from './enhancer-map';
import { createLogger } from '../utils/logger';
import { isLikelyVisibleVideo, walkVisibleVideos } from './video-discovery';

type SettingsUpdateMessage = {
  type: string;
  // Omit for global setting changes; provide only when an existing custom mode's definition changed.
  modifiedModeId?: string;
};

type SettingsUpdateResponse = {
  status: 'SUCCESS' | 'NO_ACTION' | 'PARTIAL_SUCCESS' | 'ERROR';
  message: string;
  updatedCount?: number;
  failedCount?: number;
  skippedCount?: number;
  failedReasons?: string[];
};

const processedDocs = new Set<Document | ShadowRoot>();
const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];

let domObserver: MutationObserver | null = null;
let beforeUnloadRegistered = false;
const logger = createLogger('video-manager');

function hasRenderableParent(videoEl: HTMLVideoElement): boolean {
  return isLikelyVisibleVideo(videoEl);
}

function shouldSkipRemovalCleanup(video: HTMLVideoElement, addedVideos: ReadonlySet<HTMLVideoElement>): boolean {
  return addedVideos.has(video) && video.isConnected;
}

function processObservedVideoMutations(
  addedVideos: ReadonlySet<HTMLVideoElement>,
  removedVideos: ReadonlySet<HTMLVideoElement>,
): void {
  removedVideos.forEach(video => {
    if (shouldSkipRemovalCleanup(video, addedVideos)) {
      logger.debug('Skipping cleanup for reconnected video element.', video);
      return;
    }

    cleanupVideoEnhancer(video);
  });

  addedVideos.forEach(video => processVideoElement(video, 'mutation-observer:batched-added'));
}

function cleanupVideoEnhancer(video: HTMLVideoElement): void {
  const enhancer = EnhancerMap.getEnhancer(video);
  if (!enhancer) {
    return;
  }

  if (video.hasAttribute(ANIME4K_APPLIED_ATTR)) {
    stashEnhancer(enhancer);
  } else {
    enhancer.destroy();
  }

  EnhancerMap.dissociateEnhancer(video);
  logger.debug('Cleaned up or stashed enhancer for video.', video);
}

export function processVideoElement(videoEl: HTMLVideoElement, source: string): void {
  logger.debug(`processVideoElement called from: ${source}`);

  if (EnhancerMap.hasEnhancer(videoEl)) {
    logger.debug(`Enhancer already exists for this video. Skipping. Source: ${source}`);
    return;
  }

  if (!hasRenderableParent(videoEl)) {
    logger.debug('Video is not in the DOM, skipping enhancer creation for now.', videoEl);
    return;
  }

  const stashedEnhancer = findAndunstashEnhancer(videoEl);
  if (stashedEnhancer) {
    logger.debug('Re-attaching stashed enhancer.');
    EnhancerMap.associateEnhancer(videoEl, stashedEnhancer);
    stashedEnhancer.reattach(videoEl).catch(err => {
      logger.error('Failed to re-attach stashed enhancer.', err);
      EnhancerMap.dissociateEnhancer(videoEl);
      stashedEnhancer.destroy();
    });
    return;
  }

  try {
    logger.debug('Creating new enhancer for video.', videoEl);
    const enhancer = VideoEnhancer.create(videoEl);
    if (EnhancerMap.hasEnhancer(videoEl)) {
      logger.warn('Detected duplicate enhancer creation attempt for the same video element. Discarding new instance.');
      enhancer.destroy();
      return;
    }
    EnhancerMap.associateEnhancer(videoEl, enhancer);
    logger.debug('Associated new enhancer to video.', videoEl);
  } catch (error) {
    logger.error('Failed to create enhancer for video.', videoEl, error);
  }
}

function scanNodeTreeForVideos(root: ParentNode, visitor: (video: HTMLVideoElement) => void): void {
  walkVisibleVideos(root, {
    onRoot: processDoc,
    onVideo: video => {
      visitor(video);
    },
  });
}

function collectVideosFromNode(node: Node, collector: Set<HTMLVideoElement>): void {
  if (node.nodeType !== Node.ELEMENT_NODE) {
    return;
  }

  scanNodeTreeForVideos(node as Element, video => collector.add(video));
}

function handleMediaEvent(event: Event): void {
  if (event.target instanceof HTMLVideoElement) {
    processVideoElement(event.target, `handleMediaEvent:${event.type}`);
  }
}

function handleBeforeUnload(): void {
  EnhancerMap.getAllManagedVideos().forEach(cleanupVideoEnhancer);
}

function processDoc(doc: Document | ShadowRoot): void {
  if (processedDocs.has(doc)) {
    return;
  }

  logger.debug('Processing document/shadowRoot for media events.', doc);
  for (const eventName of mediaEventsToWatch) {
    doc.addEventListener(eventName, handleMediaEvent, { capture: true, passive: true });
  }
  processedDocs.add(doc);
}

export function initializeOnPage(): void {
  if (domObserver) {
    logger.warn('initializeOnPage called while already initialized. Ignoring.');
    return;
  }

  processDoc(document);
  scanNodeTreeForVideos(document, video => processVideoElement(video, 'initial-scan'));
  domObserver = setupDOMObserver();

  if (!beforeUnloadRegistered) {
    window.addEventListener('beforeunload', handleBeforeUnload);
    beforeUnloadRegistered = true;
  }
}

export function setupDOMObserver(): MutationObserver {
  const observer = new MutationObserver(mutationsList => {
    const addedVideos = new Set<HTMLVideoElement>();
    const removedVideos = new Set<HTMLVideoElement>();

    for (const mutation of mutationsList) {
      mutation.addedNodes.forEach(node => collectVideosFromNode(node, addedVideos));
      mutation.removedNodes.forEach(node => collectVideosFromNode(node, removedVideos));
    }

    processObservedVideoMutations(addedVideos, removedVideos);
  });

  observer.observe(document.documentElement ?? document, { childList: true, subtree: true });
  return observer;
}

export async function handleSettingsUpdate(
  message: SettingsUpdateMessage,
  settings: Anime4KWebExtSettings,
  sendResponse?: (response?: SettingsUpdateResponse) => void,
): Promise<SettingsUpdateResponse> {
  logger.debug('Received settings update.', message);

  let updatedCount = 0;
  let failedCount = 0;
  let skippedCount = 0;
  const failedReasons: string[] = [];
  const videos = EnhancerMap.getAllManagedVideos();

  for (const videoElement of videos) {
    const enhancer = EnhancerMap.getEnhancer(videoElement);
    if (!enhancer || videoElement.getAttribute(ANIME4K_APPLIED_ATTR) !== 'true') {
      skippedCount++;
      continue;
    }

    const shouldUpdate = !message.modifiedModeId || enhancer.getCurrentModeId() === message.modifiedModeId;
    if (!shouldUpdate) {
      skippedCount++;
      continue;
    }

    try {
      await enhancer.updateSettings(settings);
      updatedCount++;
    } catch (error) {
      failedCount++;
      const reason = error instanceof Error ? error.message : String(error);
      if (failedReasons.length < 3) {
        failedReasons.push(reason);
      }
      logger.error('Error updating video settings.', error, videoElement);
      if (failedCount === 1) {
        logger.warn(`Renderer update failed for one or more videos: ${reason}`);
      }
      if (failedCount === 3) {
        logger.warn('Additional video update failures suppressed for brevity.');
      }
    }
  }

  let response: SettingsUpdateResponse;
  if (updatedCount > 0 && failedCount > 0) {
    response = {
      status: 'PARTIAL_SUCCESS',
      message: `Updated ${updatedCount} videos, but ${failedCount} failed.`,
      updatedCount,
      failedCount,
      skippedCount,
      failedReasons,
    };
  } else if (updatedCount > 0) {
    response = {
      status: 'SUCCESS',
      message: `Updated ${updatedCount} videos.`,
      updatedCount,
      failedCount,
      skippedCount,
    };
  } else if (failedCount > 0) {
    response = {
      status: 'ERROR',
      message: `Failed to update ${failedCount} videos.`,
      updatedCount,
      failedCount,
      skippedCount,
      failedReasons,
    };
  } else {
    response = {
      status: 'NO_ACTION',
      message: 'No active instances needed an update.',
      updatedCount,
      failedCount,
      skippedCount,
    };
  }

  sendResponse?.(response);
  return response;
}

export function deinitializeOnPage(): void {
  if (domObserver) {
    domObserver.disconnect();
    domObserver = null;
    logger.debug('DOM observer disconnected.');
  }

  processedDocs.forEach(doc => {
    for (const eventName of mediaEventsToWatch) {
      doc.removeEventListener(eventName, handleMediaEvent, { capture: true });
    }
  });
  processedDocs.clear();
  logger.debug('All media event listeners removed.');

  if (beforeUnloadRegistered) {
    window.removeEventListener('beforeunload', handleBeforeUnload);
    beforeUnloadRegistered = false;
  }

  const videos = EnhancerMap.getAllManagedVideos();
  logger.debug(`De-initializing and cleaning up ${videos.length} videos.`);
  videos.forEach(video => {
    const enhancer = EnhancerMap.getEnhancer(video);
    if (enhancer) {
      enhancer.destroy();
      EnhancerMap.dissociateEnhancer(video);
    }
  });
}

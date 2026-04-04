import { VideoEnhancer } from './video-enhancer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import type { Anime4KWebExtSettings } from '../types';
import { stashEnhancer, findAndunstashEnhancer } from './enhancer-stash';
import * as EnhancerMap from './enhancer-map';

type SettingsUpdateMessage = {
  type: string;
  modifiedModeId?: string;
};

type SettingsUpdateResponse = {
  status: 'SUCCESS' | 'NO_ACTION' | 'ERROR';
  message: string;
};

const processedDocs = new Set<Document | ShadowRoot>();
const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];

let domObserver: MutationObserver | null = null;
let beforeUnloadRegistered = false;

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
  console.log('[Anime4KWebExt] Cleaned up or stashed enhancer for video:', video);
}

export function processVideoElement(videoEl: HTMLVideoElement, source: string): void {
  console.log(`[Anime4KWebExt] processVideoElement called from: ${source}`);

  if (EnhancerMap.hasEnhancer(videoEl)) {
    console.log(`[Anime4KWebExt] Enhancer already exists for this video. Skipping. Source: ${source}`);
    return;
  }

  if (!videoEl.parentElement) {
    console.log('[Anime4KWebExt] Video is not in the DOM, skipping enhancer creation for now.', videoEl);
    return;
  }

  const stashedEnhancer = findAndunstashEnhancer(videoEl);
  if (stashedEnhancer) {
    console.log('[Anime4KWebExt] Re-attaching stashed enhancer.');
    EnhancerMap.associateEnhancer(videoEl, stashedEnhancer);
    stashedEnhancer.reattach(videoEl).catch(err => {
      console.error('[Anime4KWebExt] Failed to re-attach stashed enhancer:', err);
      EnhancerMap.dissociateEnhancer(videoEl);
      stashedEnhancer.destroy();
    });
    return;
  }

  try {
    console.log('[Anime4KWebExt] Creating new enhancer for video:', videoEl);
    const enhancer = VideoEnhancer.create(videoEl);
    EnhancerMap.associateEnhancer(videoEl, enhancer);
    console.log('[Anime4KWebExt] Associated new enhancer to video:', videoEl);
  } catch (error) {
    console.error('Failed to create enhancer for video:', videoEl, error);
  }
}

function scanNodeTreeForVideos(root: ParentNode, visitor: (video: HTMLVideoElement) => void): void {
  const visitElement = (element: Element) => {
    if (element.tagName === 'VIDEO') {
      visitor(element as HTMLVideoElement);
    }

    if (element.shadowRoot) {
      processDoc(element.shadowRoot);
      scanNodeTreeForVideos(element.shadowRoot, visitor);
    }
  };

  if (root instanceof Element) {
    visitElement(root);
  }

  const walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
  let currentNode: Node | null;
  while ((currentNode = walker.nextNode())) {
    visitElement(currentNode as Element);
  }
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

  console.log('[Anime4KWebExt] Processing document/shadowRoot for media events:', doc);
  for (const eventName of mediaEventsToWatch) {
    doc.addEventListener(eventName, handleMediaEvent, { capture: true, passive: true });
  }
  processedDocs.add(doc);
}

export function initializeOnPage(): void {
  if (domObserver) {
    console.warn('[Anime4KWebExt] initializeOnPage called while already initialized. Ignoring.');
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

    addedVideos.forEach(video => processVideoElement(video, 'mutation-observer:batched-added'));
    removedVideos.forEach(cleanupVideoEnhancer);
  });

  observer.observe(document.documentElement ?? document, { childList: true, subtree: true });
  return observer;
}

export async function handleSettingsUpdate(
  message: SettingsUpdateMessage,
  settings: Anime4KWebExtSettings,
  sendResponse?: (response?: SettingsUpdateResponse) => void,
): Promise<SettingsUpdateResponse> {
  console.log('Received settings update:', message);

  let updatedCount = 0;
  const videos = EnhancerMap.getAllManagedVideos();

  for (const videoElement of videos) {
    const enhancer = EnhancerMap.getEnhancer(videoElement);
    if (enhancer && videoElement.getAttribute(ANIME4K_APPLIED_ATTR) === 'true') {
      const shouldUpdate = !message.modifiedModeId || enhancer.getCurrentModeId() === message.modifiedModeId;

      if (shouldUpdate) {
        try {
          await enhancer.updateSettings(settings);
          updatedCount++;
        } catch (error) {
          console.error('Error updating video settings:', error, videoElement);
        }
      }
    }
  }

  const response: SettingsUpdateResponse = updatedCount > 0
    ? { status: 'SUCCESS', message: `Updated ${updatedCount} videos.` }
    : { status: 'NO_ACTION', message: 'No active instances needed an update.' };

  sendResponse?.(response);
  return response;
}

export function deinitializeOnPage(): void {
  if (domObserver) {
    domObserver.disconnect();
    domObserver = null;
    console.log('[Anime4KWebExt] DOM Observer disconnected.');
  }

  processedDocs.forEach(doc => {
    for (const eventName of mediaEventsToWatch) {
      doc.removeEventListener(eventName, handleMediaEvent, { capture: true });
    }
  });
  processedDocs.clear();
  console.log('[Anime4KWebExt] All media event listeners removed.');

  if (beforeUnloadRegistered) {
    window.removeEventListener('beforeunload', handleBeforeUnload);
    beforeUnloadRegistered = false;
  }

  const videos = EnhancerMap.getAllManagedVideos();
  console.log(`[Anime4KWebExt] De-initializing and cleaning up ${videos.length} videos.`);
  videos.forEach(video => {
    const enhancer = EnhancerMap.getEnhancer(video);
    if (enhancer) {
      enhancer.destroy();
      EnhancerMap.dissociateEnhancer(video);
    }
  });
}

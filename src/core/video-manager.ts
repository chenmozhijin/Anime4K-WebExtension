import { VideoEnhancer } from './video-enhancer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import { getSettings } from '../utils/settings';
import { Anime4KWebExtSettings } from '../types';
import { stashEnhancer, findAndunstashEnhancer } from './enhancer-stash';
import * as EnhancerMap from './enhancer-map';

// 使用 Set 跟踪已处理的文档或 ShadowRoot，以便能够移除监听器
const processedDocs = new Set<Document | ShadowRoot>();
// 定义需要监听的核心媒体事件，以最优化性能
const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];

let domObserver: MutationObserver | null = null;

/**
 * 清理视频元素的增强器资源
 * @param video 视频元素
 */
function cleanupVideoEnhancer(video: HTMLVideoElement): void {
  const enhancer = EnhancerMap.getEnhancer(video);
  if (enhancer) {
    if (video.hasAttribute(ANIME4K_APPLIED_ATTR)) {
      stashEnhancer(enhancer);
    } else {
      enhancer.destroy();
    }
    EnhancerMap.dissociateEnhancer(video);
    console.log('[Anime4KWebExt] Cleaned up or stashed enhancer for video:', video);
  }
}

/**
 * 处理单个视频元素，为其添加增强器。
 * 这是所有视频发现途径（事件、DOM变动）的最终处理入口。
 * @param videoEl 要处理的视频元素
 */
export function processVideoElement(videoEl: HTMLVideoElement, source: string): void {
  console.log(`[Anime4KWebExt] processVideoElement called from: ${source}`);
  // 1. 状态检查 (防竞争条件的关键)
  if (EnhancerMap.hasEnhancer(videoEl)) {
    console.log(`[Anime4KWebExt] Enhancer already exists for this video. Skipping. Source: ${source}`);
    return;
  }

  // 2. 检查视频是否在 DOM 中 (UI 附加的前提)
  if (!videoEl.parentElement) {
    console.log('[Anime4KWebExt] Video is not in the DOM, skipping enhancer creation for now.', videoEl);
    return;
  }

  // 3. 优先从 Stash 中恢复
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

  // 4. 创建新的 Enhancer 实例 (同步)
  console.log('[Anime4KWebExt] Creating new enhancer for video:', videoEl);
  try {
    const enhancer = VideoEnhancer.create(videoEl);
    // 立即在 Map 中注册，建立“锁”
    EnhancerMap.associateEnhancer(videoEl, enhancer);
    console.log('[Anime4KWebExt] Associated new enhancer to video:', videoEl);
  } catch (error) {
    console.error('Failed to create enhancer for video:', videoEl, error);
  }
}

/**
 * 媒体事件的统一回调处理函数。
 * 使用事件委托模式，在根节点捕获事件。
 * @param event 媒体事件
 */
function handleMediaEvent(event: Event): void {
  const target = event.target;
  // 确认事件源是视频元素
  if (target instanceof HTMLVideoElement) {
    processVideoElement(target, `handleMediaEvent:${event.type}`);
  }
}

/**
 * 为指定的文档或 ShadowRoot 节点添加媒体事件监听器。
 * 这是实现对 Shadow DOM 内视频进行监听的关键。
 * @param doc Document 或 ShadowRoot
 */
function processDoc(doc: Document | ShadowRoot): void {
  if (processedDocs.has(doc)) {
    return; // 避免重复处理
  }

  console.log('[Anime4KWebExt] Processing document/shadowRoot for media events:', doc);
  for (const eventName of mediaEventsToWatch) {
    // 使用捕获模式，尽早发现视频
    doc.addEventListener(eventName, handleMediaEvent, { capture: true, passive: true });
  }
  processedDocs.add(doc);
}

/**
 * 初始化页面，设置事件监听和 DOM 观察器
 */
export function initializeOnPage(): void {
  if (domObserver) {
    console.warn('[Anime4KWebExt] initializeOnPage called while already initialized. Ignoring.');
    return;
  }
  // 1. 处理主文档
  processDoc(document);
  
  // 2. 初始扫描页面上已存在的视频，以处理静态加载的视频
  document.querySelectorAll('video').forEach(video => processVideoElement(video, 'initial-scan'));

  // 3. 设置DOM观察器以处理动态加载的视频和Shadow DOM
  domObserver = setupDOMObserver();
}

/**
 * 设置DOM观察器，以监听新添加的视频元素和 Shadow DOM 的创建
 */
export function setupDOMObserver(): MutationObserver {
  const handleMutations = (mutationsList: MutationRecord[]) => {
    for (const mutation of mutationsList) {
      // A. 处理新增的节点
      mutation.addedNodes.forEach(node => {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        
        const element = node as Element;

        // Case 1: 新增节点本身就是 video
        if (element.tagName === 'VIDEO') {
          processVideoElement(element as HTMLVideoElement, 'mutation-observer:added-video-node');
        }
        // Case 2: 新增节点包含 Shadow DOM
        if (element.shadowRoot) {
          processDoc(element.shadowRoot);
          // 立即扫描这个新的 Shadow DOM 内部可能已存在的 video
          element.shadowRoot.querySelectorAll('video').forEach(video => processVideoElement(video, 'mutation-observer:added-shadow-dom-scan'));
        }
        // Case 3: 扫描新增节点内部的常规 video 元素
        element.querySelectorAll('video').forEach(video => processVideoElement(video, 'mutation-observer:added-node-subtree-scan'));
      });
      
      // B. 处理被移除的节点，进行资源清理
      mutation.removedNodes.forEach(node => {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        const element = node as Element;
        if (element.tagName === 'VIDEO') {
          cleanupVideoEnhancer(element as HTMLVideoElement);
        } else {
          element.querySelectorAll('video').forEach(cleanupVideoEnhancer);
        }
      });
    }
  };

  const observer = new MutationObserver(handleMutations);
  observer.observe(document.body, { childList: true, subtree: true });
  
  // 添加页面卸载时的全局清理，确保不会有内存泄漏
  window.addEventListener('beforeunload', () => {
    document.querySelectorAll('video').forEach(cleanupVideoEnhancer);
  });
  
  return observer;
}

/**
 * 处理设置更新事件
 * @param settings 新的设置
 * @param sendResponse 响应回调函数
 */
export async function handleSettingsUpdate(
  message: { type: string, modifiedModeId?: string },
  sendResponse: (response?: any) => void
): Promise<void> {
  console.log('Received settings update:', message);

  const newSettings = await getSettings();
  let updatedCount = 0;
  const videos = EnhancerMap.getAllManagedVideos();

  for (const videoElement of videos) {
    const enhancer = EnhancerMap.getEnhancer(videoElement);
    if (enhancer && videoElement.getAttribute(ANIME4K_APPLIED_ATTR) === 'true') {
      const shouldUpdate = !message.modifiedModeId || enhancer.getCurrentModeId() === message.modifiedModeId;

      if (shouldUpdate) {
        try {
          await enhancer.updateSettings(newSettings);
          updatedCount++;
        } catch (error) {
          console.error('Error updating video settings:', error, videoElement);
        }
      }
    }
  }

  if (updatedCount > 0) {
    sendResponse({ status: 'SUCCESS', message: `Updated ${updatedCount} videos.` });
  } else {
    sendResponse({ status: 'NO_ACTION', message: 'No active instances needed an update.' });
  }
}

/**
 * 反初始化页面，彻底清理所有资源
 */
export function deinitializeOnPage(): void {
  // 1. 断开并清除 DOM 观察器
  if (domObserver) {
    domObserver.disconnect();
    domObserver = null;
    console.log('[Anime4KWebExt] DOM Observer disconnected.');
  }

  // 2. 移除所有媒体事件监听器
  processedDocs.forEach(doc => {
    for (const eventName of mediaEventsToWatch) {
      doc.removeEventListener(eventName, handleMediaEvent, { capture: true });
    }
  });
  processedDocs.clear();
  console.log('[Anime4KWebExt] All media event listeners removed.');

  // 3. 销毁所有增强器实例
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

import { VideoEnhancer } from './video-enhancer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import { getSettings } from '../utils/settings';
import { Anime4KWebExtSettings } from '../types';

// 使用 WeakSet 跟踪已处理的文档或 ShadowRoot，避免重复绑定监听器
const processedDocs = new WeakSet<Document | ShadowRoot>();
// 定义需要监听的核心媒体事件，以最优化性能
const mediaEventsToWatch: ReadonlyArray<string> = ['loadedmetadata', 'play', 'playing'];

/**
 * 清理视频元素的增强器资源
 * @param video 视频元素
 */
function cleanupVideoEnhancer(video: HTMLVideoElement): void {
  if (video._anime4kEnhancer) {
    video._anime4kEnhancer.destroy();
    delete video._anime4kEnhancer;
    console.log('[Anime4KWebExt] Cleaned up enhancer for video:', video);
  }
}

/**
 * 处理单个视频元素，为其添加增强器。
 * 这是所有视频发现途径（事件、DOM变动）的最终处理入口。
 * @param videoEl 要处理的视频元素
 */
export function processVideoElement(videoEl: HTMLVideoElement): void {
  // 如果视频已经处理过，则直接返回，避免重复工作
  if (videoEl._anime4kEnhancer || videoEl.hasAttribute(ANIME4K_APPLIED_ATTR)) {
    return;
  }

  // 视频需要加载完元数据后才能获取宽高信息，因此在此处等待
  if (videoEl.readyState >= 1) { // HAVE_METADATA
    addEnhancerToVideo(videoEl);
  } else {
    // 如果元数据未加载，则添加一次性监听器
    videoEl.addEventListener('loadedmetadata', () => addEnhancerToVideo(videoEl), { once: true });
  }
}

/**
 * 核心实现：为视频元素创建并附加增强器实例
 * @param video 视频元素
 */
function addEnhancerToVideo(video: HTMLVideoElement): void {
  if (video._anime4kEnhancer) return;
  // 视频必须在DOM中才能附加UI
  if (!video.parentElement) return;
  
  try {
    const enhancer = new VideoEnhancer(video);
    video._anime4kEnhancer = enhancer;
    console.log('[Anime4KWebExt] Attached enhancer to video:', video);
  } catch (error) {
    console.error('Failed to create enhancer for video:', video, error);
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
    processVideoElement(target);
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
  // 1. 处理主文档
  processDoc(document);
  
  // 2. 初始扫描页面上已存在的视频，以处理静态加载的视频
  document.querySelectorAll('video').forEach(processVideoElement);

  // 3. 设置DOM观察器以处理动态加载的视频和Shadow DOM
  setupDOMObserver();
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
          processVideoElement(element as HTMLVideoElement);
        }
        // Case 2: 新增节点包含 Shadow DOM
        if (element.shadowRoot) {
          processDoc(element.shadowRoot);
          // 立即扫描这个新的 Shadow DOM 内部可能已存在的 video
          element.shadowRoot.querySelectorAll('video').forEach(processVideoElement);
        }
        // Case 3: 扫描新增节点内部的常规 video 元素
        element.querySelectorAll('video').forEach(processVideoElement);
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
  const videos = Array.from(document.querySelectorAll<HTMLVideoElement>('video'));

  for (const videoElement of videos) {
    const enhancer = videoElement._anime4kEnhancer;
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

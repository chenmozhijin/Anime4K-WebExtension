import { VideoEnhancer } from './video-enhancer';
import { ANIME4K_APPLIED_ATTR } from '../constants';

/**
 * 清理视频元素的增强器资源
 * @param video 视频元素
 */
function cleanupVideoEnhancer(video: HTMLVideoElement): void {
  if (video._anime4kEnhancer) {
    video._anime4kEnhancer.destroy();
    delete video._anime4kEnhancer;
  }
}

/**
 * 处理单个视频元素，添加增强器
 * @param videoEl 要处理的视频元素
 */
export function processVideoElement(videoEl: HTMLVideoElement): void {
  // 确保视频元数据已加载
  if (videoEl.readyState >= 1) { // HAVE_METADATA
    addEnhancerToVideo(videoEl);
  } else {
    videoEl.addEventListener('loadedmetadata', () => addEnhancerToVideo(videoEl), { once: true });
  }
}

/**
 * 为视频元素添加增强器
 * @param video 视频元素
 */
function addEnhancerToVideo(video: HTMLVideoElement): void {
  if (video._anime4kEnhancer) return;
  if (!video.parentElement) return;
  
  try {
    // 创建并关联增强器实例
    const enhancer = new VideoEnhancer(video);
    video._anime4kEnhancer = enhancer;
  } catch (error) {
    console.error('Failed to create enhancer for video:', video, error);
  }
}

/**
 * 初始化页面上的所有视频元素
 */
export function initializeOnPage(): void {
  const videos = Array.from(document.querySelectorAll('video'));
  videos.forEach(processVideoElement);
  
  // 设置DOM观察器
  setupDOMObserver();
}

/**
 * 设置DOM观察器监听新添加的视频元素
 */
export function setupDOMObserver(): MutationObserver {
  const observer = new MutationObserver((mutationsList) => {
    for (const mutation of mutationsList) {
      if (mutation.type === 'childList') {
        // 处理新增节点
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            const element = node as Element;
            if (element.tagName === 'VIDEO') {
              processVideoElement(element as HTMLVideoElement);
            } else {
              const videos = Array.from(element.querySelectorAll('video'));
              videos.forEach(vid => processVideoElement(vid as HTMLVideoElement));
            }
          }
        });
        
        // 处理移除节点
        mutation.removedNodes.forEach(node => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            const element = node as Element;
            // 如果是视频元素直接清理
            if (element.tagName === 'VIDEO') {
              cleanupVideoEnhancer(element as HTMLVideoElement);
            } else {
              // 检查移除的节点内是否包含视频元素
              const videos = Array.from(element.querySelectorAll('video'));
              videos.forEach(vid => cleanupVideoEnhancer(vid as HTMLVideoElement));
            }
          }
        });
      }
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });
  
  // 添加页面卸载时的全局清理
  window.addEventListener('beforeunload', () => {
    const videos = Array.from(document.querySelectorAll<HTMLVideoElement>('video'));
    videos.forEach(cleanupVideoEnhancer);
  });
  
  return observer;
}

/**
 * 处理设置更新事件
 * @param settings 新的设置
 * @param sendResponse 响应回调函数
 */
export async function handleSettingsUpdate(
  settings: any,
  sendResponse: (response?: any) => void
): Promise<void> {
  console.log('Received settings update:', settings);
  
  let reRenderedCount = 0;
  const videos = Array.from(document.querySelectorAll<HTMLVideoElement>('video'));
  
  for (const videoElement of videos) {
    if (videoElement.getAttribute(ANIME4K_APPLIED_ATTR) === 'true') {
      
      const enhancer = videoElement._anime4kEnhancer;
      if (enhancer) {
        try {
          // 重新初始化增强器应用新设置
          enhancer.destroy();
          videoElement._anime4kEnhancer = new VideoEnhancer(videoElement);
          await (videoElement as any)._anime4kEnhancer.toggleEnhancement();  // 使用类型断言解决HTMLVideoElement扩展问题
          reRenderedCount++;
        } catch (error) {
          console.error('Error re-rendering video after settings update:', error, videoElement);
        }
      }
    }
  }

  if (reRenderedCount > 0) {
    sendResponse({ status: 'SUCCESS', message: 'Videos re-rendered successfully' });
  } else {
    sendResponse({ status: 'NO_ACTION', message: 'No active instances to update' });
  }
}

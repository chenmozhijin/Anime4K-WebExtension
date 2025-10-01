import { VideoEnhancer } from './video-enhancer';

interface StashedEnhancer {
  enhancer: VideoEnhancer;
  videoSrc: string;
  timestamp: number;
  cleanupTimer: number;
}

// 使用数组代替Map
const stash: StashedEnhancer[] = [];
const STASH_TTL = 2000;

export function stashEnhancer(enhancer: VideoEnhancer): void {
  const video = enhancer.getVideoElement();
  // 必须有 src 才能暂存，这是最可靠的标识符
  if (!video.src) return;

  console.log(`[Anime4KWebExt] Stashing enhancer for video src: ${video.src}`);
  enhancer.detach();

  const cleanupTimer = window.setTimeout(() => {
    console.log(`[Anime4KWebExt] Stash for ${video.src} expired. Cleaning up.`);
    clearStashEntry(video.src);
  }, STASH_TTL);

  stash.push({
    enhancer,
    videoSrc: video.src,
    timestamp: Date.now(),
    cleanupTimer,
  });
}

export function findAndunstashEnhancer(video: HTMLVideoElement): VideoEnhancer | null {
  if (!video.src) return null;

  // 遍历查找匹配的条目
  const index = stash.findIndex(item => item.videoSrc === video.src);
  if (index === -1) {
    return null;
  }

  const stashedItem = stash[index];
  console.log(`[Anime4KWebExt] Found stashed enhancer for video src: ${video.src}. Re-attaching.`);
  
  // 清理计时器并从数组中移除
  clearTimeout(stashedItem.cleanupTimer);
  stash.splice(index, 1);

  return stashedItem.enhancer;
}

function clearStashEntry(videoSrc: string): void {
  const index = stash.findIndex(item => item.videoSrc === videoSrc);
  if (index !== -1) {
    const stashedItem = stash[index];
    clearTimeout(stashedItem.cleanupTimer);
    stashedItem.enhancer.destroy(); // 真正销毁
    stash.splice(index, 1);
  }
}
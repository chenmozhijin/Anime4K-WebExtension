import { VideoEnhancer } from './video-enhancer';

// 使用 Map 来存储 video 元素和其对应的 enhancer 实例
const enhancerMap = new Map<HTMLVideoElement, VideoEnhancer>();

/**
 * 将一个 enhancer 实例与一个 video 元素关联起来
 * @param video HTMLVideoElement - 键
 * @param enhancer VideoEnhancer - 值
 */
export function associateEnhancer(video: HTMLVideoElement, enhancer: VideoEnhancer): void {
  enhancerMap.set(video, enhancer);
}

/**
 * 根据 video 元素获取其关联的 enhancer 实例
 * @param video HTMLVideoElement - 键
 * @returns VideoEnhancer | undefined
 */
export function getEnhancer(video: HTMLVideoElement): VideoEnhancer | undefined {
  return enhancerMap.get(video);
}

/**
 * 检查一个 video 元素是否已经有关联的 enhancer
 * @param video HTMLVideoElement - 键
 * @returns boolean
 */
export function hasEnhancer(video: HTMLVideoElement): boolean {
  return enhancerMap.has(video);
}

/**
 * 解除 video 元素与其 enhancer 实例的关联
 * @param video HTMLVideoElement - 键
 */
export function dissociateEnhancer(video: HTMLVideoElement): void {
  enhancerMap.delete(video);
}

/**
 * 获取所有被管理的 video 元素
 * @returns HTMLVideoElement[]
 */
export function getAllManagedVideos(): HTMLVideoElement[] {
  return Array.from(enhancerMap.keys());
}
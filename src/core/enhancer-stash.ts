import { VideoEnhancer } from './video-enhancer';
import { createLogger } from '../utils/logger';

interface StashedEnhancer {
  enhancer: VideoEnhancer;
  sourceKey: string;
  sourceDimensions: string;
  timestamp: number;
  cleanupTimer: number;
}

const logger = createLogger('enhancer-stash');
const stash = new Map<string, StashedEnhancer[]>();
export const STASH_TTL_MS = 2000;

function getSourceKey(video: HTMLVideoElement): string | null {
  return video.currentSrc || video.src || null;
}

function getSourceDimensions(video: HTMLVideoElement): string {
  return `${video.videoWidth}x${video.videoHeight}`;
}

export function stashEnhancer(enhancer: VideoEnhancer): void {
  const video = enhancer.getVideoElement();
  const sourceKey = getSourceKey(video);
  if (!sourceKey) {
    return;
  }

  const sourceDimensions = getSourceDimensions(video);
  enhancer.detach();

  const cleanupTimer = window.setTimeout(() => {
    clearStashEntry(sourceKey, sourceDimensions, enhancer);
  }, STASH_TTL_MS);

  const entry: StashedEnhancer = {
    enhancer,
    sourceKey,
    sourceDimensions,
    timestamp: Date.now(),
    cleanupTimer,
  };

  const candidates = stash.get(sourceKey) ?? [];
  candidates.push(entry);
  candidates.sort((left, right) => right.timestamp - left.timestamp);
  stash.set(sourceKey, candidates);
  logger.debug('Stashed enhancer.', { sourceKey, sourceDimensions, count: candidates.length });
}

export function findAndunstashEnhancer(video: HTMLVideoElement): VideoEnhancer | null {
  const sourceKey = getSourceKey(video);
  if (!sourceKey) {
    return null;
  }

  const candidates = stash.get(sourceKey);
  if (!candidates || candidates.length === 0) {
    return null;
  }

  const sourceDimensions = getSourceDimensions(video);
  const match = candidates.find(candidate => candidate.sourceDimensions === sourceDimensions)
    ?? candidates[0];
  if (!match) {
    logger.debug('Skipped stash reuse because dimensions did not match.', { sourceKey, sourceDimensions });
    return null;
  }

  clearTimeout(match.cleanupTimer);
  const remaining = candidates.filter(candidate => candidate !== match);
  if (remaining.length === 0) {
    stash.delete(sourceKey);
  } else {
    stash.set(sourceKey, remaining);
  }

  logger.debug('Reusing stashed enhancer.', { sourceKey, sourceDimensions });
  return match.enhancer;
}

function clearStashEntry(sourceKey: string, sourceDimensions: string, enhancer: VideoEnhancer): void {
  const candidates = stash.get(sourceKey);
  if (!candidates) {
    return;
  }

  const remaining = candidates.filter(candidate => candidate.enhancer !== enhancer);
  if (remaining.length === 0) {
    stash.delete(sourceKey);
  } else {
    stash.set(sourceKey, remaining);
  }

  enhancer.destroy();
  logger.debug('Discarded stale stashed enhancer.', { sourceKey, sourceDimensions });
}

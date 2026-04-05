import { describe, expect, it } from 'vitest';
import {
  associateEnhancer,
  dissociateEnhancer,
  getAllManagedVideos,
  getEnhancer,
  hasEnhancer,
} from '../../src/core/enhancer-map';

describe('enhancer map', () => {
  it('associates, queries, lists, and dissociates enhancers', () => {
    const firstVideo = {} as HTMLVideoElement;
    const secondVideo = {} as HTMLVideoElement;
    const firstEnhancer = { id: 'first' };
    const secondEnhancer = { id: 'second' };

    associateEnhancer(firstVideo, firstEnhancer as any);
    associateEnhancer(secondVideo, secondEnhancer as any);

    expect(hasEnhancer(firstVideo)).toBe(true);
    expect(getEnhancer(firstVideo)).toBe(firstEnhancer);
    expect(getAllManagedVideos()).toEqual([firstVideo, secondVideo]);

    dissociateEnhancer(firstVideo);

    expect(hasEnhancer(firstVideo)).toBe(false);
    expect(getEnhancer(firstVideo)).toBeUndefined();
    expect(getAllManagedVideos()).toEqual([secondVideo]);

    dissociateEnhancer(secondVideo);
  });
});

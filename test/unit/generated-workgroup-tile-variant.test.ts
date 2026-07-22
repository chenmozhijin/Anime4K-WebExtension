import fs from 'node:fs';
import path from 'node:path';
import { describe, expect, it } from 'vitest';
import {
  createACNetWorkgroupTileVariants,
  createCuNNyWorkgroupTileVariants,
} from '../../src/core/generated-models/workgroup-tile-variant';

function read(relativePath: string): string {
  return fs.readFileSync(path.join(process.cwd(), relativePath), 'utf8');
}

describe('generated workgroup tile variants', () => {
  it('keeps the original ACNet shader as the autotuning baseline', () => {
    const shader = read('src/engines/acnet/generated/acnet_f8b4/shaders/stage0.wgsl');
    const variants = createACNetWorkgroupTileVariants(shader);

    expect(variants.map(variant => variant.id)).toEqual([
      'untiled-8x8',
      'tile-8x8',
      'tile-16x8',
    ]);
    expect(variants[0].wgsl).toBe(shader);
    expect(variants[0].requiredWorkgroupStorageBytes).toBeUndefined();
    expect(variants.every(variant => variant.benchmarkCacheVersion === 4)).toBe(true);
  });

  it('keeps the original CuNNy shader as the autotuning baseline', () => {
    const shader = read('src/engines/cunny/generated/2x12_ds/shaders/stage0.wgsl');
    const variants = createCuNNyWorkgroupTileVariants(shader);

    expect(variants.map(variant => variant.id)).toEqual([
      'untiled-8x8',
      'tile-8x8',
      'tile-16x8',
    ]);
    expect(variants[0].wgsl).toBe(shader);
    expect(variants[0].requiredWorkgroupStorageBytes).toBeUndefined();
    expect(variants.every(variant => variant.benchmarkCacheVersion === 4)).toBe(true);
  });
});

import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import {
  createAnime4KWorkgroupTileVariant,
  createAnime4KWorkgroupTileVariants,
} from '../../src/core/generated-models/anime4k-workgroup-tile-variant';

function collectWgsl(directory: string): string[] {
  return readdirSync(directory).flatMap(entry => {
    const fullPath = join(directory, entry);
    return statSync(fullPath).isDirectory()
      ? collectWgsl(fullPath)
      : fullPath.endsWith('.wgsl') ? [fullPath] : [];
  });
}

describe('Anime4K workgroup tile variants', () => {
  it('tiles eligible 3x3 convolutions with a barrier before the OOB return', () => {
    const shader = readFileSync(resolve(
      process.cwd(),
      'src/engines/anime4k/pipelines/upscale/CNNx2M/shaders/conv2dtf.wgsl',
    ), 'utf8');
    const tiled = createAnime4KWorkgroupTileVariant(shader);

    expect(tiled).not.toBeNull();
    expect(tiled).toContain('var<workgroup> anime4kTile_MAIN');
    expect(tiled).toContain('@builtin(local_invocation_id) localId');
    expect(tiled).not.toContain('go_0(pixel.xy, -1, -1)');
    expect(tiled!.indexOf('workgroupBarrier()')).toBeLessThan(tiled!.indexOf('// OOB check'));
  });

  it('builds certified 8x8 and 16x8 variants within explicit resource requirements', () => {
    const shader = readFileSync(resolve(
      process.cwd(),
      'src/engines/anime4k/pipelines/upscale/CNNx2M/shaders/conv2dtf.wgsl',
    ), 'utf8');
    const variants = createAnime4KWorkgroupTileVariants(shader)!;

    expect(variants.map(variant => variant.id)).toEqual(['tile-8x8', 'tile-16x8']);
    expect(variants[1].wgsl).toContain('@workgroup_size(16, 8)');
    expect(variants.every(variant => variant.correctness === 'exact')).toBe(true);
    expect(variants[1].requiredWorkgroupStorageBytes).toBe(18 * 10 * 16);
  });

  it('covers a substantial set of common Anime4K convolution shaders', () => {
    const shaderFiles = collectWgsl(resolve(process.cwd(), 'src/engines/anime4k/pipelines'));
    const eligible = shaderFiles.filter(file =>
      createAnime4KWorkgroupTileVariants(readFileSync(file, 'utf8')) !== null);

    expect(eligible.length).toBeGreaterThanOrEqual(40);
  });
});

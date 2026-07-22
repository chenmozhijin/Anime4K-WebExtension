import { describe, expect, it } from 'vitest';

interface LayerModule {
  parseArgs(args: string[]): {
    width: number;
    height: number;
    frames: number;
    repeats: number;
    includeAllVideos: boolean;
    skipVideo: boolean;
  };
  singleEffectWorkloads: Array<{ id: string; effectId: string; targetScale: number }>;
}

const {
  parseArgs,
  singleEffectWorkloads,
} = require('../../scripts/benchmark-gpu-layers.js') as LayerModule;

describe('layered GPU benchmark', () => {
  it('covers representative single-effect backends', () => {
    expect(singleEffectWorkloads.map(workload => workload.effectId)).toEqual([
      'anime4k/Helper/ClampHighlights',
      'anime4k/Upscale/CNNx2M',
      'acnet/Upscale/F8B4',
      'cunny/Upscale/DS/2x12',
      'artcnn/Upscale/C4F32',
    ]);
  });

  it('keeps production sampling defaults and explicit smoke settings', () => {
    expect(parseArgs([])).toMatchObject({
      width: 1920,
      height: 1080,
      frames: 300,
      repeats: 5,
      includeAllVideos: false,
      skipVideo: false,
    });
    expect(parseArgs(['--smoke', '--all-videos'])).toMatchObject({
      width: 64,
      height: 48,
      frames: 6,
      repeats: 1,
      includeAllVideos: true,
    });
  });
});

import { createRequire } from 'node:module';
import { describe, expect, it } from 'vitest';

const require = createRequire(import.meta.url);
const { computeImageMetrics, deltaE2000, rgbToLab } = require('../../scripts/verify/lib/image-metrics');

describe('verification image metrics', () => {
  it('reports perfect similarity for identical RGBA images', () => {
    const image = Float32Array.from([
      0, 0, 0, 1,
      1, 1, 1, 1,
      1, 0, 0, 1,
      0, 1, 0, 1,
    ]);
    const metrics = computeImageMetrics(image, image, 2, 4);

    expect(metrics.mse).toBe(0);
    expect(metrics.psnr).toBe(Infinity);
    expect(metrics.ssim).toBeCloseTo(1, 12);
    expect(metrics.deltaE2000.max).toBe(0);
    expect(metrics.edgeWeightedMeanAbs).toBe(0);
  });

  it('computes symmetric DeltaE2000 values', () => {
    const first = rgbToLab(0.8, 0.2, 0.1);
    const second = rgbToLab(0.7, 0.25, 0.15);

    expect(deltaE2000(first, second)).toBeCloseTo(deltaE2000(second, first), 12);
    expect(deltaE2000(first, second)).toBeGreaterThan(0);
  });
});

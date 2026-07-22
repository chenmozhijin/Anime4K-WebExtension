import { describe, expect, it } from 'vitest';
import {
  TemporalMetricsAccumulator,
  defaultTemporalThresholds,
} from '../verify/browser/temporal-metrics';

function frame(value: number): Float32Array {
  return new Float32Array([
    value, value, value, 1,
    value, value, value, 1,
    value, value, value, 1,
    value, value, value, 1,
  ]);
}

describe('TemporalMetricsAccumulator', () => {
  it('accepts identical finite frames and reports a stable zero error field', () => {
    const metrics = new TemporalMetricsAccumulator(2, 2);
    metrics.addFrame(frame(0.25), frame(0.25), 0);
    metrics.addFrame(frame(0.75), frame(0.75), 1);

    expect(metrics.summarize()).toMatchObject({
      passed: true,
      frameCount: 2,
      meanAbs: 0,
      maxAbs: 0,
      temporalChangeP99: 0,
      nonFiniteCount: 0,
    });
  });

  it('rejects a temporally unstable error even when custom spatial thresholds allow each frame', () => {
    const metrics = new TemporalMetricsAccumulator(2, 2, {
      ...defaultTemporalThresholds,
      meanAbs: 1,
      maxAbs: 1,
      psnr: 0,
      ssim: -1,
      deltaE2000P99: 100,
      deltaE2000Max: 100,
      temporalChangeP99: 1 / 255,
    });
    metrics.addFrame(frame(0.25), frame(0.25), 0);
    metrics.addFrame(frame(0.25), frame(0.5), 1);

    const summary = metrics.summarize();
    expect(summary.temporalChangeP99).toBeGreaterThan(1 / 255);
    expect(summary.passed).toBe(false);
  });
});

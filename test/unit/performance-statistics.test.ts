import { describe, expect, it } from 'vitest';
import { summarizePerformanceSamples } from '../../src/core/performance-statistics';

describe('summarizePerformanceSamples', () => {
  it('reports stable percentiles and variation', () => {
    const result = summarizePerformanceSamples([1, 2, 3, 4, 5, 100]);
    expect(result).toMatchObject({
      count: 6,
      median: 4,
      p50: 4,
      p95: 100,
      p99: 100,
      min: 1,
      max: 100,
    });
    expect(result.mean).toBeCloseTo(19.1666667);
    expect(result.coefficientOfVariation).toBeGreaterThan(1);
  });

  it('returns zeroed statistics for an empty sample', () => {
    expect(summarizePerformanceSamples([])).toEqual({
      count: 0,
      mean: 0,
      median: 0,
      p50: 0,
      p95: 0,
      p99: 0,
      min: 0,
      max: 0,
      standardDeviation: 0,
      coefficientOfVariation: 0,
    });
  });
});

import { describe, expect, it } from 'vitest';

interface BenchmarkVariant {
  id: string;
  correctness: string;
  flags: Record<string, boolean>;
  report: ReturnType<typeof report>;
}

interface BenchmarkModule {
  benchmarkableFlagVariants: string[];
  buildComparisons(variants: BenchmarkVariant[]): Array<{ tiers: Array<{
    gpuP50GainPercent: number;
    peakTextureReductionPercent: number;
    passReductionPercent: number;
    acceptance: { passed: boolean; structurallyNeutral: boolean; noMajorRegression: boolean };
  }> }>;
  optimizedFlags: Record<string, boolean>;
  parseArgs(args: string[]): { variants: string[] };
  sanitizeBenchmarkReport(report: Record<string, unknown>): Record<string, unknown>;
  resolveOptimizationVariant(id: string): {
    id: string;
    correctness: string;
    flags: Record<string, boolean>;
  };
}

const {
  benchmarkableFlagVariants,
  buildComparisons,
  optimizedFlags,
  parseArgs,
  resolveOptimizationVariant,
  sanitizeBenchmarkReport,
} = require('../../scripts/benchmark-gpu-suite.js') as BenchmarkModule;

function statistics(p50: number) {
  return { p50, p95: p50 * 1.1, p99: p50 * 1.2 };
}

function report(passCount: number, peakTextureBytes: number, p50: number) {
  return {
    tiers: [{
      tier: 'performance',
      passCount,
      peakTextureBytes,
      aggregate: {
        gpuMs: { statistics: statistics(p50) },
        endToEndMs: { statistics: statistics(p50 + 1) },
      },
    }],
  };
}

describe('benchmark GPU suite CLI', () => {
  it('builds correctness-scoped optimization profiles', () => {
    const baseline = resolveOptimizationVariant('baseline');
    const exact = resolveOptimizationVariant('exact');
    const quantized = resolveOptimizationVariant('quantized');
    const optimized = resolveOptimizationVariant('optimized');

    expect(Object.values(baseline.flags).every(value => value === false)).toBe(true);
    expect(exact.flags.textureLifetimeReuse).toBe(true);
    expect(exact.flags.vectorizedPixelShuffle).toBe(false);
    expect(exact.flags.anime4kWorkgroupTile).toBe(false);
    expect(exact.flags.ganMultiOutputDispatch).toBe(false);
    expect(quantized.flags.fusedModelTail).toBe(true);
    expect(quantized.flags.terminalDirect).toBe(false);
    expect(optimized.flags).toEqual(optimizedFlags);
  });

  it('adds independently benchmarkable flag variants', () => {
    const args = parseArgs(['--variants', 'baseline', '--flag-variants']);
    expect(args.variants).toEqual([
      'baseline',
      ...benchmarkableFlagVariants.map((flag: string) => `flag:${flag}`),
    ]);
  });

  it('rejects unknown variants', () => {
    expect(() => parseArgs(['--variants=unknown'])).toThrow('Unknown GPU benchmark variant');
    expect(() => resolveOptimizationVariant('flag:nope')).toThrow('Unknown optimization flag variant');
  });

  it('removes local environment and input URL metadata from public reports', () => {
    const sanitized = sanitizeBenchmarkReport({
      timestamp: '2026-09-02T00:00:00.000Z',
      browser: { name: 'Chromium' },
      adapter: { vendor: 'test' },
      features: ['timestamp-query'],
      limits: { maxTextureDimension2D: 8192 },
      timestampQuery: true,
      source: { kind: 'video', url: 'http://127.0.0.1:1234/private.mp4' },
      tiers: [],
    });

    expect(sanitized).not.toHaveProperty('timestamp');
    expect(sanitized).not.toHaveProperty('browser');
    expect(sanitized).not.toHaveProperty('adapter');
    expect(sanitized).not.toHaveProperty('features');
    expect(sanitized).not.toHaveProperty('limits');
    expect(sanitized).not.toHaveProperty('timestampQuery');
    expect(sanitized.source).toEqual({ kind: 'video' });
  });

  it('computes performance and memory acceptance against baseline', () => {
    const comparisons = buildComparisons([
      { id: 'baseline', correctness: 'exact', flags: {}, report: report(100, 1000, 10) },
      { id: 'optimized', correctness: 'perceptual', flags: {}, report: report(60, 700, 8) },
    ]);
    const comparison = comparisons[0].tiers[0];

    expect(comparison.gpuP50GainPercent).toBeCloseTo(20);
    expect(comparison.peakTextureReductionPercent).toBeCloseTo(30);
    expect(comparison.passReductionPercent).toBeCloseTo(40);
    expect(comparison.acceptance.passed).toBe(true);
  });

  it('accepts a stable profile that is structurally a no-op for a workload', () => {
    const comparisons = buildComparisons([
      { id: 'baseline', correctness: 'exact', flags: {}, report: report(40, 1000, 10) },
      { id: 'exact', correctness: 'exact', flags: {}, report: report(40, 1000, 10.1) },
    ]);

    expect(comparisons[0].tiers[0].acceptance).toMatchObject({
      structurallyNeutral: true,
      noMajorRegression: true,
      passed: true,
    });
  });
});

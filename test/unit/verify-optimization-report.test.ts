import {
  mkdirSync,
  mkdtempSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { afterEach, describe, expect, it } from 'vitest';

const {
  buildOptimizationReport,
  reportFiles,
} = require('../../scripts/verify-optimization-report.js') as {
  buildOptimizationReport: (root: string) => any;
  reportFiles: Record<string, string>;
};

const roots: string[] = [];

function writeJson(root: string, relativePath: string, value: unknown): void {
  const filePath = join(root, relativePath);
  mkdirSync(dirname(filePath), { recursive: true });
  writeFileSync(filePath, JSON.stringify(value));
}

function createPassingRoot(): string {
  const root = mkdtempSync(join(tmpdir(), 'optimization-report-'));
  roots.push(root);
  writeJson(root, reportFiles.rawMath, { generatedAt: 'raw', caseCount: 456, failureCount: 0 });
  writeJson(root, reportFiles.optimizationAudit, {
    generatedAt: 'optimization',
    command: 'verify-effects --optimization-audit',
    caseCount: 456,
    failureCount: 0,
  });
  writeJson(root, reportFiles.terminalAudit, {
    generatedAt: 'terminal',
    command: 'verify-effects --terminal-audit',
    caseCount: 456,
    failureCount: 0,
  });
  writeJson(root, reportFiles.wgsl, { fileCount: 5341, failureCount: 0 });
  writeJson(root, reportFiles.presets, { passed: true, cases: Array.from({ length: 24 }, () => ({})) });
  writeJson(root, reportFiles.kernelVariants, { caseCount: 4, failureCount: 0 });
  writeJson(root, reportFiles.externalTexture, { caseCount: 12, failureCount: 0 });
  writeJson(root, reportFiles.temporal, {
    caseCount: 24,
    framesPerCase: 300,
    profiles: ['optimized', 'external'],
    failureCount: 0,
  });
  writeJson(root, reportFiles.textureLifetimes, {
    acceptance: {
      arnetF8B64MaxIntermediateSlots: 7,
      arnetF8B64ActualIntermediateSlots: 7,
    },
    models: [{}],
  });
  const tiers = Object.entries({ performance: 34, balanced: 36, quality: 37, ultra: 54 })
    .map(([tier, passCount]) => ({
      tier,
      terminalPresented: tier === 'performance' || tier === 'balanced',
      passCount,
    }));
  writeJson(root, reportFiles.performanceMatrix, {
    measurement: {
      warmupFrames: 60,
      warmupMinimumMs: 2000,
      frames: 300,
      repeats: 5,
      pairedComparison: true,
    },
    variants: [{
      id: 'optimized',
      report: { browser: { name: 'chrome' }, adapter: { vendor: 'nvidia' }, tiers },
    }],
    comparisons: [{
      variant: 'optimized',
      tiers: tiers.map(item => ({
        tier: item.tier,
        baseline: { passCount: item.passCount + 8 },
        candidate: { passCount: item.passCount },
        gpuP50GainPercent: 4,
        gpuP95GainPercent: 3,
        gpuP99GainPercent: 2,
        peakTextureReductionPercent: 30,
        acceptance: { passed: true },
      })),
    }],
  });
  writeJson(root, reportFiles.performanceLayers, {
    layers: {
      microKernel: [{
        measurement: { workloadId: 'depth-to-space' },
        comparisons: [{
          variant: 'optimized',
          tiers: [{
            tier: 'depth-to-space',
            gpuP50GainPercent: 7,
            gpuP95GainPercent: 6,
            gpuP99GainPercent: 5,
            peakTextureReductionPercent: 0,
            passReductionPercent: 0,
            acceptance: { meetsPrimaryTarget: true, noMajorRegression: true },
          }],
        }],
      }],
    },
  });
  mkdirSync(join(root, 'src', 'core'), { recursive: true });
  writeFileSync(
    join(root, 'src', 'core', 'optimization-flags.ts'),
    'export const defaults = { perceptualShaderF16: false, };',
  );
  return root;
}

afterEach(() => {
  while (roots.length > 0) {
    rmSync(roots.pop()!, { recursive: true, force: true });
  }
});

describe('optimization release report', () => {
  it('returns local validation without machine or release-status metadata', () => {
    const report = buildOptimizationReport(createPassingRoot());

    expect(report.localValidationPassed).toBe(true);
    expect(report).not.toHaveProperty('generatedAt');
    expect(report).not.toHaveProperty('root');
    expect(report).not.toHaveProperty('releaseCertificationComplete');
    expect(report).not.toHaveProperty('releaseCertification');
    expect(report.checks.performanceMatrix).not.toHaveProperty('browser');
    expect(report.checks.performanceMatrix).not.toHaveProperty('adapter');
    expect(report.runtimePolicy.uncertifiedPerceptualShaderF16Disabled).toBe(true);
    expect(report.checks.performanceMatrix.tiers.map((tier: any) => tier.processingPassCount))
      .toEqual([34, 36, 36, 53]);
  });

  it('fails local validation when a required report is missing', () => {
    const root = createPassingRoot();
    rmSync(join(root, reportFiles.externalTexture), { force: true });

    const report = buildOptimizationReport(root);

    expect(report.localValidationPassed).toBe(false);
    expect(report.checks.externalTexture).toMatchObject({ missing: true, passed: false });
  });
});

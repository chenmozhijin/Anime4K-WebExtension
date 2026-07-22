import { describe, expect, it } from 'vitest';

interface KernelVerifierModule {
  compareOutputs(baseline: number[], candidate: number[]): {
    passed: boolean;
    meanAbs?: number;
    maxAbs?: number;
  };
  parseArgs(args: string[]): { noBuild: boolean; filter: string | null };
}

const {
  compareOutputs,
  parseArgs,
} = require('../../scripts/verify-kernel-variants.js') as KernelVerifierModule;

describe('kernel variant verifier', () => {
  it('enforces the exact variant thresholds', () => {
    expect(compareOutputs([0, 0.5, 1], [0, 0.5, 1])).toMatchObject({
      passed: true,
      meanAbs: 0,
      maxAbs: 0,
    });
    expect(compareOutputs([0], [0.002])).toMatchObject({ passed: false });
  });

  it('parses filtering and bundle reuse options', () => {
    expect(parseArgs(['--no-build', '--filter=ACNET'])).toMatchObject({
      noBuild: true,
      filter: 'acnet',
    });
  });
});

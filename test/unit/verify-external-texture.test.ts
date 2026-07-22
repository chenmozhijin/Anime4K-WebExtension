import { describe, expect, it } from 'vitest';

interface ExternalVerifierModule {
  compare(reference: number[], candidate: number[], width: number): {
    passed: boolean;
    meanAbs?: number;
    maxAbs?: number;
  };
  parseArgs(args: string[]): { noBuild: boolean; filter: string | null };
}

const {
  compare,
  parseArgs,
} = require('../../scripts/verify-external-texture.js') as ExternalVerifierModule;

describe('external texture verifier', () => {
  it('accepts perceptually equivalent RGB output and rejects visible error', () => {
    const reference = [0.1, 0.2, 0.3, 1, 0.7, 0.8, 0.9, 1];
    expect(compare(reference, [...reference], 2)).toMatchObject({ passed: true, meanAbs: 0 });
    expect(compare(reference, reference.map((value, index) => index % 4 === 3 ? value : value + 0.02), 2))
      .toMatchObject({ passed: false });
  });

  it('parses smoke and filter options', () => {
    expect(parseArgs(['--no-build', '--filter=PQ'])).toMatchObject({
      noBuild: true,
      filter: 'pq',
    });
  });
});

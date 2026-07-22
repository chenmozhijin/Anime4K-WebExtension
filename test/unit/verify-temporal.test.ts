import { describe, expect, it } from 'vitest';

const { parseArgs } = require('../../scripts/verify-temporal');

describe('verify-temporal arguments', () => {
  it('uses the complete fixture and both certified profiles by default', () => {
    expect(parseArgs([])).toMatchObject({
      preset: 'A+A',
      tier: 'balanced',
      targetScale: 1,
      profiles: ['optimized', 'external'],
    });
  });

  it('supports smoke fixtures and bounded frame runs', () => {
    expect(parseArgs(['--smoke', '--frames=3', '--profiles=optimized'])).toMatchObject({
      frameCount: 3,
      profiles: ['optimized'],
    });
  });
});

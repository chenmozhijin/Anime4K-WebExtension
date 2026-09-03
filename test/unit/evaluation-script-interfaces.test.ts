import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const visualRunner = require('../../scripts/run-visual-corpus-matrix.js') as {
  parseArgs(args: string[]): { manifest: string; matrix: string; output: string };
};
const frameCorpus = require('../../scripts/prepare-motion-frame-corpus.js') as {
  parseArgs(args: string[]): { manifest: string; output: string };
};
const compressedClips = require('../../scripts/prepare-compressed-motion-clips.js') as {
  parseArgs(args: string[]): { manifest: string; sourceRoot: string | null; outputRoot: string };
};
const candidateBenchmark = require('../../scripts/benchmark-candidates.js') as {
  parseArgs(args: string[]): { outputRoot: string; batchSize: number };
};

describe('public evaluation script interfaces', () => {
  it('requires explicit external paths for visual evaluation', () => {
    expect(() => visualRunner.parseArgs([])).toThrow('--manifest must be provided');

    const args = visualRunner.parseArgs([
      '--manifest', resolve('external', 'manifest.json'),
      '--matrix', resolve('external', 'matrix.json'),
      '--output', resolve('external', 'evaluation'),
    ]);

    expect(args.manifest).toBe(resolve('external', 'manifest.json'));
    expect(args.matrix).toBe(resolve('external', 'matrix.json'));
    expect(args.output).toBe(resolve('external', 'evaluation'));
  });

  it('requires explicit paths for motion corpus preparation', () => {
    expect(() => frameCorpus.parseArgs([])).toThrow('Both --manifest and --output must be provided');
    expect(() => compressedClips.parseArgs([])).toThrow('Both --manifest and --output-root must be provided');

    const args = compressedClips.parseArgs([
      '--manifest', resolve('external', 'motion', 'manifest.json'),
      '--output-root', resolve('external', 'motion', 'compressed'),
    ]);

    expect(args.sourceRoot).toBe(resolve('external', 'motion'));
  });

  it('requires an external output directory for candidate benchmarks', () => {
    expect(() => candidateBenchmark.parseArgs([])).toThrow('--output-dir must be provided');

    const args = candidateBenchmark.parseArgs([
      '--output-dir', resolve('external', 'benchmarks'),
      '--batch-size', '2',
    ]);

    expect(args.outputRoot).toBe(resolve('external', 'benchmarks'));
    expect(args.batchSize).toBe(2);
  });
});

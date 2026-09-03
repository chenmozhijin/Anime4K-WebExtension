import { describe, expect, it } from 'vitest';

const {
  checkPublicSurface,
  containsPath,
  pathFindings,
  repoPaths,
} = require('../../scripts/check-public-surface.js') as {
  checkPublicSurface: () => Array<{ filePath: string; reason: string }>;
  containsPath: (root: string, candidate: string) => boolean;
  pathFindings: (paths: string[]) => Array<{ filePath: string; reason: string }>;
  repoPaths: (gitRunner?: (args: string[], input?: string) => string) => string[];
};

describe('public surface policy', () => {
  it('matches forbidden roots at any path depth', () => {
    expect(containsPath('test-results', 'test-results/output.json')).toBe(true);
    expect(containsPath('.reference', '.reference/CuNNy/LICENSE')).toBe(true);
    expect(containsPath('test-results', 'scripts/test-results/report.json')).toBe(true);
    expect(containsPath('test-results', 'tests/results.json')).toBe(false);
  });

  it('rejects generated and private paths', () => {
    const findings = pathFindings([
      'test-results/report.json',
      '.local-archive/audit.md',
      'test/verify/corpus/matrix.json',
    ]);

    expect(findings.map(finding => finding.filePath)).toEqual(expect.arrayContaining([
      'test-results/report.json',
      '.local-archive/audit.md',
      'test/verify/corpus/matrix.json',
    ]));
  });

  it('asks git to exclude staged deletions from submitted paths', () => {
    const calls: string[][] = [];
    const fakeGit = (args: string[]) => {
      calls.push(args);
      if (args[0] === 'diff') return 'package.json\0';
      return 'package.json\0';
    };

    expect(repoPaths(fakeGit)).toContain('package.json');
    expect(calls).toContainEqual([
      'diff', '--cached', '--name-only', '--diff-filter=ACMRTUXB', '-z',
    ]);
  });

  it('passes for the current public working tree', () => {
    expect(checkPublicSurface()).toEqual([]);
  });
});

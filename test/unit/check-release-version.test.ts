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
  parseArgs,
  validateReleaseVersions,
} = require('../../scripts/check-release-version.js') as {
  parseArgs: (argv: string[]) => { root: string; tag: string | null; distDirs: string[] };
  validateReleaseVersions: (options: {
    root: string;
    tag?: string | null;
    distDirs?: string[];
  }) => { version: string; expectedTag: string; files: string[] };
};

const roots: string[] = [];

function writeJson(root: string, relativePath: string, value: unknown): void {
  const filePath = join(root, relativePath);
  mkdirSync(dirname(filePath), { recursive: true });
  writeFileSync(filePath, JSON.stringify(value));
}

function createReleaseRoot(version = '1.2.3'): string {
  const root = mkdtempSync(join(tmpdir(), 'release-version-'));
  roots.push(root);
  writeJson(root, 'package.json', { version });
  writeJson(root, 'manifest.json', { version });
  writeJson(root, 'dist-chrome/manifest.json', { version });
  writeJson(root, 'dist-firefox/manifest.json', { version });
  return root;
}

afterEach(() => {
  while (roots.length > 0) rmSync(roots.pop()!, { recursive: true, force: true });
});

describe('check-release-version', () => {
  it('parses tag, root, and repeated dist options', () => {
    expect(parseArgs([
      '--root', '.',
      '--tag=v1.2.3',
      '--dist', 'dist-chrome',
      '--dist=dist-firefox',
    ])).toMatchObject({
      tag: 'v1.2.3',
      distDirs: ['dist-chrome', 'dist-firefox'],
    });
  });

  it('accepts matching source, build, and tag versions', () => {
    const result = validateReleaseVersions({
      root: createReleaseRoot(),
      tag: 'v1.2.3',
      distDirs: ['dist-chrome', 'dist-firefox'],
    });

    expect(result).toMatchObject({ version: '1.2.3', expectedTag: 'v1.2.3' });
    expect(result.files).toHaveLength(4);
  });

  it('rejects a source manifest version mismatch', () => {
    const root = createReleaseRoot();
    writeJson(root, 'manifest.json', { version: '1.2.2' });

    expect(() => validateReleaseVersions({ root })).toThrow(
      'manifest.json version 1.2.2 does not match package.json version 1.2.3',
    );
  });

  it('rejects a tag version mismatch', () => {
    expect(() => validateReleaseVersions({
      root: createReleaseRoot(),
      tag: 'v1.2.2',
    })).toThrow('Tag v1.2.2 does not match expected release tag v1.2.3');
  });

  it('rejects a missing build manifest', () => {
    const root = createReleaseRoot();
    rmSync(join(root, 'dist-firefox/manifest.json'));

    expect(() => validateReleaseVersions({
      root,
      distDirs: ['dist-firefox'],
    })).toThrow('Version file does not exist: dist-firefox/manifest.json');
  });

  it('rejects a build manifest version mismatch', () => {
    const root = createReleaseRoot();
    writeJson(root, 'dist-chrome/manifest.json', { version: '1.2.4' });

    expect(() => validateReleaseVersions({
      root,
      distDirs: ['dist-chrome'],
    })).toThrow('dist-chrome/manifest.json version 1.2.4 does not match package.json version 1.2.3');
  });
});

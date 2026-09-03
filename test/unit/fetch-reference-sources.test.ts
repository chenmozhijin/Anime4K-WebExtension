import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { tmpdir } from 'node:os';
import { basename, dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { describe, expect, it, vi } from 'vitest';

const require = createRequire(import.meta.url);
const {
  assertLockedRelativePath,
  copyLockedFiles,
  parseArgs,
  run,
  selectedTargets,
  verifyReference,
} = require('../../scripts/fetch-reference-sources.js');

type LockedFile = {
  path: string;
  sha256: string;
};

type FixtureTarget = {
  component: string;
  license: string;
  sourceUrl: string;
  archiveUrl: string;
  commit: string;
  referenceRoot: string;
  includedFiles: LockedFile[];
};

const hashText = (content: string): string => createHash('sha256').update(content).digest('hex');

function writeFixtureFile(root: string, relativePath: string, content: string): LockedFile {
  const filePath = join(root, relativePath);
  mkdirSync(dirname(filePath), { recursive: true });
  writeFileSync(filePath, content);
  return { path: relativePath, sha256: hashText(content) };
}

function makeTarget(referenceRoot: string, includedFiles: LockedFile[], archiveUrl = 'file:///fixture.zip'): FixtureTarget {
  return {
    component: 'FixtureReference',
    license: 'MIT',
    sourceUrl: 'https://github.com/example/FixtureReference',
    archiveUrl,
    commit: '0123456789abcdef0123456789abcdef01234567',
    referenceRoot,
    includedFiles,
  };
}

function writeLock(path: string, target: FixtureTarget): void {
  writeFileSync(path, JSON.stringify({
    version: 1,
    targets: {
      fixture: target,
    },
  }));
}

function makeZip(sourceDir: string, archivePath: string): void {
  if (process.platform === 'win32') {
    execFileSync('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      '& { param($sourceDir, $archivePath) Compress-Archive -LiteralPath $sourceDir -DestinationPath $archivePath -Force }',
      sourceDir,
      archivePath,
    ]);
    return;
  }

  execFileSync('zip', ['-q', '-r', archivePath, basename(sourceDir)], { cwd: dirname(sourceDir) });
}

function canCreateZip(): boolean {
  try {
    const root = mkdtempSync(join(tmpdir(), 'reference-zip-check-'));
    const sourceDir = join(root, 'source');
    mkdirSync(sourceDir);
    makeZip(sourceDir, join(root, 'source.zip'));
    rmSync(root, { recursive: true, force: true });
    return true;
  } catch {
    return false;
  }
}

describe('fetch-reference-sources', () => {
  it('parses target/all/check options and rejects ambiguous invocation', () => {
    expect(parseArgs(['--target', 'anime4k']).target).toBe('anime4k');
    expect(parseArgs(['--all', '--check']).checkOnly).toBe(true);
    expect(() => parseArgs([])).toThrow('Pass --target <id> or --all.');
    expect(() => parseArgs(['--all', '--target', 'cunny'])).toThrow('Pass either --target <id> or --all');
    expect(() => parseArgs(['--nope'])).toThrow('Unknown fetch-reference-sources option');
  });

  it('selects one target or all targets from the lock', () => {
    const lock = {
      targets: {
        anime4k: { component: 'Anime4K' },
        cunny: { component: 'CuNNy' },
      },
    };

    expect(selectedTargets(lock, { all: false, target: 'cunny' })).toEqual([['cunny', { component: 'CuNNy' }]]);
    expect(selectedTargets(lock, { all: true })).toHaveLength(2);
    expect(() => selectedTargets(lock, { all: false, target: 'missing' })).toThrow('Unknown reference target');
  });

  it('rejects locked file paths that could escape the reference root', () => {
    expect(() => assertLockedRelativePath('glsl/model.glsl')).not.toThrow();
    expect(() => assertLockedRelativePath('../model.glsl')).toThrow('must not escape');
    expect(() => assertLockedRelativePath('glsl/../model.glsl')).toThrow('must not escape');
    expect(() => assertLockedRelativePath('/tmp/model.glsl')).toThrow('must be relative');
  });

  it('checks existing references without downloading or writing files', async () => {
    const root = mkdtempSync(join(tmpdir(), 'reference-check-'));
    try {
      const referenceRoot = join(root, 'reference');
      const lockPath = join(root, 'lock.json');
      const file = writeFixtureFile(referenceRoot, 'glsl/effect.glsl', 'locked shader');
      writeLock(lockPath, makeTarget(referenceRoot, [file]));

      const log = vi.spyOn(console, 'log').mockImplementation(() => undefined);
      await expect(run(['--target', 'fixture', '--check', '--lock-file', lockPath])).resolves.toBeUndefined();
      expect(log).toHaveBeenCalledWith(expect.stringContaining('is ready'));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it('reports missing files and hash mismatches in check mode', async () => {
    const root = mkdtempSync(join(tmpdir(), 'reference-check-fail-'));
    try {
      const referenceRoot = join(root, 'reference');
      const lockPath = join(root, 'lock.json');
      const expected = [
        { path: 'missing.glsl', sha256: hashText('missing') },
        writeFixtureFile(referenceRoot, 'mismatch.glsl', 'actual'),
      ];
      expected[1].sha256 = hashText('expected');
      writeLock(lockPath, makeTarget(referenceRoot, expected));

      const error = vi.spyOn(console, 'error').mockImplementation(() => undefined);
      await expect(run(['--target', 'fixture', '--check', '--lock-file', lockPath])).rejects.toThrow('Reference check failed');
      expect(error).toHaveBeenCalledWith(expect.stringContaining('Missing: missing.glsl'));
      expect(error).toHaveBeenCalledWith(expect.stringContaining('Mismatched: mismatch.glsl'));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  it('copies only locked files into the reference root', () => {
    const root = mkdtempSync(join(tmpdir(), 'reference-copy-'));
    try {
      const sourceRoot = join(root, 'source');
      const referenceRoot = join(root, 'reference');
      const file = writeFixtureFile(sourceRoot, 'glsl/effect.glsl', 'locked shader');
      writeFixtureFile(sourceRoot, 'large/unused.bin', 'do not copy');

      copyLockedFiles(sourceRoot, makeTarget(referenceRoot, [file]));

      expect(readFileSync(join(referenceRoot, 'glsl/effect.glsl'), 'utf8')).toBe('locked shader');
      expect(existsSync(join(referenceRoot, 'large/unused.bin'))).toBe(false);
      expect(verifyReference(makeTarget(referenceRoot, [file]))).toEqual({ missing: [], mismatched: [] });
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });

  const zipRestoreTest = canCreateZip() ? it : it.skip;

  zipRestoreTest('restores a target from a local locked archive and validates hashes', async () => {
    const root = mkdtempSync(join(tmpdir(), 'reference-restore-'));
    try {
      const sourceRoot = join(root, 'FixtureReference-0123456');
      const referenceRoot = join(root, 'reference');
      const cacheRoot = join(root, 'cache');
      const archivePath = join(root, 'fixture.zip');
      const lockPath = join(root, 'lock.json');
      const file = writeFixtureFile(sourceRoot, 'glsl/effect.glsl', 'locked shader');
      writeFixtureFile(sourceRoot, 'large/unused.bin', 'do not copy');
      makeZip(sourceRoot, archivePath);
      writeLock(lockPath, makeTarget(referenceRoot, [file], pathToFileURL(archivePath).href));

      const log = vi.spyOn(console, 'log').mockImplementation(() => undefined);
      await expect(run(['--target', 'fixture', '--lock-file', lockPath, '--cache-dir', cacheRoot])).resolves.toBeUndefined();

      expect(readFileSync(join(referenceRoot, 'glsl/effect.glsl'), 'utf8')).toBe('locked shader');
      expect(existsSync(join(referenceRoot, 'large/unused.bin'))).toBe(false);
      expect(log).toHaveBeenCalledWith(expect.stringContaining('restored at'));
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  }, 15_000);

  it('rejects unknown targets from custom locks', async () => {
    const root = mkdtempSync(join(tmpdir(), 'reference-unknown-'));
    try {
      const lockPath = join(root, 'lock.json');
      writeFileSync(lockPath, JSON.stringify({ version: 1, targets: {} }));

      await expect(run(['--target', 'fixture', '--lock-file', lockPath])).rejects.toThrow('Unknown reference target');
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
});

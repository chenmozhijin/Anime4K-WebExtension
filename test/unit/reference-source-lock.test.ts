import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

type LockedFile = {
  path: string;
  sha256: string;
};

type ReferenceTarget = {
  component: string;
  license: string;
  sourceUrl: string;
  archiveUrl: string;
  commit: string;
  referenceRoot: string;
  includedFiles: LockedFile[];
  excludedPaths: string[];
};

type ReferenceLock = {
  version: number;
  targets: Record<string, ReferenceTarget>;
};

const readProjectFile = (path: string): string => readFileSync(resolve(process.cwd(), path), 'utf8');
const lock = JSON.parse(readProjectFile('scripts/reference-source-lock.json')) as ReferenceLock;

describe('reference source lock', () => {
  it('defines every restorable reference target with pinned source metadata', () => {
    expect(Object.keys(lock.targets).sort()).toEqual(['acnet', 'anime4k', 'artcnn', 'cunny']);

    for (const [targetId, target] of Object.entries(lock.targets)) {
      expect(target.component, targetId).toBeTruthy();
      expect(target.license, targetId).toMatch(/^(MIT|LGPL-3\.0-or-later)$/);
      expect(target.sourceUrl, targetId).toMatch(/^https:\/\/github\.com\//);
      expect(target.archiveUrl, targetId).toContain(target.commit);
      expect(target.commit, targetId).toMatch(/^[0-9a-f]{40}$/);
      expect(target.referenceRoot, targetId).toMatch(/^\.reference\//);
      expect(target.includedFiles.length, targetId).toBeGreaterThan(0);
      expect(target.excludedPaths.length, targetId).toBeGreaterThan(0);
    }
  });

  it('pins hashes for only locked files and avoids heavy source artifacts', () => {
    const disallowedPathParts = [
      '.git',
      '.github',
      'Images',
      'Inferencer',
      'Notebooks',
      'ONNX',
      'pretrained',
      'results',
      'Scripts',
      'tensorflow',
    ];

    for (const [targetId, target] of Object.entries(lock.targets)) {
      const seen = new Set<string>();
      const includedPaths = target.includedFiles.map(file => file.path);

      expect(includedPaths, `${targetId} should include the upstream license`).toContain('LICENSE');
      expect(includedPaths, `${targetId} should include the upstream README`).toContain('README.md');

      for (const file of target.includedFiles) {
        expect(file.path, targetId).not.toMatch(/(^|[\\/])\.\.($|[\\/])/);
        expect(file.path, targetId).not.toMatch(/^[a-z]+:|^[\\/]/i);
        expect(file.sha256, `${targetId}:${file.path}`).toMatch(/^[0-9a-f]{64}$/);
        expect(seen.has(file.path), `${targetId} has duplicate locked path ${file.path}`).toBe(false);
        seen.add(file.path);

        const segments = file.path.split(/[\\/]+/);
        for (const disallowed of disallowedPathParts) {
          expect(segments, `${targetId}:${file.path} should not include ${disallowed}`).not.toContain(disallowed);
        }
      }
    }
  });

  it('preserves CuNNy LGPL metadata and compatibility fetch command', () => {
    expect(lock.targets.cunny.component).toBe('CuNNy');
    expect(lock.targets.cunny.license).toBe('LGPL-3.0-or-later');
    expect(lock.targets.cunny.referenceRoot).toBe('.reference/CuNNy');

    const packageJson = readProjectFile('package.json');
    expect(packageJson).toContain('"fetch:references": "node scripts/fetch-reference-sources.js"');
    expect(packageJson).toContain('"fetch:cunny-reference": "node scripts/fetch-cunny-reference.js"');
  });

  it('keeps Anime4K-WebGPU as notice-only unless it gets a restorable lock target', () => {
    const notices = readProjectFile('THIRD_PARTY_NOTICES.md');

    expect(lock.targets['anime4k-webgpu']).toBeUndefined();
    expect(notices).toContain('Anime4K-WebGPU');
    expect(notices).toContain('not part of the current `fetch:references` v1 restore set');
  });
});

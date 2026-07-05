import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { cunnyGeneratedModelMetas } from '../../src/engines/cunny/generated/models';
import { cunnyGeneratedReferenceModelMetas } from '../../src/engines/cunny/generated/reference-models';

const sourceLock = JSON.parse(
  readFileSync(resolve(process.cwd(), 'scripts/reference-source-lock.json'), 'utf8'),
) as {
  targets: {
    cunny: {
      includedFiles: Array<{ path: string; sha256: string }>;
    };
  };
};

const cunnySourceLock = sourceLock.targets.cunny;
const cunnyLockedModelFiles = cunnySourceLock.includedFiles.filter(file => file.path.endsWith('.glsl'));

function countSourceStages(sourceFile: string): number {
  const source = readFileSync(resolve(process.cwd(), sourceFile), 'utf8');
  return (source.match(/^\/\/!DESC/gm) ?? []).length;
}

function sha256(sourceFile: string): string {
  return createHash('sha256')
    .update(readFileSync(resolve(process.cwd(), '.reference/CuNNy', sourceFile)))
    .digest('hex');
}

describe('CuNNy generated models', () => {
  it('contains the locked v1 non-dp4a mpv model set', () => {
    expect(cunnyGeneratedModelMetas).toHaveLength(18);
    expect(cunnyGeneratedReferenceModelMetas).toHaveLength(18);
    expect(cunnyLockedModelFiles).toHaveLength(18);
    expect(cunnySourceLock.includedFiles.map(file => file.path)).toEqual(expect.arrayContaining(['LICENSE', 'README.md']));
    expect(cunnyGeneratedReferenceModelMetas.every(model => !model.sourceFile.includes('/dp4a/'))).toBe(true);
    expect(cunnyGeneratedReferenceModelMetas.every(model => !model.sourceFile.endsWith('-Q.glsl'))).toBe(true);
    expect(readFileSync(resolve(process.cwd(), 'src/engines/cunny/generated/models.ts'), 'utf8'))
      .not.toContain('.reference/CuNNy');
  });

  it('matches source lock hashes', () => {
    for (const file of cunnySourceLock.includedFiles) {
      expect(sha256(file.path), file.path).toBe(file.sha256);
    }
  });

  it('matches stage counts from every referenced GLSL model', () => {
    for (const model of cunnyGeneratedReferenceModelMetas) {
      expect(model.stageCount, model.id).toBe(countSourceStages(model.sourceFile));
      expect(existsSync(resolve(process.cwd(), 'src/engines/cunny/generated', model.directory, 'index.ts'))).toBe(true);
    }
  });

  it('emits one WGSL shader per parsed stage with LGPL SPDX headers', () => {
    for (const model of cunnyGeneratedModelMetas) {
      const shaderDir = resolve(process.cwd(), 'src/engines/cunny/generated', model.directory, 'shaders');
      const shaders = readdirSync(shaderDir).filter(file => file.endsWith('.wgsl'));
      expect(shaders).toHaveLength(model.stageCount);
      for (const shader of shaders) {
        const source = readFileSync(resolve(shaderDir, shader), 'utf8');
        expect(source.startsWith('// SPDX-License-Identifier: LGPL-3.0-or-later')).toBe(true);
      }
    }
  });

  it('marks generated manifest and loaders as LGPL components', () => {
    expect(readFileSync(resolve(process.cwd(), 'src/engines/cunny/generated/models.ts'), 'utf8'))
      .toContain('SPDX-License-Identifier: LGPL-3.0-or-later');
    expect(readFileSync(resolve(process.cwd(), 'src/engines/cunny/generated/loaders.ts'), 'utf8'))
      .toContain('SPDX-License-Identifier: LGPL-3.0-or-later');
  });

  it('generates representative input, packed, and final shuffle shader structures', () => {
    const inputStage = readFileSync(
      resolve(process.cwd(), 'src/engines/cunny/generated/fast_ds/shaders/stage0.wgsl'),
      'utf8',
    );
    const packedStage = readFileSync(
      resolve(process.cwd(), 'src/engines/cunny/generated/fast_ds/shaders/stage1.wgsl'),
      'utf8',
    );
    const finalStage = readFileSync(
      resolve(process.cwd(), 'src/engines/cunny/generated/fast_ds/shaders/stage3.wgsl'),
      'utf8',
    );

    expect(inputStage).toContain('fn sample_LUMA_f32');
    expect(packedStage).toContain('fn sample_in_vec4');
    expect(finalStage).toContain('fn sample_original_luma');
    expect(finalStage).toContain('textureStore(out_tex, outBase + vec2i(1, 1)');
  });
});

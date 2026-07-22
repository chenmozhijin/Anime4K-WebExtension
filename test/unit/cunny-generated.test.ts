import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { cunnyGeneratedModelMetas } from '../../src/engines/cunny/generated/models';
import { cunnyGeneratedReferenceModelMetas } from '../../src/engines/cunny/generated/reference-models';
import { createCuNNyWorkgroupTileVariant } from '../../src/core/generated-models/workgroup-tile-variant';

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
      expect(shaders.filter(file => /^stage\d+\.wgsl$/.test(file))).toHaveLength(model.stageCount);
      expect(shaders.filter(file => /\.tiled\.wgsl$/.test(file))).toHaveLength(model.stageCount);
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

  it('reconstructs every scalar and packed tiled shader without duplicate bundle sources', () => {
    for (const model of cunnyGeneratedModelMetas) {
      const shaderDir = resolve(process.cwd(), 'src/engines/cunny/generated', model.directory, 'shaders');
      const tiledShaders = readdirSync(shaderDir).filter(file => /^stage\d+\.tiled\.wgsl$/.test(file));
      for (const tiledShader of tiledShaders) {
        const baselineName = tiledShader.replace('.tiled.wgsl', '.wgsl');
        const baseline = readFileSync(resolve(shaderDir, baselineName), 'utf8');
        const expected = readFileSync(resolve(shaderDir, tiledShader), 'utf8');
        expect(createCuNNyWorkgroupTileVariant(baseline), `${model.id}/${tiledShader}`).toBe(expected);
      }
    }
  });
});

import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { acnetGeneratedModelMetas } from '../../src/engines/acnet/generated/models';
import { acnetGeneratedReferenceModelMetas } from '../../src/engines/acnet/generated/reference-models';
import { createACNetWorkgroupTileVariant } from '../../src/core/generated-models/workgroup-tile-variant';

function countSourceStages(sourceFile: string): number {
  const source = readFileSync(resolve(process.cwd(), sourceFile), 'utf8');
  return (source.match(/^\/\/!DESC/gm) ?? []).length;
}

describe('ACNetGLSL generated models', () => {
  it('contains every referenced GLSL model with matching stage counts', () => {
    expect(acnetGeneratedModelMetas).toHaveLength(33);
    expect(acnetGeneratedReferenceModelMetas).toHaveLength(33);

    acnetGeneratedReferenceModelMetas.forEach(model => {
      expect(model.stageCount).toBe(countSourceStages(model.sourceFile));
      expect(existsSync(resolve(process.cwd(), 'src/engines/acnet/generated', model.directory, 'index.ts'))).toBe(true);
    });
  });

  it('keeps reference GLSL paths out of production metadata', () => {
    const modelSource = readFileSync(resolve(process.cwd(), 'src/engines/acnet/generated/models.ts'), 'utf8');
    expect(modelSource).not.toContain('.reference/ACNetGLSL');
    expect(modelSource).not.toContain('sourceFile');
  });

  it('emits one WGSL shader per parsed stage', () => {
    acnetGeneratedModelMetas.forEach(model => {
      const shaderDir = resolve(process.cwd(), 'src/engines/acnet/generated', model.directory, 'shaders');
      const shaders = readdirSync(shaderDir).filter(file => file.endsWith('.wgsl'));
      expect(shaders.filter(file => /^stage\d+\.wgsl$/.test(file))).toHaveLength(model.stageCount);
    });
  });

  it('keeps reference GLSL paths out of lazy-loaded runtime configs', () => {
    acnetGeneratedModelMetas.forEach(model => {
      const configSource = readFileSync(
        resolve(process.cwd(), 'src/engines/acnet/generated', model.directory, 'index.ts'),
        'utf8',
      );
      expect(configSource, model.id).not.toContain('.reference/ACNetGLSL');
      expect(configSource, model.id).not.toContain('sourceFile');
    });
  });

  it('generates representative output shaders for ACNet, Legacy, and ARNet', () => {
    const acnetPixelShuffle = readFileSync(
      resolve(process.cwd(), 'src/engines/acnet/generated/acnet_f8b4/shaders/stage11.vectorized.wgsl'),
      'utf8',
    );
    const legacyDeconv = readFileSync(
      resolve(process.cwd(), 'src/engines/acnet/generated/acnet_legacy_gan/shaders/stage18.wgsl'),
      'utf8',
    );
    const arnetPixelShuffle = readFileSync(
      resolve(process.cwd(), 'src/engines/acnet/generated/arnet_f8b8/shaders/stage37.wgsl'),
      'utf8',
    );

    expect(acnetPixelShuffle).toContain('let values = textureLoad');
    expect(acnetPixelShuffle.match(/textureStore\(out_tex/g)).toHaveLength(4);
    expect(legacyDeconv).toContain('result += dot(vec4f(');
    expect(arnetPixelShuffle).toContain('textureLoad(tex_TMP2_TEX_0');
  });

  it('reconstructs every tiled shader without bundling duplicate weight constants', () => {
    for (const model of acnetGeneratedModelMetas) {
      const shaderDir = resolve(process.cwd(), 'src/engines/acnet/generated', model.directory, 'shaders');
      const tiledShaders = readdirSync(shaderDir).filter(file => /^stage\d+\.tiled\.wgsl$/.test(file));
      for (const tiledShader of tiledShaders) {
        const baselineName = tiledShader.replace('.tiled.wgsl', '.wgsl');
        const baseline = readFileSync(resolve(shaderDir, baselineName), 'utf8');
        const expected = readFileSync(resolve(shaderDir, tiledShader), 'utf8');
        expect(createACNetWorkgroupTileVariant(baseline), `${model.id}/${tiledShader}`).toBe(expected);
      }
    }
  });
});

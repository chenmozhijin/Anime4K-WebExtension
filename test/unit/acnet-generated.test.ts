import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { acnetGeneratedModelMetas } from '../../src/engines/acnet/generated/models';
import { acnetGeneratedReferenceModelMetas } from '../../src/engines/acnet/generated/reference-models';

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
      const shaderCount = readdirSync(shaderDir).filter(file => file.endsWith('.wgsl')).length;
      expect(shaderCount).toBe(model.stageCount);
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
      resolve(process.cwd(), 'src/engines/acnet/generated/acnet_f8b4/shaders/stage11.wgsl'),
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

    expect(acnetPixelShuffle).toContain('let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);');
    expect(legacyDeconv).toContain('result += dot(vec4f(');
    expect(arnetPixelShuffle).toContain('textureLoad(tex_TMP2_TEX_0');
  });
});

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const readProjectFile = (path: string): string => readFileSync(resolve(process.cwd(), path), 'utf8');

const readmeFiles = [
  'README.md',
  'README.en.md',
  'README.ja.md',
  'README.ru.md',
];

describe('documentation consistency', () => {
  it('documents current source build output directories in every README', () => {
    for (const file of readmeFiles) {
      const content = readProjectFile(file);

      expect(content, `${file} should mention Chrome/Edge output`).toContain('dist-chrome');
      expect(content, `${file} should mention Firefox output`).toContain('dist-firefox/manifest.json');
      expect(content, `${file} should not tell source builders to load dist`).not.toMatch(/`dist`\s+(?:目录|directory|ディレクトリ|папк)/i);
    }
  });

  it('keeps advanced custom effect wording in sync across READMEs', () => {
    for (const file of readmeFiles) {
      const content = readProjectFile(file);

      expect(content, `${file} should mention ArtCNN`).toContain('ArtCNN');
      expect(content, `${file} should mention ACNet`).toContain('ACNet');
      expect(content, `${file} should mention CuNNy`).toContain('CuNNy');
    }
  });


  it('keeps verify docs pointed at the unified reference restore workflow', () => {
    const readme = readProjectFile('scripts/verify/README.md');
    const baseline = readProjectFile('scripts/verify/BASELINE.md');

    for (const content of [readme, baseline]) {
      expect(content).toContain('npm run fetch:references -- --all --check');
      expect(content).toContain('scripts/reference-source-lock.json');
    }
    expect(readme).toContain('npm run fetch:references -- --all');
    expect(readme).toContain('fetch:cunny-reference');
  });
});

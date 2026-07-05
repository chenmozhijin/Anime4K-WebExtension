import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

describe('third-party notice packaging', () => {
  it('keeps complete reference notices and CuNNy corresponding-source instructions', () => {
    expect(readFileSync(resolve(process.cwd(), 'package.json'), 'utf8')).toContain('MIT AND LGPL-3.0-or-later');
    expect(existsSync(resolve(process.cwd(), 'licenses/LGPL-3.0-or-later.txt'))).toBe(true);
    const notices = readFileSync(resolve(process.cwd(), 'THIRD_PARTY_NOTICES.md'), 'utf8');

    for (const component of ['Anime4K', 'Anime4K-WebGPU', 'ArtCNN', 'ACNetGLSL', 'CuNNy']) {
      expect(notices).toContain(component);
    }

    expect(notices).toContain('scripts/reference-source-lock.json');
    expect(notices).toContain('Corresponding Source');
    expect(notices).toContain('fetch:references -- --target cunny');
    expect(notices).toContain('fetch:cunny-reference');
    expect(notices).toContain('generate:cunny');
    expect(notices).not.toMatch(/SOURCE[_-]OFFER\.md/);
  });

  it('copies mixed-license notices into production bundles', () => {
    const webpackConfig = readFileSync(resolve(process.cwd(), 'webpack.config.js'), 'utf8');
    expect(webpackConfig).toContain("from: 'LICENSE'");
    expect(webpackConfig).toContain("from: 'licenses'");
    expect(webpackConfig).toContain("from: 'THIRD_PARTY_NOTICES.md'");
    expect(webpackConfig).not.toMatch(/SOURCE[_-]OFFER\.md/);
  });
});

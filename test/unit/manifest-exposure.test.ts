import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const require = createRequire(import.meta.url);
const {
  expectedManifestExposure,
  validateManifestExposure,
} = require('../../scripts/check-production-bundle');

describe('manifest exposure audit', () => {
  it('keeps the source manifest aligned with the documented broad-permission model', () => {
    const manifest = JSON.parse(readFileSync(resolve(process.cwd(), 'manifest.json'), 'utf8'));

    expect(validateManifestExposure(manifest)).toEqual([]);
    expect(expectedManifestExposure.webAccessibleResources).toEqual(['*.js']);
    expect(manifest.declarative_net_request.rule_resources[0]).toMatchObject({
      id: 'ruleset_1',
      enabled: false,
      path: 'rules.json',
    });
  });

  it('reports accidental broadening of web accessible resources or default DNR enablement', () => {
    const manifest = JSON.parse(readFileSync(resolve(process.cwd(), 'manifest.json'), 'utf8'));
    manifest.web_accessible_resources[0].resources.push('*.html');
    manifest.declarative_net_request.rule_resources[0].enabled = true;

    expect(validateManifestExposure(manifest)).toEqual([
      { file: 'manifest.json', token: 'unexpected web_accessible_resources resources' },
      { file: 'manifest.json', token: 'DNR ruleset must be disabled by default' },
    ]);
  });
});

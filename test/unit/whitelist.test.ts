import { beforeEach, describe, expect, it } from 'vitest';
import { installChromeMock } from '../support/chrome';
import {
  addWhitelistRule,
  compileWhitelistRules,
  dedupeWhitelistRules,
  getWhitelistRules,
  isUrlWhitelisted,
  normalizeWhitelistPattern,
  removeWhitelistRule,
  setDefaultWhitelist,
  updateWhitelistRule,
  validateRulePattern,
} from '../../src/utils/whitelist';

describe('whitelist utilities', () => {
  beforeEach(() => {
    installChromeMock({
      sync: {
        whitelist: [],
        whitelistEnabled: false,
        customModes: [],
        selectedModeId: 'builtin-mode-a',
        targetResolutionSetting: 'x2',
        enableCrossOriginFix: false,
      },
      local: {
        performanceTier: 'balanced',
        gpuBenchmarkResult: null,
        hasCompletedOnboarding: false,
      },
    });
  });

  it('normalizes and validates rule patterns', () => {
    expect(normalizeWhitelistPattern('  example.com/*  ')).toBe('example.com/*');
    expect(validateRulePattern('example.com/*')).toBe(true);
    expect(validateRulePattern('   ')).toBe(false);
  });

  it('dedupes and compiles wildcard rules', () => {
    const rules = compileWhitelistRules(dedupeWhitelistRules([
      { pattern: 'example.com/*', enabled: true },
      { pattern: ' example.com/* ', enabled: false },
      { pattern: 'sub.example.com/watch/*', enabled: true },
    ]));

    expect(rules).toHaveLength(2);
    expect(isUrlWhitelisted('https://example.com/watch/1', rules)).toBe(false);
    expect(isUrlWhitelisted('https://sub.example.com/watch/1', rules)).toBe(true);
  });

  it('matches whitelist rules against hostname and pathname only', () => {
    const rules = compileWhitelistRules([{ pattern: 'example.com/watch/*', enabled: true }]);

    expect(isUrlWhitelisted('http://example.com:8080/watch/1?episode=2', rules)).toBe(true);
    expect(isUrlWhitelisted('https://example.com:443/watch/1#comments', rules)).toBe(true);
    expect(isUrlWhitelisted('https://example.com:443/watch', rules)).toBe(false);
    expect(isUrlWhitelisted('https://example.com:443/other/1?path=/watch/1', rules)).toBe(false);
  });

  it('returns false for invalid URLs', () => {
    const rules = compileWhitelistRules([{ pattern: 'example.com/*', enabled: true }]);
    expect(isUrlWhitelisted('not-a-url', rules)).toBe(false);
  });

  it('adds, updates and removes persisted whitelist rules', async () => {
    await addWhitelistRule('example.com/*');
    await addWhitelistRule(' example.com/* ', false);
    await updateWhitelistRule('example.com/*', false);
    await updateWhitelistRule('example.com/*', 'sub.example.com/*');

    let rules = await getWhitelistRules();
    expect(rules).toEqual([{ pattern: 'sub.example.com/*', enabled: false }]);

    await removeWhitelistRule('sub.example.com/*');
    rules = await getWhitelistRules();
    expect(rules).toEqual([]);
  });

  it('updates enabled when adding a duplicate persisted whitelist rule', async () => {
    await addWhitelistRule('example.com/*', false);
    await addWhitelistRule('example.com/*', true);

    expect(await getWhitelistRules()).toEqual([{ pattern: 'example.com/*', enabled: true }]);
  });

  it('applies the default whitelist preset', async () => {
    await setDefaultWhitelist();
    const rules = await getWhitelistRules();

    expect(rules).toHaveLength(2);
    expect(rules[0].pattern).toContain('ani.gamer.com.tw');
  });
});

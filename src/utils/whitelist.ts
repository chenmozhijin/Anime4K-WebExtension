/**
 * 白名单管理模块
 * 提供白名单规则匹配、验证和持久化功能
 */
import { getSettings, saveSettings } from './settings';
import { createLogger } from './logger';

export interface WhitelistRule {
  pattern: string;
  enabled: boolean;
}

export interface CompiledWhitelistRule extends WhitelistRule {
  normalizedPattern: string;
  regex: RegExp;
}

const REGEX_ESCAPE_PATTERN = /[|\\{}()[\]^$+?.]/g;
const WILDCARD_PLACEHOLDER = '__ANIME4K_WILDCARD__';
const logger = createLogger('whitelist');

export function normalizeWhitelistPattern(pattern: string): string {
  return pattern.trim();
}

function compilePattern(pattern: string): RegExp {
  const wildcardSafePattern = pattern.replace(/\*/g, WILDCARD_PLACEHOLDER);
  const escapedPattern = wildcardSafePattern.replace(REGEX_ESCAPE_PATTERN, '\\$&');
  const regexPattern = escapedPattern.replace(new RegExp(WILDCARD_PLACEHOLDER, 'g'), '.*');
  return new RegExp(`^${regexPattern}$`, 'i');
}

function getUrlMatchTarget(url: string): string {
  const parsedUrl = new URL(url);
  return parsedUrl.hostname + parsedUrl.pathname;
}

function isCompiledWhitelistRule(rule: WhitelistRule | CompiledWhitelistRule): rule is CompiledWhitelistRule {
  return 'regex' in rule;
}

export function validateRulePattern(pattern: string): boolean {
  try {
    return normalizeWhitelistPattern(pattern).length > 0;
  } catch {
    return false;
  }
}

export function dedupeWhitelistRules(rules: WhitelistRule[]): WhitelistRule[] {
  const dedupedRules = new Map<string, WhitelistRule>();

  rules.forEach(rule => {
    const normalizedPattern = normalizeWhitelistPattern(rule.pattern);
    if (!normalizedPattern) {
      return;
    }

    dedupedRules.set(normalizedPattern, {
      pattern: normalizedPattern,
      enabled: rule.enabled,
    });
  });

  return Array.from(dedupedRules.values());
}

function areWhitelistRulesEqual(left: WhitelistRule[], right: WhitelistRule[]): boolean {
  if (left.length !== right.length) {
    return false;
  }

  return left.every((leftRule, index) => {
    const rightRule = right[index];
    return rightRule !== undefined
      && normalizeWhitelistPattern(leftRule.pattern) === normalizeWhitelistPattern(rightRule.pattern)
      && leftRule.enabled === rightRule.enabled;
  });
}

export function compileWhitelistRules(rules: WhitelistRule[]): CompiledWhitelistRule[] {
  return dedupeWhitelistRules(rules)
    .filter(rule => validateRulePattern(rule.pattern))
    .map(rule => {
      const normalizedPattern = normalizeWhitelistPattern(rule.pattern);
      return {
        ...rule,
        pattern: normalizedPattern,
        normalizedPattern,
        regex: compilePattern(normalizedPattern),
      };
    });
}

export function isUrlWhitelisted(
  url: string,
  rules: ReadonlyArray<WhitelistRule | CompiledWhitelistRule>,
): boolean {
  if (rules.length === 0) {
    return false;
  }

  try {
    const baseUrl = getUrlMatchTarget(url);

    return rules.some(rule => {
      if (!rule.enabled) {
        return false;
      }

      const compiledRule = isCompiledWhitelistRule(rule)
        ? rule
        : {
          ...rule,
          normalizedPattern: normalizeWhitelistPattern(rule.pattern),
          regex: compilePattern(normalizeWhitelistPattern(rule.pattern)),
        };

      return compiledRule.regex.test(baseUrl);
    });
  } catch (error) {
    logger.error('URL match failed.', error);
    return false;
  }
}

export async function addWhitelistRule(pattern: string, enabled: boolean = true): Promise<void> {
  const normalizedPattern = normalizeWhitelistPattern(pattern);
  if (!validateRulePattern(normalizedPattern)) {
    return;
  }

  const { whitelist } = await getSettings();
  const existingWhitelist = dedupeWhitelistRules(whitelist || []);
  const nextWhitelist = existingWhitelist.map(rule => ({ ...rule }));
  const existingIndex = nextWhitelist.findIndex(rule => normalizeWhitelistPattern(rule.pattern) === normalizedPattern);

  if (existingIndex === -1) {
    nextWhitelist.push({ pattern: normalizedPattern, enabled });
  } else {
    nextWhitelist[existingIndex] = {
      pattern: normalizedPattern,
      enabled,
    };
  }

  if (!areWhitelistRulesEqual(existingWhitelist, nextWhitelist)) {
    await saveSettings({ whitelist: nextWhitelist });
  }
}

export async function removeWhitelistRule(pattern: string): Promise<void> {
  const { whitelist } = await getSettings();
  const normalizedPattern = normalizeWhitelistPattern(pattern);

  if (whitelist) {
    const nextWhitelist = whitelist.filter(rule => normalizeWhitelistPattern(rule.pattern) !== normalizedPattern);
    await saveSettings({ whitelist: dedupeWhitelistRules(nextWhitelist) });
  }
}

export async function updateWhitelistRule(oldPattern: string, update: boolean | string): Promise<void> {
  const { whitelist } = await getSettings();
  const normalizedOldPattern = normalizeWhitelistPattern(oldPattern);

  if (!whitelist) {
    return;
  }

  const nextWhitelist = whitelist.map(rule => ({
    ...rule,
    pattern: normalizeWhitelistPattern(rule.pattern),
  }));

  const ruleIndex = nextWhitelist.findIndex(rule => rule.pattern === normalizedOldPattern);
  if (ruleIndex === -1) {
    return;
  }

  if (typeof update === 'boolean') {
    nextWhitelist[ruleIndex].enabled = update;
  } else {
    const normalizedUpdate = normalizeWhitelistPattern(update);
    if (!validateRulePattern(normalizedUpdate)) {
      return;
    }
    nextWhitelist[ruleIndex].pattern = normalizedUpdate;
  }

  await saveSettings({ whitelist: dedupeWhitelistRules(nextWhitelist) });
}

export async function getWhitelistRules(): Promise<WhitelistRule[]> {
  const settings = await getSettings();
  return dedupeWhitelistRules(settings.whitelist || []);
}

export async function setDefaultWhitelist(): Promise<void> {
  const defaultRules = [
    { pattern: 'ani.gamer.com.tw/animeVideo.php', enabled: true },
    { pattern: 'www.bilibili.com/bangumi/play/*', enabled: true },
  ];

  await saveSettings({
    whitelist: dedupeWhitelistRules(defaultRules),
    whitelistEnabled: false,
  });
}

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const htmlFiles = [
  'src/ui/options/options.html',
  'src/ui/popup/popup.html',
  'src/ui/onboarding/onboarding.html',
];

const localeFiles = [
  'public/_locales/en/messages.json',
  'public/_locales/ja/messages.json',
  'public/_locales/ru/messages.json',
  'public/_locales/zh_CN/messages.json',
  'public/_locales/zh_TW/messages.json',
];

function readProjectFile(path: string): string {
  return readFileSync(resolve(process.cwd(), path), 'utf8');
}

function collectI18nKeys(html: string): string[] {
  const keys = new Set<string>();
  const pattern = /\bdata-i18n(?:-title)?="([^"]+)"/g;
  for (const match of html.matchAll(pattern)) {
    keys.add(match[1]);
  }
  return [...keys].sort();
}

describe('locale and design token hygiene', () => {
  it('defines every HTML data-i18n key in every locale', () => {
    const htmlKeys = new Set<string>();
    htmlFiles.forEach(file => {
      collectI18nKeys(readProjectFile(file)).forEach(key => htmlKeys.add(key));
    });

    localeFiles.forEach(file => {
      const messages = JSON.parse(readProjectFile(file)) as Record<string, unknown>;
      const missingKeys = [...htmlKeys].filter(key => !(key in messages));
      expect(missingKeys, `${file} missing locale keys`).toEqual([]);
    });
  });

  it('defines design tokens used by onboarding styles', () => {
    const commonVars = readProjectFile('src/ui/common-vars.css');
    const onboardingCss = readProjectFile('src/ui/onboarding/onboarding.css');

    expect(onboardingCss).toContain('var(--border-radius-md)');
    expect(commonVars).toContain('--border-radius-md:');
  });
});

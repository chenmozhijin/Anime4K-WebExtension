import { readdirSync, readFileSync, statSync } from 'node:fs';
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

type LocaleEntry = {
  message?: string;
  placeholders?: Record<string, unknown>;
};

type LocaleMessages = Record<string, LocaleEntry>;

function readProjectFile(path: string): string {
  return readFileSync(resolve(process.cwd(), path), 'utf8');
}

function readLocaleFile(path: string): LocaleMessages {
  return JSON.parse(readProjectFile(path)) as LocaleMessages;
}

function walkProjectFiles(path: string, extensions: Set<string>, files: string[] = []): string[] {
  const absolutePath = resolve(process.cwd(), path);
  readdirSync(absolutePath).forEach(entry => {
    const relativePath = `${path}/${entry}`.replaceAll('\\', '/');
    const entryPath = resolve(process.cwd(), relativePath);
    const stat = statSync(entryPath);
    if (stat.isDirectory()) {
      walkProjectFiles(relativePath, extensions, files);
      return;
    }

    if (extensions.has(entry.slice(entry.lastIndexOf('.')))) {
      files.push(relativePath);
    }
  });
  return files;
}

function collectI18nKeys(html: string): string[] {
  const keys = new Set<string>();
  const pattern = /\bdata-i18n(?:-title|-aria-label)?="([^"]+)"/g;
  for (const match of html.matchAll(pattern)) {
    keys.add(match[1]);
  }
  return [...keys].sort();
}

function collectStaticI18nKeys(): string[] {
  const keys = new Set<string>();
  const addKey = (key: string) => {
    if (key !== '@@ui_locale') {
      keys.add(key);
    }
  };

  htmlFiles.forEach(file => {
    collectI18nKeys(readProjectFile(file)).forEach(addKey);
  });

  for (const match of readProjectFile('manifest.json').matchAll(/__MSG_([A-Za-z0-9_@.-]+)__/g)) {
    addKey(match[1]);
  }

  walkProjectFiles('src', new Set(['.ts', '.js'])).forEach(file => {
    const source = readProjectFile(file);
    for (const match of source.matchAll(/(?:chrome\.i18n\.)?getMessage\(\s*['"]([A-Za-z0-9_@.-]+)['"]/g)) {
      addKey(match[1]);
    }
    for (const match of source.matchAll(/\bhudMessage\(\s*['"]([A-Za-z0-9_@.-]+)['"]/g)) {
      addKey(match[1]);
    }
  });

  return [...keys].sort();
}

function collectPlaceholderTokens(message: string): string[] {
  return [...message.matchAll(/\$([A-Za-z0-9_]+)\$/g)].map(match => match[1].toLowerCase()).sort();
}

describe('locale and design token hygiene', () => {
  it('keeps every locale key set in sync', () => {
    const [baseFile, ...otherFiles] = localeFiles;
    const baseMessages = readLocaleFile(baseFile);
    const baseKeys = Object.keys(baseMessages).sort();

    otherFiles.forEach(file => {
      const messages = readLocaleFile(file);
      const localeKeys = Object.keys(messages).sort();
      const missingKeys = baseKeys.filter(key => !(key in messages));
      const extraKeys = localeKeys.filter(key => !(key in baseMessages));
      expect({ missingKeys, extraKeys }, `${file} key drift from ${baseFile}`).toEqual({
        missingKeys: [],
        extraKeys: [],
      });
    });
  });

  it('defines every HTML data-i18n key in every locale', () => {
    const htmlKeys = new Set<string>();
    htmlFiles.forEach(file => {
      collectI18nKeys(readProjectFile(file)).forEach(key => htmlKeys.add(key));
    });

    localeFiles.forEach(file => {
      const messages = readLocaleFile(file);
      const missingKeys = [...htmlKeys].filter(key => !(key in messages));
      expect(missingKeys, `${file} missing locale keys`).toEqual([]);
    });
  });

  it('defines every statically referenced i18n key in every locale', () => {
    const usedKeys = collectStaticI18nKeys();

    localeFiles.forEach(file => {
      const messages = readLocaleFile(file);
      const missingKeys = usedKeys.filter(key => !(key in messages));
      expect(missingKeys, `${file} missing statically referenced locale keys`).toEqual([]);
    });
  });

  it('keeps locale placeholder declarations aligned with message tokens', () => {
    localeFiles.forEach(file => {
      const messages = readLocaleFile(file);
      const mismatches = Object.entries(messages).flatMap(([key, entry]) => {
        const tokens = collectPlaceholderTokens(entry.message ?? '');
        const placeholders = Object.keys(entry.placeholders ?? {}).map(name => name.toLowerCase()).sort();
        const missingDeclarations = tokens.filter(token => !placeholders.includes(token));
        const unusedDeclarations = placeholders.filter(placeholder => !tokens.includes(placeholder));
        return missingDeclarations.length > 0 || unusedDeclarations.length > 0
          ? [{ key, missingDeclarations, unusedDeclarations }]
          : [];
      });

      expect(mismatches, `${file} placeholder mismatches`).toEqual([]);
    });
  });

  it('reports locale keys that are not statically referenced', () => {
    const usedKeys = new Set(collectStaticI18nKeys());
    const messages = readLocaleFile(localeFiles[0]);
    const unusedKeys = Object.keys(messages).filter(key => !usedKeys.has(key)).sort();

    if (unusedKeys.length > 0) {
      console.warn(`Locale keys not found by static scan: ${unusedKeys.join(', ')}`);
    }
  });

  it('defines design tokens used by onboarding styles', () => {
    const commonVars = readProjectFile('src/ui/common-vars.css');
    const onboardingCss = readProjectFile('src/ui/onboarding/onboarding.css');

    expect(onboardingCss).toContain('var(--border-radius-md)');
    expect(commonVars).toContain('--border-radius-md:');
  });
});

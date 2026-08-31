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

type LocaleCopyExpectation = {
  description: string;
  extensionDescription: string;
  nativeResolution: string;
  performanceMonitor: string;
  performanceMonitorDesc: string;
  setupCompleteDesc: string;
  tip1: string;
  monitorModes: readonly [string, string, string];
  benchmarkMessages: readonly [string, string, string];
};

const localeCopyExpectations: Record<string, LocaleCopyExpectation> = {
  'public/_locales/en/messages.json': {
    description: 'NijiLucid is a WebGPU-powered browser extension for real-time anime video super-resolution.',
    extensionDescription: 'NijiLucid is a WebGPU-powered browser extension that enhances anime video quality in real time.',
    nativeResolution: 'Native Resolution (No Upscaling)',
    performanceMonitor: 'Performance Monitor',
    performanceMonitorDesc: 'Show performance information on the video. Lite shows overall frame performance; GPU Diagnostics shows per-effect GPU time when supported.',
    setupCompleteDesc: 'You\'re all set! Hover over the left-center area of the video player, then click the purple "✨ Enhance" button to turn super-resolution on or off.',
    tip1: 'Hover over the left-center area of the video player and click the purple "✨ Enhance" button to turn super-resolution on or off',
    monitorModes: ['Off', 'Lite', 'GPU Diagnostics'],
    benchmarkMessages: [
      'The previous benchmark did not complete. You can run it again manually.',
      'The previous benchmark was interrupted. Performance tier was reset to $tier$.',
      'Benchmark finished. Recommended tier: $tier$.',
    ],
  },
  'public/_locales/ja/messages.json': {
    description: 'NijiLucid は WebGPU を活用した、アニメ動画向けリアルタイム超解像ブラウザ拡張機能です。',
    extensionDescription: 'NijiLucid は、WebGPU を活用してアニメ動画の画質をリアルタイムで高めるブラウザ拡張機能です。',
    nativeResolution: 'オリジナル解像度 (拡大なし)',
    performanceMonitor: 'パフォーマンスモニター',
    performanceMonitorDesc: '動画上にパフォーマンス情報を表示します。軽量は全体のフレーム性能を表示し、GPU 診断は対応時に各エフェクトの GPU 処理時間を表示します。',
    setupCompleteDesc: '準備完了です！動画ページで動画プレーヤーの左側中央付近にマウスを合わせ、紫色の「✨ 超解像」ボタンをクリックすると、超解像をオン/オフできます。',
    tip1: '動画プレーヤーの左側中央付近にマウスを合わせ、紫色の「✨ 超解像」ボタンをクリックすると、超解像をオン/オフできます。',
    monitorModes: ['オフ', '軽量', 'GPU 診断'],
    benchmarkMessages: [
      '前回の GPU ベンチマークは完了しませんでした。必要なら手動で再実行できます。',
      '前回の GPU ベンチマークは中断され、パフォーマンス階層は $tier$ に戻されました。',
      'GPU ベンチマークが完了しました。推奨階層: $tier$。',
    ],
  },
  'public/_locales/ru/messages.json': {
    description: 'NijiLucid — браузерное расширение на базе WebGPU для супер-разрешения аниме-видео в реальном времени.',
    extensionDescription: 'NijiLucid — браузерное расширение на базе WebGPU, которое в реальном времени повышает качество аниме-видео.',
    nativeResolution: 'Исходное разрешение (без масштабирования)',
    performanceMonitor: 'Монитор производительности',
    performanceMonitorDesc: 'Показывает информацию о производительности поверх видео. Облегчённый режим отображает общую производительность кадров, а Диагностика GPU — время работы GPU для каждого эффекта, если это поддерживается.',
    setupCompleteDesc: 'Все готово! На странице с видео наведите курсор на центральную часть левого края видеоплеера и нажмите фиолетовую кнопку «✨ Улучшить», чтобы включить или выключить улучшение.',
    tip1: 'Наведите курсор на центральную часть левого края видеоплеера и нажмите фиолетовую кнопку «✨ Улучшить», чтобы включить или выключить улучшение.',
    monitorModes: ['Выкл.', 'Облегчённый', 'Диагностика GPU'],
    benchmarkMessages: [
      'Предыдущий тест производительности GPU не был завершён. При необходимости его можно запустить снова вручную.',
      'Предыдущий тест производительности GPU был прерван; уровень производительности сброшен до $tier$.',
      'Тест производительности GPU завершён. Рекомендуемый уровень: $tier$.',
    ],
  },
  'public/_locales/zh_CN/messages.json': {
    description: 'NijiLucid 是一款基于 WebGPU 的实时动漫视频超分辨率浏览器扩展。',
    extensionDescription: 'NijiLucid 是一款基于 WebGPU、专注于实时提升动漫视频画质的浏览器扩展。',
    nativeResolution: '原始分辨率 (不放大)',
    performanceMonitor: '性能监视器',
    performanceMonitorDesc: '在视频上显示性能信息。轻量显示整体帧性能；GPU 诊断会在支持时显示各效果的 GPU 耗时。',
    setupCompleteDesc: '一切就绪！在视频页面中，将鼠标悬停在播放器左侧中部，点击紫色「✨ 超分」按钮即可开启或关闭超分。',
    tip1: '将鼠标悬停在视频播放器左侧中部，点击紫色「✨ 超分」按钮即可开启或关闭超分。',
    monitorModes: ['关闭', '轻量', 'GPU 诊断'],
    benchmarkMessages: [
      '上次 GPU 基准测试未完成，您可以手动重新运行。',
      '上次 GPU 基准测试被中断，性能档位已回退到 $tier$。',
      'GPU 基准测试已完成，推荐档位：$tier$。',
    ],
  },
  'public/_locales/zh_TW/messages.json': {
    description: 'NijiLucid 是一款基於 WebGPU 的即時動漫影片超解析瀏覽器擴充功能。',
    extensionDescription: 'NijiLucid 是一款基於 WebGPU、專注於即時提升動漫影片畫質的瀏覽器擴充功能。',
    nativeResolution: '原始解析度 (不放大)',
    performanceMonitor: '效能監視器',
    performanceMonitorDesc: '在影片上顯示效能資訊。輕量顯示整體影格效能；GPU 診斷會在支援時顯示各效果的 GPU 耗時。',
    setupCompleteDesc: '一切就緒！在影片頁面中，將滑鼠懸停在播放器左側中部，點擊紫色「✨ 超解析」按鈕即可開啟或關閉超解析。',
    tip1: '將滑鼠懸停在影片播放器左側中部，點擊紫色「✨ 超解析」按鈕即可開啟或關閉超解析。',
    monitorModes: ['關閉', '輕量', 'GPU 診斷'],
    benchmarkMessages: [
      '上次 GPU 基準測試未完成，您可以手動重新執行。',
      '上次 GPU 基準測試被中斷，效能檔位已回退到 $tier$。',
      'GPU 基準測試已完成，建議檔位：$tier$。',
    ],
  },
};

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

  it('keeps approved user-facing copy consistent across locales', () => {
    Object.entries(localeCopyExpectations).forEach(([file, expectation]) => {
      const messages = readLocaleFile(file);

      expect(messages.description.message, `${file} description`).toBe(expectation.description);
      expect(messages.extensionDescription.message, `${file} extension description`).toBe(expectation.extensionDescription);
      expect(messages.description.message, `${file} description should not name Anime4K as the product`).not.toContain('Anime4K');
      expect(messages.extensionDescription.message, `${file} about description should not name Anime4K as the product`).not.toContain('Anime4K');
      expect(messages.nativeResolution.message, `${file} Native label`).toBe(expectation.nativeResolution);
      expect(messages.performanceMonitor.message, `${file} monitor title`).toBe(expectation.performanceMonitor);
      expect(messages.performanceMonitorDesc.message, `${file} monitor description`).toBe(expectation.performanceMonitorDesc);
      expect(messages.setupCompleteDesc.message, `${file} setup completion instruction`).toBe(expectation.setupCompleteDesc);
      expect(messages.tip1.message, `${file} video control tip`).toBe(expectation.tip1);
      expect(messages.performanceMonitorOff.message, `${file} Off label`).toBe(expectation.monitorModes[0]);
      expect(messages.performanceMonitorLite.message, `${file} Lite label`).toBe(expectation.monitorModes[1]);
      expect(messages.performanceMonitorGpu.message, `${file} GPU Diagnostics label`).toBe(expectation.monitorModes[2]);
      expect(messages.benchmarkInterrupted.message, `${file} interrupted benchmark copy`).toBe(expectation.benchmarkMessages[0]);
      expect(messages.benchmarkFallbackApplied.message, `${file} fallback benchmark copy`).toBe(expectation.benchmarkMessages[1]);
      expect(messages.benchmarkApplyRecommendation.message, `${file} recommendation benchmark copy`).toBe(expectation.benchmarkMessages[2]);
    });

    const packageJson = JSON.parse(readProjectFile('package.json')) as { description: string };
    expect(packageJson.description).toBe('NijiLucid is a WebGPU-powered browser extension for real-time anime video super-resolution.');

    const optionsHtml = readProjectFile('src/ui/options/options.html');
    expect(optionsHtml).toContain(localeCopyExpectations['public/_locales/en/messages.json'].extensionDescription);
    expect(optionsHtml).toContain(localeCopyExpectations['public/_locales/en/messages.json'].performanceMonitorDesc);

    const onboardingHtml = readProjectFile('src/ui/onboarding/onboarding.html');
    expect(onboardingHtml).toContain('Hover over the left-center area of the video player');
    expect(onboardingHtml).toContain('"✨ Enhance" button to turn super-resolution on or off');
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

import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const readProjectFile = (path: string): string => readFileSync(resolve(process.cwd(), path), 'utf8');

const readmeFiles = [
  'README.md',
  'README.en.md',
  'README.ja.md',
  'README.ru.md',
];

const documentationExpectations = [
  {
    file: 'README.md',
    intro: 'NijiLucid 利用 WebGPU 实时提升动漫视频画质，逐帧呈现更清晰锐利的视觉体验！',
    tiers: '快速/均衡/质量/极致',
    modeTerms: ['内置模式', '推荐预设', '兼容模式', '自定义模式'],
    button: '「✨ 超分」',
    hover: '视频播放器左侧中部',
    resolution: '720p、1080p、2K (1440p)、4K (2160p)',
    native: 'Native 使用原始分辨率输出，不进行放大',
    crossOrigin: ['此模式会尝试修复跨域加载问题', '刷新已打开的页面'],
    staleWording: ['不参与自动推荐', '不会由 GPU 基准测试自动推荐'],
    absoluteCompatibility: '覆盖绝大多数视频网站',
  },
  {
    file: 'README.en.md',
    intro: 'NijiLucid uses WebGPU to enhance anime video quality in real time, delivering a clearer and sharper visual experience frame by frame!',
    tiers: 'Fast/Balanced/Quality/Ultra',
    modeTerms: ['Built-in Modes', 'Recommended Presets', 'Compatibility Modes', 'Custom Modes'],
    button: '"✨ Enhance"',
    hover: 'left-center area of the video player',
    resolution: '720p, 1080p, 2K (1440p), and 4K (2160p)',
    native: 'Native uses the original resolution without upscaling',
    crossOrigin: ['This mode attempts to fix cross-origin loading issues', 'refresh open pages'],
    staleWording: ['not used for automatic recommendations', 'does not recommend them through GPU Benchmark'],
    absoluteCompatibility: 'cover the vast majority of video websites',
  },
  {
    file: 'README.ja.md',
    intro: 'NijiLucid は WebGPU を利用してアニメ動画の画質をリアルタイムで高め、フレームごとにより鮮明でシャープな視聴体験を提供します！',
    tiers: '速い/バランス/品質/ウルトラ',
    modeTerms: ['内蔵モード', 'おすすめプリセット', '互換モード', 'カスタムモード'],
    button: '「✨ 超解像」',
    hover: '動画プレーヤーの左側中央付近',
    resolution: '720p、1080p、2K (1440p)、4K (2160p)',
    native: 'Native は元の解像度で出力し、拡大は行いません',
    crossOrigin: ['このモードはクロスオリジン読み込みの問題を修正しようとします', '開いているページを更新'],
    staleWording: ['自動推奨には使われず', '自動推奨や内蔵モードとしては提供されません'],
    absoluteCompatibility: '大多数の動画サイトをカバー',
  },
  {
    file: 'README.ru.md',
    intro: 'NijiLucid использует WebGPU для улучшения качества аниме-видео в реальном времени, обеспечивая более чёткое и резкое изображение кадр за кадром!',
    tiers: 'Быстро/Сбалансированно/Качество/Ультра',
    modeTerms: ['Встроенные режимы', 'Рекомендуемые пресеты', 'Режимы совместимости', 'Пользовательские режимы'],
    button: '«✨ Улучшить»',
    hover: 'центральную часть левого края видеоплеера',
    resolution: '720p, 1080p, 2K (1440p) или 4K (2160p)',
    native: 'Native использует исходное разрешение без масштабирования',
    crossOrigin: ['Этот режим пытается исправить проблемы с кросс-доменной загрузкой', 'обновите уже открытые страницы'],
    staleWording: ['не участвуют в автоматических рекомендациях', 'не рекомендует их через GPU Benchmark'],
    absoluteCompatibility: 'охватывая подавляющее большинство видеосайтов',
  },
] as const;

describe('documentation consistency', () => {
  it('documents current source build output directories in every README', () => {
    for (const file of readmeFiles) {
      const content = readProjectFile(file);

      expect(content, `${file} should mention Chrome/Edge output`).toContain('dist-chrome');
      expect(content, `${file} should mention Firefox output`).toContain('dist-firefox/manifest.json');
      expect(content, `${file} should document the Chrome/Edge build command`).toContain('npm run build:chrome');
      expect(content, `${file} should document the Firefox build command`).toContain('npm run build:firefox');
      expect(content, `${file} should document the Chrome/Edge package`).toContain('nijilucid.zip');
      expect(content, `${file} should document the Firefox package`).toContain('nijilucid-firefox.zip');
      expect(content, `${file} should not tell source builders to load dist`).not.toMatch(/`dist`\s+(?:目录|directory|ディレクトリ|папк)/i);
    }
  });

  it('keeps advanced custom effect wording in sync across READMEs', () => {
    for (const file of readmeFiles) {
      const content = readProjectFile(file);

      expect(content, `${file} should mention ArtCNN`).toContain('ArtCNN');
      expect(content, `${file} should mention ACNet`).toContain('ACNet');
      expect(content, `${file} should mention ARNet`).toContain('ARNet');
      expect(content, `${file} should mention CuNNy`).toContain('CuNNy');
    }
  });

  it('keeps user-facing copy aligned with the current product behavior', () => {
    for (const expectation of documentationExpectations) {
      const content = readProjectFile(expectation.file);
      const intro = content.split(/\r?\n/).find(line => line.startsWith('NijiLucid '));

      expect(intro, `${expectation.file} should use the approved product introduction`).toBe(expectation.intro);
      expect(intro, `${expectation.file} should not position Anime4K as the product`).not.toContain('Anime4K');
      expect(content, `${expectation.file} should document the four UI tier names`).toContain(expectation.tiers);
      expectation.modeTerms.forEach(term => {
        expect(content, `${expectation.file} should document ${term}`).toContain(term);
      });
      expect(content, `${expectation.file} should document the actual button`).toContain(expectation.button);
      expect(content, `${expectation.file} should document the left-center reveal area`).toContain(expectation.hover);
      expect(content, `${expectation.file} should document fixed target resolutions`).toContain(expectation.resolution);
      expect(content, `${expectation.file} should document Native without claiming enhancement is disabled`).toContain(expectation.native);
      expectation.crossOrigin.forEach(term => {
        expect(content, `${expectation.file} should document cross-origin recovery`).toContain(term);
      });
      expect(content, `${expectation.file} should retain the EME/DRM limitation`).toContain('Encrypted Media Extensions (EME)');
      expect(content, `${expectation.file} should acknowledge ArtCNN`).toContain('[ArtCNN]');
      expect(content, `${expectation.file} should acknowledge ACNetGLSL`).toContain('[ACNetGLSL]');
      expectation.staleWording.forEach(term => {
        expect(content, `${expectation.file} should not retain stale advanced-effect wording`).not.toContain(term);
      });
      expect(content, `${expectation.file} should avoid an absolute compatibility promise`).not.toContain(expectation.absoluteCompatibility);
    }
  });


  it('keeps verification documentation minimal and data-free', () => {
    const readme = readProjectFile('scripts/verify/README.md');
    const reproduction = readProjectFile('scripts/verify/REPRODUCTION.md');

    for (const content of [readme, reproduction]) {
      expect(content).not.toMatch(/test-results[\\/]user-image-evaluation/i);
      expect(content).not.toContain('formal-evaluation');
      expect(content).not.toMatch(/\bfinalist\b/i);
      expect(content).not.toMatch(/[A-Za-z]:[\\/]/);
    }
    expect(readme).toContain('--manifest <external-root>/manifest.json');
    expect(readme).toContain('--output <external-root>/evaluation');
    expect(readme).toContain('fetch:cunny-reference');
    expect(reproduction).toContain('scripts/verify/examples/manifest.template.json');
    expect(reproduction).toContain('scripts/verify/examples/matrix.template.json');
    expect(existsSync(resolve(process.cwd(), 'scripts/verify/BASELINE.md'))).toBe(false);
  });
});

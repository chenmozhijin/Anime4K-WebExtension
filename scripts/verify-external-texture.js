const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');
const { computeImageMetrics } = require('./verify/lib/image-metrics');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');

function parseArgs(argv) {
  const args = {
    manifest: path.join(repoRoot, 'test-results', 'video-fixtures', 'manifest.json'),
    output: path.join(repoRoot, 'test-results', 'verify', 'external-texture.json'),
    filter: null,
    noBuild: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--manifest') args.manifest = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--manifest=')) args.manifest = path.resolve(repoRoot, arg.slice(11));
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else if (arg === '--filter') args.filter = argv[++index].toLowerCase();
    else if (arg.startsWith('--filter=')) args.filter = arg.slice(9).toLowerCase();
    else if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--smoke') {
      args.manifest = path.join(repoRoot, 'test-results', 'video-fixtures-smoke', 'manifest.json');
      args.output = path.join(repoRoot, 'test-results', 'verify', 'external-texture-smoke.json');
    } else throw new Error(`Unknown external texture verification option: ${arg}`);
  }
  return args;
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  const result = spawnSync(process.execPath, [webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], {
    cwd: repoRoot,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error('Failed to build external texture verification bundle.');
  }
  fs.copyFileSync(
    path.join(repoRoot, 'test', 'verify', 'browser', 'index.html'),
    path.join(browserOutDir, 'index.html'),
  );
}

function writeJsonAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.tmp`;
  fs.writeFileSync(temporaryPath, JSON.stringify(value, null, 2));
  fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function compare(reference, candidate, width) {
  if (reference.length !== candidate.length) {
    return { passed: false, reason: 'output lengths differ' };
  }
  let sum = 0;
  let maxAbs = 0;
  let alphaMaxAbs = 0;
  let nonFiniteCount = 0;
  for (let index = 0; index < reference.length; index += 1) {
    const left = reference[index];
    const right = candidate[index];
    if (!Number.isFinite(left) || !Number.isFinite(right)) {
      nonFiniteCount += 1;
      continue;
    }
    const difference = Math.abs(left - right);
    sum += difference;
    maxAbs = Math.max(maxAbs, difference);
    if (index % 4 === 3) alphaMaxAbs = Math.max(alphaMaxAbs, difference);
  }
  const meanAbs = sum / reference.length;
  const perceptual = computeImageMetrics(reference, candidate, width, 4);
  const thresholds = {
    meanAbs: 0.25 / 255,
    maxAbs: 2 / 255,
    psnr: 50,
    ssim: 0.9995,
    deltaE2000P99: 0.5,
    deltaE2000Max: 2,
  };
  return {
    passed: nonFiniteCount === 0
      && meanAbs <= thresholds.meanAbs
      && maxAbs <= thresholds.maxAbs
      && perceptual.psnr >= thresholds.psnr
      && perceptual.ssim >= thresholds.ssim
      && perceptual.deltaE2000.p99 <= thresholds.deltaE2000P99
      && perceptual.deltaE2000.max <= thresholds.deltaE2000Max,
    meanAbs,
    maxAbs,
    alphaMaxAbs,
    nonFiniteCount,
    perceptual,
    thresholds,
  };
}

async function launchBrowser() {
  try {
    return await chromium.launch({ channel: 'chromium', headless: true, args: ['--enable-unsafe-webgpu'] });
  } catch {
    return chromium.launch({ headless: true, args: ['--enable-unsafe-webgpu'] });
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(args.manifest)) {
    throw new Error(`Video fixture manifest does not exist: ${args.manifest}`);
  }
  if (!args.noBuild) buildVerifyBundle();
  const manifest = JSON.parse(fs.readFileSync(args.manifest, 'utf8'));
  const fixtures = manifest.fixtures.filter(fixture =>
    !args.filter || fixture.id.toLowerCase().includes(args.filter));
  if (fixtures.length === 0) {
    throw new Error('No external texture fixtures matched.');
  }
  const assetDirectory = path.join(browserOutDir, 'external-texture-assets');
  fs.mkdirSync(assetDirectory, { recursive: true });
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  const cases = [];
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(15 * 60 * 1000);
    await page.goto(server.url);
    await page.waitForFunction(() => Boolean(window.__runExternalTextureVerification));
    for (const fixture of fixtures) {
      const sourcePath = path.join(path.dirname(args.manifest), fixture.file);
      const assetName = `${fixture.id}-${path.basename(fixture.file)}`;
      fs.copyFileSync(sourcePath, path.join(assetDirectory, assetName));
      const videoUrl = new URL(`external-texture-assets/${encodeURIComponent(assetName)}`, server.url).href;
      console.log(`verify external texture ${fixture.id} ...`);
      try {
        const result = await page.evaluate(async url => {
          if (!window.__runExternalTextureVerification) {
            throw new Error('External texture verifier is unavailable.');
          }
          return window.__runExternalTextureVerification({ videoUrl: url });
        }, videoUrl);
        const input = compare(result.nativeInput, result.externalInput, result.width);
        const convertedClamp = compare(result.nativeClamp, result.externalClamp, result.width);
        const directClamp = compare(result.externalClamp, result.directExternalClamp, result.width);
        cases.push({
          id: fixture.id,
          intendedBitDepth: fixture.intendedBitDepth,
          intendedColor: fixture.intendedColor,
          width: result.width,
          height: result.height,
          adapterInfo: result.adapterInfo,
          input,
          convertedClamp,
          directClamp,
          passed: input.passed && convertedClamp.passed && directClamp.passed,
        });
      } catch (error) {
        cases.push({
          id: fixture.id,
          intendedBitDepth: fixture.intendedBitDepth,
          intendedColor: fixture.intendedColor,
          passed: false,
          reason: error instanceof Error ? error.message : String(error),
        });
      }
    }
    await page.evaluate(() => window.__resetEffectVerification?.());
  } finally {
    await browser.close();
    await server.close();
  }

  const report = {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    manifest: args.manifest,
    caseCount: cases.length,
    failureCount: cases.filter(testCase => !testCase.passed).length,
    cases,
  };
  writeJsonAtomic(args.output, report);
  console.log(`External texture report: ${args.output}`);
  if (report.failureCount > 0) process.exitCode = 1;
}

module.exports = { compare, parseArgs };

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

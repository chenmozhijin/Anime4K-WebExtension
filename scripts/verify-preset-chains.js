const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');
const { computeImageMetrics } = require('./verify/lib/image-metrics');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');

function parseArgs(argv) {
  const args = {
    presets: ['A', 'B', 'C', 'A+A', 'B+B', 'C+A'],
    tiers: ['performance', 'balanced', 'quality', 'ultra'],
    width: 64,
    height: 48,
    output: path.join(repoRoot, 'test-results', 'verify', 'presets', 'report.json'),
    noBuild: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--presets') args.presets = argv[++index].split(',');
    else if (arg.startsWith('--presets=')) args.presets = arg.slice(10).split(',');
    else if (arg === '--tiers') args.tiers = argv[++index].split(',');
    else if (arg.startsWith('--tiers=')) args.tiers = arg.slice(8).split(',');
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else throw new Error(`Unknown preset verification option: ${arg}`);
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
  if (result.status !== 0) throw new Error('Failed to build preset verification bundle.');
  fs.copyFileSync(
    path.join(repoRoot, 'test', 'verify', 'browser', 'index.html'),
    path.join(browserOutDir, 'index.html'),
  );
}

function getBuildIdentity() {
  const pkg = JSON.parse(fs.readFileSync(path.join(repoRoot, 'package.json'), 'utf8'));
  const revision = spawnSync('git', ['rev-parse', 'HEAD'], {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  return {
    version: pkg.version,
    commit: revision.status === 0 ? revision.stdout.trim() : null,
    driverVersion: null,
    driverVersionReason: 'WebGPU does not expose a standard driver version API.',
  };
}

function createFixture(width, height) {
  const rgba = new Uint8Array(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const offset = (y * width + x) * 4;
      rgba[offset] = Math.round((x / Math.max(1, width - 1)) * 255);
      rgba[offset + 1] = Math.round((y / Math.max(1, height - 1)) * 255);
      rgba[offset + 2] = ((x * 37) ^ (y * 73)) & 0xff;
      rgba[offset + 3] = 255;
    }
  }
  return Array.from(rgba);
}

function compare(reference, candidate, width, components, thresholds) {
  if (!reference || !candidate || reference.length !== candidate.length) {
    return { passed: false, reason: 'output arrays differ in length' };
  }
  let sum = 0;
  let maxAbs = 0;
  let nonFiniteCount = 0;
  let alphaMaxAbs = 0;
  for (let index = 0; index < reference.length; index += 1) {
    const delta = Math.abs(reference[index] - candidate[index]);
    sum += delta;
    maxAbs = Math.max(maxAbs, delta);
    if (!Number.isFinite(candidate[index])) nonFiniteCount += 1;
    if (components === 4 && index % 4 === 3) alphaMaxAbs = Math.max(alphaMaxAbs, delta);
  }
  const meanAbs = sum / Math.max(1, reference.length);
  const perceptual = computeImageMetrics(reference, candidate, width, components);
  const passed = nonFiniteCount === 0
    && meanAbs <= thresholds.meanAbs
    && maxAbs <= thresholds.maxAbs
    && (thresholds.psnr === undefined || (perceptual.psnr ?? Infinity) >= thresholds.psnr)
    && (thresholds.ssim === undefined || (perceptual.ssim ?? 1) >= thresholds.ssim)
    && (thresholds.deltaE2000P99 === undefined || (perceptual.deltaE2000?.p99 ?? 0) <= thresholds.deltaE2000P99)
    && (thresholds.deltaE2000Max === undefined || (perceptual.deltaE2000?.max ?? 0) <= thresholds.deltaE2000Max);
  return {
    passed,
    meanAbs,
    maxAbs,
    nonFiniteCount,
    alphaMaxAbs,
    perceptual,
    thresholds,
  };
}

function hashF32(values) {
  const array = Float32Array.from(values);
  return crypto.createHash('sha256')
    .update(Buffer.from(array.buffer, array.byteOffset, array.byteLength))
    .digest('hex');
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
  if (!args.noBuild) buildVerifyBundle();
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  const report = {
    schemaVersion: 1,
    timestamp: new Date().toISOString(),
    fixture: { width: args.width, height: args.height, targetScale: 4 },
    cases: [],
    build: getBuildIdentity(),
  };
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(10 * 60 * 1000);
    await page.goto(server.url);
    await page.waitForFunction(() => Boolean(window.__runChainVerification && window.__resolvePresetChain));
    const rgba = createFixture(args.width, args.height);
    for (const preset of args.presets) {
      for (const tier of args.tiers) {
        process.stdout.write(`verify preset ${preset}/${tier} ... `);
        const result = await page.evaluate(async ({ preset, tier, width, height, rgba }) => {
          const effectIds = window.__resolvePresetChain(preset, tier);
          const base = {
            effectIds,
            width,
            height,
            targetWidth: width * 4,
            targetHeight: height * 4,
            rgba,
          };
          const baselineFlags = {
            textureLifetimeReuse: false,
            vectorizedPixelShuffle: false,
            fusedPixelShuffleRecompose: false,
            cunnyWorkgroupTile: false,
            fusedClampHighlights: false,
            acnetWorkgroupTile: false,
            anime4kWorkgroupTile: false,
            multiOutputDispatch: false,
            ganMultiOutputDispatch: false,
            fusedModelTail: false,
            terminalDirect: false,
            externalTexture: false,
            perceptualShaderF16: false,
            kernelAutotune: false,
          };
          const baseline = await window.__runChainVerification({
            ...base,
            includePreview: true,
            optimizationFlags: baselineFlags,
          });
          const exactOptimized = await window.__runChainVerification({
            ...base,
            optimizationFlags: {
              ...baselineFlags,
              textureLifetimeReuse: true,
              multiOutputDispatch: true,
              ganMultiOutputDispatch: true,
              anime4kWorkgroupTile: true,
            },
          });
          const optimized = await window.__runChainVerification({ ...base, includePreview: true });
          const terminal = await window.__runChainVerification({
            ...base,
            includePreview: true,
            terminalPresentation: true,
          });
          return { effectIds, baseline, exactOptimized, optimized, terminal };
        }, { preset, tier, width: args.width, height: args.height, rgba });

        const exact = compare(
          result.baseline.rgbaF32,
          result.exactOptimized.rgbaF32,
          result.baseline.width,
          4,
          { meanAbs: 1e-6, maxAbs: 1 / 1024 },
        );
        const perceptual = compare(
          result.baseline.rgbaF32,
          result.optimized.rgbaF32,
          result.baseline.width,
          4,
          {
            meanAbs: 0.25 / 255,
            maxAbs: 2 / 255,
            psnr: 50,
            ssim: 0.9995,
            deltaE2000P99: 0.5,
            deltaE2000Max: 2,
          },
        );
        const optimizedRgba = result.optimized.rgba.map(value => value / 255);
        const terminalRgba = result.terminal.rgba.map(value => value / 255);
        const terminal = result.terminal.terminalPresented
          ? compare(optimizedRgba, terminalRgba, result.optimized.width, 4, {
            meanAbs: 0.25 / 255,
            maxAbs: 2 / 255,
            psnr: 50,
            ssim: 0.9995,
            deltaE2000P99: 0.5,
            deltaE2000Max: 2,
          })
          : { passed: true, skipped: true, reason: 'no terminal presenter' };
        const passed = exact.passed && perceptual.passed && terminal.passed;
        console.log(passed ? 'ok' : 'failed');
        report.cases.push({
          preset,
          tier,
          effectIds: result.effectIds,
          output: { width: result.baseline.width, height: result.baseline.height },
          baselineHash: hashF32(result.baseline.rgbaF32),
          baselinePlan: {
            passCount: result.baseline.passCount,
            peakTextureBytes: result.baseline.peakTextureBytes,
            textureSlotCount: result.baseline.textureSlotCount,
          },
          exactOptimizedPlan: {
            passCount: result.exactOptimized.passCount,
            peakTextureBytes: result.exactOptimized.peakTextureBytes,
            textureSlotCount: result.exactOptimized.textureSlotCount,
          },
          optimizedPlan: {
            passCount: result.optimized.passCount,
            peakTextureBytes: result.optimized.peakTextureBytes,
            textureSlotCount: result.optimized.textureSlotCount,
          },
          exact,
          perceptual,
          terminal,
          passed,
          adapterInfo: result.optimized.adapterInfo,
        });
      }
    }
  } finally {
    await browser.close();
    await server.close();
  }
  report.passed = report.cases.every(testCase => testCase.passed);
  fs.mkdirSync(path.dirname(args.output), { recursive: true });
  fs.writeFileSync(args.output, JSON.stringify(report, null, 2));
  console.log(`Preset verification report: ${args.output}`);
  if (!report.passed) process.exitCode = 1;
}

module.exports = { parseArgs };

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

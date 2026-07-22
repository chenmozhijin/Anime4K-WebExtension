const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');

function parseArgs(argv) {
  const args = {
    noBuild: false,
    output: path.join(repoRoot, 'test-results', 'verify', 'kernel-variants.json'),
    filter: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else if (arg === '--filter') args.filter = argv[++index].toLowerCase();
    else if (arg.startsWith('--filter=')) args.filter = arg.slice(9).toLowerCase();
    else throw new Error(`Unknown kernel verification option: ${arg}`);
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
    throw new Error('Failed to build kernel verification browser bundle.');
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

function createFixture(width, height) {
  const rgba = new Array(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const offset = (y * width + x) * 4;
      rgba[offset] = ((x * 17 + y * 3) & 255) / 255;
      rgba[offset + 1] = ((x * 5 + y * 29) & 255) / 255;
      rgba[offset + 2] = ((x * 13 ^ y * 11) & 255) / 255;
      rgba[offset + 3] = 1;
    }
  }
  return rgba;
}

function compareOutputs(baseline, candidate) {
  if (baseline.length !== candidate.length) {
    return { passed: false, reason: 'output lengths differ' };
  }
  let sum = 0;
  let maxAbs = 0;
  let maxIndex = 0;
  let nonFiniteCount = 0;
  for (let index = 0; index < baseline.length; index += 1) {
    const left = baseline[index];
    const right = candidate[index];
    if (!Number.isFinite(left) || !Number.isFinite(right)) {
      nonFiniteCount += 1;
      continue;
    }
    const difference = Math.abs(left - right);
    sum += difference;
    if (difference > maxAbs) {
      maxAbs = difference;
      maxIndex = index;
    }
  }
  const meanAbs = sum / baseline.length;
  return {
    passed: nonFiniteCount === 0 && meanAbs <= 1e-6 && maxAbs <= 1 / 1024,
    meanAbs,
    maxAbs,
    maxIndex,
    nonFiniteCount,
    thresholds: { meanAbs: 1e-6, maxAbs: 1 / 1024 },
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
  if (!args.noBuild) buildVerifyBundle();
  const cases = [{
    id: 'acnet-f8b4',
    effectId: 'acnet/Upscale/F8B4',
    optimizationFlags: { acnetWorkgroupTile: true, kernelAutotune: true },
  }, {
    id: 'cunny-2x12-ds',
    effectId: 'cunny/Upscale/DS/2x12',
    optimizationFlags: { cunnyWorkgroupTile: true, kernelAutotune: true },
  }].filter(testCase => !args.filter || testCase.id.includes(args.filter));
  if (cases.length === 0) {
    throw new Error('No kernel verification cases matched.');
  }

  const width = 96;
  const height = 64;
  const rgba = createFixture(width, height);
  const disabledFlags = {
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
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  const results = [];
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(10 * 60 * 1000);
    await page.goto(server.url);
    await page.waitForFunction(() => Boolean(window.__runEffectVerification));
    for (const testCase of cases) {
      console.log(`verify ${testCase.id} untiled vs tiled variants ...`);
      const request = {
        effectId: testCase.effectId,
        width,
        height,
        rgba,
        outputMode: 'rgba',
        includePreview: false,
        terminalPresentation: false,
        optimizationFlags: { ...disabledFlags, ...testCase.optimizationFlags },
      };
      const baseline = await page.evaluate(async input => {
        if (!window.__runEffectVerification) throw new Error('Effect verifier is unavailable.');
        return window.__runEffectVerification({ ...input, kernelVariantOverride: 'untiled-8x8' });
      }, request);
      for (const variantId of ['tile-8x8', 'tile-16x8']) {
        const candidate = await page.evaluate(async ({ input, variantId }) => {
          if (!window.__runEffectVerification) throw new Error('Effect verifier is unavailable.');
          return window.__runEffectVerification({ ...input, kernelVariantOverride: variantId });
        }, { input: request, variantId });
        const comparison = baseline.width !== candidate.width || baseline.height !== candidate.height
          || !baseline.rgbaF32 || !candidate.rgbaF32
          ? { passed: false, reason: 'output dimensions or readback mode differ' }
          : compareOutputs(baseline.rgbaF32, candidate.rgbaF32);
        results.push({
          id: `${testCase.id}/${variantId}`,
          effectId: testCase.effectId,
          baselineVariantId: 'untiled-8x8',
          candidateVariantId: variantId,
          width: baseline.width,
          height: baseline.height,
          adapterInfo: baseline.adapterInfo,
          baselinePassCount: baseline.passCount,
          candidatePassCount: candidate.passCount,
          comparison,
          passed: comparison.passed,
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
    caseCount: results.length,
    failureCount: results.filter(result => !result.passed).length,
    cases: results,
  };
  writeJsonAtomic(args.output, report);
  console.log(`Kernel variant report: ${args.output}`);
  if (report.failureCount > 0) {
    process.exitCode = 1;
  }
}

module.exports = { compareOutputs, parseArgs };

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

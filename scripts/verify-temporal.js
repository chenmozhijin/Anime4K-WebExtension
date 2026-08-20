const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');

const baselineFlags = Object.freeze({
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
});

const optimizedFlags = Object.freeze({
  textureLifetimeReuse: true,
  vectorizedPixelShuffle: true,
  fusedPixelShuffleRecompose: true,
  cunnyWorkgroupTile: false,
  fusedClampHighlights: true,
  acnetWorkgroupTile: false,
  anime4kWorkgroupTile: false,
  multiOutputDispatch: true,
  ganMultiOutputDispatch: false,
  fusedModelTail: true,
  terminalDirect: false,
  externalTexture: false,
  perceptualShaderF16: false,
  kernelAutotune: true,
});

function positiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) throw new Error(`${name} must be a positive integer.`);
  return parsed;
}

function positiveNumber(value, name) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) throw new Error(`${name} must be positive.`);
  return parsed;
}

function parseArgs(argv) {
  const args = {
    manifest: path.join(repoRoot, 'test-results', 'video-fixtures', 'manifest.json'),
    output: path.join(repoRoot, 'test-results', 'verify', 'temporal.json'),
    preset: 'A+A',
    tier: 'balanced',
    effects: null,
    targetScale: 1,
    frameCount: null,
    filter: null,
    profiles: ['optimized', 'external'],
    noBuild: false,
    motionOnly: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--manifest') args.manifest = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--manifest=')) args.manifest = path.resolve(repoRoot, arg.slice(11));
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else if (arg === '--preset') args.preset = argv[++index];
    else if (arg.startsWith('--preset=')) args.preset = arg.slice(9);
    else if (arg === '--tier') args.tier = argv[++index];
    else if (arg.startsWith('--tier=')) args.tier = arg.slice(7);
    else if (arg === '--effects') args.effects = argv[++index].split(',').filter(Boolean);
    else if (arg.startsWith('--effects=')) args.effects = arg.slice(10).split(',').filter(Boolean);
    else if (arg === '--target-scale') args.targetScale = positiveNumber(argv[++index], '--target-scale');
    else if (arg.startsWith('--target-scale=')) args.targetScale = positiveNumber(arg.slice(15), '--target-scale');
    else if (arg === '--frames') args.frameCount = positiveInteger(argv[++index], '--frames');
    else if (arg.startsWith('--frames=')) args.frameCount = positiveInteger(arg.slice(9), '--frames');
    else if (arg === '--filter') args.filter = argv[++index].toLowerCase();
    else if (arg.startsWith('--filter=')) args.filter = arg.slice(9).toLowerCase();
    else if (arg === '--profiles') args.profiles = argv[++index].split(',');
    else if (arg.startsWith('--profiles=')) args.profiles = arg.slice(11).split(',');
    else if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--motion-only') args.motionOnly = true;
    else if (arg === '--smoke') {
      args.manifest = path.join(repoRoot, 'test-results', 'video-fixtures-smoke', 'manifest.json');
      args.output = path.join(repoRoot, 'test-results', 'verify', 'temporal-smoke.json');
    } else throw new Error(`Unknown temporal verification option: ${arg}`);
  }
  const supportedProfiles = new Set(['optimized', 'external']);
  const invalidProfile = args.profiles.find(profile => !supportedProfiles.has(profile));
  if (invalidProfile) throw new Error(`Unknown temporal verification profile: ${invalidProfile}`);
  return args;
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  const result = spawnSync(process.execPath, [webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], {
    cwd: repoRoot,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.status !== 0) throw new Error('Failed to build temporal verification bundle.');
  syncVerifyHtml();
}

function syncVerifyHtml() {
  fs.mkdirSync(browserOutDir, { recursive: true });
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
  else syncVerifyHtml();
  const manifest = JSON.parse(fs.readFileSync(args.manifest, 'utf8'));
  const fixtures = manifest.fixtures.filter(fixture =>
    !args.filter || fixture.id.toLowerCase().includes(args.filter));
  if (fixtures.length === 0) throw new Error('No temporal fixtures matched.');
  const frameCount = Math.min(args.frameCount ?? manifest.framesPerClip, manifest.framesPerClip);
  const assetDirectory = path.join(browserOutDir, 'temporal-assets');
  fs.mkdirSync(assetDirectory, { recursive: true });
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  const cases = [];
  let effectIds = [];
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(60 * 60 * 1000);
    await page.goto(server.url);
    await page.waitForFunction(() => Boolean(
      window.__runTemporalVerification && window.__resolvePresetChain,
    ));
    effectIds = args.effects ?? await page.evaluate(({ preset, tier }) => {
      if (!window.__resolvePresetChain) throw new Error('Preset resolver is unavailable.');
      return window.__resolvePresetChain(preset, tier);
    }, { preset: args.preset, tier: args.tier });

    for (const fixture of fixtures) {
      const sourcePath = path.join(path.dirname(args.manifest), fixture.file);
      const assetName = `${fixture.id}-${path.basename(fixture.file)}`;
      fs.copyFileSync(sourcePath, path.join(assetDirectory, assetName));
      const videoUrl = new URL(`temporal-assets/${encodeURIComponent(assetName)}`, server.url).href;
      for (const profile of args.profiles) {
        process.stdout.write(`verify temporal ${fixture.id}/${profile} (${frameCount} frames) ... `);
        try {
          const result = await page.evaluate(async request => {
            if (!window.__runTemporalVerification) throw new Error('Temporal verifier is unavailable.');
            return window.__runTemporalVerification(request);
          }, {
            videoUrl,
            effectIds,
            targetWidth: Math.round(manifest.width * args.targetScale),
            targetHeight: Math.round(manifest.height * args.targetScale),
            frameCount,
            fps: manifest.fps,
            baselineFlags,
            optimizedFlags: {
              ...optimizedFlags,
              externalTexture: profile === 'external',
            },
            externalTexture: profile === 'external',
            motionOnly: args.motionOnly,
          });
          cases.push({
            id: fixture.id,
            profile,
            intendedBitDepth: fixture.intendedBitDepth,
            intendedColor: fixture.intendedColor,
            ...result,
            passed: result.metrics.passed,
          });
          process.stdout.write(`${result.metrics.passed ? 'PASS' : 'FAIL'} `
            + `mean=${result.metrics.meanAbs.toExponential(3)} `
            + `max=${result.metrics.maxAbs.toExponential(3)} `
            + `temporal-p99=${result.metrics.temporalChangeP99.toExponential(3)} `
            + `output-motion-p99=${result.metrics.outputTemporalP99.toExponential(3)}\n`);
        } catch (error) {
          const reason = error instanceof Error ? error.message : String(error);
          const unsupported = profile === 'external' && /GPUExternalTexture is unavailable/.test(reason);
          cases.push({
            id: fixture.id,
            profile,
            intendedBitDepth: fixture.intendedBitDepth,
            intendedColor: fixture.intendedColor,
            passed: unsupported,
            skipped: unsupported,
            reason,
          });
          process.stdout.write(`${unsupported ? 'SKIP' : 'FAIL'} ${reason}\n`);
        }
      }
      await page.evaluate(() => window.__resetEffectVerification?.());
    }
  } finally {
    await browser.close();
    await server.close();
  }

  const report = {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    build: getBuildIdentity(),
    manifest: args.manifest,
    preset: args.preset,
    tier: args.tier,
    explicitEffects: args.effects,
    effectIds,
    targetScale: args.targetScale,
    framesPerCase: frameCount,
    profiles: args.profiles,
    motionOnly: args.motionOnly,
    caseCount: cases.length,
    skippedCount: cases.filter(testCase => testCase.skipped).length,
    failureCount: cases.filter(testCase => !testCase.passed).length,
    cases,
  };
  writeJsonAtomic(args.output, report);
  console.log(`Temporal verification report: ${args.output}`);
  if (report.failureCount > 0) process.exitCode = 1;
}

module.exports = { baselineFlags, optimizedFlags, parseArgs };

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

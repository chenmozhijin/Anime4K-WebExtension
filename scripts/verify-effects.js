const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { createBuiltInFixtures } = require('./verify/lib/fixtures');
const { createManifest, repoRoot } = require('./verify/lib/manifest');
const { requireUcrt64Root } = require('./verify/lib/native-tools');
const { decodePng, encodePng } = require('./verify/lib/png');
const { startStaticServer } = require('./verify/lib/static-server');

const artifactsRoot = path.join(repoRoot, 'test-results/verify/effects');
const browserOutDir = path.join(repoRoot, 'test-results/verify/browser');
const referenceCacheRoot = path.join(repoRoot, '.cache', 'verify-effects', 'reference');
const workRoot = path.join(repoRoot, '.cache', 'verify-effects', 'work');
const lumaRunnerPath = path.join(repoRoot, '.cache', 'verify-tools', 'native', 'libplacebo-luma-runner.exe');
const rgbaRunnerPath = path.join(repoRoot, '.cache', 'verify-tools', 'native', 'libplacebo-rgba-runner.exe');
const BT709 = [0.2126, 0.7152, 0.0722];

function parseArgs(argv) {
  const args = {
    filter: null,
    effectId: null,
    fixture: null,
    fixtureExact: false,
    keepArtifacts: false,
    caseTimeoutMs: null,
    browserRecycleEvery: 8,
    shard: null,
    noBuild: false,
    referenceCache: true,
    runId: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--keep-artifacts') args.keepArtifacts = true;
    else if (arg === '--fixture-exact') args.fixtureExact = true;
    else if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--no-reference-cache') args.referenceCache = false;
    else if (arg === '--effect-id') args.effectId = argv[++index];
    else if (arg.startsWith('--effect-id=')) args.effectId = arg.slice('--effect-id='.length);
    else if (arg === '--filter') args.filter = argv[++index];
    else if (arg.startsWith('--filter=')) args.filter = arg.slice('--filter='.length);
    else if (arg === '--fixture') args.fixture = argv[++index];
    else if (arg.startsWith('--fixture=')) args.fixture = arg.slice('--fixture='.length);
    else if (arg === '--case-timeout-ms') args.caseTimeoutMs = parsePositiveInteger(argv[++index], '--case-timeout-ms');
    else if (arg.startsWith('--case-timeout-ms=')) args.caseTimeoutMs = parsePositiveInteger(arg.slice('--case-timeout-ms='.length), '--case-timeout-ms');
    else if (arg === '--browser-recycle-every') args.browserRecycleEvery = parsePositiveInteger(argv[++index], '--browser-recycle-every');
    else if (arg.startsWith('--browser-recycle-every=')) args.browserRecycleEvery = parsePositiveInteger(arg.slice('--browser-recycle-every='.length), '--browser-recycle-every');
    else if (arg === '--shard') args.shard = parseShard(argv[++index]);
    else if (arg.startsWith('--shard=')) args.shard = parseShard(arg.slice('--shard='.length));
    else if (arg === '--run-id') args.runId = argv[++index];
    else if (arg.startsWith('--run-id=')) args.runId = arg.slice('--run-id='.length);
    else throw new Error(`Unknown verify:effects option: ${arg}`);
  }
  return args;
}

function parsePositiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0 || String(parsed) !== String(value).trim()) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function parseShard(value) {
  const match = /^(\d+)\/(\d+)$/.exec(String(value).trim());
  if (!match) {
    throw new Error('--shard must use the form <index>/<count>, for example 1/2.');
  }
  const index = Number.parseInt(match[1], 10);
  const count = Number.parseInt(match[2], 10);
  if (count <= 0 || index <= 0 || index > count) {
    throw new Error('--shard index must be between 1 and count.');
  }
  return { index, count };
}

function formatShard(shard) {
  return shard ? `${shard.index}/${shard.count}` : null;
}

function nowMs() {
  return Number(process.hrtime.bigint() / 1000000n);
}

function createEmptyTimings() {
  return {
    referenceMs: 0,
    candidateMs: 0,
    compareMs: 0,
    totalMs: 0,
  };
}

function withTimeout(promise, timeoutMs, label) {
  let timeout;
  return Promise.race([
    promise.finally(() => clearTimeout(timeout)),
    new Promise((_, reject) => {
      timeout = setTimeout(() => {
        reject(new Error(`${label} timed out after ${timeoutMs}ms.`));
      }, timeoutMs);
    }),
  ]);
}

function isCandidateTimeoutError(error) {
  return error instanceof Error
    && /^candidate .+ timed out after \d+ms\.$/.test(error.message);
}

function sanitize(value) {
  return value.replace(/[^a-z0-9_.-]+/gi, '_');
}

function rgbaToLumaF32(fixture) {
  const luma = new Float32Array(fixture.width * fixture.height);
  for (let index = 0; index < luma.length; index += 1) {
    const offset = index * 4;
    luma[index] = (
      fixture.rgba[offset] * BT709[0]
      + fixture.rgba[offset + 1] * BT709[1]
      + fixture.rgba[offset + 2] * BT709[2]
    ) / 255;
  }
  return luma;
}

function rgbaToF32(fixture) {
  const rgba = new Float32Array(fixture.width * fixture.height * 4);
  for (let index = 0; index < rgba.length; index += 1) {
    rgba[index] = fixture.rgba[index] / 255;
  }
  return rgba;
}

function writeF32(pathname, values) {
  const buffer = Buffer.alloc(values.length * 4);
  values.forEach((value, index) => buffer.writeFloatLE(value, index * 4));
  fs.writeFileSync(pathname, buffer);
}

function readF32(pathname) {
  const buffer = fs.readFileSync(pathname);
  if (buffer.length % 4 !== 0) {
    throw new Error(`Invalid f32 raw length for ${pathname}: ${buffer.length}`);
  }
  const values = new Float32Array(buffer.length / 4);
  for (let index = 0; index < values.length; index += 1) {
    values[index] = buffer.readFloatLE(index * 4);
  }
  return values;
}

function sha256Buffer(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function sha256File(pathname) {
  return sha256Buffer(fs.readFileSync(pathname));
}

function createReferenceCacheKey({ mode, effect, fixture, inputPath, runnerPath }) {
  const shaderPath = path.isAbsolute(effect.referenceShader)
    ? effect.referenceShader
    : path.join(repoRoot, effect.referenceShader);
  const payload = {
    version: 2,
    mode,
    validationMode: effect.validationMode,
    outputMode: effect.outputMode,
    referenceShader: effect.referenceShader,
    shaderSha256: sha256File(shaderPath),
    runnerName: path.basename(runnerPath),
    runnerSha256: sha256File(runnerPath),
    inputSha256: sha256File(inputPath),
    width: fixture.width,
    height: fixture.height,
    scale: effect.expectedScale ?? (mode === 'rgba' ? 1 : 2),
  };
  return sha256Buffer(Buffer.from(JSON.stringify(payload), 'utf8'));
}

function createReferenceCacheEntry({ mode, effect, fixture, inputPath, runnerPath }) {
  const key = createReferenceCacheKey({ mode, effect, fixture, inputPath, runnerPath });
  const dir = path.join(referenceCacheRoot, mode, key.slice(0, 2), key);
  return {
    key,
    dir,
    rawPath: path.join(dir, `reference-${mode}.f32`),
    infoPath: path.join(dir, 'reference-info.json'),
  };
}

function attachReferenceCacheInfo(info, entry, outputPath, hit, enabled) {
  return {
    ...info,
    output: outputPath,
    referenceCache: {
      enabled,
      hit,
      key: entry?.key ?? null,
      path: entry?.dir ?? null,
    },
  };
}

function tryReadReferenceCache(entry, outputPath) {
  if (!fs.existsSync(entry.rawPath) || !fs.existsSync(entry.infoPath)) {
    return null;
  }
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.copyFileSync(entry.rawPath, outputPath);
  const info = JSON.parse(fs.readFileSync(entry.infoPath, 'utf8'));
  return attachReferenceCacheInfo(info, entry, outputPath, true, true);
}

function writeReferenceCache(entry, outputPath, info) {
  if (fs.existsSync(entry.rawPath) && fs.existsSync(entry.infoPath)) {
    return;
  }
  fs.mkdirSync(entry.dir, { recursive: true });
  const cachedInfo = { ...info };
  delete cachedInfo.referenceCache;
  const suffix = `${process.pid}-${Date.now()}`;
  const rawTempPath = path.join(entry.dir, `reference.tmp.${suffix}.f32`);
  const infoTempPath = path.join(entry.dir, `reference-info.tmp.${suffix}.json`);
  fs.copyFileSync(outputPath, rawTempPath);
  fs.writeFileSync(infoTempPath, JSON.stringify(cachedInfo, null, 2));
  try {
    if (!fs.existsSync(entry.rawPath)) {
      fs.renameSync(rawTempPath, entry.rawPath);
    }
    if (!fs.existsSync(entry.infoPath)) {
      fs.renameSync(infoTempPath, entry.infoPath);
    }
  } finally {
    fs.rmSync(rawTempPath, { force: true });
    fs.rmSync(infoTempPath, { force: true });
  }
}

function measureF32Region(reference, candidate, width, height, components, region) {
  let sum = 0;
  let maxAbs = 0;
  let maxIndex = 0;
  let samples = 0;
  for (let y = region.top; y < region.bottom; y += 1) {
    for (let x = region.left; x < region.right; x += 1) {
      const pixelBase = (y * width + x) * components;
      for (let channel = 0; channel < components; channel += 1) {
        const index = pixelBase + channel;
        const delta = Math.abs(reference[index] - candidate[index]);
        sum += delta;
        samples += 1;
        if (delta > maxAbs) {
          maxAbs = delta;
          maxIndex = index;
        }
      }
    }
  }
  const pixelIndex = Math.floor(maxIndex / components);
  return {
    meanAbs: samples ? sum / samples : 0,
    maxAbs,
    maxPosition: {
      x: width ? pixelIndex % width : 0,
      y: width ? Math.floor(pixelIndex / width) : 0,
      channel: components > 1 ? maxIndex % components : 0,
    },
    region,
  };
}

function compareF32(reference, candidate, width, options) {
  const components = options.components ?? 1;
  if (reference.length !== candidate.length) {
    return {
      passed: false,
      reason: `raw length mismatch: reference ${reference.length}, candidate ${candidate.length}`,
    };
  }

  const height = width && components ? reference.length / components / width : 0;
  const full = measureF32Region(reference, candidate, width, height, components, {
    left: 0,
    top: 0,
    right: width,
    bottom: height,
  });
  const cropBorderPx = options.cropBorderPx ?? 2;
  const cropped = width > cropBorderPx * 2 && height > cropBorderPx * 2
    ? measureF32Region(reference, candidate, width, height, components, {
      left: cropBorderPx,
      top: cropBorderPx,
      right: width - cropBorderPx,
      bottom: height - cropBorderPx,
    })
    : null;
  const { meanAbs, maxAbs, maxPosition } = full;
  const passed = meanAbs <= options.meanAbs && maxAbs <= options.maxAbs;
  return {
    passed,
    meanAbs,
    maxAbs,
    maxPosition,
    cropped,
    thresholds: {
      meanAbs: options.meanAbs,
      maxAbs: options.maxAbs,
    },
    reason: passed
      ? null
      : `meanAbs=${meanAbs}, maxAbs=${maxAbs} at ${maxPosition.x},${maxPosition.y}, channel ${maxPosition.channel}`,
  };
}

function adaptFixtureForEffect(fixture, expectedScale) {
  const minOutputWidth = 224;
  const minOutputHeight = 96;
  const width = Math.max(fixture.width, Math.ceil(minOutputWidth / expectedScale));
  const height = Math.max(fixture.height, Math.ceil(minOutputHeight / expectedScale));
  if (width === fixture.width && height === fixture.height) {
    return fixture;
  }

  const rgba = new Uint8Array(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    const sourceY = height === 1 ? 0 : (y / (height - 1)) * (fixture.height - 1);
    const y0 = Math.floor(sourceY);
    const y1 = Math.min(fixture.height - 1, y0 + 1);
    const fy = sourceY - y0;
    for (let x = 0; x < width; x += 1) {
      const sourceX = width === 1 ? 0 : (x / (width - 1)) * (fixture.width - 1);
      const x0 = Math.floor(sourceX);
      const x1 = Math.min(fixture.width - 1, x0 + 1);
      const fx = sourceX - x0;
      const targetOffset = (y * width + x) * 4;
      for (let channel = 0; channel < 4; channel += 1) {
        const topLeft = fixture.rgba[(y0 * fixture.width + x0) * 4 + channel];
        const topRight = fixture.rgba[(y0 * fixture.width + x1) * 4 + channel];
        const bottomLeft = fixture.rgba[(y1 * fixture.width + x0) * 4 + channel];
        const bottomRight = fixture.rgba[(y1 * fixture.width + x1) * 4 + channel];
        const top = topLeft * (1 - fx) + topRight * fx;
        const bottom = bottomLeft * (1 - fx) + bottomRight * fx;
        rgba[targetOffset + channel] = Math.round(top * (1 - fy) + bottom * fy);
      }
    }
  }

  return {
    ...fixture,
    id: `${fixture.id}_${width}x${height}`,
    width,
    height,
    rgba,
  };
}

function buildVerifyBundle() {
  const webpackCli = path.join(
    repoRoot,
    'node_modules',
    'webpack-cli',
    'bin',
    'cli.js',
  );
  const result = spawnSync(process.execPath, [webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], {
    cwd: repoRoot,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error(describeProcessFailure(result, 'Failed to build verification browser bundle.'));
  }
  fs.copyFileSync(
    path.join(repoRoot, 'test/verify/browser/index.html'),
    path.join(browserOutDir, 'index.html'),
  );
}

function loadDatasetFixtures() {
  const datasetDir = process.env.VERIFY_DATASET_DIR;
  if (!datasetDir) return [];
  if (!fs.existsSync(datasetDir)) {
    throw new Error(`VERIFY_DATASET_DIR does not exist: ${datasetDir}`);
  }
  return fs.readdirSync(datasetDir)
    .filter(file => file.toLowerCase().endsWith('.png'))
    .map(file => {
      const image = decodePng(fs.readFileSync(path.join(datasetDir, file)));
      return {
        id: `dataset_${path.basename(file, path.extname(file))}`,
        width: image.width,
        height: image.height,
        rgba: image.rgba,
      };
    });
}

async function launchBrowser() {
  try {
    return await chromium.launch({
      channel: 'chromium',
      headless: true,
      args: ['--enable-unsafe-webgpu'],
    });
  } catch {
    return chromium.launch({
      headless: true,
      args: ['--enable-unsafe-webgpu'],
    });
  }
}

async function openVerifyPage(browser, serverUrl) {
  const page = await browser.newPage();
  page.setDefaultTimeout(300_000);
  await page.goto(serverUrl);
  await page.waitForFunction(() => Boolean(window.__runEffectVerification));
  return page;
}

async function closeVerifyPage(page) {
  await page.evaluate(() => window.__resetEffectVerification?.()).catch(() => {});
  await page.close().catch(() => {});
}

async function runCandidate(page, effect, fixture, options = {}) {
  return page.evaluate(
    async ({ effectId, width, height, rgba, outputMode, includePreview }) => {
      if (!window.__runEffectVerification) {
        throw new Error('Verification runner is not loaded.');
      }
      return window.__runEffectVerification({ effectId, width, height, rgba, outputMode, includePreview });
    },
    {
      effectId: effect.id,
      width: fixture.width,
      height: fixture.height,
      rgba: Array.from(fixture.rgba),
      outputMode: effect.outputMode,
      includePreview: Boolean(options.includePreview),
    },
  );
}

function createCaseList(manifest, fixtures) {
  const cases = [];
  for (const effect of manifest) {
    for (const fixture of fixtures) {
      if (fixture.validationModes && !fixture.validationModes.includes(effect.validationMode)) {
        continue;
      }
      cases.push({
        effect,
        fixture: adaptFixtureForEffect(fixture, effect.expectedScale),
      });
    }
  }
  return cases;
}

function filterFixtures(fixtures, args) {
  return fixtures
    .filter(fixture => args.fixture || !fixture.diagnosticOnly)
    .filter(fixture => {
      if (!args.fixture) return true;
      const fixtureId = fixture.id.toLowerCase();
      const selected = args.fixture.toLowerCase();
      return args.fixtureExact ? fixtureId === selected : fixtureId.includes(selected);
    });
}

function applyShard(cases, shard) {
  if (!shard) return cases;
  return cases.filter((_, index) => index % shard.count === shard.index - 1);
}

function createCaseWorkspace(effect, fixture, keepArtifacts) {
  const artifactDir = path.join(artifactsRoot, sanitize(effect.id), sanitize(fixture.id));
  if (keepArtifacts) {
    fs.mkdirSync(artifactDir, { recursive: true });
    return {
      artifactDir,
      workDir: artifactDir,
      keepArtifacts: true,
      usesTemporaryWorkDir: false,
    };
  }

  fs.mkdirSync(workRoot, { recursive: true });
  return {
    artifactDir,
    workDir: fs.mkdtempSync(path.join(workRoot, `${sanitize(effect.id)}-${sanitize(fixture.id)}-`)),
    keepArtifacts: false,
    usesTemporaryWorkDir: true,
  };
}

function cleanupCaseWorkspace(workspace, passed) {
  if (workspace.usesTemporaryWorkDir && passed) {
    fs.rmSync(workspace.workDir, { recursive: true, force: true });
    fs.rmSync(workspace.artifactDir, { recursive: true, force: true });
  }
}

function materializeFailedCaseArtifact(workspace) {
  if (!workspace.usesTemporaryWorkDir) return;
  fs.rmSync(workspace.artifactDir, { recursive: true, force: true });
  fs.mkdirSync(path.dirname(workspace.artifactDir), { recursive: true });
  fs.cpSync(workspace.workDir, workspace.artifactDir, { recursive: true });
  fs.rmSync(workspace.workDir, { recursive: true, force: true });
}

function createSummaryPayload({
  runId,
  startedAt,
  finishedAt,
  failures,
  cases,
  caseTotal,
  args,
}) {
  const finished = finishedAt ?? new Date().toISOString();
  return {
    generatedAt: finished,
    runId,
    startedAt,
    finishedAt,
    durationMs: Date.parse(finished) - Date.parse(startedAt),
    caseCount: cases.length,
    caseTotal,
    failureCount: failures.length,
    shard: formatShard(args.shard),
    command: process.argv.join(' '),
    filters: {
      effectId: args.effectId,
      filter: args.filter,
      fixture: args.fixture,
      fixtureExact: args.fixtureExact,
      runId: args.runId,
      referenceCache: args.referenceCache,
    },
    cases,
  };
}

function writeProcessLogs(caseDir, prefix, result) {
  if (typeof result.stdout === 'string' && result.stdout.length > 0) {
    fs.writeFileSync(path.join(caseDir, `${prefix}.stdout.log`), result.stdout);
  }
  if (typeof result.stderr === 'string' && result.stderr.length > 0) {
    fs.writeFileSync(path.join(caseDir, `${prefix}.stderr.log`), result.stderr);
  }
}

function describeProcessFailure(result, fallback) {
  const details = [
    fallback,
    result.error ? `error=${result.error.message}` : null,
    result.signal ? `signal=${result.signal}` : null,
    typeof result.status === 'number' ? `status=${result.status}` : null,
    result.stderr?.trim() ? `stderr=${result.stderr.trim()}` : null,
    result.stdout?.trim() ? `stdout=${result.stdout.trim()}` : null,
  ].filter(Boolean);
  return details.join('; ');
}

function nativeReferenceEnv() {
  const ucrt64Root = requireUcrt64Root();
  return {
    ...process.env,
    PATH: `${path.join(ucrt64Root, 'bin')}${path.delimiter}${process.env.PATH ?? ''}`,
  };
}

function renderLibplaceboLumaReference({ effect, fixture, inputPath, outputPath, caseDir, timeoutMs, useReferenceCache }) {
  if (!fs.existsSync(lumaRunnerPath)) {
    throw new Error('libplacebo LUMA runner is not built. Run npm run verify:reference-libplacebo:build-luma.');
  }
  const cacheEntry = useReferenceCache
    ? createReferenceCacheEntry({ mode: 'luma', effect, fixture, inputPath, runnerPath: lumaRunnerPath })
    : null;
  if (cacheEntry) {
    const cached = tryReadReferenceCache(cacheEntry, outputPath);
    if (cached) return cached;
  }
  const shaderPath = path.join(repoRoot, effect.referenceShader);
  const env = nativeReferenceEnv();
  const result = spawnSync(lumaRunnerPath, [
    '--shader',
    shaderPath,
    '--width',
    String(fixture.width),
    '--height',
    String(fixture.height),
    '--scale',
    String(effect.expectedScale ?? 2),
    '--input-luma-f32',
    inputPath,
    '--output',
    outputPath,
  ], {
    cwd: repoRoot,
    encoding: 'utf8',
    env,
    windowsHide: true,
    timeout: timeoutMs ?? effect.referenceTimeoutMs ?? 180_000,
  });
  writeProcessLogs(caseDir, 'reference-luma', result);
  if (result.status !== 0) {
    throw new Error(describeProcessFailure(result, 'libplacebo LUMA reference failed.'));
  }
  const info = JSON.parse(result.stdout.trim());
  if (cacheEntry) {
    writeReferenceCache(cacheEntry, outputPath, info);
    return attachReferenceCacheInfo(info, cacheEntry, outputPath, false, true);
  }
  return attachReferenceCacheInfo(info, null, outputPath, false, false);
}

function renderLibplaceboRgbaReference({ effect, fixture, inputPath, outputPath, caseDir, timeoutMs, useReferenceCache }) {
  if (!fs.existsSync(rgbaRunnerPath)) {
    throw new Error('libplacebo RGBA runner is not built. Run npm run verify:reference-libplacebo:build-rgba.');
  }
  const cacheEntry = useReferenceCache
    ? createReferenceCacheEntry({ mode: 'rgba', effect, fixture, inputPath, runnerPath: rgbaRunnerPath })
    : null;
  if (cacheEntry) {
    const cached = tryReadReferenceCache(cacheEntry, outputPath);
    if (cached) return cached;
  }
  const shaderPath = path.join(repoRoot, effect.referenceShader);
  const env = nativeReferenceEnv();
  const result = spawnSync(rgbaRunnerPath, [
    '--shader',
    shaderPath,
    '--width',
    String(fixture.width),
    '--height',
    String(fixture.height),
    '--scale',
    String(effect.expectedScale ?? 1),
    '--input-rgba-f32',
    inputPath,
    '--output',
    outputPath,
  ], {
    cwd: repoRoot,
    encoding: 'utf8',
    env,
    windowsHide: true,
    timeout: timeoutMs ?? effect.referenceTimeoutMs ?? 180_000,
  });
  writeProcessLogs(caseDir, 'reference-rgba', result);
  if (result.status !== 0) {
    throw new Error(describeProcessFailure(result, 'libplacebo RGBA reference failed.'));
  }
  const info = JSON.parse(result.stdout.trim());
  if (cacheEntry) {
    writeReferenceCache(cacheEntry, outputPath, info);
    return attachReferenceCacheInfo(info, cacheEntry, outputPath, false, true);
  }
  return attachReferenceCacheInfo(info, null, outputPath, false, false);
}

async function readCandidatePreview({ page, effect, fixture, caseTimeoutMs }) {
  const previewPromise = runCandidate(page, effect, fixture, { includePreview: true });
  return caseTimeoutMs
    ? withTimeout(previewPromise, caseTimeoutMs, `candidate preview ${effect.id} / ${fixture.id}`)
    : previewPromise;
}

async function runOneLumaMath({ page, effect, fixture, keepArtifacts, caseTimeoutMs, runId, useReferenceCache }) {
  const timings = createEmptyTimings();
  const totalStart = nowMs();
  const workspace = createCaseWorkspace(effect, fixture, keepArtifacts);
  const caseDir = workspace.workDir;
  const inputPath = path.join(caseDir, 'input.png');
  const inputLumaPath = path.join(caseDir, 'input-luma.f32');
  const referenceRawPath = path.join(caseDir, 'reference-luma.f32');
  const candidateRawPath = path.join(caseDir, 'candidate-luma.f32');
  const candidatePath = path.join(caseDir, 'candidate.png');
  const metricsPath = path.join(caseDir, 'metrics.json');

  try {
  if (keepArtifacts) fs.writeFileSync(inputPath, encodePng(fixture));
  writeF32(inputLumaPath, rgbaToLumaF32(fixture));
  const referenceStart = nowMs();
  const referenceInfo = renderLibplaceboLumaReference({
    effect,
    fixture,
    inputPath: inputLumaPath,
    outputPath: referenceRawPath,
    caseDir,
    timeoutMs: caseTimeoutMs,
    useReferenceCache,
  });
  timings.referenceMs = nowMs() - referenceStart;

  const candidateStart = nowMs();
  const candidatePromise = runCandidate(page, effect, fixture, { includePreview: keepArtifacts });
  const candidateResult = caseTimeoutMs
    ? await withTimeout(candidatePromise, caseTimeoutMs, `candidate ${effect.id} / ${fixture.id}`)
    : await candidatePromise;
  timings.candidateMs = nowMs() - candidateStart;
  if (!candidateResult.lumaF32) {
    throw new Error(`Candidate did not return lumaF32 for ${effect.id}.`);
  }

  const expectedWidth = fixture.width * effect.expectedScale;
  const expectedHeight = fixture.height * effect.expectedScale;
  const compareStart = nowMs();
  const dimensionFailure = candidateResult.width !== expectedWidth || candidateResult.height !== expectedHeight
    ? `candidate dimension ${candidateResult.width}x${candidateResult.height} does not match expected ${expectedWidth}x${expectedHeight}`
    : referenceInfo.width !== expectedWidth || referenceInfo.height !== expectedHeight
      ? `reference dimension ${referenceInfo.width}x${referenceInfo.height} does not match expected ${expectedWidth}x${expectedHeight}`
      : null;
  const comparison = dimensionFailure
    ? { passed: false, reason: dimensionFailure }
    : compareF32(readF32(referenceRawPath), Float32Array.from(candidateResult.lumaF32), expectedWidth, effect.compare);
  timings.compareMs = nowMs() - compareStart;
  timings.totalMs = nowMs() - totalStart;
  const passed = Boolean(comparison.passed);
  if (!passed && workspace.usesTemporaryWorkDir) {
    referenceInfo.output = path.join(workspace.artifactDir, path.basename(referenceRawPath));
  }

  if (!passed || keepArtifacts) {
    if (!fs.existsSync(inputPath)) fs.writeFileSync(inputPath, encodePng(fixture));
    writeF32(candidateRawPath, candidateResult.lumaF32);
    let candidatePreview = candidateResult;
    if (!candidatePreview.rgba) {
      candidatePreview = await readCandidatePreview({ page, effect, fixture, caseTimeoutMs });
    }
    if (candidatePreview.rgba) {
      fs.writeFileSync(candidatePath, encodePng({
        width: candidatePreview.width,
        height: candidatePreview.height,
        rgba: Uint8Array.from(candidatePreview.rgba),
      }));
    }
  }

  const metrics = {
    runId,
    effectId: effect.id,
    fixtureId: fixture.id,
    referenceShader: effect.referenceShader,
    validationMode: effect.validationMode ?? 'luma-math',
    referenceInputFormat: 'luma-f32',
    input: { width: fixture.width, height: fixture.height },
    output: {
      expected: { width: expectedWidth, height: expectedHeight },
      reference: { width: referenceInfo.width, height: referenceInfo.height },
      candidate: { width: candidateResult.width, height: candidateResult.height },
    },
    adapterInfo: candidateResult.adapterInfo,
    referenceInfo,
    referenceCache: referenceInfo.referenceCache,
    timings,
    comparisonPassed: passed,
    ...comparison,
    passed,
  };
  fs.writeFileSync(metricsPath, JSON.stringify(metrics, null, 2));

  if (!passed) materializeFailedCaseArtifact(workspace);
  cleanupCaseWorkspace(workspace, passed);

  const finalCaseDir = passed && !keepArtifacts ? null : workspace.artifactDir;
  return {
    passed,
    metrics,
    caseDir: finalCaseDir,
    metricsPath: finalCaseDir ? path.join(finalCaseDir, 'metrics.json') : null,
  };
  } catch (error) {
    materializeFailedCaseArtifact(workspace);
    throw error;
  }
}

async function runOneRgbMath({ page, effect, fixture, keepArtifacts, caseTimeoutMs, runId, useReferenceCache }) {
  const timings = createEmptyTimings();
  const totalStart = nowMs();
  const workspace = createCaseWorkspace(effect, fixture, keepArtifacts);
  const caseDir = workspace.workDir;
  const inputPath = path.join(caseDir, 'input.png');
  const inputRgbaPath = path.join(caseDir, 'input-rgba.f32');
  const referenceRawPath = path.join(caseDir, 'reference-rgba.f32');
  const candidateRawPath = path.join(caseDir, 'candidate-rgba.f32');
  const candidatePath = path.join(caseDir, 'candidate.png');
  const metricsPath = path.join(caseDir, 'metrics.json');

  try {
  if (keepArtifacts) fs.writeFileSync(inputPath, encodePng(fixture));
  writeF32(inputRgbaPath, rgbaToF32(fixture));
  const referenceStart = nowMs();
  const referenceInfo = renderLibplaceboRgbaReference({
    effect,
    fixture,
    inputPath: inputRgbaPath,
    outputPath: referenceRawPath,
    caseDir,
    timeoutMs: caseTimeoutMs,
    useReferenceCache,
  });
  timings.referenceMs = nowMs() - referenceStart;

  const candidateStart = nowMs();
  const candidatePromise = runCandidate(page, effect, fixture, { includePreview: keepArtifacts });
  const candidateResult = caseTimeoutMs
    ? await withTimeout(candidatePromise, caseTimeoutMs, `candidate ${effect.id} / ${fixture.id}`)
    : await candidatePromise;
  timings.candidateMs = nowMs() - candidateStart;
  if (!candidateResult.rgbaF32) {
    throw new Error(`Candidate did not return rgbaF32 for ${effect.id}.`);
  }

  const expectedWidth = fixture.width * effect.expectedScale;
  const expectedHeight = fixture.height * effect.expectedScale;
  const compareStart = nowMs();
  const dimensionFailure = candidateResult.width !== expectedWidth || candidateResult.height !== expectedHeight
    ? `candidate dimension ${candidateResult.width}x${candidateResult.height} does not match expected ${expectedWidth}x${expectedHeight}`
    : referenceInfo.width !== expectedWidth || referenceInfo.height !== expectedHeight
      ? `reference dimension ${referenceInfo.width}x${referenceInfo.height} does not match expected ${expectedWidth}x${expectedHeight}`
      : null;
  const comparison = dimensionFailure
    ? { passed: false, reason: dimensionFailure }
    : compareF32(
      readF32(referenceRawPath),
      Float32Array.from(candidateResult.rgbaF32),
      expectedWidth,
      { ...effect.compare, components: 4 },
    );
  timings.compareMs = nowMs() - compareStart;
  timings.totalMs = nowMs() - totalStart;
  const passed = Boolean(comparison.passed);
  if (!passed && workspace.usesTemporaryWorkDir) {
    referenceInfo.output = path.join(workspace.artifactDir, path.basename(referenceRawPath));
  }

  if (!passed || keepArtifacts) {
    if (!fs.existsSync(inputPath)) fs.writeFileSync(inputPath, encodePng(fixture));
    writeF32(candidateRawPath, candidateResult.rgbaF32);
    let candidatePreview = candidateResult;
    if (!candidatePreview.rgba) {
      candidatePreview = await readCandidatePreview({ page, effect, fixture, caseTimeoutMs });
    }
    if (candidatePreview.rgba) {
      fs.writeFileSync(candidatePath, encodePng({
        width: candidatePreview.width,
        height: candidatePreview.height,
        rgba: Uint8Array.from(candidatePreview.rgba),
      }));
    }
  }

  const metrics = {
    runId,
    effectId: effect.id,
    fixtureId: fixture.id,
    referenceShader: effect.referenceShader,
    validationMode: effect.validationMode ?? 'rgb-math',
    referenceInputFormat: 'rgba-f32',
    input: { width: fixture.width, height: fixture.height },
    output: {
      expected: { width: expectedWidth, height: expectedHeight },
      reference: { width: referenceInfo.width, height: referenceInfo.height },
      candidate: { width: candidateResult.width, height: candidateResult.height },
    },
    adapterInfo: candidateResult.adapterInfo,
    referenceInfo,
    referenceCache: referenceInfo.referenceCache,
    timings,
    comparisonPassed: passed,
    ...comparison,
    passed,
  };
  fs.writeFileSync(metricsPath, JSON.stringify(metrics, null, 2));

  if (!passed) materializeFailedCaseArtifact(workspace);
  cleanupCaseWorkspace(workspace, passed);

  const finalCaseDir = passed && !keepArtifacts ? null : workspace.artifactDir;
  return {
    passed,
    metrics,
    caseDir: finalCaseDir,
    metricsPath: finalCaseDir ? path.join(finalCaseDir, 'metrics.json') : null,
  };
  } catch (error) {
    materializeFailedCaseArtifact(workspace);
    throw error;
  }
}

async function runOne({ page, effect, fixture, keepArtifacts, caseTimeoutMs, runId, useReferenceCache }) {
  const validationMode = effect.validationMode;
  if (validationMode === 'luma-math') {
    return runOneLumaMath({ page, effect, fixture, keepArtifacts, caseTimeoutMs, runId, useReferenceCache });
  }
  if (validationMode === 'rgb-math') {
    return runOneRgbMath({ page, effect, fixture, keepArtifacts, caseTimeoutMs, runId, useReferenceCache });
  }
  throw new Error(`Unsupported validation mode: ${validationMode ?? '(missing)'}`);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.noBuild) {
    buildVerifyBundle();
  }
  const manifest = createManifest()
    .filter(effect => !args.effectId || effect.id === args.effectId)
    .filter(effect => !args.filter || effect.id.toLowerCase().includes(args.filter.toLowerCase()));
  const fixtures = filterFixtures([...createBuiltInFixtures(), ...loadDatasetFixtures()], args);

  if (manifest.length === 0) throw new Error('No effects matched the selected filter.');
  if (fixtures.length === 0) throw new Error('No fixtures matched the selected filter.');
  const allCases = createCaseList(manifest, fixtures);
  const selectedCases = applyShard(allCases, args.shard);
  if (selectedCases.length === 0) throw new Error('No verification cases matched the selected shard.');

  fs.mkdirSync(artifactsRoot, { recursive: true });
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  let page = await openVerifyPage(browser, server.url);

  const failures = [];
  const cases = [];
  const summaryPath = path.join(artifactsRoot, 'summary.json');
  const startedAt = new Date().toISOString();
  const runId = args.runId
    ?? process.env.VERIFY_RUN_ID
    ?? startedAt.replace(/[^0-9A-Za-z]+/g, '-').replace(/^-|-$/g, '');
  const writeSummary = () => {
    fs.writeFileSync(summaryPath, JSON.stringify(createSummaryPayload({
      runId,
      startedAt,
      finishedAt: null,
      failures,
      cases,
      caseTotal: selectedCases.length,
      args,
    }), null, 2));
  };
  let caseCount = 0;
  try {
    for (const [index, testCase] of selectedCases.entries()) {
      if (index > 0 && args.browserRecycleEvery > 0 && index % args.browserRecycleEvery === 0) {
        await closeVerifyPage(page);
        page = await openVerifyPage(browser, server.url);
      }
      const { effect, fixture: adaptedFixture } = testCase;
      const label = `${effect.id} / ${adaptedFixture.id}`;
      caseCount += 1;
      const caseIndex = index + 1;
      const caseStart = nowMs();
      process.stdout.write(`verify ${caseIndex}/${selectedCases.length} ${label} ... `);
      try {
        const result = await runOne({
          page,
          effect,
          fixture: adaptedFixture,
          keepArtifacts: args.keepArtifacts,
          caseTimeoutMs: args.caseTimeoutMs,
          runId,
          useReferenceCache: args.referenceCache,
        });
        if (result.passed) {
          console.log('ok');
        } else {
          console.log('failed');
          failures.push({ label, result });
          console.log(`  artifact: ${result.caseDir}`);
          console.log(`  reason: ${result.metrics.reason ?? `mean=${result.metrics.meanAbs}, max=${result.metrics.maxAbs}`}`);
        }
        cases.push({
          label,
          caseIndex,
          caseTotal: selectedCases.length,
          effectId: effect.id,
          fixtureId: adaptedFixture.id,
          validationMode: result.metrics.validationMode,
          passed: result.passed,
          timings: result.metrics.timings ?? null,
          referenceMs: result.metrics.timings?.referenceMs ?? null,
          candidateMs: result.metrics.timings?.candidateMs ?? null,
          compareMs: result.metrics.timings?.compareMs ?? null,
          totalMs: result.metrics.timings?.totalMs ?? null,
          referenceCacheHit: result.metrics.referenceCache?.hit ?? null,
          meanAbs: result.metrics.meanAbs ?? null,
          maxAbs: result.metrics.maxAbs ?? null,
          maxPosition: result.metrics.maxPosition ?? null,
          artifact: result.caseDir,
          metricsPath: result.metricsPath,
          reason: result.metrics.reason ?? null,
        });
        writeSummary();
      } catch (error) {
        console.log('error');
        failures.push({ label, error });
        console.log(`  ${error instanceof Error ? error.message : error}`);
        const recyclePage = isCandidateTimeoutError(error);
        if (recyclePage) {
          console.log('  recycling verification page after candidate timeout');
        }
        const elapsedMs = nowMs() - caseStart;
        cases.push({
          label,
          caseIndex,
          caseTotal: selectedCases.length,
          effectId: effect.id,
          fixtureId: adaptedFixture.id,
          passed: false,
          timings: {
            referenceMs: null,
            candidateMs: null,
            compareMs: null,
            totalMs: elapsedMs,
          },
          totalMs: elapsedMs,
          error: error instanceof Error ? error.message : String(error),
        });
        writeSummary();
        if (recyclePage && caseIndex < selectedCases.length) {
          await closeVerifyPage(page);
          page = await openVerifyPage(browser, server.url);
        }
      }
    }
  } finally {
    await closeVerifyPage(page);
    await browser.close();
    await server.close();
  }

  fs.writeFileSync(summaryPath, JSON.stringify(createSummaryPayload({
    runId,
    startedAt,
    finishedAt: new Date().toISOString(),
    failures,
    cases,
    caseTotal: selectedCases.length,
    args,
  }), null, 2));

  if (failures.length > 0) {
    console.error(`${failures.length} verification case(s) failed.`);
    console.error(`Summary: ${summaryPath}`);
    process.exitCode = 1;
    return;
  }
  console.log(`All verification cases passed (${caseCount} cases).`);
  console.log(`Summary: ${summaryPath}`);
}

module.exports = {
  applyShard,
  createCaseList,
  createReferenceCacheKey,
  createSummaryPayload,
  filterFixtures,
  isCandidateTimeoutError,
  parseArgs,
  parseShard,
};

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

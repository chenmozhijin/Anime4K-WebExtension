const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { decodePng, encodePng } = require('./verify/lib/png');
const { startStaticServer } = require('./verify/lib/static-server');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');

function positiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function resolvePathArgument(value, name) {
  if (!value || value.startsWith('--')) {
    throw new Error(`${name} requires a path.`);
  }
  return path.resolve(value);
}

function parseArgs(argv) {
  const args = {
    manifest: null,
    matrix: null,
    output: null,
    workers: 2,
    timeoutMs: 20 * 60 * 1000,
    noBuild: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--manifest') args.manifest = resolvePathArgument(argv[++index], '--manifest');
    else if (arg.startsWith('--manifest=')) args.manifest = resolvePathArgument(arg.slice(11), '--manifest');
    else if (arg === '--matrix') args.matrix = resolvePathArgument(argv[++index], '--matrix');
    else if (arg.startsWith('--matrix=')) args.matrix = resolvePathArgument(arg.slice(9), '--matrix');
    else if (arg === '--output') args.output = resolvePathArgument(argv[++index], '--output');
    else if (arg.startsWith('--output=')) args.output = resolvePathArgument(arg.slice(9), '--output');
    else if (arg === '--workers') args.workers = positiveInteger(argv[++index], '--workers');
    else if (arg.startsWith('--workers=')) args.workers = positiveInteger(arg.slice(10), '--workers');
    else if (arg === '--timeout-ms') args.timeoutMs = positiveInteger(argv[++index], '--timeout-ms');
    else if (arg.startsWith('--timeout-ms=')) args.timeoutMs = positiveInteger(arg.slice(13), '--timeout-ms');
    else throw new Error(`Unknown visual corpus option: ${arg}`);
  }
  for (const name of ['manifest', 'matrix', 'output']) {
    if (!args[name]) throw new Error(`--${name} must be provided.`);
  }
  if (args.workers !== 2) {
    throw new Error('The visual evaluation runner requires exactly two WebGPU workers.');
  }
  return args;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function sha256(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

function writeFileAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.${Date.now()}.tmp`;
  fs.writeFileSync(temporaryPath, value);
  if (fs.existsSync(filePath)) fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function writeJsonAtomic(filePath, value) {
  writeFileAtomic(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  const result = spawnSync(
    process.execPath,
    [webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'],
    { cwd: repoRoot, stdio: 'inherit', windowsHide: true },
  );
  if (result.status !== 0) {
    throw new Error('Failed to build visual corpus browser bundle.');
  }
  copyVerifyHtml();
}

function copyVerifyHtml() {
  fs.mkdirSync(browserOutDir, { recursive: true });
  fs.copyFileSync(
    path.join(repoRoot, 'test', 'verify', 'browser', 'index.html'),
    path.join(browserOutDir, 'index.html'),
  );
}

async function launchBrowser() {
  const launchOptions = {
    headless: true,
    args: ['--enable-unsafe-webgpu'],
  };
  try {
    return await chromium.launch({ ...launchOptions, channel: 'chromium' });
  } catch {
    return chromium.launch(launchOptions);
  }
}

async function openWorkerPage(browser, serverUrl) {
  const page = await browser.newPage();
  page.setDefaultTimeout(30 * 60 * 1000);
  const response = await page.goto(serverUrl);
  if (!response?.ok()) {
    throw new Error(`Visual corpus browser entry failed to load: HTTP ${response?.status() ?? 'unknown'}.`);
  }
  await page.waitForFunction(() => Boolean(window.__runChainVerification));
  return page;
}

async function closeWorkerPage(page) {
  await page.evaluate(() => window.__resetEffectVerification?.()).catch(() => {});
  await page.close().catch(() => {});
}

function resolveInputPath(manifestPath, input) {
  const candidate = path.isAbsolute(input.path)
    ? input.path
    : path.resolve(path.dirname(manifestPath), input.path);
  if (!fs.existsSync(candidate)) {
    throw new Error(`Corpus input is missing: ${candidate}`);
  }
  return candidate;
}

function validateCrop(crop, width, height, inputId) {
  const values = [crop.x, crop.y, crop.width, crop.height];
  if (!values.every(Number.isInteger) || crop.width <= 0 || crop.height <= 0) {
    throw new Error(`Invalid crop dimensions for ${inputId}/${crop.id}.`);
  }
  if (crop.x < 0 || crop.y < 0 || crop.x + crop.width > width || crop.y + crop.height > height) {
    throw new Error(`Crop is outside ${inputId}: ${JSON.stringify(crop)}.`);
  }
}

function cropRgba(image, crop) {
  const rgba = new Uint8Array(crop.width * crop.height * 4);
  const sourceRowBytes = image.width * 4;
  const targetRowBytes = crop.width * 4;
  for (let y = 0; y < crop.height; y += 1) {
    const sourceOffset = (crop.y + y) * sourceRowBytes + crop.x * 4;
    rgba.set(image.rgba.subarray(sourceOffset, sourceOffset + targetRowBytes), y * targetRowBytes);
  }
  return { width: crop.width, height: crop.height, rgba };
}

function buildCases(manifestPath, manifest, matrix) {
  const seenInputs = new Set();
  const seenChains = new Set();
  const selectedInputIds = Array.isArray(matrix.inputIds) ? new Set(matrix.inputIds) : null;
  for (const chain of matrix.chains) {
    if (!chain.id || seenChains.has(chain.id)) throw new Error(`Duplicate or empty chain id: ${chain.id}`);
    seenChains.add(chain.id);
    if (!Array.isArray(chain.effects) && !(chain.preset && chain.tier)) {
      throw new Error(`Chain ${chain.id} must define effects or preset+tier.`);
    }
  }
  const cases = manifest.inputs
    .filter(input => input.enabled !== false && (!selectedInputIds || selectedInputIds.has(input.id)))
    .flatMap(input => {
    if (!input.id || seenInputs.has(input.id)) throw new Error(`Duplicate or empty input id: ${input.id}`);
    seenInputs.add(input.id);
    const inputPath = resolveInputPath(manifestPath, input);
    const bytes = fs.readFileSync(inputPath);
    const inputSha256 = sha256(bytes);
    if (input.sha256 && input.sha256 !== inputSha256) {
      throw new Error(`SHA-256 mismatch for ${input.id}.`);
    }
    const image = decodePng(bytes);
    if (input.width && input.width !== image.width) throw new Error(`Width mismatch for ${input.id}.`);
    if (input.height && input.height !== image.height) throw new Error(`Height mismatch for ${input.id}.`);
    for (const crop of input.crops ?? []) validateCrop(crop, image.width, image.height, input.id);
    return matrix.chains.map(chain => ({
      input,
      inputPath,
      inputSha256,
      sourceImage: image,
      chain,
      targetWidth: image.width * matrix.targetScale,
      targetHeight: image.height * matrix.targetScale,
    }));
    });
  if (selectedInputIds) {
    const missing = [...selectedInputIds].filter(inputId => !seenInputs.has(inputId));
    if (missing.length > 0) throw new Error(`Selected corpus inputs are missing or disabled: ${missing.join(', ')}`);
  }
  return cases;
}

async function resolveEffectIds(page, chains) {
  const resolved = new Map();
  for (const chain of chains) {
    const effectIds = Array.isArray(chain.effects)
      ? [...chain.effects]
      : await page.evaluate(({ preset, tier }) => {
        if (!window.__resolvePresetChain) throw new Error('Preset resolver is not loaded.');
        return window.__resolvePresetChain(preset, tier);
      }, { preset: chain.preset, tier: chain.tier });
    if (effectIds.length === 0) throw new Error(`Chain ${chain.id} resolved to no effects.`);
    resolved.set(chain.id, effectIds);
  }
  return resolved;
}

function materializeCases(cases, matrix, resolvedEffects, outputRoot) {
  return cases.map(candidate => {
    const effectIds = resolvedEffects.get(candidate.chain.id);
    const identity = {
      runnerVersion: matrix.runnerVersion,
      transportVersion: 'png-base64-v1',
      terminalPresentation: true,
      inputSha256: candidate.inputSha256,
      effectIds,
      targetWidth: candidate.targetWidth,
      targetHeight: candidate.targetHeight,
    };
    const caseId = sha256(JSON.stringify(identity));
    const sourceClass = candidate.input.sourceClass ?? 'unclassified';
    const outputPath = path.join(
      outputRoot,
      'outputs',
      sourceClass,
      candidate.input.id,
      `${candidate.chain.id}.png`,
    );
    return {
      ...candidate,
      effectIds,
      identity,
      caseId,
      outputPath,
      checkpointPath: path.join(outputRoot, 'state', 'cases', `${caseId}.json`),
    };
  });
}

function completedCase(candidate) {
  if (!fs.existsSync(candidate.checkpointPath) || !fs.existsSync(candidate.outputPath)) return false;
  try {
    const checkpoint = readJson(candidate.checkpointPath);
    return checkpoint.status === 'complete'
      && checkpoint.caseId === candidate.caseId
      && checkpoint.outputSha256 === sha256(fs.readFileSync(candidate.outputPath));
  } catch {
    return false;
  }
}

async function withTimeout(promise, timeoutMs, label) {
  let timeout;
  try {
    return await Promise.race([
      promise,
      new Promise((_, reject) => {
        timeout = setTimeout(() => reject(new Error(`${label} timed out after ${timeoutMs}ms.`)), timeoutMs);
      }),
    ]);
  } finally {
    clearTimeout(timeout);
  }
}

function writeOutputCrops(candidate, outputImage, targetScale) {
  const cropRecords = [];
  for (const crop of candidate.input.crops ?? []) {
    const outputCrop = {
      x: crop.x * targetScale,
      y: crop.y * targetScale,
      width: crop.width * targetScale,
      height: crop.height * targetScale,
    };
    const cropped = cropRgba(outputImage, outputCrop);
    const cropPath = path.join(
      path.dirname(candidate.outputPath),
      'crops-1x-native',
      `${candidate.chain.id}--${crop.id}.png`,
    );
    const png = encodePng(cropped);
    writeFileAtomic(cropPath, png);
    cropRecords.push({
      id: crop.id,
      sourceCoordinates: crop,
      outputCoordinates: outputCrop,
      path: path.relative(path.dirname(candidate.checkpointPath), cropPath).replaceAll('\\', '/'),
      sha256: sha256(png),
    });
  }
  return cropRecords;
}

async function runCase(page, candidate, matrix, timeoutMs, workerId, attempt) {
  const start = Date.now();
  const inputEncodeStartedAt = Date.now();
  const rgbaBase64 = Buffer.from(
    candidate.sourceImage.rgba.buffer,
    candidate.sourceImage.rgba.byteOffset,
    candidate.sourceImage.rgba.byteLength,
  ).toString('base64');
  const inputEncodeMs = Date.now() - inputEncodeStartedAt;
  const browserCallStartedAt = Date.now();
  const response = await withTimeout(page.evaluate(async request => {
    if (!window.__runChainVerification) throw new Error('Chain runner is not loaded.');
    return window.__runChainVerification(request);
  }, {
    effectIds: candidate.effectIds,
    width: candidate.sourceImage.width,
    height: candidate.sourceImage.height,
    targetWidth: candidate.targetWidth,
    targetHeight: candidate.targetHeight,
    rgbaBase64,
    includePreview: true,
    includeFloatOutput: false,
    outputEncoding: 'png-base64',
    terminalPresentation: true,
  }), timeoutMs, candidate.caseId);
  const browserCallMs = Date.now() - browserCallStartedAt;
  if (!response.pngBase64) throw new Error(`Case ${candidate.caseId} returned no PNG preview.`);
  if (response.width !== candidate.targetWidth || response.height !== candidate.targetHeight) {
    throw new Error(
      `Case ${candidate.caseId} returned ${response.width}x${response.height}; `
      + `expected ${candidate.targetWidth}x${candidate.targetHeight}.`,
    );
  }
  const outputDecodeStartedAt = Date.now();
  const outputPng = Buffer.from(response.pngBase64, 'base64');
  const outputImage = decodePng(outputPng);
  const outputDecodeMs = Date.now() - outputDecodeStartedAt;
  const outputWriteStartedAt = Date.now();
  writeFileAtomic(candidate.outputPath, outputPng);
  const cropRecords = writeOutputCrops(candidate, outputImage, matrix.targetScale);
  const outputWriteAndCropMs = Date.now() - outputWriteStartedAt;
  const checkpoint = {
    schemaVersion: 1,
    status: 'complete',
    caseId: candidate.caseId,
    workerId,
    attempt,
    elapsedMs: Date.now() - start,
    timings: {
      nodeInputBase64Ms: inputEncodeMs,
      browserCallMs,
      ...response.timings,
      playwrightAndProtocolMs: response.timings
        ? Math.max(0, browserCallMs - Object.values(response.timings).reduce((sum, value) => sum + value, 0))
        : null,
      nodeOutputBase64DecodeAndPngDecodeMs: outputDecodeMs,
      nodeOutputWriteAndCropMs: outputWriteAndCropMs,
    },
    input: {
      id: candidate.input.id,
      sha256: candidate.inputSha256,
      width: candidate.sourceImage.width,
      height: candidate.sourceImage.height,
    },
    chain: {
      id: candidate.chain.id,
      effectIds: candidate.effectIds,
    },
    target: { width: response.width, height: response.height },
    runnerVersion: matrix.runnerVersion,
    outputSha256: sha256(outputPng),
    crops: cropRecords,
    passCount: response.passCount,
    peakTextureBytes: response.peakTextureBytes,
    textureSlotCount: response.textureSlotCount,
  };
  writeJsonAtomic(candidate.checkpointPath, checkpoint);
  return checkpoint;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!fs.existsSync(args.manifest)) throw new Error(`Corpus manifest does not exist: ${args.manifest}`);
  if (!fs.existsSync(args.matrix)) throw new Error(`Effect matrix does not exist: ${args.matrix}`);
  const manifest = readJson(args.manifest);
  const matrix = readJson(args.matrix);
  if (!Array.isArray(manifest.inputs) || manifest.inputs.length === 0) {
    throw new Error('Corpus manifest must contain at least one input.');
  }
  if (!manifest.inputs.some(input => input.enabled !== false)) {
    throw new Error('Corpus manifest contains no enabled inputs.');
  }
  if (!Array.isArray(matrix.chains) || matrix.chains.length === 0) {
    throw new Error('Effect matrix must contain at least one chain.');
  }
  if (!Number.isInteger(matrix.targetScale) || matrix.targetScale <= 0) {
    throw new Error('Effect matrix targetScale must be a positive integer.');
  }

  if (!args.noBuild) buildVerifyBundle();
  else copyVerifyHtml();
  const server = await startStaticServer(browserOutDir);
  const browser = await launchBrowser();
  const workerPages = [];
  const failures = [];
  try {
    for (let index = 0; index < args.workers; index += 1) {
      workerPages.push(await openWorkerPage(browser, server.url));
    }
    const resolvedEffects = await resolveEffectIds(workerPages[0], matrix.chains);
    const initialCases = buildCases(args.manifest, manifest, matrix);
    const cases = materializeCases(initialCases, matrix, resolvedEffects, args.output);
    const pendingCases = cases.filter(candidate => !completedCase(candidate));
    const skipped = cases.length - pendingCases.length;
    console.log(`visual evaluation: ${cases.length} cases, ${skipped} complete, ${pendingCases.length} pending`);
    const assignments = Array.from({ length: args.workers }, () => []);
    pendingCases.forEach((candidate, index) => assignments[index % args.workers].push(candidate));

    await Promise.all(assignments.map(async (workerCases, workerIndex) => {
      const workerId = workerIndex + 1;
      let page = workerPages[workerIndex];
      for (let caseIndex = 0; caseIndex < workerCases.length; caseIndex += 1) {
        const candidate = workerCases[caseIndex];
        let complete = false;
        for (let attempt = 1; attempt <= 2 && !complete; attempt += 1) {
          console.log(
            `[worker ${workerId}] ${caseIndex + 1}/${workerCases.length} `
            + `${candidate.input.id} :: ${candidate.chain.id} (attempt ${attempt})`,
          );
          try {
            await runCase(page, candidate, matrix, args.timeoutMs, workerId, attempt);
            complete = true;
          } catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            if (attempt === 1) {
              console.warn(`[worker ${workerId}] retrying after: ${message}`);
              await closeWorkerPage(page);
              page = await openWorkerPage(browser, server.url);
              workerPages[workerIndex] = page;
            } else {
              failures.push({
                caseId: candidate.caseId,
                inputId: candidate.input.id,
                chainId: candidate.chain.id,
                workerId,
                attempts: 2,
                message,
              });
              writeJsonAtomic(candidate.checkpointPath, {
                schemaVersion: 1,
                status: 'failed',
                caseId: candidate.caseId,
                inputId: candidate.input.id,
                chainId: candidate.chain.id,
                workerId,
                attempts: 2,
                message,
              });
            }
          }
        }
      }
    }));

    const summary = {
      schemaVersion: 1,
      runnerVersion: matrix.runnerVersion,
      workers: args.workers,
      totalCases: cases.length,
      skippedCases: skipped,
      attemptedCases: pendingCases.length,
      failedCases: failures.length,
      failures,
    };
    writeJsonAtomic(path.join(args.output, 'run-summary.json'), summary);
    if (failures.length > 0) process.exitCode = 1;
  } finally {
    await Promise.all(workerPages.map(closeWorkerPage));
    await browser.close().catch(() => {});
    await server.close().catch(() => {});
  }
}

module.exports = {
  buildCases,
  materializeCases,
  parseArgs,
  positiveInteger,
  resolveEffectIds,
  resolveInputPath,
  resolvePathArgument,
};

if (require.main === module) {
  main().catch(error => {
    console.error(error);
    process.exitCode = 1;
  });
}

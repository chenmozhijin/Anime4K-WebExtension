const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');

const repoRoot = path.resolve(__dirname, '..');
const browserOutDir = path.join(repoRoot, 'test-results', 'verify', 'browser');
const anime4kPresetIds = new Set(['A', 'B', 'C', 'A+A', 'B+B', 'C+A']);

const optimizationFlagClasses = Object.freeze({
  textureLifetimeReuse: 'exact',
  vectorizedPixelShuffle: 'quantized-equivalent',
  fusedPixelShuffleRecompose: 'quantized-equivalent',
  cunnyWorkgroupTile: 'exact',
  fusedClampHighlights: 'quantized-equivalent',
  acnetWorkgroupTile: 'exact',
  anime4kWorkgroupTile: 'exact',
  multiOutputDispatch: 'exact',
  ganMultiOutputDispatch: 'exact',
  fusedModelTail: 'quantized-equivalent',
  terminalDirect: 'perceptual',
  externalTexture: 'perceptual',
  perceptualShaderF16: 'perceptual',
  kernelAutotune: 'exact',
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
  terminalDirect: true,
  externalTexture: false,
  perceptualShaderF16: false,
  kernelAutotune: true,
});

const benchmarkableFlagVariants = Object.freeze(Object.keys(optimizedFlags)
  .filter(flag => optimizedFlags[flag]));

function positiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function nonNegativeInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed < 0) {
    throw new Error(`${name} must be a non-negative integer.`);
  }
  return parsed;
}

function parseArgs(argv) {
  const args = {
    width: 1920,
    height: 1080,
    targetWidth: 3840,
    targetHeight: 2160,
    warmupFrames: 60,
    warmupMinimumMs: 0,
    frames: 300,
    repeats: 5,
    batchSize: 6,
    tiers: ['performance', 'balanced', 'quality', 'ultra'],
    variants: ['optimized'],
    includeFlagVariants: false,
    enforceAcceptance: false,
    pairedComparison: false,
    effectIds: null,
    presetId: 'A+A',
    microKernel: null,
    workloadId: null,
    video: null,
    output: path.join(repoRoot, 'test-results', 'performance', 'gpu-benchmark.json'),
    noBuild: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--no-build') args.noBuild = true;
    else if (arg === '--width') args.width = positiveInteger(argv[++index], '--width');
    else if (arg.startsWith('--width=')) args.width = positiveInteger(arg.slice(8), '--width');
    else if (arg === '--height') args.height = positiveInteger(argv[++index], '--height');
    else if (arg.startsWith('--height=')) args.height = positiveInteger(arg.slice(9), '--height');
    else if (arg === '--target-width') args.targetWidth = positiveInteger(argv[++index], '--target-width');
    else if (arg.startsWith('--target-width=')) args.targetWidth = positiveInteger(arg.slice(15), '--target-width');
    else if (arg === '--target-height') args.targetHeight = positiveInteger(argv[++index], '--target-height');
    else if (arg.startsWith('--target-height=')) args.targetHeight = positiveInteger(arg.slice(16), '--target-height');
    else if (arg === '--warmup') args.warmupFrames = positiveInteger(argv[++index], '--warmup');
    else if (arg.startsWith('--warmup=')) args.warmupFrames = positiveInteger(arg.slice(9), '--warmup');
    else if (arg === '--warmup-ms') args.warmupMinimumMs = nonNegativeInteger(argv[++index], '--warmup-ms');
    else if (arg.startsWith('--warmup-ms=')) args.warmupMinimumMs = nonNegativeInteger(arg.slice(12), '--warmup-ms');
    else if (arg === '--frames') args.frames = positiveInteger(argv[++index], '--frames');
    else if (arg.startsWith('--frames=')) args.frames = positiveInteger(arg.slice(9), '--frames');
    else if (arg === '--repeats') args.repeats = positiveInteger(argv[++index], '--repeats');
    else if (arg.startsWith('--repeats=')) args.repeats = positiveInteger(arg.slice(10), '--repeats');
    else if (arg === '--batch-size') args.batchSize = positiveInteger(argv[++index], '--batch-size');
    else if (arg.startsWith('--batch-size=')) args.batchSize = positiveInteger(arg.slice(13), '--batch-size');
    else if (arg === '--tiers') args.tiers = argv[++index].split(',');
    else if (arg.startsWith('--tiers=')) args.tiers = arg.slice(8).split(',');
    else if (arg === '--variants') args.variants = argv[++index].split(',');
    else if (arg.startsWith('--variants=')) args.variants = arg.slice(11).split(',');
    else if (arg === '--flag-variants') args.includeFlagVariants = true;
    else if (arg === '--enforce') args.enforceAcceptance = true;
    else if (arg === '--paired') args.pairedComparison = true;
    else if (arg === '--effects') args.effectIds = argv[++index].split(',');
    else if (arg.startsWith('--effects=')) args.effectIds = arg.slice(10).split(',');
    else if (arg === '--preset') args.presetId = argv[++index];
    else if (arg.startsWith('--preset=')) args.presetId = arg.slice(9);
    else if (arg === '--micro') args.microKernel = argv[++index];
    else if (arg.startsWith('--micro=')) args.microKernel = arg.slice(8);
    else if (arg === '--workload-id') args.workloadId = argv[++index];
    else if (arg.startsWith('--workload-id=')) args.workloadId = arg.slice(14);
    else if (arg === '--video') args.video = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--video=')) args.video = path.resolve(repoRoot, arg.slice(8));
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else throw new Error(`Unknown GPU benchmark option: ${arg}`);
  }
  args.variants = [...new Set(args.variants.map(value => value.trim()).filter(Boolean))];
  if (args.includeFlagVariants) {
    args.variants.push(...benchmarkableFlagVariants.map(flag => `flag:${flag}`));
    args.variants = [...new Set(args.variants)];
  }
  for (const variant of args.variants) {
    resolveOptimizationVariant(variant);
  }
  if (args.effectIds && args.microKernel) {
    throw new Error('Pass either --effects or --micro, not both.');
  }
  if (!anime4kPresetIds.has(args.presetId)) {
    throw new Error(`Unknown Anime4K preset: ${args.presetId}`);
  }
  if (args.microKernel && args.microKernel !== 'depth-to-space') {
    throw new Error(`Unknown GPU micro-kernel: ${args.microKernel}`);
  }
  if (args.video && !fs.existsSync(args.video)) {
    throw new Error(`GPU benchmark video does not exist: ${args.video}`);
  }
  if (args.pairedComparison && !args.variants.includes('baseline')) {
    throw new Error('Paired GPU comparison requires the baseline variant.');
  }
  if (args.pairedComparison && args.repeats < 2) {
    throw new Error('Paired GPU comparison requires at least two repeats.');
  }
  return args;
}

function disabledOptimizationFlags() {
  return Object.fromEntries(Object.keys(optimizationFlagClasses).map(flag => [flag, false]));
}

function resolveOptimizationVariant(id) {
  if (id === 'baseline') {
    return { id, correctness: 'exact', flags: disabledOptimizationFlags() };
  }
  if (id === 'exact') {
    const flags = disabledOptimizationFlags();
    for (const [flag, correctness] of Object.entries(optimizationFlagClasses)) {
      flags[flag] = correctness === 'exact' && optimizedFlags[flag];
    }
    return { id, correctness: 'exact', flags };
  }
  if (id === 'quantized') {
    const flags = disabledOptimizationFlags();
    for (const [flag, correctness] of Object.entries(optimizationFlagClasses)) {
      flags[flag] = correctness !== 'perceptual' && optimizedFlags[flag];
    }
    return { id, correctness: 'quantized-equivalent', flags };
  }
  if (id === 'optimized') {
    return { id, correctness: 'perceptual', flags: { ...optimizedFlags } };
  }
  if (id.startsWith('flag:')) {
    const flag = id.slice(5);
    const correctness = optimizationFlagClasses[flag];
    if (!correctness) {
      throw new Error(`Unknown optimization flag variant: ${flag}`);
    }
    return {
      id,
      correctness,
      flags: { ...disabledOptimizationFlags(), [flag]: true },
    };
  }
  throw new Error(`Unknown GPU benchmark variant: ${id}`);
}

function getMetricStatistics(tier) {
  return tier.aggregate.gpuMs?.statistics ?? tier.aggregate.endToEndMs.statistics;
}

function percentChange(baseline, candidate) {
  return baseline === 0 ? 0 : (baseline - candidate) / baseline * 100;
}

function buildComparisons(variantReports) {
  const baseline = variantReports.find(variant => variant.id === 'baseline');
  if (!baseline) {
    return [];
  }
  return variantReports.filter(variant => variant !== baseline).map(variant => ({
    variant: variant.id,
    correctness: variant.correctness,
    tiers: variant.report.tiers.map(candidateTier => {
      const baselineTier = baseline.report.tiers.find(tier => tier.tier === candidateTier.tier);
      if (!baselineTier) {
        throw new Error(`Baseline report is missing tier ${candidateTier.tier}.`);
      }
      const baselineMetric = getMetricStatistics(baselineTier);
      const candidateMetric = getMetricStatistics(candidateTier);
      const gpuP50GainPercent = percentChange(baselineMetric.p50, candidateMetric.p50);
      const gpuP95GainPercent = percentChange(baselineMetric.p95, candidateMetric.p95);
      const gpuP99GainPercent = percentChange(baselineMetric.p99, candidateMetric.p99);
      const peakTextureReductionPercent = percentChange(
        baselineTier.peakTextureBytes,
        candidateTier.peakTextureBytes,
      );
      const passReductionPercent = percentChange(baselineTier.passCount, candidateTier.passCount);
      const noMajorRegression = gpuP50GainPercent >= -2;
      const meetsPrimaryTarget = gpuP50GainPercent >= 3 || peakTextureReductionPercent >= 20;
      const structurallyNeutral = Math.abs(peakTextureReductionPercent) < 1e-9
        && Math.abs(passReductionPercent) < 1e-9;
      return {
        tier: candidateTier.tier,
        baseline: {
          passCount: baselineTier.passCount,
          peakTextureBytes: baselineTier.peakTextureBytes,
          p50Ms: baselineMetric.p50,
          p95Ms: baselineMetric.p95,
          p99Ms: baselineMetric.p99,
        },
        candidate: {
          passCount: candidateTier.passCount,
          peakTextureBytes: candidateTier.peakTextureBytes,
          p50Ms: candidateMetric.p50,
          p95Ms: candidateMetric.p95,
          p99Ms: candidateMetric.p99,
        },
        gpuP50GainPercent,
        gpuP95GainPercent,
        gpuP99GainPercent,
        peakTextureReductionPercent,
        passReductionPercent,
        acceptance: {
          minimumGpuGainPercent: 3,
          minimumPeakTextureReductionPercent: 20,
          maximumRegressionPercent: 2,
          meetsPrimaryTarget,
          structurallyNeutral,
          noMajorRegression,
          passed: noMajorRegression && (meetsPrimaryTarget || structurallyNeutral),
        },
      };
    }),
  }));
}

function summarizeSamples(samples) {
  if (samples.length === 0) {
    return {
      count: 0,
      mean: 0,
      median: 0,
      p50: 0,
      p95: 0,
      p99: 0,
      min: 0,
      max: 0,
      standardDeviation: 0,
      coefficientOfVariation: 0,
    };
  }
  const sorted = [...samples].sort((left, right) => left - right);
  const mean = samples.reduce((sum, value) => sum + value, 0) / samples.length;
  const variance = samples.reduce((sum, value) => sum + (value - mean) ** 2, 0) / samples.length;
  const standardDeviation = Math.sqrt(variance);
  const percentile = fraction => sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * fraction))];
  const p50 = percentile(0.5);
  return {
    count: samples.length,
    mean,
    median: p50,
    p50,
    p95: percentile(0.95),
    p99: percentile(0.99),
    min: sorted[0],
    max: sorted[sorted.length - 1],
    standardDeviation,
    coefficientOfVariation: mean === 0 ? 0 : standardDeviation / mean,
  };
}

function mergeMetricReports(repeats, key) {
  const samples = repeats.flatMap(repeat => repeat[key]?.samples ?? []);
  return samples.length > 0 ? { samples, statistics: summarizeSamples(samples) } : null;
}

function aggregateRepeatReports(repeats) {
  return {
    gpuMs: mergeMetricReports(repeats, 'gpuMs'),
    encodeMs: mergeMetricReports(repeats, 'encodeMs'),
    uploadMs: mergeMetricReports(repeats, 'uploadMs'),
    submitMs: mergeMetricReports(repeats, 'submitMs'),
    queueCompletionMs: mergeMetricReports(repeats, 'queueCompletionMs'),
    endToEndMs: mergeMetricReports(repeats, 'endToEndMs'),
    fps: repeats.reduce((sum, repeat) => sum + repeat.fps, 0) / Math.max(1, repeats.length),
  };
}

function mergeTierReports(tierReports) {
  if (tierReports.length === 0) {
    throw new Error('Cannot merge an empty GPU tier report set.');
  }
  const [first] = tierReports;
  for (const report of tierReports.slice(1)) {
    // Never merge samples from different compiled plans. A pass/resource change is
    // a different workload even if the user-facing tier name is unchanged.
    if (
      report.tier !== first.tier
      || report.passCount !== first.passCount
      || report.peakTextureBytes !== first.peakTextureBytes
      || report.planHash !== first.planHash
    ) {
      throw new Error(`Paired GPU reports disagree for tier ${first.tier}.`);
    }
  }
  const repeats = tierReports
    .flatMap(report => report.repeats)
    .map((repeat, index) => ({ ...repeat, repeat: index + 1 }));
  return {
    ...first,
    warmupFramesExecuted: tierReports.reduce((sum, report) => sum + report.warmupFramesExecuted, 0),
    warmupMs: tierReports.reduce((sum, report) => sum + report.warmupMs, 0),
    warmupRuns: tierReports.map(report => ({
      frames: report.warmupFramesExecuted,
      milliseconds: report.warmupMs,
    })),
    repeats,
    aggregate: aggregateRepeatReports(repeats),
  };
}

function mergeVariantRuns(variant, runs, tierOrder, expectedRepeats) {
  if (runs.length === 0) {
    throw new Error(`No GPU benchmark runs were recorded for ${variant.id}.`);
  }
  const template = runs[0];
  const tiers = tierOrder.map(tierId => {
    const reports = runs.flatMap(run => run.tiers.filter(tier => tier.tier === tierId));
    const merged = mergeTierReports(reports);
    if (merged.repeats.length !== expectedRepeats) {
      throw new Error(
        `Paired GPU benchmark ${variant.id}/${tierId} recorded ${merged.repeats.length} repeats, expected ${expectedRepeats}.`,
      );
    }
    return merged;
  });
  return {
    ...variant,
    report: {
      ...template,
      timestamp: new Date().toISOString(),
      measurement: { ...template.measurement, repeats: expectedRepeats },
      tiers,
      pairedComparison: true,
    },
  };
}

function writeJsonAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.tmp`;
  fs.writeFileSync(temporaryPath, JSON.stringify(value, null, 2));
  fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  const result = spawnSync(process.execPath, [webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], {
    cwd: repoRoot,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error('Failed to build GPU benchmark browser bundle.');
  }
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
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(30 * 60 * 1000);
    await page.goto(server.url);
    await page.waitForFunction(() => Boolean(window.__runGpuPerformanceSuite));
    const build = getBuildIdentity();
    let videoUrl;
    if (args.video) {
      const assetDirectory = path.join(browserOutDir, 'benchmark-assets');
      fs.mkdirSync(assetDirectory, { recursive: true });
      const assetName = `${Date.now()}-${path.basename(args.video)}`;
      fs.copyFileSync(args.video, path.join(assetDirectory, assetName));
      videoUrl = new URL(`benchmark-assets/${encodeURIComponent(assetName)}`, server.url).href;
    }
    const runVariant = async ({ variant, tiers, repeats, runLabel }) => {
      console.log(`benchmark variant ${variant.id}${runLabel ? ` (${runLabel})` : ''} ...`);
      const report = await page.evaluate(async request => {
        if (!window.__runGpuPerformanceSuite) throw new Error('GPU performance suite is not loaded.');
        return window.__runGpuPerformanceSuite(request);
      }, {
        width: args.width,
        height: args.height,
        targetWidth: args.targetWidth,
        targetHeight: args.targetHeight,
        warmupFrames: args.warmupFrames,
        warmupMinimumMs: args.warmupMinimumMs,
        frames: args.frames,
        repeats,
        batchSize: args.batchSize,
        tiers,
        optimizationFlags: variant.flags,
        effectIds: args.effectIds,
        presetId: args.presetId,
        microKernel: args.microKernel,
        workloadId: args.workloadId,
        videoUrl,
      });
      report.build = build;
      for (const tier of report.tiers) {
        const gpu = tier.aggregate.gpuMs?.statistics;
        const endToEnd = tier.aggregate.endToEndMs.statistics;
        console.log(
          `${variant.id}/${tier.tier}: passes=${tier.passCount}, textures=${tier.textureSlotCount}, `
          + `gpu p50/p95/p99=${gpu ? `${gpu.p50.toFixed(2)}/${gpu.p95.toFixed(2)}/${gpu.p99.toFixed(2)}ms` : 'n/a'}, `
          + `end-to-end p50=${endToEnd.p50.toFixed(2)}ms, fps=${tier.aggregate.fps.toFixed(2)}`,
        );
      }
      return report;
    };

    let variantReports;
    if (args.pairedComparison && args.variants.length > 1) {
      const variants = args.variants.map(resolveOptimizationVariant);
      const baseline = variants.find(variant => variant.id === 'baseline');
      const candidates = variants.filter(variant => variant.id !== 'baseline');
      const runsByVariant = new Map(variants.map(variant => [variant.id, []]));
      const beforeRepeats = Math.ceil(args.repeats / 2);
      const afterRepeats = Math.floor(args.repeats / 2);
      const workloadTierId = args.microKernel
        ? args.workloadId ?? `micro:${args.microKernel}`
        : args.effectIds
          ? args.workloadId ?? args.effectIds.join('+')
          : `preset:${args.presetId}`;
      const comparisonCases = workloadTierId
        ? [{ tierId: workloadTierId, requestTiers: [args.tiers[0]] }]
        : args.tiers.map(tier => ({ tierId: tier, requestTiers: [tier] }));
      for (const [tierIndex, comparisonCase] of comparisonCases.entries()) {
        const { tierId, requestTiers } = comparisonCase;
        runsByVariant.get(baseline.id).push(await runVariant({
          variant: baseline,
          tiers: requestTiers,
          repeats: beforeRepeats,
          runLabel: `${tierId}/baseline-before`,
        }));
        // Alternate candidate order by tier, then run the reverse order. This keeps
        // thermal/clock drift and shader-cache warming from systematically favoring
        // whichever implementation happens to run last.
        const forwardOrder = tierIndex % 2 === 0 ? candidates : [...candidates].reverse();
        for (const candidate of forwardOrder) {
          runsByVariant.get(candidate.id).push(await runVariant({
            variant: candidate,
            tiers: requestTiers,
            repeats: beforeRepeats,
            runLabel: `${tierId}/forward`,
          }));
        }
        for (const candidate of [...forwardOrder].reverse()) {
          runsByVariant.get(candidate.id).push(await runVariant({
            variant: candidate,
            tiers: requestTiers,
            repeats: afterRepeats,
            runLabel: `${tierId}/reverse`,
          }));
        }
        runsByVariant.get(baseline.id).push(await runVariant({
          variant: baseline,
          tiers: requestTiers,
          repeats: afterRepeats,
          runLabel: `${tierId}/baseline-after`,
        }));
      }
      variantReports = variants.map(variant => mergeVariantRuns(
        variant,
        runsByVariant.get(variant.id),
        comparisonCases.map(comparisonCase => comparisonCase.tierId),
        args.repeats,
      ));
    } else {
      variantReports = [];
      for (const variantId of args.variants) {
        const variant = resolveOptimizationVariant(variantId);
        const report = await runVariant({
          variant,
          tiers: args.tiers,
          repeats: args.repeats,
          runLabel: '',
        });
        variantReports.push({ ...variant, report });
      }
    }

    const comparisons = buildComparisons(variantReports);
    const report = variantReports.length === 1
      ? { ...variantReports[0].report, benchmarkVariant: variantReports[0].id }
      : {
        schemaVersion: 2,
        timestamp: new Date().toISOString(),
        measurement: {
          width: args.width,
          height: args.height,
          targetWidth: args.targetWidth,
          targetHeight: args.targetHeight,
          warmupFrames: args.warmupFrames,
          warmupMinimumMs: args.warmupMinimumMs,
          frames: args.frames,
          repeats: args.repeats,
          batchSize: args.batchSize,
          tiers: args.tiers,
          effectIds: args.effectIds,
          presetId: args.presetId,
          microKernel: args.microKernel,
          workloadId: args.workloadId,
          video: args.video,
          pairedComparison: args.pairedComparison,
        },
        build,
        variants: variantReports,
        comparisons,
      };
    writeJsonAtomic(args.output, report);
    if (args.enforceAcceptance) {
      const failures = comparisons.flatMap(comparison => comparison.tiers
        .filter(tier => !tier.acceptance.passed)
        .map(tier => `${comparison.variant}/${tier.tier}`));
      if (failures.length > 0) {
        throw new Error(`GPU performance acceptance failed: ${failures.join(', ')}`);
      }
    }
    console.log(`GPU benchmark report: ${args.output}`);
  } finally {
    await browser.close();
    await server.close();
  }
}

module.exports = {
  benchmarkableFlagVariants,
  buildComparisons,
  optimizationFlagClasses,
  optimizedFlags,
  parseArgs,
  resolveOptimizationVariant,
};

if (require.main === module) {
  main().catch(error => {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  });
}

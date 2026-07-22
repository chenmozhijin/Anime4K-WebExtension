const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const benchmarkScript = path.join(repoRoot, 'scripts', 'benchmark-gpu-suite.js');

const singleEffectWorkloads = Object.freeze([
  { id: 'clamp-highlights', effectId: 'anime4k/Helper/ClampHighlights', targetScale: 1 },
  { id: 'anime4k-cnnx2m', effectId: 'anime4k/Upscale/CNNx2M', targetScale: 2 },
  { id: 'acnet-f8b4', effectId: 'acnet/Upscale/F8B4', targetScale: 2 },
  { id: 'cunny-2x12-ds', effectId: 'cunny/Upscale/DS/2x12', targetScale: 2 },
  { id: 'artcnn-c4f32', effectId: 'artcnn/Upscale/C4F32', targetScale: 2 },
]);

function positiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function parseArgs(argv) {
  const args = {
    width: 1920,
    height: 1080,
    warmupFrames: 60,
    warmupMinimumMs: 2000,
    frames: 300,
    repeats: 5,
    batchSize: 6,
    variants: 'baseline,exact,quantized,optimized',
    output: path.join(repoRoot, 'test-results', 'performance', 'gpu-benchmark-layers.json'),
    videoManifest: path.join(repoRoot, 'test-results', 'video-fixtures', 'manifest.json'),
    includeAllVideos: false,
    skipVideo: false,
    resume: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--width') args.width = positiveInteger(argv[++index], '--width');
    else if (arg.startsWith('--width=')) args.width = positiveInteger(arg.slice(8), '--width');
    else if (arg === '--height') args.height = positiveInteger(argv[++index], '--height');
    else if (arg.startsWith('--height=')) args.height = positiveInteger(arg.slice(9), '--height');
    else if (arg === '--warmup') args.warmupFrames = positiveInteger(argv[++index], '--warmup');
    else if (arg.startsWith('--warmup=')) args.warmupFrames = positiveInteger(arg.slice(9), '--warmup');
    else if (arg === '--warmup-ms') args.warmupMinimumMs = positiveInteger(argv[++index], '--warmup-ms');
    else if (arg.startsWith('--warmup-ms=')) args.warmupMinimumMs = positiveInteger(arg.slice(12), '--warmup-ms');
    else if (arg === '--frames') args.frames = positiveInteger(argv[++index], '--frames');
    else if (arg.startsWith('--frames=')) args.frames = positiveInteger(arg.slice(9), '--frames');
    else if (arg === '--repeats') args.repeats = positiveInteger(argv[++index], '--repeats');
    else if (arg.startsWith('--repeats=')) args.repeats = positiveInteger(arg.slice(10), '--repeats');
    else if (arg === '--batch-size') args.batchSize = positiveInteger(argv[++index], '--batch-size');
    else if (arg.startsWith('--batch-size=')) args.batchSize = positiveInteger(arg.slice(13), '--batch-size');
    else if (arg === '--variants') args.variants = argv[++index];
    else if (arg.startsWith('--variants=')) args.variants = arg.slice(11);
    else if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else if (arg === '--video-manifest') args.videoManifest = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--video-manifest=')) args.videoManifest = path.resolve(repoRoot, arg.slice(17));
    else if (arg === '--all-videos') args.includeAllVideos = true;
    else if (arg === '--skip-video') args.skipVideo = true;
    else if (arg === '--resume') args.resume = true;
    else if (arg === '--smoke') Object.assign(args, {
      width: 64,
      height: 48,
      warmupFrames: 2,
      warmupMinimumMs: 0,
      frames: 6,
      repeats: 1,
      batchSize: 2,
      variants: 'baseline,optimized',
      videoManifest: path.join(repoRoot, 'test-results', 'video-fixtures-smoke', 'manifest.json'),
    });
    else throw new Error(`Unknown layered GPU benchmark option: ${arg}`);
  }
  return args;
}

function writeJsonAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.tmp`;
  fs.writeFileSync(temporaryPath, JSON.stringify(value, null, 2));
  fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function runNode(args, label) {
  console.log(`${label} ...`);
  const result = spawnSync(process.execPath, args, {
    cwd: repoRoot,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error(`${label} failed.`);
  }
}

function runBenchmark(args, commandArgs, label, output) {
  if (args.resume && fs.existsSync(output)) {
    const report = readReport(output);
    const measurement = report.measurement ?? report.variants?.[0]?.report?.measurement;
    const reportVariants = report.variants?.map(variant => variant.id) ?? [report.benchmarkVariant];
    const reusable = measurement?.warmupFrames === args.warmupFrames
      && measurement?.warmupMinimumMs === args.warmupMinimumMs
      && measurement?.frames === args.frames
      && measurement?.repeats === args.repeats
      && reportVariants.join(',') === args.variants;
    if (reusable) {
      console.log(`reuse ${label}: ${output}`);
      return;
    }
    console.log(`rerun stale ${label}: ${output}`);
  }
  runNode(commandArgs, label);
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  runNode([webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], 'build benchmark bundle');
  fs.copyFileSync(
    path.join(repoRoot, 'test', 'verify', 'browser', 'index.html'),
    path.join(repoRoot, 'test-results', 'verify', 'browser', 'index.html'),
  );
}

function commonArgs(args, output) {
  const common = [
    benchmarkScript,
    '--no-build',
    '--width', String(args.width),
    '--height', String(args.height),
    '--warmup', String(args.warmupFrames),
    '--warmup-ms', String(args.warmupMinimumMs),
    '--frames', String(args.frames),
    '--repeats', String(args.repeats),
    '--batch-size', String(args.batchSize),
    '--variants', args.variants,
    '--output', output,
  ];
  if (args.repeats >= 2 && args.variants.split(',').includes('baseline')) {
    common.push('--paired');
  }
  return common;
}

function readReport(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function loadVideoFixtures(args) {
  if (args.skipVideo) {
    return [];
  }
  if (!fs.existsSync(args.videoManifest)) {
    throw new Error(`Video fixture manifest does not exist: ${args.videoManifest}`);
  }
  const manifest = JSON.parse(fs.readFileSync(args.videoManifest, 'utf8'));
  const fixtures = args.includeAllVideos ? manifest.fixtures : manifest.fixtures.slice(0, 1);
  return fixtures.map(fixture => ({
    id: fixture.id,
    file: path.join(path.dirname(args.videoManifest), fixture.file),
    width: Number(fixture.stream.width ?? manifest.width),
    height: Number(fixture.stream.height ?? manifest.height),
  }));
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const outputDirectory = path.join(path.dirname(args.output), 'layers');
  fs.mkdirSync(outputDirectory, { recursive: true });
  buildVerifyBundle();

  const layers = { microKernel: [], singleEffect: [], preset: [], videoEndToEnd: [] };
  const microOutput = path.join(outputDirectory, 'micro-depth-to-space.json');
  runBenchmark(args, [
    ...commonArgs(args, microOutput),
    '--target-width', String(args.width * 2),
    '--target-height', String(args.height * 2),
    '--micro', 'depth-to-space',
    '--workload-id', 'depth-to-space',
  ], 'benchmark micro-kernel depth-to-space', microOutput);
  layers.microKernel.push(readReport(microOutput));

  for (const workload of singleEffectWorkloads) {
    const output = path.join(outputDirectory, `effect-${workload.id}.json`);
    runBenchmark(args, [
      ...commonArgs(args, output),
      '--target-width', String(args.width * workload.targetScale),
      '--target-height', String(args.height * workload.targetScale),
      '--effects', workload.effectId,
      '--workload-id', workload.id,
    ], `benchmark single effect ${workload.id}`, output);
    layers.singleEffect.push(readReport(output));
  }

  const presetOutput = path.join(outputDirectory, 'preset-a-plus-a.json');
  runBenchmark(args, [
    ...commonArgs(args, presetOutput),
    '--target-width', String(args.width * 2),
    '--target-height', String(args.height * 2),
    '--tiers', 'performance,balanced,quality,ultra',
  ], 'benchmark full A+A preset', presetOutput);
  layers.preset.push(readReport(presetOutput));

  for (const fixture of loadVideoFixtures(args)) {
    const output = path.join(outputDirectory, `video-${fixture.id}.json`);
    runBenchmark(args, [
      ...commonArgs(args, output),
      '--video', fixture.file,
      '--target-width', String(fixture.width * 2),
      '--target-height', String(fixture.height * 2),
      '--tiers', 'performance',
      '--workload-id', `video:${fixture.id}`,
    ], `benchmark video ${fixture.id}`, output);
    layers.videoEndToEnd.push(readReport(output));
  }

  const report = {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    measurement: {
      width: args.width,
      height: args.height,
      warmupFrames: args.warmupFrames,
      frames: args.frames,
      repeats: args.repeats,
      batchSize: args.batchSize,
      variants: args.variants.split(','),
    },
    videoManifest: args.skipVideo ? null : args.videoManifest,
    layers,
  };
  writeJsonAtomic(args.output, report);
  console.log(`Layered GPU benchmark report: ${args.output}`);
}

module.exports = { parseArgs, singleEffectWorkloads };

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  }
}

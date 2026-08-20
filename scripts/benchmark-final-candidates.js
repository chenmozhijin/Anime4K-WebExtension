const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const benchmarkScript = path.join(repoRoot, 'scripts', 'benchmark-gpu-suite.js');
const defaultOutputRoot = path.join(repoRoot, 'test-results', 'performance', 'final-candidates');

const candidates = Object.freeze([
  { id: 'cunny-faster-ds', label: 'CuNNy Faster DS', effects: ['cunny/Upscale/DS/Faster'] },
  { id: 'cunny-4x16-ds', label: 'CuNNy 4x16 DS', effects: ['cunny/Upscale/DS/4x16'] },
  { id: 'acnet-f8b8-box-hdn', label: 'ACNet F8B8 Box HDN', effects: ['acnet/Upscale/F8B8_BOX_HDN'] },
  { id: 'acnet-f8b18-box-hdn', label: 'ACNet F8B18 Box HDN', effects: ['acnet/Upscale/F8B18_BOX_HDN'] },
  { id: 'anime4k-c-performance', label: 'Anime4K C / performance', preset: 'C', tier: 'performance' },
  { id: 'artcnn-c4f16-ds', label: 'ArtCNN C4F16 DS (soft option)', effects: ['artcnn/Upscale/C4F16_DS'] },
]);

const workloads = Object.freeze([
  { id: '360p-to-720p', width: 640, height: 360, targetWidth: 1280, targetHeight: 720 },
  { id: '540p-to-1080p', width: 960, height: 540, targetWidth: 1920, targetHeight: 1080 },
  { id: '1080p-to-4k', width: 1920, height: 1080, targetWidth: 3840, targetHeight: 2160 },
]);

const defaultMeasurement = Object.freeze({ warmupFrames: 120, frames: 300, repeats: 3, batchSize: 1 });

function parseArgs(argv) {
  const args = { outputRoot: defaultOutputRoot, batchSize: defaultMeasurement.batchSize };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--batch-size') args.batchSize = Number.parseInt(argv[++index], 10);
    else if (arg.startsWith('--batch-size=')) args.batchSize = Number.parseInt(arg.slice(13), 10);
    else if (arg === '--output-dir') args.outputRoot = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output-dir=')) args.outputRoot = path.resolve(repoRoot, arg.slice(13));
    else throw new Error(`Unknown final candidate benchmark option: ${arg}`);
  }
  if (!Number.isInteger(args.batchSize) || args.batchSize <= 0) {
    throw new Error('--batch-size must be a positive integer.');
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
  if (result.status !== 0) throw new Error(`${label} failed.`);
}

function buildVerifyBundle() {
  const webpackCli = path.join(repoRoot, 'node_modules', 'webpack-cli', 'bin', 'cli.js');
  runNode([webpackCli, '--config', 'webpack.verify.config.js', '--mode', 'development'], 'build benchmark bundle');
  fs.copyFileSync(
    path.join(repoRoot, 'test', 'verify', 'browser', 'index.html'),
    path.join(repoRoot, 'test-results', 'verify', 'browser', 'index.html'),
  );
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function reportMatches(report, workload, candidate, measurement) {
  const actual = report.measurement;
  return report.input?.width === workload.width
    && report.input?.height === workload.height
    && report.target?.width === workload.targetWidth
    && report.target?.height === workload.targetHeight
    && actual?.warmupFrames === measurement.warmupFrames
    && actual?.frames === measurement.frames
    && actual?.repeats === measurement.repeats
    && actual?.batchSize === measurement.batchSize
    && report.benchmarkVariant === 'optimized'
    && report.workload?.id === candidate.id;
}

function queryNvidiaGpu() {
  const result = spawnSync('nvidia-smi', [
    '--query-gpu=name,driver_version,memory.total,pci.bus_id',
    '--format=csv,noheader,nounits',
  ], { cwd: repoRoot, encoding: 'utf8', windowsHide: true });
  if (result.status !== 0) return null;
  const [name, driverVersion, memoryMiB, pciBusId] = result.stdout.trim().split(',').map(value => value.trim());
  return { name, driverVersion, memoryMiB: Number(memoryMiB), pciBusId };
}

function summarize(report, candidate, workload) {
  const tier = report.tiers[0];
  const e2e = tier.aggregate.endToEndMs.statistics;
  const gpu = tier.aggregate.gpuMs?.statistics ?? null;
  return {
    candidate: { id: candidate.id, label: candidate.label },
    workload,
    passCount: tier.passCount,
    peakTextureBytes: tier.peakTextureBytes,
    textureSlotCount: tier.textureSlotCount,
    warmupFramesExecuted: tier.warmupFramesExecuted,
    warmupMs: tier.warmupMs,
    gpuMs: gpu,
    endToEndMs: e2e,
    fps: tier.aggregate.fps,
    eligibility: {
      fps24: e2e.p95 <= 33.3,
      fps30: e2e.p95 <= 26.7,
      fps60: e2e.p95 <= 13.3,
    },
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const outputRoot = args.outputRoot;
  const measurement = { ...defaultMeasurement, batchSize: args.batchSize };
  fs.mkdirSync(outputRoot, { recursive: true });
  buildVerifyBundle();
  const cases = [];
  for (const workload of workloads) {
    for (const candidate of candidates) {
      const output = path.join(outputRoot, `${workload.id}__${candidate.id}.json`);
      if (fs.existsSync(output)) {
        const existing = readJson(output);
        if (reportMatches(existing, workload, candidate, measurement)) {
          console.log(`reuse ${workload.id}/${candidate.id}`);
          cases.push(summarize(existing, candidate, workload));
          continue;
        }
      }
      const args = [
        benchmarkScript,
        '--no-build',
        '--width', String(workload.width),
        '--height', String(workload.height),
        '--target-width', String(workload.targetWidth),
        '--target-height', String(workload.targetHeight),
        '--warmup', String(measurement.warmupFrames),
        '--frames', String(measurement.frames),
        '--repeats', String(measurement.repeats),
        '--batch-size', String(measurement.batchSize),
        '--variants', 'optimized',
        '--workload-id', candidate.id,
        '--output', output,
      ];
      if (candidate.effects) args.push('--effects', candidate.effects.join(','));
      else args.push('--preset', candidate.preset, '--tiers', candidate.tier);
      runNode(args, `benchmark ${workload.id}/${candidate.id}`);
      const report = readJson(output);
      cases.push(summarize(report, candidate, workload));
      writeJsonAtomic(path.join(outputRoot, 'summary.json'), {
        schemaVersion: 1,
        status: 'running',
        updatedAt: new Date().toISOString(),
        measurement,
        gpu: queryNvidiaGpu(),
        cases,
      });
    }
  }
  writeJsonAtomic(path.join(outputRoot, 'summary.json'), {
    schemaVersion: 1,
    status: 'complete',
    updatedAt: new Date().toISOString(),
    measurement,
    gpu: queryNvidiaGpu(),
    cases,
  });
  console.log(`Final candidate benchmark summary: ${path.join(outputRoot, 'summary.json')}`);
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.stack : error);
    process.exitCode = 1;
  }
}

module.exports = { candidates, workloads, defaultMeasurement, parseArgs, reportMatches, summarize };

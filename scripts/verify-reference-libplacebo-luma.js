const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { createManifest, repoRoot } = require('./verify/lib/manifest');
const { requireUcrt64Root } = require('./verify/lib/native-tools');

const runnerPath = path.join(repoRoot, '.cache', 'verify-tools', 'native', 'libplacebo-luma-runner.exe');

function parseArgs(argv) {
  const args = {
    effectId: null,
    filter: null,
    outputDir: null,
    width: 64,
    height: 48,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--effect-id') args.effectId = argv[++index];
    else if (arg.startsWith('--effect-id=')) args.effectId = arg.slice('--effect-id='.length);
    else if (arg === '--filter') args.filter = argv[++index];
    else if (arg.startsWith('--filter=')) args.filter = arg.slice('--filter='.length);
    else if (arg === '--output-dir') args.outputDir = argv[++index];
    else if (arg.startsWith('--output-dir=')) args.outputDir = arg.slice('--output-dir='.length);
    else if (arg === '--width') args.width = Number(argv[++index]);
    else if (arg.startsWith('--width=')) args.width = Number(arg.slice('--width='.length));
    else if (arg === '--height') args.height = Number(argv[++index]);
    else if (arg.startsWith('--height=')) args.height = Number(arg.slice('--height='.length));
  }
  return args;
}

function main() {
  if (!fs.existsSync(runnerPath)) {
    throw new Error('libplacebo LUMA runner is not built. Run npm run verify:reference-libplacebo:build-luma first.');
  }

  const args = parseArgs(process.argv.slice(2));
  if (!Number.isInteger(args.width) || args.width <= 0 || !Number.isInteger(args.height) || args.height <= 0) {
    throw new Error('width and height must be positive integers.');
  }

  const manifest = createManifest()
    .filter(effect => effect.validationMode === 'luma-math')
    .filter(effect => !args.effectId || effect.id === args.effectId)
    .filter(effect => !args.filter || effect.id.toLowerCase().includes(args.filter.toLowerCase()));

  if (manifest.length === 0) {
    throw new Error('No luma-math effects matched the selected filter.');
  }

  const ucrt64Root = requireUcrt64Root();
  const env = {
    ...process.env,
    PATH: `${path.join(ucrt64Root, 'bin')}${path.delimiter}${process.env.PATH ?? ''}`,
  };
  if (args.outputDir) fs.mkdirSync(args.outputDir, { recursive: true });

  const failures = [];
  for (const effect of manifest) {
    const shaderPath = path.join(repoRoot, effect.referenceShader);
    const outputPath = args.outputDir
      ? path.join(args.outputDir, `${effect.id.replace(/[^a-z0-9_.-]+/gi, '_')}.f32`)
      : null;
    process.stdout.write(`luma ${effect.id} ... `);
    const runnerArgs = [
      '--shader',
      shaderPath,
      '--width',
      String(args.width),
      '--height',
      String(args.height),
      '--scale',
      String(effect.expectedScale ?? 2),
    ];
    if (outputPath) {
      runnerArgs.push('--output', outputPath);
    }
    const result = spawnSync(runnerPath, runnerArgs, {
      cwd: repoRoot,
      encoding: 'utf8',
      env,
      windowsHide: true,
      timeout: effect.referenceTimeoutMs ?? 180_000,
    });

    if (result.status !== 0) {
      console.log('failed');
      console.log((result.stderr || result.stdout).trim());
      failures.push(effect.id);
      continue;
    }

    const payload = JSON.parse(result.stdout.trim());
    const expectedWidth = args.width * (effect.expectedScale ?? 2);
    const expectedHeight = args.height * (effect.expectedScale ?? 2);
    if (payload.width !== expectedWidth || payload.height !== expectedHeight) {
      console.log('failed');
      console.log(`  expected ${expectedWidth}x${expectedHeight}, got ${payload.width}x${payload.height}`);
      failures.push(effect.id);
      continue;
    }

    console.log(`ok ${payload.width}x${payload.height} ${payload.format} mean=${payload.mean.toFixed(6)} range=${payload.min.toFixed(6)}..${payload.max.toFixed(6)}`);
  }

  if (failures.length > 0) {
    console.error(`${failures.length} LUMA runner case(s) failed.`);
    process.exitCode = 1;
    return;
  }
  console.log(`All libplacebo LUMA runner cases passed (${manifest.length} effects).`);
}

main();

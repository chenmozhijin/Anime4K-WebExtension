const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { createManifest, repoRoot } = require('./verify/lib/manifest');
const { requireUcrt64Root } = require('./verify/lib/native-tools');

const probePath = path.join(repoRoot, '.cache', 'verify-tools', 'native', 'libplacebo-probe.exe');

function parseArgs(argv) {
  const args = {
    filter: null,
    effectId: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--effect-id') args.effectId = argv[++index];
    else if (arg.startsWith('--effect-id=')) args.effectId = arg.slice('--effect-id='.length);
    else if (arg === '--filter') args.filter = argv[++index];
    else if (arg.startsWith('--filter=')) args.filter = arg.slice('--filter='.length);
  }
  return args;
}

function main() {
  if (!fs.existsSync(probePath)) {
    throw new Error('libplacebo probe is not built. Run npm run verify:reference-libplacebo:build-probe.');
  }

  const args = parseArgs(process.argv.slice(2));
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
  const failures = [];
  for (const effect of manifest) {
    const shaderPath = path.join(repoRoot, effect.referenceShader);
    process.stdout.write(`probe ${effect.id} ... `);
    const result = spawnSync(probePath, [shaderPath], {
      cwd: repoRoot,
      encoding: 'utf8',
      env,
      windowsHide: true,
      timeout: 60_000,
    });
    if (result.status !== 0) {
      console.log('failed');
      console.log(result.stderr.trim() || result.stdout.trim());
      failures.push(effect.id);
      continue;
    }
    const payload = JSON.parse(result.stdout.trim());
    if ((payload.stages & 2) === 0) {
      console.log('failed');
      console.log(`  expected PL_HOOK_LUMA_INPUT stage, got stages=${payload.stages}`);
      failures.push(effect.id);
      continue;
    }
    console.log(`ok stages=${payload.stages} signature=${payload.signature}`);
  }

  if (failures.length > 0) {
    console.error(`${failures.length} probe case(s) failed.`);
    process.exitCode = 1;
    return;
  }
  console.log(`All libplacebo probe cases passed (${manifest.length} effects).`);
}

main();

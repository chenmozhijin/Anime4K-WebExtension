const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const {
  findMeson,
  nativePythonDir,
  nativePythonEnv,
  repoRoot,
} = require('./verify/lib/native-tools');

function main() {
  fs.mkdirSync(nativePythonDir, { recursive: true });

  const existing = findMeson();
  if (existing) {
    console.log(`Meson already available: ${existing.version} (${existing.source})`);
    return;
  }

  console.log(`Installing Meson into ${nativePythonDir}`);
  const result = spawnSync('python', [
    '-m',
    'pip',
    'install',
    '--target',
    nativePythonDir,
    'meson',
  ], {
    cwd: repoRoot,
    stdio: 'inherit',
    env: nativePythonEnv(),
    windowsHide: true,
  });

  if (result.status !== 0) {
    process.exitCode = result.status ?? 1;
    return;
  }

  const meson = findMeson();
  if (!meson) {
    console.error('Meson installation finished, but Meson is still not importable.');
    process.exitCode = 1;
    return;
  }

  console.log(`Meson ready: ${meson.version} (${meson.source})`);
}

main();

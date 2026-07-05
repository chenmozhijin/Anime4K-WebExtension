const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const {
  requireUcrt64Root,
  repoRoot,
} = require('./verify/lib/native-tools');

const sourcePath = path.join(repoRoot, 'scripts', 'verify', 'native', 'libplacebo-probe.c');
const outDir = path.join(repoRoot, '.cache', 'verify-tools', 'native');
const outputPath = path.join(outDir, 'libplacebo-probe.exe');
const ucrt64Root = requireUcrt64Root();
const gccPath = path.join(ucrt64Root, 'bin', 'gcc.exe');
const pkgConfigPath = path.join(ucrt64Root, 'bin', 'pkg-config.exe');

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
    ...options,
  });
  if (!options.silent && result.stdout) process.stdout.write(result.stdout);
  if (!options.silent && result.stderr) process.stderr.write(result.stderr);
  return result;
}

function splitPkgConfig(text) {
  return text.trim().split(/\s+/).filter(Boolean);
}

function main() {
  if (!fs.existsSync(gccPath)) {
    throw new Error(`UCRT64 gcc not found: ${gccPath}`);
  }
  if (!fs.existsSync(pkgConfigPath)) {
    throw new Error(`UCRT64 pkg-config not found: ${pkgConfigPath}`);
  }

  const pkg = run(pkgConfigPath, ['--cflags', '--libs', 'libplacebo'], { silent: true });
  if (pkg.status !== 0) {
    process.exitCode = pkg.status ?? 1;
    return;
  }

  fs.mkdirSync(outDir, { recursive: true });
  const args = [
    '-std=c11',
    '-O2',
    '-Wall',
    '-Wextra',
    sourcePath,
    '-o',
    outputPath,
    ...splitPkgConfig(pkg.stdout),
  ];

  const result = run(gccPath, args);
  if (result.status !== 0) {
    process.exitCode = result.status ?? 1;
    return;
  }

  console.log(`Built ${outputPath}`);
}

main();

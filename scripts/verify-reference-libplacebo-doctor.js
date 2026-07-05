const fs = require('node:fs');
const {
  commandExists,
  findMeson,
  findVsDevCmd,
  libplaceboSourceDir,
  msysRoot,
  nativePythonEnv,
  nativePythonDir,
  runInVsDevCmd,
  ucrt64Root,
} = require('./verify/lib/native-tools');
const { spawnSync } = require('node:child_process');
const path = require('node:path');

function printCheck(ok, label, detail) {
  console.log(`[${ok ? 'ok' : 'missing'}] ${label}${detail ? `: ${detail}` : ''}`);
}

function firstLine(text) {
  return String(text || '').split(/\r?\n/).map(line => line.trim()).find(Boolean) ?? '';
}

function run(command, args) {
  return spawnSync(command, args, {
    encoding: 'utf8',
    windowsHide: true,
  });
}

function main() {
  console.log('Native libplacebo reference environment');
  const vsDevCmd = findVsDevCmd();
  printCheck(Boolean(vsDevCmd), 'Visual Studio DevCmd', vsDevCmd);

  const cl = runInVsDevCmd('where cl');
  printCheck(cl.status === 0, 'MSVC cl', firstLine(cl.stdout) || firstLine(cl.stderr));

  const ninja = commandExists('ninja');
  printCheck(ninja.length > 0, 'Ninja', ninja[0]);

  const python = commandExists('python');
  printCheck(python.length > 0, 'Python', python[0]);

  const meson = findMeson();
  printCheck(Boolean(meson), 'Meson', meson ? `${meson.version} (${meson.source})` : `run npm run verify:setup-native; local target ${nativePythonDir}`);

  const glslc = commandExists('glslc');
  printCheck(glslc.length > 0, 'Vulkan SDK glslc', glslc[0]);

  const glslang = commandExists('glslangValidator');
  printCheck(glslang.length > 0, 'Vulkan SDK glslangValidator', glslang[0]);

  const shaderc = commandExists('shaderc_shared.dll');
  printCheck(shaderc.length > 0, 'shaderc shared library', shaderc[0]);

  printCheck(fs.existsSync(libplaceboSourceDir), 'libplacebo source', libplaceboSourceDir);

  const msysHelp = 'set VERIFY_MSYS2_ROOT or run from a UCRT64 environment';
  printCheck(Boolean(msysRoot) && fs.existsSync(msysRoot), 'MSYS2 root', msysRoot || msysHelp);
  const ucrtGcc = ucrt64Root ? path.join(ucrt64Root, 'bin', 'gcc.exe') : null;
  const ucrtPkgConfig = ucrt64Root ? path.join(ucrt64Root, 'bin', 'pkg-config.exe') : null;
  printCheck(Boolean(ucrtGcc) && fs.existsSync(ucrtGcc), 'UCRT64 gcc', ucrtGcc || msysHelp);
  printCheck(Boolean(ucrtPkgConfig) && fs.existsSync(ucrtPkgConfig), 'UCRT64 pkg-config', ucrtPkgConfig || msysHelp);
  const libplaceboPkg = ucrtPkgConfig && fs.existsSync(ucrtPkgConfig)
    ? run(ucrtPkgConfig, ['--modversion', 'libplacebo'])
    : { status: 1, stdout: '', stderr: '' };
  printCheck(libplaceboPkg.status === 0, 'UCRT64 libplacebo', firstLine(libplaceboPkg.stdout) || firstLine(libplaceboPkg.stderr));

  const env = nativePythonEnv();
  if (env.PYTHONPATH.includes(nativePythonDir)) {
    console.log(`     PYTHONPATH includes local native tools cache: ${nativePythonDir}`);
  }

  const failed = [
    !vsDevCmd,
    cl.status !== 0,
    ninja.length === 0,
    python.length === 0,
    !meson,
    glslc.length === 0 && glslang.length === 0,
    !fs.existsSync(libplaceboSourceDir),
    !ucrtGcc || !fs.existsSync(ucrtGcc),
    !ucrtPkgConfig || !fs.existsSync(ucrtPkgConfig),
    libplaceboPkg.status !== 0,
  ].some(Boolean);

  if (failed) {
    process.exitCode = 1;
  }
}

main();

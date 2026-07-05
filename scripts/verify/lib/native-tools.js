const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { repoRoot } = require('./manifest');

const nativePythonDir = path.join(repoRoot, '.cache', 'verify-tools', 'python');
const sourceRoot = path.join(repoRoot, '.cache', 'source');
const libplaceboSourceDir = path.join(sourceRoot, 'libplacebo');

function commandExists(command, env = process.env) {
  const lookup = process.platform === 'win32' ? 'where' : 'which';
  const result = spawnSync(lookup, [command], {
    cwd: repoRoot,
    encoding: 'utf8',
    env,
    windowsHide: true,
  });
  return result.status === 0
    ? result.stdout.split(/\r?\n/).map(line => line.trim()).filter(Boolean)
    : [];
}

function uniquePaths(paths) {
  const seen = new Set();
  return paths.filter(candidate => {
    if (!candidate) return false;
    const key = path.normalize(candidate).toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function findVsDevCmdUnder(vsRoot) {
  if (!vsRoot) return null;
  const candidates = [
    path.join(vsRoot, 'Common7', 'Tools', 'VsDevCmd.bat'),
    path.join(vsRoot, '2022', 'Community', 'Common7', 'Tools', 'VsDevCmd.bat'),
    path.join(vsRoot, '2022', 'BuildTools', 'Common7', 'Tools', 'VsDevCmd.bat'),
    path.join(vsRoot, '2022', 'Professional', 'Common7', 'Tools', 'VsDevCmd.bat'),
    path.join(vsRoot, '2022', 'Enterprise', 'Common7', 'Tools', 'VsDevCmd.bat'),
  ];
  return candidates.find(candidate => fs.existsSync(candidate)) ?? null;
}

function findVsWhere() {
  const fromPath = commandExists('vswhere');
  const standardInstallerPath = process.env['ProgramFiles(x86)']
    ? path.join(process.env['ProgramFiles(x86)'], 'Microsoft Visual Studio', 'Installer', 'vswhere.exe')
    : null;
  return uniquePaths([...fromPath, standardInstallerPath]).find(candidate => fs.existsSync(candidate)) ?? null;
}

function findVsInstallationsFromVsWhere() {
  const vswhere = findVsWhere();
  if (!vswhere) return [];
  const result = spawnSync(vswhere, [
    '-latest',
    '-products',
    '*',
    '-requires',
    'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
    '-property',
    'installationPath',
  ], {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  return result.status === 0
    ? result.stdout.split(/\r?\n/).map(line => line.trim()).filter(Boolean)
    : [];
}

function findVsDevCmd(vsRoot = null) {
  const roots = uniquePaths([
    vsRoot,
    process.env.VERIFY_VS_PATH,
    process.env.VSINSTALLDIR,
    ...findVsInstallationsFromVsWhere(),
  ]);
  for (const root of roots) {
    const vsDevCmd = findVsDevCmdUnder(root);
    if (vsDevCmd) return vsDevCmd;
  }
  return null;
}

function inferMsysRootFromPath(value) {
  if (!value) return null;
  const normalized = path.normalize(value);
  const parts = normalized.split(path.sep);
  const ucrtIndex = parts.findIndex(part => part.toLowerCase() === 'ucrt64');
  if (ucrtIndex > 0) {
    return parts.slice(0, ucrtIndex).join(path.sep);
  }
  const msysIndex = parts.findIndex(part => part.toLowerCase() === 'msys64');
  if (msysIndex >= 0) {
    return parts.slice(0, msysIndex + 1).join(path.sep);
  }
  return normalized;
}

function findMsysRoot() {
  const roots = uniquePaths([
    process.env.VERIFY_MSYS2_ROOT,
    inferMsysRootFromPath(process.env.MSYSTEM_PREFIX),
    inferMsysRootFromPath(process.env.MINGW_PREFIX),
    ...commandExists('gcc').map(inferMsysRootFromPath),
    ...commandExists('pkg-config').map(inferMsysRootFromPath),
  ]);
  return roots.find(candidate => {
    if (!candidate) return false;
    const ucrt64Bin = path.join(candidate, 'ucrt64', 'bin');
    return fs.existsSync(ucrt64Bin);
  }) ?? null;
}

const msysRoot = findMsysRoot();
const ucrt64Root = msysRoot ? path.join(msysRoot, 'ucrt64') : null;

function requireUcrt64Root() {
  if (!ucrt64Root) {
    throw new Error('UCRT64 MSYS2 root was not found. Set VERIFY_MSYS2_ROOT to the MSYS2 root, or run from an environment where UCRT64 gcc/pkg-config are on PATH.');
  }
  return ucrt64Root;
}

function quoteCmd(value) {
  return `"${String(value).replace(/"/g, '""')}"`;
}

function runInVsDevCmd(command, options = {}) {
  const vsDevCmd = options.vsDevCmd || findVsDevCmd();
  if (!vsDevCmd) {
    return {
      status: 1,
      stdout: '',
      stderr: 'VsDevCmd.bat not found. Set VERIFY_VS_PATH, run from a Visual Studio developer environment, or install Visual Studio Build Tools with MSVC x64 tools.',
    };
  }

  const tempDir = path.join(repoRoot, '.cache', 'verify-tools');
  fs.mkdirSync(tempDir, { recursive: true });
  const scriptPath = path.join(tempDir, `vsdevcmd-${process.pid}-${Date.now()}.cmd`);
  fs.writeFileSync(scriptPath, [
    '@echo off',
    `call ${quoteCmd(vsDevCmd)} -arch=x64 -host_arch=x64 >nul`,
    'if errorlevel 1 exit /b %errorlevel%',
    command,
  ].join('\r\n'), 'utf8');

  const result = spawnSync('cmd.exe', ['/d', '/c', scriptPath], {
    cwd: options.cwd ?? repoRoot,
    encoding: 'utf8',
    env: options.env ?? process.env,
    windowsHide: true,
    timeout: options.timeoutMs ?? 60_000,
  });
  fs.rmSync(scriptPath, { force: true });
  return result;
}

function localPythonPath() {
  const existing = process.env.PYTHONPATH ? `${nativePythonDir}${path.delimiter}${process.env.PYTHONPATH}` : nativePythonDir;
  return existing;
}

function nativePythonEnv(extra = {}) {
  return {
    ...process.env,
    PYTHONPATH: localPythonPath(),
    ...extra,
  };
}

function findMeson(env = nativePythonEnv()) {
  const moduleResult = spawnSync('python', ['-m', 'mesonbuild.mesonmain', '--version'], {
    cwd: repoRoot,
    encoding: 'utf8',
    env,
    windowsHide: true,
  });
  if (moduleResult.status === 0) {
    return {
      command: ['python', '-m', 'mesonbuild.mesonmain'],
      version: moduleResult.stdout.trim(),
      source: 'python module',
    };
  }

  const paths = commandExists('meson', env);
  if (paths.length > 0) {
    const result = spawnSync('meson', ['--version'], {
      cwd: repoRoot,
      encoding: 'utf8',
      env,
      windowsHide: true,
    });
    return {
      command: ['meson'],
      version: result.status === 0 ? result.stdout.trim() : 'unknown',
      source: paths[0],
    };
  }

  return null;
}

module.exports = {
  commandExists,
  findMeson,
  findVsDevCmd,
  libplaceboSourceDir,
  msysRoot,
  nativePythonDir,
  nativePythonEnv,
  repoRoot,
  requireUcrt64Root,
  runInVsDevCmd,
  sourceRoot,
  ucrt64Root,
};

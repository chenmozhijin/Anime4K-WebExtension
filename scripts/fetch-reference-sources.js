const fs = require('node:fs');
const path = require('node:path');
const https = require('node:https');
const crypto = require('node:crypto');
const { execFileSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const defaultLockPath = path.join(__dirname, 'reference-source-lock.json');

function loadLock(lockPath = defaultLockPath) {
  return JSON.parse(fs.readFileSync(lockPath, 'utf8'));
}

function parseArgs(argv) {
  const args = {
    lockPath: defaultLockPath,
    target: null,
    all: false,
    checkOnly: false,
    cacheDir: path.join(repoRoot, '.cache', 'verify-sources'),
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--target') {
      args.target = argv[++index];
      continue;
    }
    if (arg === '--all') {
      args.all = true;
      continue;
    }
    if (arg === '--check') {
      args.checkOnly = true;
      continue;
    }
    if (arg === '--lock-file') {
      args.lockPath = path.resolve(argv[++index]);
      continue;
    }
    if (arg === '--cache-dir') {
      args.cacheDir = path.resolve(argv[++index]);
      continue;
    }
    throw new Error(`Unknown fetch-reference-sources option: ${arg}`);
  }

  if (!args.all && !args.target) {
    throw new Error('Pass --target <id> or --all.');
  }
  if (args.all && args.target) {
    throw new Error('Pass either --target <id> or --all, not both.');
  }

  return args;
}

function sha256(filePath) {
  const hash = crypto.createHash('sha256');
  hash.update(fs.readFileSync(filePath));
  return hash.digest('hex');
}

function assertLockedRelativePath(filePath) {
  if (!filePath || path.isAbsolute(filePath)) {
    throw new Error(`Locked reference file path must be relative: ${filePath}`);
  }
  const segments = filePath.split(/[\\/]+/);
  if (segments.includes('..')) {
    throw new Error(`Locked reference file path must not escape its root: ${filePath}`);
  }
}

function resolveReferenceRoot(target) {
  if (!target.referenceRoot) {
    throw new Error(`${target.component || 'Reference'} target must define referenceRoot.`);
  }

  const referenceRoot = path.isAbsolute(target.referenceRoot)
    ? target.referenceRoot
    : path.join(repoRoot, target.referenceRoot);
  const resolvedRoot = path.resolve(referenceRoot);
  const filesystemRoot = path.parse(resolvedRoot).root;

  if (resolvedRoot === filesystemRoot || resolvedRoot === repoRoot) {
    throw new Error(`Refusing to use unsafe reference root: ${resolvedRoot}`);
  }

  return resolvedRoot;
}

function verifyReference(target) {
  const referenceRoot = resolveReferenceRoot(target);
  const missing = [];
  const mismatched = [];

  for (const file of target.includedFiles) {
    assertLockedRelativePath(file.path);
    const filePath = path.join(referenceRoot, file.path);
    if (!fs.existsSync(filePath)) {
      missing.push(file.path);
      continue;
    }
    const actual = sha256(filePath);
    if (actual !== file.sha256) {
      mismatched.push({ path: file.path, expected: file.sha256, actual });
    }
  }

  return { missing, mismatched };
}

function download(url, outputPath) {
  if (url.startsWith('file://')) {
    fs.copyFileSync(new URL(url), outputPath);
    return Promise.resolve();
  }

  return new Promise((resolve, reject) => {
    const request = https.get(url, response => {
      if (response.statusCode && response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        response.resume();
        download(response.headers.location, outputPath).then(resolve, reject);
        return;
      }

      if (response.statusCode !== 200) {
        response.resume();
        reject(new Error(`Download failed with HTTP ${response.statusCode}: ${url}`));
        return;
      }

      const file = fs.createWriteStream(outputPath);
      response.pipe(file);
      file.on('finish', () => file.close(resolve));
      file.on('error', reject);
    });
    request.on('error', reject);
  });
}

function extractZip(zipPath, outputDir) {
  fs.rmSync(outputDir, { recursive: true, force: true });
  fs.mkdirSync(outputDir, { recursive: true });

  if (process.platform === 'win32') {
    execFileSync('powershell.exe', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      '& { param($zipPath, $outputDir) Expand-Archive -LiteralPath $zipPath -DestinationPath $outputDir -Force }',
      zipPath,
      outputDir,
    ], { stdio: 'inherit' });
    return;
  }

  execFileSync('unzip', ['-q', '-o', zipPath, '-d', outputDir], { stdio: 'inherit' });
}

function findExtractedRoot(extractDir, target) {
  const entries = fs.readdirSync(extractDir, { withFileTypes: true }).filter(entry => entry.isDirectory());
  if (entries.length !== 1) {
    throw new Error(`Expected one extracted ${target.component} directory in ${extractDir}, found ${entries.length}.`);
  }
  return path.join(extractDir, entries[0].name);
}

function copyLockedFiles(sourceRoot, target) {
  const referenceRoot = resolveReferenceRoot(target);
  fs.rmSync(referenceRoot, { recursive: true, force: true });

  for (const file of target.includedFiles) {
    assertLockedRelativePath(file.path);
    const sourcePath = path.join(sourceRoot, file.path);
    const targetPath = path.join(referenceRoot, file.path);
    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
    fs.copyFileSync(sourcePath, targetPath);
  }
}

function selectedTargets(lock, args) {
  if (!lock.targets || typeof lock.targets !== 'object') {
    throw new Error('Reference source lock must contain a targets object.');
  }
  if (args.all) {
    return Object.entries(lock.targets);
  }
  const target = lock.targets[args.target];
  if (!target) {
    throw new Error(`Unknown reference target: ${args.target}`);
  }
  return [[args.target, target]];
}

function printVerificationError(targetId, target, current) {
  console.error(`${target.component} reference (${targetId}) is incomplete at ${resolveReferenceRoot(target)}.`);
  if (current.missing.length > 0) {
    console.error(`Missing: ${current.missing.join(', ')}`);
  }
  if (current.mismatched.length > 0) {
    console.error(`Mismatched: ${current.mismatched.map(item => item.path).join(', ')}`);
  }
}

async function restoreTarget(targetId, target, args) {
  const current = verifyReference(target);
  if (current.missing.length === 0 && current.mismatched.length === 0) {
    console.log(`${target.component} reference (${targetId}) is ready at ${path.relative(repoRoot, resolveReferenceRoot(target)) || resolveReferenceRoot(target)}.`);
    return;
  }

  if (args.checkOnly) {
    printVerificationError(targetId, target, current);
    throw new Error(`Reference check failed for ${targetId}.`);
  }

  const targetCacheDir = path.join(args.cacheDir, targetId);
  fs.mkdirSync(targetCacheDir, { recursive: true });
  const archivePath = path.join(targetCacheDir, `${target.commit}.zip`);
  const extractDir = path.join(targetCacheDir, `extract-${target.commit}`);

  if (!fs.existsSync(archivePath)) {
    console.log(`Downloading ${target.component} ${target.commit} from ${target.archiveUrl}`);
    await download(target.archiveUrl, archivePath);
  } else {
    console.log(`Using cached archive ${archivePath}`);
  }

  extractZip(archivePath, extractDir);
  copyLockedFiles(findExtractedRoot(extractDir, target), target);

  const after = verifyReference(target);
  if (after.missing.length > 0 || after.mismatched.length > 0) {
    printVerificationError(targetId, target, after);
    throw new Error(`${target.component} reference fetch completed, but hash verification failed.`);
  }

  console.log(`${target.component} reference (${targetId}) restored at ${path.relative(repoRoot, resolveReferenceRoot(target)) || resolveReferenceRoot(target)}.`);
}

async function run(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  const lock = loadLock(args.lockPath);
  const targets = selectedTargets(lock, args);

  for (const [targetId, target] of targets) {
    await restoreTarget(targetId, target, args);
  }
}

if (require.main === module) {
  run().catch(error => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(1);
  });
}

module.exports = {
  copyLockedFiles,
  download,
  extractZip,
  findExtractedRoot,
  assertLockedRelativePath,
  loadLock,
  parseArgs,
  resolveReferenceRoot,
  restoreTarget,
  run,
  selectedTargets,
  sha256,
  verifyReference,
};

const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');
const policyFile = path.join(__dirname, 'reference-source-lock.json');
const forbiddenRoots = Object.freeze([
  'test-results',
  'test/verify/corpus',
  '.reference',
  '.local-archive',
  'dist',
  'experiment',
  'img',
]);
const forbiddenContentPatterns = Object.freeze([
  /(?:\b[A-Za-z]:[\\/]|\/(?:Users|home)\/)/,
  /test-results[\\/]user-image-evaluation/i,
  /formal-evaluation/i,
  /pending-hardware-matrix/i,
  /\bfinalist\b/i,
]);

function runGit(args, input = '') {
  const result = spawnSync('git', args, {
    cwd: repoRoot,
    input,
    encoding: 'utf8',
    windowsHide: true,
  });
  if (result.status !== 0 && result.status !== 1) {
    throw new Error(result.stderr || `git ${args.join(' ')} failed`);
  }
  return result.stdout;
}

function splitNullDelimited(value) {
  return value.split('\0').filter(Boolean);
}

function repoPaths(gitRunner = runGit) {
  const tracked = splitNullDelimited(gitRunner(['ls-files', '-z']))
    .filter(filePath => fs.existsSync(path.join(repoRoot, filePath)));
  const staged = splitNullDelimited(gitRunner([
    'diff', '--cached', '--name-only', '--diff-filter=ACMRTUXB', '-z',
  ]));
  const untracked = splitNullDelimited(gitRunner([
    'ls-files', '--others', '--exclude-standard', '-z',
  ]));
  return [...new Set([...tracked, ...staged, ...untracked])];
}

function pathSegments(filePath) {
  return filePath.replaceAll('\\', '/').split('/').filter(Boolean);
}

function containsPath(root, candidate) {
  const rootSegments = pathSegments(root);
  const candidateSegments = pathSegments(candidate);
  if (rootSegments.length > candidateSegments.length) return false;
  return candidateSegments.some((_, index) => rootSegments.every(
    (segment, segmentIndex) => candidateSegments[index + segmentIndex] === segment,
  ));
}

function loadExcludedSourcePaths() {
  const lock = JSON.parse(fs.readFileSync(policyFile, 'utf8'));
  return Object.values(lock.targets ?? {})
    .flatMap(target => target.excludedPaths ?? [])
    .filter(Boolean);
}

function ignoredPaths(paths) {
  if (paths.length === 0) return [];
  return splitNullDelimited(runGit(['check-ignore', '--no-index', '-z', '--stdin'], `${paths.join('\0')}\0`));
}

function pathFindings(paths) {
  const excludedSourcePaths = loadExcludedSourcePaths();
  const ignored = new Set(ignoredPaths(paths));
  const findings = [];
  for (const filePath of paths) {
    const root = forbiddenRoots.find(candidate => containsPath(candidate, filePath));
    if (root) findings.push({ filePath, reason: `forbidden repository path: ${root}` });
    if (ignored.has(filePath)) findings.push({ filePath, reason: 'matched .gitignore' });
    const excluded = excludedSourcePaths.find(candidate => containsPath(candidate, filePath));
    if (excluded) findings.push({ filePath, reason: `excluded source path: ${excluded}` });
  }
  return findings;
}

function contentFindings(paths) {
  const findings = [];
  for (const filePath of paths) {
    if (filePath === 'scripts/check-public-surface.js') continue;
    if (filePath.startsWith('test/')) continue;
    if (!/\.(?:js|mjs|cjs|py|md|json|yml|yaml|ts)$/i.test(filePath)) continue;
    const absolutePath = path.join(repoRoot, filePath);
    if (!fs.existsSync(absolutePath)) continue;
    const source = fs.readFileSync(absolutePath, 'utf8');
    for (const pattern of forbiddenContentPatterns) {
      if (pattern.test(source)) {
        findings.push({ filePath, reason: `forbidden public content: ${pattern}` });
      }
    }
  }
  return findings;
}

function checkPublicSurface(paths = repoPaths()) {
  return [...pathFindings(paths), ...contentFindings(paths)];
}

function main() {
  const findings = checkPublicSurface();
  if (findings.length > 0) {
    console.error('Public surface check failed:');
    for (const finding of findings) {
      console.error(`- ${finding.filePath}: ${finding.reason}`);
    }
    process.exitCode = 1;
    return;
  }
  console.log(`Public surface check passed for ${repoPaths().length} repository paths.`);
}

module.exports = {
  checkPublicSurface,
  containsPath,
  forbiddenRoots,
  pathFindings,
  repoPaths,
  splitNullDelimited,
};

if (require.main === module) main();

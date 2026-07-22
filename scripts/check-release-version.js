const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');

function parseArgs(argv) {
  const args = {
    root: repoRoot,
    tag: null,
    distDirs: [],
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--root') args.root = path.resolve(argv[++index]);
    else if (arg.startsWith('--root=')) args.root = path.resolve(arg.slice(7));
    else if (arg === '--tag') args.tag = argv[++index];
    else if (arg.startsWith('--tag=')) args.tag = arg.slice(6);
    else if (arg === '--dist') args.distDirs.push(argv[++index]);
    else if (arg.startsWith('--dist=')) args.distDirs.push(arg.slice(7));
    else throw new Error(`Unknown release version option: ${arg}`);
  }

  if (!args.root) throw new Error('--root requires a directory.');
  if (args.tag === undefined) throw new Error('--tag requires a value.');
  if (args.distDirs.some(value => !value)) throw new Error('--dist requires a directory.');
  return args;
}

function readVersion(root, relativePath) {
  const filePath = path.resolve(root, relativePath);
  if (!fs.existsSync(filePath)) {
    throw new Error(`Version file does not exist: ${relativePath}`);
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    throw new Error(`Version file is not valid JSON: ${relativePath}`, { cause: error });
  }

  if (typeof parsed.version !== 'string' || parsed.version.length === 0) {
    throw new Error(`Version file has no string version: ${relativePath}`);
  }
  return parsed.version;
}

function validateReleaseVersions({ root = repoRoot, tag = null, distDirs = [] } = {}) {
  const packageVersion = readVersion(root, 'package.json');
  const versions = [{ file: 'manifest.json', version: readVersion(root, 'manifest.json') }];
  for (const distDir of distDirs) {
    const manifestPath = path.join(distDir, 'manifest.json').replace(/\\/g, '/');
    versions.push({ file: manifestPath, version: readVersion(root, manifestPath) });
  }

  const errors = versions
    .filter(entry => entry.version !== packageVersion)
    .map(entry => `${entry.file} version ${entry.version} does not match package.json version ${packageVersion}.`);
  const expectedTag = `v${packageVersion}`;
  if (tag !== null && tag !== expectedTag) {
    errors.push(`Tag ${tag} does not match expected release tag ${expectedTag}.`);
  }
  if (errors.length > 0) {
    throw new Error(`Release version validation failed:\n- ${errors.join('\n- ')}`);
  }

  return {
    version: packageVersion,
    expectedTag,
    files: ['package.json', ...versions.map(entry => entry.file)],
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const result = validateReleaseVersions(args);
  console.log(`Release version ${result.version} validated (${result.files.length} files).`);
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}

module.exports = {
  parseArgs,
  readVersion,
  validateReleaseVersions,
};

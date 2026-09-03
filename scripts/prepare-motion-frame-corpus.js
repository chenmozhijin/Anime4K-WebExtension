const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { decodePng } = require('./verify/lib/png');

const repoRoot = path.resolve(__dirname, '..');

function resolvePathArgument(value, name) {
  if (!value || value.startsWith('--')) {
    throw new Error(`${name} requires a path.`);
  }
  return path.resolve(value);
}

function parseArgs(argv) {
  const args = {
    manifest: null,
    output: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--manifest') args.manifest = resolvePathArgument(argv[++index], '--manifest');
    else if (arg.startsWith('--manifest=')) args.manifest = resolvePathArgument(arg.slice(11), '--manifest');
    else if (arg === '--output') args.output = resolvePathArgument(argv[++index], '--output');
    else if (arg.startsWith('--output=')) args.output = resolvePathArgument(arg.slice(9), '--output');
    else throw new Error(`Unknown motion corpus option: ${arg}`);
  }
  if (!args.manifest || !args.output) {
    throw new Error('Both --manifest and --output must be provided.');
  }
  return args;
}

function sha256(bytes) {
  return crypto.createHash('sha256').update(bytes).digest('hex');
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error(`${command} failed: ${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const clipManifestPath = args.manifest;
  const clipsRoot = path.dirname(clipManifestPath);
  const outputRoot = args.output;
  const clips = JSON.parse(fs.readFileSync(clipManifestPath, 'utf8'));
  const inputs = [];
  for (const fixture of clips.fixtures) {
    const sourcePath = path.join(clipsRoot, fixture.file);
    const frameRoot = path.join(outputRoot, fixture.id);
    fs.mkdirSync(frameRoot, { recursive: true });
    run('ffmpeg', [
      '-hide_banner', '-loglevel', 'error', '-y',
      '-i', sourcePath,
      '-map', '0:v:0', '-vsync', '0',
      path.join(frameRoot, 'frame-%06d.png'),
    ]);
    const probe = JSON.parse(run('ffprobe', [
      '-v', 'error', '-select_streams', 'v:0', '-show_frames',
      '-show_entries', 'frame=best_effort_timestamp_time,pkt_duration_time,key_frame',
      '-of', 'json', sourcePath,
    ]));
    const frames = fs.readdirSync(frameRoot)
      .filter(name => /^frame-\d{6}\.png$/.test(name))
      .sort();
    if (frames.length !== clips.framesPerClip) {
      throw new Error(`${fixture.id} decoded ${frames.length} frames; expected ${clips.framesPerClip}.`);
    }
    frames.forEach((name, index) => {
      const absolutePath = path.join(frameRoot, name);
      const bytes = fs.readFileSync(absolutePath);
      const image = decodePng(bytes);
      const metadata = probe.frames[index] ?? {};
      inputs.push({
        id: `${fixture.id}-frame-${String(index).padStart(6, '0')}`,
        path: path.relative(outputRoot, absolutePath).replaceAll('\\', '/'),
        sha256: sha256(bytes),
        width: image.width,
        height: image.height,
        sourceClass: fixture.id,
        frameIndex: index,
        ptsSeconds: Number(metadata.best_effort_timestamp_time ?? index / clips.fps),
        keyFrame: Boolean(metadata.key_frame),
        crops: [],
      });
    });
  }
  const manifest = {
    schemaVersion: 1,
    fps: clips.fps,
    framesPerClip: clips.framesPerClip,
    inputs,
  };
  fs.writeFileSync(path.join(outputRoot, 'corpus-manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`Motion frame corpus: ${inputs.length} frames -> ${outputRoot}`);
}

module.exports = { parseArgs, resolvePathArgument };

if (require.main === module) main();

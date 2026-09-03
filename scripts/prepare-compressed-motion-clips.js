const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

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
    sourceRoot: null,
    outputRoot: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--manifest') args.manifest = resolvePathArgument(argv[++index], '--manifest');
    else if (arg.startsWith('--manifest=')) args.manifest = resolvePathArgument(arg.slice(11), '--manifest');
    else if (arg === '--source-root') args.sourceRoot = resolvePathArgument(argv[++index], '--source-root');
    else if (arg.startsWith('--source-root=')) args.sourceRoot = resolvePathArgument(arg.slice(14), '--source-root');
    else if (arg === '--output-root') args.outputRoot = resolvePathArgument(argv[++index], '--output-root');
    else if (arg.startsWith('--output-root=')) args.outputRoot = resolvePathArgument(arg.slice(14), '--output-root');
    else throw new Error(`Unknown compressed motion option: ${arg}`);
  }
  if (!args.manifest || !args.outputRoot) {
    throw new Error('Both --manifest and --output-root must be provided.');
  }
  args.sourceRoot ??= path.dirname(args.manifest);
  return args;
}

function run(command, args) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  if (result.status !== 0) throw new Error(`${command} failed: ${result.stderr || result.stdout}`);
  return result.stdout;
}

function encode(source, output, codec, kbps) {
  const common = [
    '-hide_banner', '-loglevel', 'error', '-y', '-i', source,
    '-map', '0:v:0', '-an', '-frames:v', String(sourceManifest.framesPerClip),
    '-pix_fmt', 'yuv420p', '-r', String(sourceManifest.fps), '-g', '48',
  ];
  const bitrate = `${kbps}k`;
  const codecArgs = codec === 'h264'
    ? ['-c:v', 'libx264', '-preset', 'medium', '-b:v', bitrate, '-maxrate', bitrate, '-bufsize', `${kbps * 2}k`]
    : ['-c:v', 'libvpx-vp9', '-deadline', 'good', '-cpu-used', '2', '-row-mt', '1',
      '-b:v', bitrate, '-minrate', bitrate, '-maxrate', bitrate, '-bufsize', `${kbps * 2}k`];
  run('ffmpeg', [...common, ...codecArgs, output]);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const sourceManifest = JSON.parse(fs.readFileSync(args.manifest, 'utf8'));
  const sourceRoot = args.sourceRoot;
  const outputRoot = args.outputRoot;
  fs.mkdirSync(outputRoot, { recursive: true });
  const fixtures = [];
  const modernFixtures = sourceManifest.fixtures.filter(fixture => fixture.id.startsWith('modern-'));
  for (const fixture of modernFixtures) {
    for (const codec of ['h264', 'vp9']) {
      for (const kbps of [500, 1000, 2000]) {
        const extension = codec === 'h264' ? 'mp4' : 'webm';
        const id = `${fixture.id}-${codec}-${String(kbps).padStart(4, '0')}k`;
        const file = `${id}.${extension}`;
        encode(path.join(sourceRoot, fixture.file), path.join(outputRoot, file), codec, kbps);
        const probe = JSON.parse(run('ffprobe', [
          '-v', 'error', '-count_frames', '-select_streams', 'v:0',
          '-show_entries', 'stream=codec_name,width,height,r_frame_rate,nb_read_frames,bit_rate',
          '-of', 'json', path.join(outputRoot, file),
        ]));
        const stream = probe.streams[0];
        if (Number(stream.nb_read_frames) !== sourceManifest.framesPerClip) {
          throw new Error(`${id} contains ${stream.nb_read_frames} frames.`);
        }
        fixtures.push({
          id,
          file,
          sourceFixture: fixture.id,
          codec,
          targetKbps: kbps,
          measuredBitrate: Number(stream.bit_rate || 0),
          severity: kbps === 500 ? 'heavy' : kbps === 1000 ? 'medium' : 'light',
        });
      }
    }
  }
  const manifest = {
    schemaVersion: 1,
    framesPerClip: sourceManifest.framesPerClip,
    fps: sourceManifest.fps,
    width: sourceManifest.width,
    height: sourceManifest.height,
    fixtures,
  };
  fs.writeFileSync(path.join(outputRoot, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`Compressed motion clips: ${fixtures.length} -> ${outputRoot}`);
}

module.exports = { parseArgs, resolvePathArgument };

if (require.main === module) main();

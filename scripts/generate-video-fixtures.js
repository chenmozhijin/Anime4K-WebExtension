const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const repoRoot = path.resolve(__dirname, '..');

function positiveInteger(value, name) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function parseSize(value) {
  const match = /^(\d+)x(\d+)$/.exec(value);
  if (!match) {
    throw new Error('--size must use WIDTHxHEIGHT.');
  }
  return { width: positiveInteger(match[1], '--size width'), height: positiveInteger(match[2], '--size height') };
}

function parseArgs(argv) {
  const args = {
    output: path.join(repoRoot, 'test-results', 'video-fixtures'),
    frames: 300,
    fps: 30,
    width: 320,
    height: 180,
    force: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--output') args.output = path.resolve(repoRoot, argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(repoRoot, arg.slice(9));
    else if (arg === '--frames') args.frames = positiveInteger(argv[++index], '--frames');
    else if (arg.startsWith('--frames=')) args.frames = positiveInteger(arg.slice(9), '--frames');
    else if (arg === '--fps') args.fps = positiveInteger(argv[++index], '--fps');
    else if (arg.startsWith('--fps=')) args.fps = positiveInteger(arg.slice(6), '--fps');
    else if (arg === '--size') Object.assign(args, parseSize(argv[++index]));
    else if (arg.startsWith('--size=')) Object.assign(args, parseSize(arg.slice(7)));
    else if (arg === '--force') args.force = true;
    else if (arg === '--smoke') Object.assign(args, { frames: 30, width: 160, height: 90 });
    else throw new Error(`Unknown video fixture option: ${arg}`);
  }
  return args;
}

function writeJsonAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.tmp`;
  fs.writeFileSync(temporaryPath, JSON.stringify(value, null, 2));
  fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function run(command, args, label) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  if (result.status !== 0) {
    throw new Error(`${label} failed:\n${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

function h264Metadata(primaries, transfer, matrix) {
  return [
    '-an', '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '18', '-pix_fmt', 'yuv420p',
    '-color_primaries', primaries, '-color_trc', transfer, '-colorspace', matrix,
    '-x264-params', `colorprim=${primaries}:transfer=${transfer}:colormatrix=${matrix}`,
    '-movflags', '+faststart',
  ];
}

function createFixtureDefinitions({ width, height, fps }) {
  const largeWidth = width * 2;
  const fontSize = Math.max(12, Math.round(height / 9));
  return [
    {
      id: 'lineart_bt709_8bit',
      content: ['line-art', 'moving-edges'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `color=c=white:size=${width}x${height}:rate=${fps},drawgrid=w=16:h=16:t=1:c=black@0.8,drawbox=x='mod(t*80,iw+40)-40':y=ih*0.2:w=40:h=ih*0.6:t=2:c=black`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'subtitles_bt709_8bit',
      content: ['fine-subtitles', 'high-contrast-text'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `testsrc2=size=${width}x${height}:rate=${fps},drawbox=x=0:y=ih*0.68:w=iw:h=ih*0.25:c=black@0.65:t=fill,drawtext=fontfile='C\\:/Windows/Fonts/arial.ttf':text='Anime4K 0123456789':fontcolor=white:borderw=1:bordercolor=black:fontsize=${fontSize}:x='(w-text_w)/2':y='h*0.74'`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'halftone_bt601_8bit',
      content: ['halftone', 'moire', 'fine-pattern'],
      bitDepth: 8,
      color: 'BT.601',
      extension: 'mp4',
      source: `nullsrc=size=${width}x${height}:rate=${fps},geq=r='if(lt(mod(X+floor(T*18)\,6)\,3)\,235\,16)':g='if(lt(mod(Y+floor(T*12)\,6)\,3)\,235\,16)':b='if(lt(mod(X+Y+floor(T*9)\,8)\,4)\,235\,16)'`,
      codec: h264Metadata('smpte170m', 'smpte170m', 'smpte170m'),
    },
    {
      id: 'grain_bt709_8bit',
      content: ['film-grain', 'texture'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `testsrc2=size=${width}x${height}:rate=${fps},noise=alls=24:allf=t+u`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'dark_scene_bt709_8bit',
      content: ['dark-scene', 'shadow-detail', 'low-contrast-motion'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `color=c=0x030508:size=${width}x${height}:rate=${fps},drawbox=x='mod(t*35\,iw+60)-60':y=ih*0.28:w=60:h=ih*0.44:c=0x182438:t=fill,noise=alls=5:allf=t+u`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'gradient_bt709_8bit',
      content: ['gradient', 'banding'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `gradients=size=${width}x${height}:rate=${fps}:c0=black:c1=white:n=2:speed=0.03:type=linear`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'horizontal_pan_bt709_8bit',
      content: ['horizontal-pan', 'scrolling-detail'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `testsrc2=size=${largeWidth}x${height}:rate=${fps},crop=${width}:${height}:x='mod(t*90\,${width})':y=0`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'zoom_bt709_8bit',
      content: ['zoom', 'scale-change'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `testsrc2=size=${width}x${height}:rate=${fps},zoompan=z='1+0.0015*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=${width}x${height}:fps=${fps}`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'high_motion_bt709_8bit',
      content: ['high-motion', 'rotation'],
      bitDepth: 8,
      color: 'BT.709',
      extension: 'mp4',
      source: `testsrc2=size=${width}x${height}:rate=${fps},rotate='t*2.4':ow=iw:oh=ih:c=black`,
      codec: h264Metadata('bt709', 'bt709', 'bt709'),
    },
    {
      id: 'low_bitrate_bt601_8bit',
      content: ['low-bitrate', 'blocking', 'ringing'],
      bitDepth: 8,
      color: 'BT.601',
      extension: 'mp4',
      source: `testsrc2=size=${width}x${height}:rate=${fps},noise=alls=8:allf=t`,
      codec: [
        '-an', '-c:v', 'libx264', '-preset', 'veryfast', '-b:v', '110k', '-maxrate', '110k',
        '-bufsize', '220k', '-g', String(fps * 2), '-pix_fmt', 'yuv420p',
        '-color_primaries', 'smpte170m', '-color_trc', 'smpte170m', '-colorspace', 'smpte170m',
        '-x264-params', 'colorprim=smpte170m:transfer=smpte170m:colormatrix=smpte170m',
        '-movflags', '+faststart',
      ],
    },
    {
      id: 'hdr_pq_bt2020_10bit',
      content: ['10-bit', 'BT.2020', 'PQ', 'gradient', 'highlight'],
      bitDepth: 10,
      color: 'BT.2020/PQ',
      extension: 'webm',
      source: `testsrc2=size=${width}x${height}:rate=${fps},format=gbrpf32le,zscale=primariesin=bt709:transferin=bt709:matrixin=bt709:primaries=bt2020:transfer=smpte2084:matrix=bt2020nc:npl=100,format=yuv420p10le`,
      codec: [
        '-an', '-c:v', 'libvpx-vp9', '-profile:v', '2', '-deadline', 'good', '-cpu-used', '4',
        '-row-mt', '1', '-crf', '28', '-b:v', '0', '-pix_fmt', 'yuv420p10le',
        '-color_primaries', 'bt2020', '-color_trc', 'smpte2084', '-colorspace', 'bt2020nc',
      ],
    },
    {
      id: 'hdr_hlg_bt2020_10bit',
      content: ['10-bit', 'BT.2020', 'HLG', 'motion'],
      bitDepth: 10,
      color: 'BT.2020/HLG',
      extension: 'webm',
      source: `testsrc2=size=${width}x${height}:rate=${fps},format=gbrpf32le,zscale=primariesin=bt709:transferin=bt709:matrixin=bt709:primaries=bt2020:transfer=arib-std-b67:matrix=bt2020nc:npl=100,format=yuv420p10le`,
      codec: [
        '-an', '-c:v', 'libvpx-vp9', '-profile:v', '2', '-deadline', 'good', '-cpu-used', '4',
        '-row-mt', '1', '-crf', '28', '-b:v', '0', '-pix_fmt', 'yuv420p10le',
        '-color_primaries', 'bt2020', '-color_trc', 'arib-std-b67', '-colorspace', 'bt2020nc',
      ],
    },
  ];
}

function probe(filePath) {
  const output = run('ffprobe', [
    '-v', 'error', '-count_frames', '-select_streams', 'v:0',
    '-show_entries', 'stream=codec_name,width,height,pix_fmt,color_space,color_transfer,color_primaries,nb_read_frames',
    '-of', 'json', filePath,
  ], `ffprobe ${path.basename(filePath)}`);
  return JSON.parse(output).streams?.[0] ?? {};
}

function expectedColorMetadata(color) {
  switch (color) {
    case 'BT.601':
      return { color_primaries: 'smpte170m', color_transfer: 'smpte170m', color_space: 'smpte170m' };
    case 'BT.709':
      return { color_primaries: 'bt709', color_transfer: 'bt709', color_space: 'bt709' };
    case 'BT.2020/PQ':
      return { color_primaries: 'bt2020', color_transfer: 'smpte2084', color_space: 'bt2020nc' };
    case 'BT.2020/HLG':
      return { color_primaries: 'bt2020', color_transfer: 'arib-std-b67', color_space: 'bt2020nc' };
    default:
      throw new Error(`Unknown fixture color metadata: ${color}`);
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const fixtures = createFixtureDefinitions(args);
  fs.mkdirSync(args.output, { recursive: true });
  const reports = [];
  for (const fixture of fixtures) {
    const fileName = `${fixture.id}.${fixture.extension}`;
    const filePath = path.join(args.output, fileName);
    if (args.force || !fs.existsSync(filePath)) {
      console.log(`generate ${fixture.id} ...`);
      run('ffmpeg', [
        '-hide_banner', '-loglevel', 'error', '-f', 'lavfi', '-i', fixture.source,
        '-frames:v', String(args.frames), ...fixture.codec, '-y', filePath,
      ], `ffmpeg ${fixture.id}`);
    }
    const stream = probe(filePath);
    const frameCount = Number.parseInt(stream.nb_read_frames, 10);
    if (frameCount !== args.frames) {
      throw new Error(`${fixture.id} contains ${frameCount} frames, expected ${args.frames}.`);
    }
    const expectedColor = expectedColorMetadata(fixture.color);
    for (const [field, expected] of Object.entries(expectedColor)) {
      if (stream[field] !== expected) {
        throw new Error(`${fixture.id} ${field} is ${stream[field] ?? 'missing'}, expected ${expected}.`);
      }
    }
    reports.push({
      id: fixture.id,
      file: fileName,
      content: fixture.content,
      intendedBitDepth: fixture.bitDepth,
      intendedColor: fixture.color,
      stream,
    });
  }
  const manifest = {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    framesPerClip: args.frames,
    fps: args.fps,
    width: args.width,
    height: args.height,
    clipCount: reports.length,
    fixtures: reports,
  };
  writeJsonAtomic(path.join(args.output, 'manifest.json'), manifest);
  console.log(`Video fixture manifest: ${path.join(args.output, 'manifest.json')}`);
}

module.exports = { createFixtureDefinitions, parseArgs };

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  }
}

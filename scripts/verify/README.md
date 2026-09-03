# Verification and Reproduction

The scripts in this directory provide optional local correctness, visual, and
performance checks. They are not required at extension runtime.

## Requirements

- Node.js and npm dependencies from `package-lock.json`.
- A Chromium build with WebGPU for GPU and visual checks.
- Python with OpenCV, NumPy, and Pillow for image and motion analysis.
- `ffmpeg` and `ffprobe` for motion-clip preparation.

Keep input manifests, source media, generated images, reports, and benchmark
results outside this repository. Do not stage generated output.

## Basic checks

```powershell
npm run verify:doctor
npm run verify:effects
npm run verify:wgsl
npm run verify:optimization-report
npm run check:public-surface
```

Run the commands that match the available local tools. GPU and native checks
may require platform-specific drivers or toolchains.

## Reference sources

When a generation or verification command needs an upstream reference, restore
the locked files and regenerate the derived sources as needed:

```powershell
npm run fetch:references -- --target <reference-id>
npm run fetch:cunny-reference
npm run generate:cunny
```

Keep restored source and generated artifacts local. The lock file is an
allowlist of files and includes their expected SHA-256 hashes.

## Visual evaluation

The visual runner requires explicit paths for the input manifest, effect matrix,
and output directory:

```powershell
npm run evaluate:visual-corpus -- `
  --manifest <external-root>/manifest.json `
  --matrix <external-root>/matrix.json `
  --output <external-root>/evaluation
```

The runner writes PNG outputs, checkpoints, and a summary below the output
directory. Those files are local evaluation artifacts and must remain outside
the repository.

## Motion analysis

Prepare compressed clips and decoded frames with explicit external paths:

```powershell
node scripts/prepare-compressed-motion-clips.js `
  --manifest <external-root>/motion/manifest.json `
  --source-root <external-root>/motion `
  --output-root <external-root>/motion/compressed

node scripts/prepare-motion-frame-corpus.js `
  --manifest <external-root>/motion/compressed/manifest.json `
  --output <external-root>/motion/frames
```

Motion-event analysis consumes the frame manifest and the corresponding output
frames:

```powershell
python scripts/analyze-motion-events.py `
  --manifest <external-root>/motion/frames/corpus-manifest.json `
  --outputs <external-root>/evaluation `
  --report <external-root>/motion/report `
  --chains <variant-a>,<variant-b>
```

## Image and preset comparison

Image comparison scripts also require explicit external result directories:

```powershell
python scripts/analyze-quality-single-model.py `
  --manifest <external-root>/manifest.json `
  --results-root <external-root>/evaluation/outputs `
  --results-root <external-root>/previous/outputs `
  --output <external-root>/analysis/quality.json

python scripts/analyze-preset-variants.py `
  --outputs <external-root>/evaluation/outputs `
  --inspection <external-root>/analysis/inspection `
  --output <external-root>/analysis/presets.json `
  --chains <variant-a>,<variant-b>,<variant-c>
```

## Performance comparison

Run the candidate benchmark with an external output directory:

```powershell
npm run benchmark:candidates -- --output-dir <external-root>/benchmarks
```

For a single GPU suite run, pass `--output <external-root>/gpu.json` to
`scripts/benchmark-gpu-suite.js`.

## Failure handling

Commands return a non-zero exit code when required inputs are missing, hashes do
not match, a report is incomplete, or an acceptance check fails. Check the
terminal error and the external output directory. Do not copy generated reports
or source media into the repository when sharing a result.

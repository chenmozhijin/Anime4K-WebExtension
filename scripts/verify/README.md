# Effect verification notes

Current recorded verification results are summarized in
[`BASELINE.md`](./BASELINE.md).

## Release validation policy

This project is primarily maintained by one maintainer. Release readiness is
therefore determined by the reproducible core checks that can be run in CI and
on the maintainer's available hardware. A complete cross-vendor hardware lab is
not a release requirement.

Required release gates are type checking, automated tests and coverage,
Chrome/Firefox production builds, production-bundle scanning, WGSL compilation,
and the applicable correctness checks for changed effects and preset chains.
WebGPU performance, temporal, and external-texture checks are run on the
maintainer's available browser and GPU environment.

The broader Edge, Firefox, AMD, Intel, Apple Silicon, macOS, and Linux matrix is
coverage metadata and a source of follow-up work. A report status such as
`pending-hardware-matrix` records those untested combinations; it does not by
itself prevent a release when the required local and CI gates pass. Release
notes should identify the validated environment and known limitations.

Optimizations that lack sufficient cross-hardware evidence remain disabled by
default. In particular, uncertified perceptual `shader-f16` paths must not be
enabled globally merely to satisfy performance targets on one device.

### Local GPU release checklist

GitHub-hosted CI intentionally excludes checks that require a real WebGPU
adapter. Before publishing a draft release that changes GPU execution, run the
applicable checks on the maintainer machine and record the browser, adapter,
and relevant limitations in the release notes:

```powershell
npm run verify:wgsl
npm run verify:kernel-variants
npm run verify:preset-chains -- --no-build
npm run generate:video-fixtures -- --smoke --output test-results/video-fixtures-smoke
npm run verify:external-texture -- --smoke
npm run verify:temporal -- --smoke --no-build
npm run test:gpu:smoke
npm run test:gpu:benchmark
```

These commands remain local release evidence. They are not GitHub branch
protection checks, and missing third-party hardware coverage does not prevent a
release when the reproducible software gates pass.

## Supported validation modes

`verify:effects` is intentionally raw-math only. It supports:

- `luma-math`: ACNetGLSL, ArtCNN, and CuNNy. The verifier writes a float32
  LUMA input fixture, renders the original GLSL through native libplacebo,
  captures the post-model LUMA texture, and compares `reference-luma.f32`
  against WebGPU `candidate-luma.f32`.
- `rgb-math`: Anime4K. The verifier writes a float32 RGBA input fixture,
  renders the original `HOOK MAIN` GLSL through native libplacebo, reads back
  `reference-rgba.f32`, and compares it against WebGPU `candidate-rgba.f32`.

The screenshot-comparison route was removed. It was useful while exploring the
problem, but it was not a stable math authority for LUMA-only shaders or
Anime4K boundary/color-path diagnostics.

ArtCNN exposes its existing packed final LUMA stage to the verifier. The browser
verification readback shader unpacks the 2x2 lanes into an x2 float32 LUMA
stream, so production rendering does not gain an extra unpack pass.

Reference sources are intentionally not committed as upstream source mirrors.
Run `npm run fetch:references -- --all --check` to verify the local locked
reference trees, or `npm run fetch:references -- --all` to restore the v1
reference files from `scripts/reference-source-lock.json`. The legacy
`npm run fetch:cunny-reference` alias is kept for CuNNy corresponding-source
compatibility.

## Source findings

The checked source caches are under `.cache/source`:

- libplacebo: `src/include/libplacebo/shaders/custom.h`,
  `src/shaders/custom_mpv.c`, `src/renderer.c`
- mpv: `video/out/vo_gpu_next.c`

Relevant findings:

- `vo_gpu_next` loads mpv-style GLSL through `pl_mpv_user_shader_parse`.
- libplacebo maps mpv `HOOK LUMA` to `PL_HOOK_LUMA_INPUT`.
- During plane reading, `pass_hook` runs on the LUMA plane before planes are
  merged and converted to RGB.
- `SAVE` textures from mpv-style shaders are private to libplacebo's
  `custom_mpv.c` hook implementation and are not exposed by the public renderer
  callback API.
- libplacebo exposes `pl_tex_download`, so the native runners read textures by
  owning or intercepting the target texture.

## Native reference runners

For strict ACNet/ArtCNN math validation, use the native libplacebo LUMA runner.
The implemented design is:

1. Upload deterministic LUMA fixtures into a `pl_frame`.
2. Load the original GLSL with `pl_mpv_user_shader_parse`.
3. Add an additional custom hook that runs after the LUMA model hook and copies
   the current LUMA texture into a caller-owned/downloadable texture.
4. Render with `pl_render_image`.
5. Download the captured texture via `pl_tex_download`.
6. Emit JSON metadata and optionally write first-channel `f32le` raw output for
   comparison against WebGPU readback.

For Anime4K, the native RGBA runner follows the same shape but uploads RGBA
fixtures and captures the final RGBA texture.

Build and exercise the runners with:

- `npm run verify:reference-libplacebo:build-luma`
- `npm run verify:reference-libplacebo:build-rgba`
- `npm run verify:reference-libplacebo:luma -- --effect-id artcnn/Upscale/C4F16`
- `npm run verify:reference-libplacebo:luma -- --width 16 --height 16 --output-dir test-results/verify/libplacebo-luma`

`verify:effects` stores `input-luma.f32`, `reference-luma.f32`,
`candidate-luma.f32`, `candidate.png`, and `metrics.json` for failed or
`--keep-artifacts` LUMA cases. For Anime4K `rgb-math` cases it stores
`input-rgba.f32`, `reference-rgba.f32`, `candidate-rgba.f32`, `candidate.png`,
and `metrics.json`.

On passing cases without `--keep-artifacts`, the verifier keeps the hot path
raw-only: it does not request the browser-side 8-bit preview readback and uses a
temporary work directory that is removed after comparison. Failed cases are
materialized into `test-results/verify/effects/**` with the preview PNG and raw
files needed for diagnosis.

The default built-in fixture set uses opaque alpha for strict raw math. The
`deterministic_noise_alpha` fixture is kept as an explicit alpha-semantics
diagnostic and is not included in default full runs unless selected with
`--fixture deterministic_noise_alpha`.

Native reference runner stdout/stderr are saved as `reference-luma.*.log` or
`reference-rgba.*.log` when present. `test-results/verify/effects/summary.json`
is refreshed after every case, so long runs still leave a usable partial report
if they are interrupted. It includes per-case timings for reference rendering,
WebGPU candidate rendering, comparison, total elapsed time, and a per-run
`runId`.

The native libplacebo reference runners use the D3D11 backend. Their stdout
JSON, and therefore `metrics.json` under `referenceInfo`, includes
`referenceBackend`, `referenceAdapter`, `referenceSoftware`, and
`referenceAdapterInfo`. Software fallback is not disabled by default so CI or
headless machines can still run the checks, but local hardware validation can
confirm `referenceSoftware: false` and inspect the adapter name. High CPU usage
during reference generation is expected because shader parsing, GPU/CPU
synchronization, texture download, and raw artifact writes all happen in the
native runner process.

`verify:effects` caches native reference raw output under
`.cache/verify-effects/reference` by default. The cache key includes the native
runner binary hash, original GLSL hash, raw input hash, validation mode,
dimensions, and scale, so changing fixtures, shaders, runner builds, or output
size forces a cold reference render. Cache hits still copy `reference-*.f32`
into the current case artifact directory and are reported as
`referenceCache.hit` in `metrics.json` and `referenceCacheHit` in
`summary.json`.

The browser candidate runner also reuses one WebGPU device per verification
page. This lets the production GPU resource cache reuse shader modules,
pipeline layouts, compute/render pipelines, and samplers across cases in the
same page, and it also caches the verifier's readback pipelines. Use
`--browser-recycle-every <n>` to bound long-run resource growth; setting it to
`1` intentionally disables most page-local candidate reuse.

Useful `verify:effects` options:

- `--fixture-exact`: require an exact fixture id match, so
  `--fixture checker_edges` does not also match `luma_checker_edges`.
- `--case-timeout-ms <ms>`: apply the same timeout to the native reference
  process and browser candidate run for each case.
- `--browser-recycle-every <n>`: recreate the Playwright page every N cases to
  release WebGPU and JS-side resources during long batches. The default is 8.
- `--shard <index>/<count>`: split the stable effect/fixture case list for
  manual or CI parallelism, for example `--shard 1/2` and `--shard 2/2`.
- `--no-build`: reuse the existing verification browser bundle during tight
  debug loops. By default the bundle is rebuilt.
- `--no-reference-cache`: force native libplacebo reference rendering even when
  a matching cached raw output exists.
- `--run-id <id>` or `VERIFY_RUN_ID=<id>`: stamp metrics and `summary.json`
  with a shared id, useful when one baseline is split across several commands.

Recommended baseline commands:

- `npm run verify:effects -- --filter anime4k --fixture gradient --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter anime4k --fixture checker_edges --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter anime4k --fixture deterministic_noise --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter acnet --fixture checker_edges --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter acnet --fixture luma_checker_edges --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter acnet --fixture gradient --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter acnet --fixture deterministic_noise --fixture-exact --keep-artifacts`
- `npm run verify:effects -- --filter artcnn --fixture checker_edges --fixture-exact --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter artcnn --fixture luma_checker_edges --fixture-exact --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter artcnn --fixture gradient --fixture-exact --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter artcnn --fixture deterministic_noise --fixture-exact --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter artcnn --fixture checker_edges --fixture-exact --shard 1/2 --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter artcnn --fixture checker_edges --fixture-exact --shard 2/2 --keep-artifacts --browser-recycle-every 1 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter cunny --fixture checker_edges --fixture-exact --keep-artifacts --browser-recycle-every 4 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter cunny --fixture luma_checker_edges --fixture-exact --keep-artifacts --browser-recycle-every 4 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter cunny --fixture gradient --fixture-exact --keep-artifacts --browser-recycle-every 4 --case-timeout-ms 300000`
- `npm run verify:effects -- --filter cunny --fixture deterministic_noise --fixture-exact --keep-artifacts --browser-recycle-every 4 --case-timeout-ms 300000`

Use `npm run verify:report` to aggregate existing `metrics.json` files into a
Markdown report. Pass `-- --format json` for machine-readable output, or
`-- --output test-results/verify/effects/report.md` to write the report.
Diagnostic fixtures are skipped by default; add `-- --include-diagnostic` when
you intentionally want alpha-semantics probes in the report. Add
`-- --run-id <id>` to report only metrics from one verification run.

## Native probe status

The parser probe remains useful for checking shader compatibility:

- `npm run verify:setup-native` installs Meson into `.cache/verify-tools/python`.
- `npm run verify:reference-libplacebo:doctor` checks VS, Python/Meson, Vulkan
  SDK, MSYS2/UCRT64, and UCRT64 libplacebo.
- `npm run verify:reference-libplacebo:build-probe` builds
  `.cache/verify-tools/native/libplacebo-probe.exe`.
- `npm run verify:reference-libplacebo:probe -- --filter acnet` verifies that
  original LUMA GLSL files parse through system libplacebo and expose
  `PL_HOOK_LUMA_INPUT`.
- `npm run verify:reference-libplacebo:build-luma` builds
  `.cache/verify-tools/native/libplacebo-luma-runner.exe`.
- `npm run verify:reference-libplacebo:build-rgba` builds
  `.cache/verify-tools/native/libplacebo-rgba-runner.exe`.
- `npm run verify:reference-libplacebo:luma -- --width 16 --height 16`
  renders all 57 LUMA effects through libplacebo and verifies the captured
  output dimensions.

MSVC environments may find Visual Studio but still fail to build current
libplacebo master if the compiler does not accept the `_Atomic` syntax used by
libplacebo's C11 atomics check. The practical route on Windows is UCRT64 MSYS2
packages: `mingw-w64-ucrt-x86_64-libplacebo` brings compatible libplacebo,
shaderc, SPIR-V, and Vulkan loader dependencies.

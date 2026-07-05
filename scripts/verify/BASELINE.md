# Effect Verification Baseline

This document records the current raw-math verification baseline for the
Anime4K, ArtCNN, ACNet, and CuNNy WebGPU implementations.

Date recorded: 2026-07-03

## Scope

The baseline uses original GLSL files under `.reference` as the mathematical
authority:

- `.reference/Anime4K`
- `.reference/ArtCNN`
- `.reference/ACNetGLSL`
- `.reference/CuNNy` restored from `scripts/reference-source-lock.json`

The verification modes are:

- `rgb-math` for Anime4K: native libplacebo RGBA reference readback compared
  against WebGPU RGBA readback.
- `luma-math` for ACNetGLSL, ArtCNN, and CuNNy: native libplacebo LUMA
  reference readback compared against WebGPU LUMA readback.

The removed mpv screenshot/final-RGB visual route is not part of this baseline.

## Pass Matrix

| Backend | Effects | Fixture | Mode | Result |
| --- | ---: | --- | --- | --- |
| Anime4K | 19 | `gradient` | `rgb-math` | 19/19 passed |
| Anime4K | 19 | `checker_edges` | `rgb-math` | 19/19 passed |
| Anime4K | 19 | `deterministic_noise` | `rgb-math` | 19/19 passed |
| ACNetGLSL | 33 | `checker_edges` | `luma-math` | 33/33 passed |
| ACNetGLSL | 33 | `luma_checker_edges` | `luma-math` | 33/33 passed |
| ACNetGLSL | 33 | `gradient` | `luma-math` | 33/33 passed |
| ACNetGLSL | 33 | `deterministic_noise` | `luma-math` | 33/33 passed |
| ArtCNN | 6 | `checker_edges` | `luma-math` | 6/6 passed |
| ArtCNN | 6 | `luma_checker_edges` | `luma-math` | 6/6 passed |
| ArtCNN | 6 | `gradient` | `luma-math` | 6/6 passed |
| ArtCNN | 6 | `deterministic_noise` | `luma-math` | 6/6 passed |
| CuNNy | 18 | `checker_edges` | `luma-math` | 18/18 passed |
| CuNNy | 18 | `luma_checker_edges` | `luma-math` | 18/18 passed |
| CuNNy | 18 | `gradient` | `luma-math` | 18/18 passed |
| CuNNy | 18 | `deterministic_noise` | `luma-math` | 18/18 passed |

Total recorded strict raw-math baseline cases: 285/285 passed.

CuNNy v1 baseline details:

- Scope: 18 non-dp4a LGPL mpv GLSL models from `.reference/CuNNy/mpv/ds`
  and `.reference/CuNNy/mpv/soft`.
- Excluded: Magpie/HLSL, GPL Magpie wrapper output, `dp4a`, and `*-Q.glsl`.
- Run id: `cunny-v1-2026-07-03`.
- Local aggregate artifact:
  `test-results/verify/effects/cunny-v1-2026-07-03.md`.
- Aggregate result: 72/72 passed, `failureCount: 0`.

The aggregate report generated from local `metrics.json` files after diagnostic
filtering reported `failureCount: 0`. That report may include extra exploratory
passing metrics from earlier local runs, so the table above is the canonical
baseline matrix.

## Graph Migration Probes

These targeted probes record raw-math checks run while migrating Anime4K
production pipelines from hand-wired classes to the shared declarative graph
runner. They do not replace the full pass matrix above; they are evidence that
the graph migration preserved output for the touched effects.

Recorded on 2026-07-05:

| Effect | Fixture | Mode | Result | meanAbs | maxAbs | Run id |
| --- | --- | --- | --- | ---: | ---: | --- |
| `anime4k/Restore/CNNM` | `gradient_224x96` | `rgb-math` | passed | 0.001086604 | 0.004882813 | `effect-graph-cnnm-probe` |
| `anime4k/Restore/CNNSoftM` | `gradient_224x96` | `rgb-math` | passed | 0.001025570 | 0.004394531 | `effect-graph-cnnsoftm-probe` |
| `anime4k/Restore/CNNL` | `gradient_224x96` | `rgb-math` | passed | 0.000786025 | 0.004394531 | `effect-graph-cnnl-probe` |
| `anime4k/Upscale/CNNx2L` | `gradient_112x48` | `rgb-math` | passed | 0.001146356 | 0.004394531 | `effect-graph-cnnx2l-probe` |
| `anime4k/Restore/CNNVL` | `gradient_224x96` | `rgb-math` | passed | 0.000876797 | 0.004882813 | `effect-graph-cnnvl-probe` |
| `anime4k/Restore/CNNSoftVL` | `gradient_224x96` | `rgb-math` | passed | 0.000897248 | 0.004394531 | `effect-graph-cnnsoftvl-probe` |
| `anime4k/Upscale/CNNx2VL` | `gradient_112x48` | `rgb-math` | passed | 0.001113704 | 0.004394531 | `effect-graph-cnnx2vl-probe` |
| `anime4k/Upscale/DenoiseCNNx2VL` | `gradient_112x48` | `rgb-math` | passed | 0.001050362 | 0.004882813 | `effect-graph-denoisecnnx2vl-probe` |
| `anime4k/Restore/CNNUL` | `gradient_224x96` | `rgb-math` | passed | 0.000962614 | 0.004882813 | `effect-graph-cnnul-probe` |
| `anime4k/Restore/GANUUL` | `gradient_224x96` | `rgb-math` | passed | 0.000989269 | 0.004882813 | `effect-graph-ganuul-probe` |
| `anime4k/Upscale/CNNx2UL` | `gradient_112x48` | `rgb-math` | passed | 0.001126723 | 0.004882813 | `effect-graph-cnnx2ul-probe` |
| `anime4k/Upscale/GANx3L` | `gradient_75x48` | `rgb-math` | passed | 0.000965455 | 0.004882813 | `effect-graph-ganx3l-probe` |
| `anime4k/Upscale/GANx4UUL` | `gradient` | `rgb-math` | passed | 0.001048376 | 0.006347656 | `effect-graph-ganx4uul-probe` |

Commands:

```powershell
npm run verify:effects -- --effect-id anime4k/Restore/CNNM --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnm-probe
npm run verify:effects -- --effect-id anime4k/Restore/CNNSoftM --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnsoftm-probe --no-build
npm run verify:effects -- --effect-id anime4k/Restore/CNNL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnl-probe
npm run verify:effects -- --effect-id anime4k/Upscale/CNNx2L --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnx2l-probe --no-build
npm run verify:effects -- --effect-id anime4k/Restore/CNNVL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnvl-probe
npm run verify:effects -- --effect-id anime4k/Restore/CNNSoftVL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnsoftvl-probe --no-build
npm run verify:effects -- --effect-id anime4k/Upscale/CNNx2VL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnx2vl-probe --no-build
npm run verify:effects -- --effect-id anime4k/Upscale/DenoiseCNNx2VL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-denoisecnnx2vl-probe --no-build
npm run verify:effects -- --effect-id anime4k/Restore/CNNUL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnul-probe
npm run verify:effects -- --effect-id anime4k/Restore/GANUUL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-ganuul-probe
npm run verify:effects -- --effect-id anime4k/Upscale/CNNx2UL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-cnnx2ul-probe --no-build
npm run verify:effects -- --effect-id anime4k/Upscale/GANx3L --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-ganx3l-probe
npm run verify:effects -- --effect-id anime4k/Upscale/GANx4UUL --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --run-id effect-graph-ganx4uul-probe
```

## Known Diagnostic Exclusion

`deterministic_noise_alpha` is intentionally excluded from the strict baseline.
It is marked `diagnosticOnly` and is only included when explicitly selected or
when `verify:report --include-diagnostic` is used.

Reason: the fixture mixes deterministic RGB noise with semi-transparent alpha.
Earlier Anime4K failures on this fixture were traced to alpha input semantics
between the native reference RGBA path and WebGPU upload path, not to RGB model
math. The opaque `deterministic_noise` fixture with the same RGB pattern passes
Anime4K 19/19.

## Reproduction Commands

Use a shared run id if these commands are split across multiple shells:

```powershell
$env:VERIFY_RUN_ID = 'baseline-2026-07-03'
```

Anime4K:

```powershell
npm run verify:effects -- --filter anime4k --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000
npm run verify:effects -- --filter anime4k --fixture checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000
npm run verify:effects -- --filter anime4k --fixture deterministic_noise --fixture-exact --keep-artifacts --case-timeout-ms 300000
```

ACNetGLSL:

```powershell
npm run verify:effects -- --filter acnet --fixture checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4
npm run verify:effects -- --filter acnet --fixture luma_checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4
npm run verify:effects -- --filter acnet --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4
npm run verify:effects -- --filter acnet --fixture deterministic_noise --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4
```

ArtCNN:

```powershell
npm run verify:effects -- --filter artcnn --fixture checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 1
npm run verify:effects -- --filter artcnn --fixture luma_checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 1
npm run verify:effects -- --filter artcnn --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 1
npm run verify:effects -- --filter artcnn --fixture deterministic_noise --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 1
```

CuNNy:

```powershell
npm run fetch:references -- --all --check
```

CuNNy:

```powershell
npm run verify:effects -- --filter cunny --fixture checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4 --run-id cunny-v1-2026-07-03
npm run verify:effects -- --filter cunny --fixture luma_checker_edges --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4 --run-id cunny-v1-2026-07-03
npm run verify:effects -- --filter cunny --fixture gradient --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4 --run-id cunny-v1-2026-07-03
npm run verify:effects -- --filter cunny --fixture deterministic_noise --fixture-exact --keep-artifacts --case-timeout-ms 300000 --browser-recycle-every 4 --run-id cunny-v1-2026-07-03
```

Aggregate report:

```powershell
npm run verify:report -- --run-id baseline-2026-07-03 --output test-results\verify\effects\baseline-2026-07-03.md
```

## Regression Checks

The following checks passed after the verification and report-hygiene changes:

- `npm run typecheck`
- `npm run test:unit`
- `npm run test:dom`
- `npm run build:chrome`
- `npm run build:firefox`
- `npm run check:production-bundle`: no forbidden verify/reference-only strings
  in `dist-chrome` or `dist-firefox` JS/HTML/CSS/JSON assets. The scan covers
  `libplacebo`, `verify-effects`, raw reference/candidate artifact names,
  `__runEffectVerification`, `scripts/verify`, `test/verify`, and
  `.reference/{Anime4K,ArtCNN,ACNetGLSL,CuNNy}`.
- CuNNy production JS scan for `.reference/CuNNy`, `Magpie`, `magpie`,
  `dp4a`, `.hlsl`, `-Q.glsl`, and `reference-models`: no matches in
  `dist-chrome` or `dist-firefox` JavaScript assets.
- `dist-chrome` and `dist-firefox` include `LICENSE`,
  `licenses/LGPL-3.0-or-later.txt`, and `THIRD_PARTY_NOTICES.md`.

## Notes

- Verification artifacts under `test-results/verify` are local run outputs and
  are not required as source files.
- The baseline intentionally validates raw math, not perceptual quality.
- The next review target is production shader diffs introduced while aligning
  Anime4K math with the original GLSL reference.

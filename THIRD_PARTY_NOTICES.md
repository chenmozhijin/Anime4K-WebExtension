# Third-Party Notices

This repository is distributed as a mixed-license project:

- Core NijiLucid code: MIT License, see `licenses/MIT.txt`.
- CuNNy-derived generated components: LGPL-3.0-or-later, see
  `licenses/LGPL-3.0-or-later.txt`.

Some optional effect components bundled with the default extension package use
separate licenses, as listed below.

## Anime4K

- Component: Anime4K shader/effect behavior and model references used by the
  built-in Anime4K effects.
- License: MIT.
- Upstream: https://github.com/bloc97/Anime4K
- Locked commit: 7684e9586f8dcc738af08a1cdceb024cc184f426
- Reference lock: `scripts/reference-source-lock.json`

The locked reference files can be restored for generation or verification with:

```powershell
npm run fetch:references -- --target anime4k
```

## Anime4K-WebGPU

- Component: Early WebGPU implementation reference.
- License: MIT.
- Upstream: https://github.com/Anime4KWebBoost/Anime4K-WebGPU

This component is acknowledged for attribution and is not a restorable source
target in the current reference lock.

## ArtCNN

- Component: ArtCNN GLSL/model references used by ArtCNN verification and
  WebGPU effect behavior.
- License: MIT.
- Upstream: https://github.com/Artoriuz/ArtCNN
- Locked commit: f606e1f0ba7e6f0ab55049f33dac4d854819b00b
- Reference lock: `scripts/reference-source-lock.json`

The locked reference files can be restored for verification with:

```powershell
npm run fetch:references -- --target artcnn
```

## ACNetGLSL

- Component: ACNet and ARNet GLSL references used by generated ACNet WebGPU
  effects and verification.
- License: MIT.
- Upstream: https://github.com/TianZerL/ACNetGLSL
- Locked commit: c7d2d8dbb5364c550e5bfb738860fc9bcc0ea424
- Reference lock: `scripts/reference-source-lock.json`

The locked reference files can be restored for generation or verification with:

```powershell
npm run fetch:references -- --target acnet
```

## CuNNy

- Component: CuNNy generated WebGPU shaders, model manifests, lazy-load model
  chunks, and CuNNy effect descriptors.
- License: LGPL-3.0-or-later.
- Upstream: https://github.com/funnyplanter/CuNNy
- Locked commit: 906031bb00c15dd6a6bbbaa21c0eb0b724ca8437
- Generated components: `src/engines/cunny/generated/**`
- Reference lock: `scripts/reference-source-lock.json`

### Corresponding Source

For the CuNNy-derived components included in the default extension package, the
corresponding upstream reference source can be retrieved with:

```powershell
npm run fetch:references -- --target cunny
npm run fetch:cunny-reference
```

These commands read `scripts/reference-source-lock.json`, download the locked
CuNNy archive from upstream, restore only the files listed by the lock, and
verify their SHA-256 hashes. They do not install anything system-wide and do
not run automatically during build or test.

The locked source details are:

- Upstream URL: https://github.com/funnyplanter/CuNNy
- Commit: `906031bb00c15dd6a6bbbaa21c0eb0b724ca8437`
- Corresponding source scope: the files listed for CuNNy in
  `scripts/reference-source-lock.json`.

The generated CuNNy files can be recreated from the restored references with:

```powershell
npm run generate:cunny
```

If the published package is redistributed, keep `LICENSE`, this file,
`licenses/MIT.txt`, and `licenses/LGPL-3.0-or-later.txt` with it.

This notice does not change the license of the MIT core code outside the
CuNNy-derived components.

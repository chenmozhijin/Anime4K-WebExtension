# Reproduction Reference

This document describes the smallest public input contract for the optional
visual and image-analysis scripts. It intentionally contains no project data or
run history.

## Manifest

The manifest is a JSON file with an `inputs` array. Each input uses:

- `id`: stable input identifier.
- `path`: an absolute path or a path relative to the manifest.
- `sourceClass`: optional grouping label used for output organization.
- `width` and `height`: optional dimension checks.
- `sha256`: optional integrity check.
- `crops`: optional rectangles with `id`, `x`, `y`, `width`, and `height`.

See `scripts/verify/examples/manifest.template.json` for a data-free template.

## Matrix

The effect matrix contains a positive integer `targetScale` and a non-empty
`chains` array. Each chain has an `id` and either an `effects` array or a
`preset` plus `tier` pair.

See `scripts/verify/examples/matrix.template.json` for a data-free template.

## Reproduction sequence

1. Prepare or obtain inputs outside the repository.
2. Create a manifest and matrix from the templates.
3. Run `npm run evaluate:visual-corpus` with explicit external paths.
4. Run the comparison or motion-analysis script against the generated outputs.
5. Compare metrics and inspection images using the same input hashes and
   effect IDs.

All generated files belong in the external output directory. The scripts do not
require the corpus or result files to be checked into Git.

## Interpretation

The reports contain dimensions, hashes, effect IDs, image-difference metrics,
timings, and pass/fail results. GPU timing and image output can vary across
browsers, drivers, and hardware, so reproduce with the same environment when a
bit-for-bit comparison is required.

// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import type { CuNNyGeneratedModelConfig } from '../pipeline';

export type CuNNyGeneratedModelLoader = () => Promise<CuNNyGeneratedModelConfig>;

export const cunnyGeneratedModelLoaders: Record<string, CuNNyGeneratedModelLoader> = {
  "CUNNY_2X12_DS": async () => (await import(/* webpackChunkName: "cunny-effect-2x12-ds" */ './2x12_ds')).default,
  "CUNNY_3X12_DS": async () => (await import(/* webpackChunkName: "cunny-effect-3x12-ds" */ './3x12_ds')).default,
  "CUNNY_4X12_DS": async () => (await import(/* webpackChunkName: "cunny-effect-4x12-ds" */ './4x12_ds')).default,
  "CUNNY_4X16_DS": async () => (await import(/* webpackChunkName: "cunny-effect-4x16-ds" */ './4x16_ds')).default,
  "CUNNY_4X24_DS": async () => (await import(/* webpackChunkName: "cunny-effect-4x24-ds" */ './4x24_ds')).default,
  "CUNNY_4X32_DS": async () => (await import(/* webpackChunkName: "cunny-effect-4x32-ds" */ './4x32_ds')).default,
  "CUNNY_8X32_DS": async () => (await import(/* webpackChunkName: "cunny-effect-8x32-ds" */ './8x32_ds')).default,
  "CUNNY_FAST_DS": async () => (await import(/* webpackChunkName: "cunny-effect-fast-ds" */ './fast_ds')).default,
  "CUNNY_FASTER_DS": async () => (await import(/* webpackChunkName: "cunny-effect-faster-ds" */ './faster_ds')).default,
  "CUNNY_2X12_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-2x12-soft" */ './2x12_soft')).default,
  "CUNNY_3X12_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-3x12-soft" */ './3x12_soft')).default,
  "CUNNY_4X12_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-4x12-soft" */ './4x12_soft')).default,
  "CUNNY_4X16_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-4x16-soft" */ './4x16_soft')).default,
  "CUNNY_4X24_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-4x24-soft" */ './4x24_soft')).default,
  "CUNNY_4X32_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-4x32-soft" */ './4x32_soft')).default,
  "CUNNY_FAST_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-fast-soft" */ './fast_soft')).default,
  "CUNNY_FASTER_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-faster-soft" */ './faster_soft')).default,
  "CUNNY_VERYFAST_SOFT": async () => (await import(/* webpackChunkName: "cunny-effect-veryfast-soft" */ './veryfast_soft')).default,
};

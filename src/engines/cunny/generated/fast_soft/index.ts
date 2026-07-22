// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import { createCuNNyWorkgroupTileVariant, createCuNNyWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';
import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const CuNNyFastSoftConfig: CuNNyGeneratedModelConfig = {
  key: "CUNNY_FAST_SOFT",
  name: "CuNNy fast SOFT",
  variant: "soft",
  stages: [
    {
      name: "CuNNy-fast-SOFT-in",
      shaderWGSL: stage0WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage0WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage0WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["LUMA"],
      outputName: "in",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-fast-SOFT-conv1",
      shaderWGSL: stage1WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage1WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage1WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["in","LUMA"],
      outputName: "conv1",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-fast-SOFT-conv2",
      shaderWGSL: stage2WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage2WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage2WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv1","LUMA"],
      outputName: "conv2",
      outputScale: {"x":2,"y":1},
      final: false,
    },
    {
      name: "CuNNy-fast-SOFT-out-shuffle",
      shaderWGSL: stage3WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage3WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage3WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv2","LUMA"],
      outputName: "__FINAL_LUMA_3",
      outputScale: {"x":2,"y":2},
      final: true,
    }
  ],
};

export default CuNNyFastSoftConfig;

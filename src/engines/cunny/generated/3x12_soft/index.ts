// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import { createCuNNyWorkgroupTileVariant, createCuNNyWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';
import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import stage4WGSL from './shaders/stage4.wgsl';
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const CuNNy3x12SoftConfig: CuNNyGeneratedModelConfig = {
  key: "CUNNY_3X12_SOFT",
  name: "CuNNy 3x12 SOFT",
  variant: "soft",
  stages: [
    {
      name: "CuNNy-3x12-SOFT-in",
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
      name: "CuNNy-3x12-SOFT-conv1",
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
      name: "CuNNy-3x12-SOFT-conv2",
      shaderWGSL: stage2WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage2WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage2WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv1","LUMA"],
      outputName: "conv2",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-3x12-SOFT-conv3",
      shaderWGSL: stage3WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage3WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage3WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv2","LUMA"],
      outputName: "conv3",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-3x12-SOFT-out-shuffle",
      shaderWGSL: stage4WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage4WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage4WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv3","LUMA"],
      outputName: "__FINAL_LUMA_4",
      outputScale: {"x":2,"y":2},
      final: true,
    }
  ],
};

export default CuNNy3x12SoftConfig;

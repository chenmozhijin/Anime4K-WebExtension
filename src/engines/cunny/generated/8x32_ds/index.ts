// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import { createCuNNyWorkgroupTileVariant, createCuNNyWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';
import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import stage4WGSL from './shaders/stage4.wgsl';
import stage5WGSL from './shaders/stage5.wgsl';
import stage6WGSL from './shaders/stage6.wgsl';
import stage7WGSL from './shaders/stage7.wgsl';
import stage8WGSL from './shaders/stage8.wgsl';
import stage9WGSL from './shaders/stage9.wgsl';
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const CuNNy8x32DsConfig: CuNNyGeneratedModelConfig = {
  key: "CUNNY_8X32_DS",
  name: "CuNNy 8x32 DS",
  variant: "ds",
  stages: [
    {
      name: "CuNNy-8x32-DS-in",
      shaderWGSL: stage0WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage0WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage0WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["LUMA"],
      outputName: "in",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv1",
      shaderWGSL: stage1WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage1WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage1WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["in","LUMA"],
      outputName: "conv1",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv2",
      shaderWGSL: stage2WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage2WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage2WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv1","LUMA"],
      outputName: "conv2",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv3",
      shaderWGSL: stage3WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage3WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage3WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv2","LUMA"],
      outputName: "conv3",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv4",
      shaderWGSL: stage4WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage4WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage4WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv3","LUMA"],
      outputName: "conv4",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv5",
      shaderWGSL: stage5WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage5WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage5WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv4","LUMA"],
      outputName: "conv5",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv6",
      shaderWGSL: stage6WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage6WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage6WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv5","LUMA"],
      outputName: "conv6",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv7",
      shaderWGSL: stage7WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage7WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage7WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv6","LUMA"],
      outputName: "conv7",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-conv8",
      shaderWGSL: stage8WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage8WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage8WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv7","LUMA"],
      outputName: "conv8",
      outputScale: {"x":4,"y":2},
      final: false,
    },
    {
      name: "CuNNy-8x32-DS-out-shuffle",
      shaderWGSL: stage9WGSL,
      optimizedShaderWGSL: createCuNNyWorkgroupTileVariant(stage9WGSL),
      kernelVariants: createCuNNyWorkgroupTileVariants(stage9WGSL),
      optimizationFlag: 'cunnyWorkgroupTile',
      bindings: ["conv8","LUMA"],
      outputName: "__FINAL_LUMA_9",
      outputScale: {"x":2,"y":2},
      final: true,
    }
  ],
};

export default CuNNy8x32DsConfig;

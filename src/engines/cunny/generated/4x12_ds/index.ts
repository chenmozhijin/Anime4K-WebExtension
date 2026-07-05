// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import stage4WGSL from './shaders/stage4.wgsl';
import stage5WGSL from './shaders/stage5.wgsl';
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const CuNNy4x12DsConfig: CuNNyGeneratedModelConfig = {
  key: "CUNNY_4X12_DS",
  name: "CuNNy 4x12 DS",
  variant: "ds",
  stages: [
    {
      name: "CuNNy-4x12-DS-in",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "in",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-4x12-DS-conv1",
      shaderWGSL: stage1WGSL,
      bindings: ["in","LUMA"],
      outputName: "conv1",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-4x12-DS-conv2",
      shaderWGSL: stage2WGSL,
      bindings: ["conv1","LUMA"],
      outputName: "conv2",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-4x12-DS-conv3",
      shaderWGSL: stage3WGSL,
      bindings: ["conv2","LUMA"],
      outputName: "conv3",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-4x12-DS-conv4",
      shaderWGSL: stage4WGSL,
      bindings: ["conv3","LUMA"],
      outputName: "conv4",
      outputScale: {"x":3,"y":1},
      final: false,
    },
    {
      name: "CuNNy-4x12-DS-out-shuffle",
      shaderWGSL: stage5WGSL,
      bindings: ["conv4","LUMA"],
      outputName: "__FINAL_LUMA_5",
      outputScale: {"x":2,"y":2},
      final: true,
    }
  ],
};

export default CuNNy4x12DsConfig;

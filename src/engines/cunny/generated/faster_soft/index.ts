// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

import stage0WGSL from './shaders/stage0.wgsl';
import stage1WGSL from './shaders/stage1.wgsl';
import stage2WGSL from './shaders/stage2.wgsl';
import stage3WGSL from './shaders/stage3.wgsl';
import type { CuNNyGeneratedModelConfig } from '../../pipeline';

export const CuNNyFasterSoftConfig: CuNNyGeneratedModelConfig = {
  key: "CUNNY_FASTER_SOFT",
  name: "CuNNy faster SOFT",
  variant: "soft",
  stages: [
    {
      name: "CuNNy-faster-SOFT-in",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "in",
      outputScale: {"x":2,"y":1},
      final: false,
    },
    {
      name: "CuNNy-faster-SOFT-conv1",
      shaderWGSL: stage1WGSL,
      bindings: ["in","LUMA"],
      outputName: "conv1",
      outputScale: {"x":2,"y":1},
      final: false,
    },
    {
      name: "CuNNy-faster-SOFT-conv2",
      shaderWGSL: stage2WGSL,
      bindings: ["conv1","LUMA"],
      outputName: "conv2",
      outputScale: {"x":2,"y":1},
      final: false,
    },
    {
      name: "CuNNy-faster-SOFT-out-shuffle",
      shaderWGSL: stage3WGSL,
      bindings: ["conv2","LUMA"],
      outputName: "__FINAL_LUMA_3",
      outputScale: {"x":2,"y":2},
      final: true,
    }
  ],
};

export default CuNNyFasterSoftConfig;

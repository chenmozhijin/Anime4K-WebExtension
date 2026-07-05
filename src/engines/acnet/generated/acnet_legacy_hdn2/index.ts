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
import stage10WGSL from './shaders/stage10.wgsl';
import stage11WGSL from './shaders/stage11.wgsl';
import stage12WGSL from './shaders/stage12.wgsl';
import stage13WGSL from './shaders/stage13.wgsl';
import stage14WGSL from './shaders/stage14.wgsl';
import stage15WGSL from './shaders/stage15.wgsl';
import stage16WGSL from './shaders/stage16.wgsl';
import stage17WGSL from './shaders/stage17.wgsl';
import stage18WGSL from './shaders/stage18.wgsl';
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const AcnetLegacyHdn2Config: ACNetGeneratedModelConfig = {
  key: "ACNET_LEGACY_HDN2",
  name: "ACNet Legacy HDN2",
  sourceFamily: "acnet-legacy",
  stages: [
    {
      name: "ACNet Legacy conv 0 1x8x3x3 part 0",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 0 1x8x3x3 part 1",
      shaderWGSL: stage1WGSL,
      bindings: ["LUMA"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 1 8x8x3x3 part 0",
      shaderWGSL: stage2WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 1 8x8x3x3 part 1",
      shaderWGSL: stage3WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 2 8x8x3x3 part 0",
      shaderWGSL: stage4WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 2 8x8x3x3 part 1",
      shaderWGSL: stage5WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 3 8x8x3x3 part 0",
      shaderWGSL: stage6WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 3 8x8x3x3 part 1",
      shaderWGSL: stage7WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 4 8x8x3x3 part 0",
      shaderWGSL: stage8WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 4 8x8x3x3 part 1",
      shaderWGSL: stage9WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 5 8x8x3x3 part 0",
      shaderWGSL: stage10WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 5 8x8x3x3 part 1",
      shaderWGSL: stage11WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 6 8x8x3x3 part 0",
      shaderWGSL: stage12WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 6 8x8x3x3 part 1",
      shaderWGSL: stage13WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 7 8x8x3x3 part 0",
      shaderWGSL: stage14WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 7 8x8x3x3 part 1",
      shaderWGSL: stage15WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 8 8x8x3x3 part 0",
      shaderWGSL: stage16WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy conv 8 8x8x3x3 part 1",
      shaderWGSL: stage17WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ACNet Legacy deconv 8x1x2x2",
      shaderWGSL: stage18WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "__FINAL_LUMA_18",
      outputScale: 2,
      final: true,
    }
  ],
};

export default AcnetLegacyHdn2Config;

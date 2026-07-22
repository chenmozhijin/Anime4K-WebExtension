import { createACNetWorkgroupTileVariant, createACNetWorkgroupTileVariants } from '../../../../core/generated-models/workgroup-tile-variant';
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
import stage19WGSL from './shaders/stage19.wgsl';
import stage20WGSL from './shaders/stage20.wgsl';
import stage21WGSL from './shaders/stage21.wgsl';
import stage22WGSL from './shaders/stage22.wgsl';
import stage23WGSL from './shaders/stage23.wgsl';
import stage24WGSL from './shaders/stage24.wgsl';
import stage25WGSL from './shaders/stage25.wgsl';
import stage26WGSL from './shaders/stage26.wgsl';
import stage27WGSL from './shaders/stage27.wgsl';
import stage28WGSL from './shaders/stage28.wgsl';
import stage29WGSL from './shaders/stage29.wgsl';
import stage30WGSL from './shaders/stage30.wgsl';
import stage31WGSL from './shaders/stage31.wgsl';
import stage32WGSL from './shaders/stage32.wgsl';
import stage33WGSL from './shaders/stage33.wgsl';
import stage34WGSL from './shaders/stage34.wgsl';
import stage35WGSL from './shaders/stage35.wgsl';
import stage36WGSL from './shaders/stage36.wgsl';
import stage37WGSL from './shaders/stage37.wgsl';
import stage38WGSL from './shaders/stage38.wgsl';
import stage39WGSL from './shaders/stage39.wgsl';
import stage39VectorizedWGSL from './shaders/stage39.vectorized.wgsl';
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const AcnetF8b18BoxHdnConfig: ACNetGeneratedModelConfig = {
  key: "ACNET_F8B18_BOX_HDN",
  name: "ACNet F8B18 Box HDN",
  sourceFamily: "acnet",
  stages: [
    {
      name: "ACNet F8B18 head conv 1x8x3x3 part 0",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage0WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage0WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 head conv 1x8x3x3 part 1",
      shaderWGSL: stage1WGSL,
      bindings: ["LUMA"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage1WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage1WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 1 conv 8x8x3x3 part 0",
      shaderWGSL: stage2WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage2WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage2WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 1 conv 8x8x3x3 part 1",
      shaderWGSL: stage3WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage3WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage3WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 2 conv 8x8x3x3 part 0",
      shaderWGSL: stage4WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage4WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage4WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 2 conv 8x8x3x3 part 1",
      shaderWGSL: stage5WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage5WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage5WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 3 conv 8x8x3x3 part 0",
      shaderWGSL: stage6WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage6WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage6WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 3 conv 8x8x3x3 part 1",
      shaderWGSL: stage7WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage7WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage7WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 4 conv 8x8x3x3 part 0",
      shaderWGSL: stage8WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage8WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage8WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 4 conv 8x8x3x3 part 1",
      shaderWGSL: stage9WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage9WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage9WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 5 conv 8x8x3x3 part 0",
      shaderWGSL: stage10WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage10WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage10WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 5 conv 8x8x3x3 part 1",
      shaderWGSL: stage11WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage11WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage11WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 6 conv 8x8x3x3 part 0",
      shaderWGSL: stage12WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage12WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage12WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 6 conv 8x8x3x3 part 1",
      shaderWGSL: stage13WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage13WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage13WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 7 conv 8x8x3x3 part 0",
      shaderWGSL: stage14WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage14WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage14WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 7 conv 8x8x3x3 part 1",
      shaderWGSL: stage15WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage15WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage15WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 8 conv 8x8x3x3 part 0",
      shaderWGSL: stage16WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage16WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage16WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 8 conv 8x8x3x3 part 1",
      shaderWGSL: stage17WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage17WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage17WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 9 conv 8x8x3x3 part 0",
      shaderWGSL: stage18WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage18WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage18WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 9 conv 8x8x3x3 part 1",
      shaderWGSL: stage19WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage19WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage19WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 10 conv 8x8x3x3 part 0",
      shaderWGSL: stage20WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage20WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage20WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 10 conv 8x8x3x3 part 1",
      shaderWGSL: stage21WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage21WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage21WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 11 conv 8x8x3x3 part 0",
      shaderWGSL: stage22WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage22WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage22WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 11 conv 8x8x3x3 part 1",
      shaderWGSL: stage23WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage23WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage23WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 12 conv 8x8x3x3 part 0",
      shaderWGSL: stage24WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage24WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage24WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 12 conv 8x8x3x3 part 1",
      shaderWGSL: stage25WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage25WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage25WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 13 conv 8x8x3x3 part 0",
      shaderWGSL: stage26WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage26WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage26WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 13 conv 8x8x3x3 part 1",
      shaderWGSL: stage27WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage27WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage27WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 14 conv 8x8x3x3 part 0",
      shaderWGSL: stage28WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage28WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage28WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 14 conv 8x8x3x3 part 1",
      shaderWGSL: stage29WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage29WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage29WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 15 conv 8x8x3x3 part 0",
      shaderWGSL: stage30WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage30WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage30WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 15 conv 8x8x3x3 part 1",
      shaderWGSL: stage31WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage31WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage31WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 16 conv 8x8x3x3 part 0",
      shaderWGSL: stage32WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage32WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage32WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 16 conv 8x8x3x3 part 1",
      shaderWGSL: stage33WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage33WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage33WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 17 conv 8x8x3x3 part 0",
      shaderWGSL: stage34WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage34WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage34WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 17 conv 8x8x3x3 part 1",
      shaderWGSL: stage35WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage35WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage35WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 18 conv 8x8x3x3 part 0",
      shaderWGSL: stage36WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage36WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage36WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 body block 18 conv 8x8x3x3 part 1",
      shaderWGSL: stage37WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage37WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage37WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18 upscale conv 8x4x3x3 part 0",
      shaderWGSL: stage38WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","LUMA"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage38WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage38WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ACNet F8B18upscale pixelshuff",
      shaderWGSL: stage39WGSL,
      bindings: ["TMP2_TEX_0"],
      outputName: "__FINAL_LUMA_39",
      outputScale: 2,

      optimizedShaderWGSL: stage39VectorizedWGSL,
      optimizationFlag: 'vectorizedPixelShuffle',
      optimizedDispatchScale: 1,
      finalOperation: 'pixel-shuffle-2x',
      final: true,
    }
  ],
};

export default AcnetF8b18BoxHdnConfig;

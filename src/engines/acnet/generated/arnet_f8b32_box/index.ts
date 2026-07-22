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
import stage40WGSL from './shaders/stage40.wgsl';
import stage41WGSL from './shaders/stage41.wgsl';
import stage42WGSL from './shaders/stage42.wgsl';
import stage43WGSL from './shaders/stage43.wgsl';
import stage44WGSL from './shaders/stage44.wgsl';
import stage45WGSL from './shaders/stage45.wgsl';
import stage46WGSL from './shaders/stage46.wgsl';
import stage47WGSL from './shaders/stage47.wgsl';
import stage48WGSL from './shaders/stage48.wgsl';
import stage49WGSL from './shaders/stage49.wgsl';
import stage50WGSL from './shaders/stage50.wgsl';
import stage51WGSL from './shaders/stage51.wgsl';
import stage52WGSL from './shaders/stage52.wgsl';
import stage53WGSL from './shaders/stage53.wgsl';
import stage54WGSL from './shaders/stage54.wgsl';
import stage55WGSL from './shaders/stage55.wgsl';
import stage56WGSL from './shaders/stage56.wgsl';
import stage57WGSL from './shaders/stage57.wgsl';
import stage58WGSL from './shaders/stage58.wgsl';
import stage59WGSL from './shaders/stage59.wgsl';
import stage60WGSL from './shaders/stage60.wgsl';
import stage61WGSL from './shaders/stage61.wgsl';
import stage62WGSL from './shaders/stage62.wgsl';
import stage63WGSL from './shaders/stage63.wgsl';
import stage64WGSL from './shaders/stage64.wgsl';
import stage65WGSL from './shaders/stage65.wgsl';
import stage66WGSL from './shaders/stage66.wgsl';
import stage67WGSL from './shaders/stage67.wgsl';
import stage68WGSL from './shaders/stage68.wgsl';
import stage69WGSL from './shaders/stage69.wgsl';
import stage70WGSL from './shaders/stage70.wgsl';
import stage71WGSL from './shaders/stage71.wgsl';
import stage72WGSL from './shaders/stage72.wgsl';
import stage73WGSL from './shaders/stage73.wgsl';
import stage74WGSL from './shaders/stage74.wgsl';
import stage75WGSL from './shaders/stage75.wgsl';
import stage76WGSL from './shaders/stage76.wgsl';
import stage77WGSL from './shaders/stage77.wgsl';
import stage78WGSL from './shaders/stage78.wgsl';
import stage79WGSL from './shaders/stage79.wgsl';
import stage80WGSL from './shaders/stage80.wgsl';
import stage81WGSL from './shaders/stage81.wgsl';
import stage82WGSL from './shaders/stage82.wgsl';
import stage83WGSL from './shaders/stage83.wgsl';
import stage84WGSL from './shaders/stage84.wgsl';
import stage85WGSL from './shaders/stage85.wgsl';
import stage86WGSL from './shaders/stage86.wgsl';
import stage87WGSL from './shaders/stage87.wgsl';
import stage88WGSL from './shaders/stage88.wgsl';
import stage89WGSL from './shaders/stage89.wgsl';
import stage90WGSL from './shaders/stage90.wgsl';
import stage91WGSL from './shaders/stage91.wgsl';
import stage92WGSL from './shaders/stage92.wgsl';
import stage93WGSL from './shaders/stage93.wgsl';
import stage94WGSL from './shaders/stage94.wgsl';
import stage95WGSL from './shaders/stage95.wgsl';
import stage96WGSL from './shaders/stage96.wgsl';
import stage97WGSL from './shaders/stage97.wgsl';
import stage98WGSL from './shaders/stage98.wgsl';
import stage99WGSL from './shaders/stage99.wgsl';
import stage100WGSL from './shaders/stage100.wgsl';
import stage101WGSL from './shaders/stage101.wgsl';
import stage102WGSL from './shaders/stage102.wgsl';
import stage103WGSL from './shaders/stage103.wgsl';
import stage104WGSL from './shaders/stage104.wgsl';
import stage105WGSL from './shaders/stage105.wgsl';
import stage106WGSL from './shaders/stage106.wgsl';
import stage107WGSL from './shaders/stage107.wgsl';
import stage108WGSL from './shaders/stage108.wgsl';
import stage109WGSL from './shaders/stage109.wgsl';
import stage110WGSL from './shaders/stage110.wgsl';
import stage111WGSL from './shaders/stage111.wgsl';
import stage112WGSL from './shaders/stage112.wgsl';
import stage113WGSL from './shaders/stage113.wgsl';
import stage114WGSL from './shaders/stage114.wgsl';
import stage115WGSL from './shaders/stage115.wgsl';
import stage116WGSL from './shaders/stage116.wgsl';
import stage117WGSL from './shaders/stage117.wgsl';
import stage118WGSL from './shaders/stage118.wgsl';
import stage119WGSL from './shaders/stage119.wgsl';
import stage120WGSL from './shaders/stage120.wgsl';
import stage121WGSL from './shaders/stage121.wgsl';
import stage122WGSL from './shaders/stage122.wgsl';
import stage123WGSL from './shaders/stage123.wgsl';
import stage124WGSL from './shaders/stage124.wgsl';
import stage125WGSL from './shaders/stage125.wgsl';
import stage126WGSL from './shaders/stage126.wgsl';
import stage127WGSL from './shaders/stage127.wgsl';
import stage128WGSL from './shaders/stage128.wgsl';
import stage129WGSL from './shaders/stage129.wgsl';
import stage130WGSL from './shaders/stage130.wgsl';
import stage131WGSL from './shaders/stage131.wgsl';
import stage132WGSL from './shaders/stage132.wgsl';
import stage133WGSL from './shaders/stage133.wgsl';
import stage133VectorizedWGSL from './shaders/stage133.vectorized.wgsl';
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const ArnetF8b32BoxConfig: ACNetGeneratedModelConfig = {
  key: "ARNET_F8B32_BOX",
  name: "ARNet F8B32 Box",
  sourceFamily: "arnet",
  stages: [
    {
      name: "ARNet F8B32 head conv 1x8x3x3 part 0",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "FEAT_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage0WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage0WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 head conv 1x8x3x3 part 1",
      shaderWGSL: stage1WGSL,
      bindings: ["LUMA"],
      outputName: "FEAT_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage1WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage1WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 0 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage2WGSL,
      bindings: ["FEAT_TEX_0","FEAT_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage2WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage2WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 0 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage3WGSL,
      bindings: ["FEAT_TEX_0","FEAT_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage3WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage3WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 0 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage4WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","FEAT_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage4WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage4WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 0 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage5WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","FEAT_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage5WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage5WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 1 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage6WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage6WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage6WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 1 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage7WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage7WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage7WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 1 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage8WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage8WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage8WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 1 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage9WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage9WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage9WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 2 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage10WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage10WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage10WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 2 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage11WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage11WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage11WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 2 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage12WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage12WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage12WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 2 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage13WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage13WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage13WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 3 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage14WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage14WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage14WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 3 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage15WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage15WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage15WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 3 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage16WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage16WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage16WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 3 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage17WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage17WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage17WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 4 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage18WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage18WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage18WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 4 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage19WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage19WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage19WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 4 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage20WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage20WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage20WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 4 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage21WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage21WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage21WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 5 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage22WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage22WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage22WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 5 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage23WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage23WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage23WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 5 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage24WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage24WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage24WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 5 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage25WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage25WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage25WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 6 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage26WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage26WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage26WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 6 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage27WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage27WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage27WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 6 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage28WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage28WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage28WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 6 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage29WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage29WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage29WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 7 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage30WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage30WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage30WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 7 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage31WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage31WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage31WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 7 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage32WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage32WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage32WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 7 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage33WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage33WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage33WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 8 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage34WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage34WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage34WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 8 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage35WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage35WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage35WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 8 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage36WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage36WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage36WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 8 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage37WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage37WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage37WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 9 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage38WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage38WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage38WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 9 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage39WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage39WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage39WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 9 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage40WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage40WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage40WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 9 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage41WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage41WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage41WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 10 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage42WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage42WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage42WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 10 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage43WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage43WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage43WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 10 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage44WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage44WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage44WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 10 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage45WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage45WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage45WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 11 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage46WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage46WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage46WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 11 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage47WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage47WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage47WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 11 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage48WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage48WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage48WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 11 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage49WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage49WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage49WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 12 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage50WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage50WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage50WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 12 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage51WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage51WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage51WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 12 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage52WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage52WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage52WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 12 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage53WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage53WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage53WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 13 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage54WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage54WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage54WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 13 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage55WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage55WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage55WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 13 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage56WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage56WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage56WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 13 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage57WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage57WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage57WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 14 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage58WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage58WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage58WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 14 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage59WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage59WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage59WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 14 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage60WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage60WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage60WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 14 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage61WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage61WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage61WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 15 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage62WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage62WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage62WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 15 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage63WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage63WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage63WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 15 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage64WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage64WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage64WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 15 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage65WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage65WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage65WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 16 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage66WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage66WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage66WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 16 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage67WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage67WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage67WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 16 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage68WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage68WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage68WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 16 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage69WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage69WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage69WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 17 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage70WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage70WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage70WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 17 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage71WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage71WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage71WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 17 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage72WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage72WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage72WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 17 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage73WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage73WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage73WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 18 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage74WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage74WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage74WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 18 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage75WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage75WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage75WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 18 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage76WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage76WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage76WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 18 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage77WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage77WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage77WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 19 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage78WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage78WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage78WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 19 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage79WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage79WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage79WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 19 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage80WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage80WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage80WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 19 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage81WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage81WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage81WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 20 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage82WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage82WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage82WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 20 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage83WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage83WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage83WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 20 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage84WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage84WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage84WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 20 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage85WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage85WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage85WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 21 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage86WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage86WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage86WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 21 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage87WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage87WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage87WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 21 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage88WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage88WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage88WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 21 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage89WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage89WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage89WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 22 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage90WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage90WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage90WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 22 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage91WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage91WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage91WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 22 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage92WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage92WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage92WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 22 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage93WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage93WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage93WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 23 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage94WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage94WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage94WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 23 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage95WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage95WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage95WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 23 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage96WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage96WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage96WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 23 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage97WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage97WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage97WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 24 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage98WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage98WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage98WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 24 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage99WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage99WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage99WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 24 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage100WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage100WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage100WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 24 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage101WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage101WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage101WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 25 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage102WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage102WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage102WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 25 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage103WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage103WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage103WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 25 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage104WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage104WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage104WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 25 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage105WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage105WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage105WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 26 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage106WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage106WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage106WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 26 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage107WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage107WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage107WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 26 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage108WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage108WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage108WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 26 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage109WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage109WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage109WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 27 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage110WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage110WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage110WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 27 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage111WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage111WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage111WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 27 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage112WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage112WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage112WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 27 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage113WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage113WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage113WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 28 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage114WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage114WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage114WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 28 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage115WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage115WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage115WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 28 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage116WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage116WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage116WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 28 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage117WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage117WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage117WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 29 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage118WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage118WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage118WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 29 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage119WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage119WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage119WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 29 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage120WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage120WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage120WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 29 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage121WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage121WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage121WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 30 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage122WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage122WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage122WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 30 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage123WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage123WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage123WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 30 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage124WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage124WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage124WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 30 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage125WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage125WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage125WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 31 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage126WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage126WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage126WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 31 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage127WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage127WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage127WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 31 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage128WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage128WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage128WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body block 31 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage129WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage129WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage129WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body fusion conv 8x8x1x1 part 0",
      shaderWGSL: stage130WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_0"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage130WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage130WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 body fusion conv 8x8x1x1 part 1",
      shaderWGSL: stage131WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage131WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage131WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 upscale conv 8x4x3x3 part 0",
      shaderWGSL: stage132WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","LUMA"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage132WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage132WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B32 upscale pixelshuff",
      shaderWGSL: stage133WGSL,
      bindings: ["TMP2_TEX_0"],
      outputName: "__FINAL_LUMA_133",
      outputScale: 2,

      optimizedShaderWGSL: stage133VectorizedWGSL,
      optimizationFlag: 'vectorizedPixelShuffle',
      optimizedDispatchScale: 1,
      finalOperation: 'pixel-shuffle-2x',
      final: true,
    }
  ],
};

export default ArnetF8b32BoxConfig;

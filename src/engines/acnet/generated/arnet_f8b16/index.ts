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
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const ArnetF8b16Config: ACNetGeneratedModelConfig = {
  key: "ARNET_F8B16",
  name: "ARNet F8B16",
  sourceFamily: "arnet",
  stages: [
    {
      name: "ARNet F8B16 head conv 1x8x3x3 part 0",
      shaderWGSL: stage0WGSL,
      bindings: ["LUMA"],
      outputName: "FEAT_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 head conv 1x8x3x3 part 1",
      shaderWGSL: stage1WGSL,
      bindings: ["LUMA"],
      outputName: "FEAT_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 0 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage2WGSL,
      bindings: ["FEAT_TEX_0","FEAT_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 0 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage3WGSL,
      bindings: ["FEAT_TEX_0","FEAT_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 0 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage4WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","FEAT_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 0 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage5WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","FEAT_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 1 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage6WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 1 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage7WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 1 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage8WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 1 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage9WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 2 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage10WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 2 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage11WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 2 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage12WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 2 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage13WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 3 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage14WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 3 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage15WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 3 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage16WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 3 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage17WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 4 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage18WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 4 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage19WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 4 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage20WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 4 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage21WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 5 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage22WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 5 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage23WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 5 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage24WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 5 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage25WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 6 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage26WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 6 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage27WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 6 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage28WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 6 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage29WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 7 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage30WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 7 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage31WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 7 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage32WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 7 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage33WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 8 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage34WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 8 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage35WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 8 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage36WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 8 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage37WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 9 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage38WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 9 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage39WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 9 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage40WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 9 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage41WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 10 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage42WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 10 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage43WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 10 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage44WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 10 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage45WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 11 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage46WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 11 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage47WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 11 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage48WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 11 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage49WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 12 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage50WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 12 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage51WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 12 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage52WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 12 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage53WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 13 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage54WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 13 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage55WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 13 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage56WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 13 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage57WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 14 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage58WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 14 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage59WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 14 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage60WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 14 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage61WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 15 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage62WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 15 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage63WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 15 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage64WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body block 15 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage65WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body fusion conv 8x8x1x1 part 0",
      shaderWGSL: stage66WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_0"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 body fusion conv 8x8x1x1 part 1",
      shaderWGSL: stage67WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 upscale conv 8x4x3x3 part 0",
      shaderWGSL: stage68WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","LUMA"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,
      final: false,
    },
    {
      name: "ARNet F8B16 upscale pixelshuff",
      shaderWGSL: stage69WGSL,
      bindings: ["TMP2_TEX_0"],
      outputName: "__FINAL_LUMA_69",
      outputScale: 2,
      final: true,
    }
  ],
};

export default ArnetF8b16Config;

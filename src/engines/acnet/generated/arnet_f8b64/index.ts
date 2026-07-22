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
import stage134WGSL from './shaders/stage134.wgsl';
import stage135WGSL from './shaders/stage135.wgsl';
import stage136WGSL from './shaders/stage136.wgsl';
import stage137WGSL from './shaders/stage137.wgsl';
import stage138WGSL from './shaders/stage138.wgsl';
import stage139WGSL from './shaders/stage139.wgsl';
import stage140WGSL from './shaders/stage140.wgsl';
import stage141WGSL from './shaders/stage141.wgsl';
import stage142WGSL from './shaders/stage142.wgsl';
import stage143WGSL from './shaders/stage143.wgsl';
import stage144WGSL from './shaders/stage144.wgsl';
import stage145WGSL from './shaders/stage145.wgsl';
import stage146WGSL from './shaders/stage146.wgsl';
import stage147WGSL from './shaders/stage147.wgsl';
import stage148WGSL from './shaders/stage148.wgsl';
import stage149WGSL from './shaders/stage149.wgsl';
import stage150WGSL from './shaders/stage150.wgsl';
import stage151WGSL from './shaders/stage151.wgsl';
import stage152WGSL from './shaders/stage152.wgsl';
import stage153WGSL from './shaders/stage153.wgsl';
import stage154WGSL from './shaders/stage154.wgsl';
import stage155WGSL from './shaders/stage155.wgsl';
import stage156WGSL from './shaders/stage156.wgsl';
import stage157WGSL from './shaders/stage157.wgsl';
import stage158WGSL from './shaders/stage158.wgsl';
import stage159WGSL from './shaders/stage159.wgsl';
import stage160WGSL from './shaders/stage160.wgsl';
import stage161WGSL from './shaders/stage161.wgsl';
import stage162WGSL from './shaders/stage162.wgsl';
import stage163WGSL from './shaders/stage163.wgsl';
import stage164WGSL from './shaders/stage164.wgsl';
import stage165WGSL from './shaders/stage165.wgsl';
import stage166WGSL from './shaders/stage166.wgsl';
import stage167WGSL from './shaders/stage167.wgsl';
import stage168WGSL from './shaders/stage168.wgsl';
import stage169WGSL from './shaders/stage169.wgsl';
import stage170WGSL from './shaders/stage170.wgsl';
import stage171WGSL from './shaders/stage171.wgsl';
import stage172WGSL from './shaders/stage172.wgsl';
import stage173WGSL from './shaders/stage173.wgsl';
import stage174WGSL from './shaders/stage174.wgsl';
import stage175WGSL from './shaders/stage175.wgsl';
import stage176WGSL from './shaders/stage176.wgsl';
import stage177WGSL from './shaders/stage177.wgsl';
import stage178WGSL from './shaders/stage178.wgsl';
import stage179WGSL from './shaders/stage179.wgsl';
import stage180WGSL from './shaders/stage180.wgsl';
import stage181WGSL from './shaders/stage181.wgsl';
import stage182WGSL from './shaders/stage182.wgsl';
import stage183WGSL from './shaders/stage183.wgsl';
import stage184WGSL from './shaders/stage184.wgsl';
import stage185WGSL from './shaders/stage185.wgsl';
import stage186WGSL from './shaders/stage186.wgsl';
import stage187WGSL from './shaders/stage187.wgsl';
import stage188WGSL from './shaders/stage188.wgsl';
import stage189WGSL from './shaders/stage189.wgsl';
import stage190WGSL from './shaders/stage190.wgsl';
import stage191WGSL from './shaders/stage191.wgsl';
import stage192WGSL from './shaders/stage192.wgsl';
import stage193WGSL from './shaders/stage193.wgsl';
import stage194WGSL from './shaders/stage194.wgsl';
import stage195WGSL from './shaders/stage195.wgsl';
import stage196WGSL from './shaders/stage196.wgsl';
import stage197WGSL from './shaders/stage197.wgsl';
import stage198WGSL from './shaders/stage198.wgsl';
import stage199WGSL from './shaders/stage199.wgsl';
import stage200WGSL from './shaders/stage200.wgsl';
import stage201WGSL from './shaders/stage201.wgsl';
import stage202WGSL from './shaders/stage202.wgsl';
import stage203WGSL from './shaders/stage203.wgsl';
import stage204WGSL from './shaders/stage204.wgsl';
import stage205WGSL from './shaders/stage205.wgsl';
import stage206WGSL from './shaders/stage206.wgsl';
import stage207WGSL from './shaders/stage207.wgsl';
import stage208WGSL from './shaders/stage208.wgsl';
import stage209WGSL from './shaders/stage209.wgsl';
import stage210WGSL from './shaders/stage210.wgsl';
import stage211WGSL from './shaders/stage211.wgsl';
import stage212WGSL from './shaders/stage212.wgsl';
import stage213WGSL from './shaders/stage213.wgsl';
import stage214WGSL from './shaders/stage214.wgsl';
import stage215WGSL from './shaders/stage215.wgsl';
import stage216WGSL from './shaders/stage216.wgsl';
import stage217WGSL from './shaders/stage217.wgsl';
import stage218WGSL from './shaders/stage218.wgsl';
import stage219WGSL from './shaders/stage219.wgsl';
import stage220WGSL from './shaders/stage220.wgsl';
import stage221WGSL from './shaders/stage221.wgsl';
import stage222WGSL from './shaders/stage222.wgsl';
import stage223WGSL from './shaders/stage223.wgsl';
import stage224WGSL from './shaders/stage224.wgsl';
import stage225WGSL from './shaders/stage225.wgsl';
import stage226WGSL from './shaders/stage226.wgsl';
import stage227WGSL from './shaders/stage227.wgsl';
import stage228WGSL from './shaders/stage228.wgsl';
import stage229WGSL from './shaders/stage229.wgsl';
import stage230WGSL from './shaders/stage230.wgsl';
import stage231WGSL from './shaders/stage231.wgsl';
import stage232WGSL from './shaders/stage232.wgsl';
import stage233WGSL from './shaders/stage233.wgsl';
import stage234WGSL from './shaders/stage234.wgsl';
import stage235WGSL from './shaders/stage235.wgsl';
import stage236WGSL from './shaders/stage236.wgsl';
import stage237WGSL from './shaders/stage237.wgsl';
import stage238WGSL from './shaders/stage238.wgsl';
import stage239WGSL from './shaders/stage239.wgsl';
import stage240WGSL from './shaders/stage240.wgsl';
import stage241WGSL from './shaders/stage241.wgsl';
import stage242WGSL from './shaders/stage242.wgsl';
import stage243WGSL from './shaders/stage243.wgsl';
import stage244WGSL from './shaders/stage244.wgsl';
import stage245WGSL from './shaders/stage245.wgsl';
import stage246WGSL from './shaders/stage246.wgsl';
import stage247WGSL from './shaders/stage247.wgsl';
import stage248WGSL from './shaders/stage248.wgsl';
import stage249WGSL from './shaders/stage249.wgsl';
import stage250WGSL from './shaders/stage250.wgsl';
import stage251WGSL from './shaders/stage251.wgsl';
import stage252WGSL from './shaders/stage252.wgsl';
import stage253WGSL from './shaders/stage253.wgsl';
import stage254WGSL from './shaders/stage254.wgsl';
import stage255WGSL from './shaders/stage255.wgsl';
import stage256WGSL from './shaders/stage256.wgsl';
import stage257WGSL from './shaders/stage257.wgsl';
import stage258WGSL from './shaders/stage258.wgsl';
import stage259WGSL from './shaders/stage259.wgsl';
import stage260WGSL from './shaders/stage260.wgsl';
import stage261WGSL from './shaders/stage261.wgsl';
import stage261VectorizedWGSL from './shaders/stage261.vectorized.wgsl';
import type { ACNetGeneratedModelConfig } from '../../pipeline';

export const ArnetF8b64Config: ACNetGeneratedModelConfig = {
  key: "ARNET_F8B64",
  name: "ARNet F8B64",
  sourceFamily: "arnet",
  stages: [
    {
      name: "ARNet F8B64 head conv 1x8x3x3 part 0",
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
      name: "ARNet F8B64 head conv 1x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 0 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 0 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 0 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 0 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 1 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 1 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 1 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 1 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 2 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 2 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 2 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 2 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 3 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 3 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 3 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 3 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 4 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 4 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 4 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 4 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 5 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 5 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 5 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 5 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 6 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 6 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 6 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 6 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 7 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 7 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 7 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 7 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 8 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 8 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 8 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 8 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 9 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 9 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 9 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 9 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 10 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 10 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 10 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 10 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 11 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 11 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 11 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 11 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 12 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 12 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 12 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 12 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 13 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 13 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 13 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 13 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 14 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 14 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 14 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 14 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 15 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 15 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 15 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 15 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 16 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 16 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 16 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 16 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 17 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 17 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 17 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 17 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 18 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 18 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 18 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 18 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 19 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 19 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 19 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 19 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 20 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 20 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 20 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 20 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 21 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 21 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 21 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 21 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 22 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 22 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 22 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 22 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 23 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 23 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 23 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 23 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 24 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 24 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 24 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 24 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 25 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 25 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 25 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 25 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 26 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 26 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 26 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 26 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 27 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 27 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 27 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 27 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 28 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 28 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 28 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 28 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 29 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 29 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 29 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 29 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 30 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 30 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 30 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 30 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 31 conv 0 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 31 conv 0 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 31 conv 1 8x8x3x3 part 0",
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
      name: "ARNet F8B64 body block 31 conv 1 8x8x3x3 part 1",
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
      name: "ARNet F8B64 body block 32 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage130WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage130WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage130WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 32 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage131WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage131WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage131WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 32 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage132WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage132WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage132WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 32 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage133WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage133WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage133WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 33 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage134WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage134WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage134WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 33 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage135WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage135WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage135WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 33 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage136WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage136WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage136WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 33 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage137WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage137WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage137WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 34 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage138WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage138WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage138WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 34 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage139WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage139WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage139WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 34 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage140WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage140WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage140WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 34 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage141WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage141WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage141WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 35 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage142WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage142WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage142WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 35 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage143WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage143WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage143WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 35 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage144WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage144WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage144WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 35 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage145WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage145WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage145WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 36 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage146WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage146WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage146WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 36 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage147WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage147WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage147WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 36 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage148WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage148WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage148WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 36 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage149WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage149WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage149WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 37 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage150WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage150WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage150WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 37 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage151WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage151WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage151WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 37 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage152WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage152WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage152WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 37 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage153WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage153WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage153WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 38 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage154WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage154WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage154WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 38 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage155WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage155WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage155WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 38 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage156WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage156WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage156WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 38 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage157WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage157WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage157WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 39 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage158WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage158WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage158WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 39 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage159WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage159WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage159WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 39 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage160WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage160WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage160WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 39 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage161WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage161WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage161WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 40 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage162WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage162WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage162WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 40 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage163WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage163WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage163WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 40 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage164WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage164WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage164WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 40 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage165WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage165WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage165WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 41 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage166WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage166WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage166WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 41 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage167WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage167WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage167WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 41 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage168WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage168WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage168WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 41 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage169WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage169WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage169WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 42 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage170WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage170WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage170WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 42 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage171WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage171WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage171WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 42 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage172WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage172WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage172WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 42 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage173WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage173WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage173WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 43 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage174WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage174WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage174WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 43 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage175WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage175WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage175WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 43 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage176WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage176WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage176WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 43 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage177WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage177WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage177WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 44 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage178WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage178WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage178WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 44 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage179WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage179WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage179WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 44 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage180WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage180WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage180WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 44 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage181WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage181WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage181WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 45 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage182WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage182WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage182WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 45 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage183WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage183WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage183WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 45 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage184WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage184WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage184WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 45 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage185WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage185WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage185WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 46 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage186WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage186WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage186WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 46 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage187WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage187WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage187WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 46 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage188WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage188WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage188WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 46 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage189WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage189WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage189WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 47 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage190WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage190WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage190WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 47 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage191WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage191WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage191WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 47 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage192WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage192WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage192WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 47 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage193WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage193WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage193WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 48 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage194WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage194WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage194WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 48 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage195WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage195WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage195WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 48 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage196WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage196WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage196WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 48 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage197WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage197WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage197WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 49 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage198WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage198WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage198WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 49 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage199WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage199WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage199WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 49 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage200WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage200WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage200WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 49 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage201WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage201WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage201WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 50 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage202WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage202WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage202WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 50 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage203WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage203WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage203WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 50 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage204WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage204WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage204WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 50 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage205WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage205WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage205WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 51 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage206WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage206WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage206WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 51 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage207WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage207WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage207WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 51 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage208WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage208WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage208WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 51 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage209WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage209WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage209WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 52 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage210WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage210WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage210WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 52 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage211WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage211WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage211WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 52 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage212WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage212WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage212WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 52 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage213WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage213WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage213WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 53 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage214WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage214WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage214WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 53 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage215WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage215WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage215WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 53 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage216WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage216WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage216WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 53 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage217WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage217WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage217WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 54 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage218WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage218WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage218WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 54 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage219WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage219WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage219WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 54 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage220WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage220WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage220WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 54 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage221WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage221WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage221WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 55 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage222WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage222WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage222WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 55 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage223WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage223WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage223WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 55 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage224WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage224WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage224WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 55 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage225WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage225WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage225WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 56 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage226WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage226WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage226WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 56 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage227WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage227WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage227WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 56 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage228WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage228WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage228WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 56 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage229WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage229WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage229WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 57 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage230WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage230WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage230WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 57 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage231WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage231WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage231WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 57 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage232WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage232WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage232WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 57 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage233WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage233WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage233WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 58 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage234WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage234WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage234WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 58 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage235WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage235WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage235WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 58 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage236WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage236WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage236WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 58 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage237WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage237WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage237WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 59 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage238WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage238WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage238WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 59 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage239WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage239WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage239WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 59 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage240WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage240WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage240WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 59 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage241WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage241WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage241WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 60 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage242WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage242WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage242WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 60 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage243WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage243WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage243WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 60 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage244WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage244WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage244WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 60 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage245WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage245WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage245WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 61 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage246WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage246WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage246WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 61 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage247WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage247WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage247WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 61 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage248WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage248WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage248WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 61 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage249WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage249WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage249WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 62 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage250WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage250WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage250WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 62 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage251WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage251WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage251WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 62 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage252WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage252WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage252WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 62 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage253WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage253WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage253WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 63 conv 0 8x8x3x3 part 0",
      shaderWGSL: stage254WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage254WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage254WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 63 conv 0 8x8x3x3 part 1",
      shaderWGSL: stage255WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage255WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage255WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 63 conv 1 8x8x3x3 part 0",
      shaderWGSL: stage256WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_0"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage256WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage256WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body block 63 conv 1 8x8x3x3 part 1",
      shaderWGSL: stage257WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","TMP2_TEX_1"],
      outputName: "TMP2_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage257WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage257WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body fusion conv 8x8x1x1 part 0",
      shaderWGSL: stage258WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_0"],
      outputName: "TMP1_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage258WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage258WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 body fusion conv 8x8x1x1 part 1",
      shaderWGSL: stage259WGSL,
      bindings: ["TMP2_TEX_0","TMP2_TEX_1","FEAT_TEX_1"],
      outputName: "TMP1_TEX_1",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage259WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage259WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 upscale conv 8x4x3x3 part 0",
      shaderWGSL: stage260WGSL,
      bindings: ["TMP1_TEX_0","TMP1_TEX_1","LUMA"],
      outputName: "TMP2_TEX_0",
      outputScale: 1,

      optimizedShaderWGSL: createACNetWorkgroupTileVariant(stage260WGSL),
      kernelVariants: createACNetWorkgroupTileVariants(stage260WGSL),
      optimizationFlag: 'acnetWorkgroupTile',
      final: false,
    },
    {
      name: "ARNet F8B64 upscale pixelshuff",
      shaderWGSL: stage261WGSL,
      bindings: ["TMP2_TEX_0"],
      outputName: "__FINAL_LUMA_261",
      outputScale: 2,

      optimizedShaderWGSL: stage261VectorizedWGSL,
      optimizationFlag: 'vectorizedPixelShuffle',
      optimizedDispatchScale: 1,
      finalOperation: 'pixel-shuffle-2x',
      final: true,
    }
  ],
};

export default ArnetF8b64Config;

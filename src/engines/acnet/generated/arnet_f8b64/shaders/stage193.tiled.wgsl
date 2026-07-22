const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP1_TEX_0: texture_2d<f32>;

fn sample_TMP1_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP1_TEX_1: texture_2d<f32>;

fn sample_TMP1_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_1, coord, 0);
}

@group(0) @binding(2) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_1: array<array<vec4f, 10>, 10>;

@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);

  let groupOrigin = pixel.xy - localId.xy;
  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      tile_TMP1_TEX_0[tileY][tileX] = sample_TMP1_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP1_TEX_1[tileY][tileX] = sample_TMP1_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP2_TEX_1[tileY][tileX] = sample_TMP2_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(0.6367975, 0.10001681, -0.10598175, 0.20726806);
      result += mat4x4<f32>(0.02127666, -0.010419158, -0.061647795, -0.08546734, -0.057322163, -0.061325856, -0.08142877, 0.0586366, -0.012610282, 0.13956611, -0.032326203, -0.06739153, 0.0077936915, 0.11366199, -0.17999916, -0.055356227) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08373697, 0.10069894, -0.050490003, -0.20270868, -0.030318616, 0.096254036, -0.06134699, -0.0971889, -0.14583011, 0.02179685, 0.06114329, 0.0152984075, -0.07107011, 0.021372097, -0.1111948, -0.0353272) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.011608144, -0.021167846, 0.06886361, -0.00086501136, -0.14892633, 0.026075419, 0.019760607, -0.12098797, -0.036271024, -0.030060379, -0.019804912, 0.007643014, -0.069922864, -0.017961146, -0.022923997, 0.06112453) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11675417, 0.013846102, 0.27941296, -0.18697773, -0.06156772, -0.1718637, -0.10582389, -0.12763071, -0.042585444, 0.15537278, 0.27711955, 0.04988725, 0.011162741, 0.053369656, -0.15489905, -0.023916507) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.012739547, -0.48745567, 0.78056973, 0.71173203, 0.55949247, 0.36242032, 0.09729957, 0.8795518, 0.100321844, 0.16233379, -0.6079124, 0.20061713, -0.22358008, 0.063424036, 0.6047076, 0.10385162) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0541241, -0.07612352, 0.11326338, 0.07435251, -0.10517774, -0.17938665, -0.009665532, 0.09670054, -0.027052617, 0.21913244, -0.2943343, -0.10123609, 0.012179144, -0.2031866, 0.43976164, -0.107769735) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.17578186, 0.032312505, 0.021726737, -0.07422777, -0.02154221, 0.017875547, -0.005650619, 0.0049645123, 0.082928956, -0.11372869, -0.19808622, 0.06502063, -0.047032274, 0.024710644, -0.02966075, -0.08448492) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.07260611, 0.26683998, 0.027158288, 0.026510924, 0.005212591, -0.105452575, 0.065329656, -0.34679046, 0.10056819, 0.24452978, 0.046226647, -0.20946117, 0.031729065, -0.15457796, -0.1786228, -0.020409333) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.06777053, 0.033253994, -0.029133452, -0.100795984, -0.033093616, 0.010449102, -0.034506954, -0.10466599, -0.061770935, 0.03774706, -0.17401561, -0.050477896, 0.05732776, 0.055010583, 0.06106161, -0.07862416) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16548, 0.14858429, 0.03767641, -0.17300628, -0.24677761, 0.27064142, -0.27658936, -0.14313811, -0.1076864, -0.039147988, -0.11246616, 0.04070368, 0.103377886, -0.08761099, 0.077360444, -0.09961456) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.17711177, 0.14914985, 0.058540445, -0.03972463, -0.05252217, 0.09995108, -0.23829584, 0.045811377, -0.21796909, 0.30790523, -0.28497362, -0.051976725, 0.030845659, -0.1657003, 0.38345402, -0.17339544) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.25126326, 0.25959656, -0.13339438, -0.18765864, 0.1700452, -0.0697001, -0.15457727, 0.16297689, 0.056232043, -0.2100995, -0.031626686, 0.06659169, -0.0204451, 0.09558404, -0.13926505, -0.2666532) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.119759046, -0.0020996658, 0.42206272, -0.1564679, -0.0937878, 0.36898056, 0.3147263, -0.22444221, -0.034376465, -0.33349636, -0.021796046, 0.0819882, 0.030644195, -0.062306635, 0.022200001, -0.16444336) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.034993358, -0.05816901, -0.04687911, -0.021738406, 0.20744984, -0.23620522, 0.033985235, 0.24388726, 0.20266692, 0.1489022, 0.76778454, -0.41586345, -0.1484269, -0.18525998, 0.24516876, -0.04877195) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14614056, 0.23555325, -0.20832063, -0.042427495, 0.1749798, -0.27155173, 0.05661276, 0.091806404, -0.04375767, -0.1059909, 0.14421359, 0.08379136, -0.24560957, -0.3014971, -0.22576088, -0.06918719) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18224138, -0.09861121, 0.15591297, 0.045411427, -0.24422516, 0.15723476, 0.12121651, -0.20066173, 0.051940575, 0.122973114, 0.0020214603, 0.0799983, 0.01429158, 0.038070302, -0.0063725384, -0.041647054) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15029734, -0.39016148, -0.19242586, 0.36643413, -0.07846249, -0.047187515, 0.2229495, -0.1909716, -0.166226, -0.10846328, -0.018814875, -0.0014620401, -0.015520305, -0.04910645, -0.039051678, -0.045744162) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16503413, -0.21127865, -0.06542234, 0.12784947, 0.17720337, -0.33383825, 0.17738363, 0.098436736, -0.13917041, -0.078348495, 0.023597047, -0.1160719, 0.09219845, 0.04217374, -0.0071291286, -0.13701381) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

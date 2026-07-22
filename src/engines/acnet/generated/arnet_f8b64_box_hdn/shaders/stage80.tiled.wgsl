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

@group(0) @binding(2) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_0: array<array<vec4f, 10>, 10>;

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
      tile_TMP2_TEX_0[tileY][tileX] = sample_TMP2_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(0.28445444, -0.017446777, 0.27211392, 0.02268614);
      result += mat4x4<f32>(0.09181276, -0.07333201, -0.10562394, -0.1436979, 0.2335682, -0.018383186, -0.41021878, 0.2780554, -0.022163898, -0.08062748, 0.044790413, -0.04533281, -0.10746329, -0.03953528, 0.2644498, -0.0048344657) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.19152, 0.054557715, -0.15748397, 0.35554335, 0.22347516, 0.084000014, -0.14061226, 0.03786266, 0.021649541, 0.10509286, -0.03959282, -0.11360486, -0.20867588, 0.18176608, -0.034362428, 0.02002163) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06969265, -0.015709816, -0.023684323, 0.23315753, -0.0054026544, -0.00066802005, 0.025296303, 0.0884125, -0.0018950163, -0.093936406, -0.13368848, -0.17759302, -0.26294684, -0.15689549, -0.025318503, -0.041969746) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11530845, 0.009181341, -0.0013204495, -0.17552857, 0.12652352, -0.075224146, -0.01684233, 0.17886384, -0.6185267, 0.11479717, 0.1298498, -0.043078844, -0.5642009, -0.12866135, -0.12353762, 0.16803886) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7605595, 0.08380716, -0.036590803, 0.0041555064, -0.19519392, 0.06786325, 0.37515414, -0.44662696, -0.38460222, -0.016500473, -0.020222828, -0.12830631, -0.54508084, 0.017502906, -0.39127144, 0.41423494) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18939407, 0.039987728, 0.14348063, 0.16966614, -0.12434641, 0.032742213, 0.17457867, 0.08097439, -0.097831205, 0.15844542, 0.08233958, -0.07964949, -0.83744234, -0.094406925, -0.17339689, 0.4485729) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.2433236, 0.050987747, 0.22853331, -0.096220784, 0.14240229, 0.074956745, -0.11405705, 0.023746239, 0.13864084, 0.07101333, -0.03147237, 0.34367654, -0.21694125, 0.07564646, 0.0641553, 0.20439708) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.16052763, 0.12514831, 0.2855579, -0.22957078, 0.16145903, -0.0769377, 0.077373765, -0.0049399943, 0.27726611, -0.15975106, -0.45202065, 0.09811375, 0.13750565, 0.04714523, -0.029341683, 0.16403095) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.21303292, 0.06633249, 0.07852604, -0.041176412, -0.040329117, 0.047400236, -0.004532839, 0.103272244, 0.04513753, 0.20362084, -0.03466981, -0.03801526, -0.09920083, 0.04706999, 0.17799781, 0.0005861005) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.27112758, -0.04432674, 0.088437006, 5.9168535e-05, 0.1778924, -0.22390825, 0.021230472, -0.032839276, 0.066013955, 0.0867508, 0.20409957, -0.20193481, -0.25533956, -0.024269776, 0.006881679, 0.121724896) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.300021, -0.04002251, 0.22170423, -0.17015621, 0.37066323, 0.04758572, -0.55204, 0.34326664, -0.0918892, 0.06328798, -0.07052196, -0.38836747, -0.20837799, 0.1076817, 0.23650004, -0.14467792) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.030688902, 0.106959686, 0.10853995, -0.024888188, 0.06671367, 0.11865495, -0.19930696, 0.2042777, 0.035617728, 0.018051941, 0.023980945, -0.19190186, 0.01465927, 0.00708519, 0.18514884, -0.2345059) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.47228777, 0.013716722, 0.053014096, 0.18233125, 0.20018724, 0.1042324, 0.026128039, -0.23339874, -0.039261483, 0.11882716, 0.20885117, -0.20563067, -0.48049676, 0.10295168, 0.11513944, 0.06106801) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.85527474, 0.23097263, 0.16907188, 0.032817096, -0.17304075, -0.036251593, 0.3408449, -0.352613, 0.24805556, -0.20141636, -0.5263471, -0.277883, -0.6807607, 0.19764969, 0.13701816, 0.20615393) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04820802, 0.10863533, 0.038622815, -0.08923704, -0.106032185, -0.1381459, -0.26211083, -0.3617577, 0.32227367, -0.08506689, -0.0436012, 0.1542858, 0.06993769, 0.08352555, -0.025860665, -0.18434349) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.043644626, 0.04920176, 0.056932125, -0.06524481, 0.059192363, 0.25534505, 0.120636486, 0.3437442, 0.083944164, 0.14733027, 0.3034007, 0.021893112, -0.30928445, -0.022951545, -0.2562197, -0.18967181) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.40492585, 0.13969849, -0.029279158, -0.14840847, 0.6370047, 0.16736543, -0.9041193, -0.045137364, 0.11373234, 0.030112224, 0.17436236, 0.02911201, -0.36238635, -0.064784676, -0.1858787, 0.19987175) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.021210443, 0.026052285, -0.029317094, 0.093778804, -0.19787218, -0.25736785, 0.03237231, -0.219782, -0.123346664, 0.07539926, 0.18633012, 0.2662682, 0.15561058, -0.0013050493, -0.18081503, -0.14422315) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

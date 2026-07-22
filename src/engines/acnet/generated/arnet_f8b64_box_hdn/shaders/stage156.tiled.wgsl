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

  var result: vec4f = vec4f(-0.22200389, 0.06846786, 0.06676263, -0.21029815);
      result += mat4x4<f32>(0.028945668, -0.0046554497, -0.2617939, 0.17237869, 0.041241292, -0.29000428, -0.15205197, 0.047135957, -0.06551337, 0.099671036, 0.042360954, -0.011342851, 0.081581876, -0.22900666, -0.041822966, -0.0010881037) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.42758557, 0.24374041, -0.23520443, 0.14662547, 0.09344837, -0.36322704, -0.103759415, 0.05504985, -0.06006325, 0.17429653, 0.05181721, -0.06773261, -0.024522083, -0.26726472, -0.18232548, -0.0587614) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.034584448, 0.05527472, -0.09867348, -0.013366128, 0.0385574, -0.261706, -0.15604272, 0.0062807915, -0.072220385, 0.14225274, 0.038159274, -0.011217896, 0.089514114, -0.31327212, -0.111797586, 0.017158628) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.083406575, 0.21848522, 0.11347107, 0.09211982, 0.08321713, -0.34920833, -0.18799244, 0.03576255, -0.042226978, 0.12474664, -0.0059776995, -0.0608361, -0.08379519, -0.2822346, -0.14090228, -0.008692501) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.37910926, 0.1415737, 0.31519035, -0.56811476, 0.07276335, -0.4483061, -0.18579604, 0.070004314, 0.0064377086, 0.24599652, 0.040505517, -0.0024281351, 0.20866086, -0.41927332, -0.09672688, -0.08379165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2657533, 0.07856005, 0.23772986, -0.16326721, 0.063992344, -0.34937015, -0.14021881, 0.08276484, -0.022088485, 0.2313048, 0.032258872, -0.053023174, 0.029201444, -0.45331687, -0.21684478, 0.022181217) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04109429, 0.009013758, -0.21768369, 0.11135326, 0.0072725103, -0.2378447, -0.11875386, 0.026137976, -0.057721503, 0.12682092, 0.054860886, -0.024259025, 0.05641332, -0.2367342, -0.09706452, 0.009185391) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.07620258, -0.10392638, -0.220772, 0.13990329, 0.01456743, -0.28908968, -0.11701202, -0.0017816138, -0.07068435, 0.21901742, 0.12666422, -0.06833444, 0.07310591, -0.35433918, -0.1543389, 0.05060249) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09034882, -0.009214262, -0.1566285, -0.10569361, 0.09474669, -0.23315531, -0.084277645, 0.06862623, -0.073898144, 0.20826666, 0.059845347, -0.084726706, 0.13429423, -0.33959275, -0.13524222, -0.01165742) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.037996534, 0.32845327, 0.57034016, -0.035834577, 0.20868683, -0.112000555, -0.13082628, 0.13403612, -0.034815516, 0.18639405, 0.07018073, -0.016519897, 0.0014033284, -0.13768052, -0.6141364, 0.42532837) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12147086, -0.15778455, -0.39810506, -0.0703982, -0.021010848, 0.081441306, -0.294433, 0.25531092, -0.047484525, 0.23461017, 0.08528653, -0.011654431, -0.058070946, 0.03583522, 0.1913572, 0.20212469) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.27086607, -0.03640111, -0.579506, 0.06028646, -0.12191957, 0.019142287, 0.07118569, 0.18109128, 0.0001344432, 0.13839518, 0.041247655, 0.03538809, 0.07465907, -0.19565529, -0.19140077, -0.16227794) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.21219654, -0.21666747, -0.1496556, 0.11184163, 0.14826502, 0.20168233, -0.007888187, 0.0025185535, -0.027976051, 0.21833478, 0.13404097, 0.02900485, 0.587635, -0.361911, -0.48735702, 0.5625701) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5536891, 0.058204, -0.9242278, -0.1356943, 0.5137436, 0.033401325, -0.62924296, 0.6114212, -0.07587845, 0.37218794, 0.1634505, -0.021333547, 0.23928043, 0.25180507, 0.14767343, -0.16426577) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12249333, -0.08668299, -0.2536449, -0.17509161, 0.18648757, 0.15134314, 0.014986756, 0.24602935, -0.03390308, 0.24605286, 0.10755067, 0.028947774, -0.25654268, 0.155823, 0.17980945, -0.069484524) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23554195, 0.03323227, 0.56833804, -0.0447008, 0.021320812, 0.07828336, 0.020815384, 0.13431542, -0.0016953571, 0.22008134, 0.12036368, 0.002939155, 0.14543974, 0.15466897, 0.044098403, 0.001435055) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.005986736, 0.12485728, 0.19683385, 0.080571204, 0.10076295, 0.13183436, -0.05450512, -0.029016297, -0.06542797, 0.2700052, 0.14074105, -0.018164132, 0.03084266, 0.1395621, -0.104527295, -0.12810235) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16640027, -0.012259844, 0.22589523, 0.0449998, -0.21820363, 0.21074498, 0.3329775, 0.07695112, -0.040733486, 0.2166359, 0.08124602, -0.020106606, -0.08933893, 0.015225122, 0.08391903, -0.016338574) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

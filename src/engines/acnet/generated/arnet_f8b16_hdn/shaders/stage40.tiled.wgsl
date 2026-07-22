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

  var result: vec4f = vec4f(0.6224224, 0.016992485, -0.016623883, -0.23112953);
      result += mat4x4<f32>(-0.16940585, -0.13861777, -0.085756786, 0.17291376, -0.102433726, 0.035875045, -0.3591395, 0.1962683, -0.15779968, 0.26801267, 0.257173, -0.07365094, 0.08203633, -0.20619471, -0.00852577, -0.19868423) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.094853155, -0.16987398, 0.14764193, 0.090759, 0.24244802, -0.38041422, -0.13257937, -0.0549698, 0.15505552, 0.21164006, 0.045082256, 0.0886888, 0.5209713, -0.2606711, -0.2501587, -0.1846867) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0041160984, -0.17664368, -0.005606966, 0.03703444, 0.032258663, -0.2659819, -0.26012802, -0.092614114, 0.005278964, 0.062350735, -0.02626595, 0.15575324, -0.1631613, 0.05356429, -0.0126500325, -0.051824044) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5902935, 0.24261622, -0.3679419, 0.4783314, -0.2947497, 0.25288463, -0.20689924, 0.08394839, -0.27277267, -0.1321764, 0.26969588, -0.08205719, 0.5382835, -0.23767258, 0.31353477, -0.14903097) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23569067, -0.089989126, -0.40442115, 0.39168024, -0.6689226, -0.7306657, 0.20561327, -0.46124136, 0.4079657, -0.0928922, -1.213036, 0.27895895, 0.46922538, -0.044487115, -0.25592035, 0.17870715) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.24048388, -0.2683008, 0.05116092, 0.075761646, -0.18994394, -0.5006456, 0.028521104, -0.33415303, -0.42099315, -0.073575, -0.22113986, -0.0038161448, -0.06538789, -0.14629829, -0.054748062, -0.118077) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06658868, -0.1697074, 0.10883095, 0.086970866, -0.23728558, -0.09148792, -0.11245561, 0.056127436, -0.3975887, -0.08113349, -0.19386707, 0.06514465, -0.8186427, 0.62504613, -0.095241636, 0.41474363) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3770839, -0.11093399, 0.04628716, -0.084379755, 0.041296903, -0.17881468, -0.080606274, 0.01593656, 0.7418035, -0.39716798, 0.3833945, -0.1857276, -0.20683165, 0.48693395, 0.13184991, -0.08914684) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.22794564, -0.019558037, -0.075451344, 0.039531972, 0.13979353, 0.020756343, 0.012554866, -0.040108334, -0.095208615, -0.12844127, 0.16214101, -0.13555788, 0.024329523, 0.13651301, -0.2910095, 0.04974418) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.43497238, -0.06656136, -0.23024741, 0.3078699, -0.030817224, -0.22500491, 0.30149984, -0.12921645, 0.09790302, 0.039069537, 0.12779306, 0.017767644, -0.1549885, -0.12488766, 0.18016545, -0.008379815) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21943298, 0.07062829, 0.0806789, 0.21642432, 0.0058056996, -0.3274543, -0.31296906, 0.111832246, 0.25511688, -0.025366182, 0.3463335, -0.10681335, -0.041087244, -0.15493757, -0.111709744, 0.12265817) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13402735, 0.067833915, -0.0964139, 0.11584758, 0.08819577, -0.020384701, -0.17751789, -0.12429926, 0.22438385, -0.30192935, -0.035175458, -0.018551966, -0.2529913, -0.2112279, 0.007331331, 0.117422484) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3880546, -0.28317496, -0.16936646, 0.12818736, 0.50006986, -0.30358362, 0.21695454, 0.045433108, 0.23620962, -0.109902404, 0.13154247, 0.0026645605, -0.046479728, -0.51935995, 0.3219683, -0.20818582) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7986828, -0.22757186, -0.06124132, -0.044621617, -0.36086166, 0.93585145, 0.23221987, -0.05359744, -0.07598899, -0.34857738, 0.034420986, -0.41061315, -0.38909972, -0.7479251, -0.030273939, 0.39047825) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.31329724, -0.17667702, -0.083038084, 0.04397077, 0.27398247, -0.8025973, 0.07042648, -0.23698562, -0.098461024, 0.25241703, -0.046659183, 0.17035626, -0.013606322, -0.082397774, -0.21969317, 0.20890601) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.31946772, -0.7015223, -0.013545451, -0.21293706, -0.14493802, -0.07994127, -0.09518965, 0.0030850195, 0.24063404, 0.04652331, 0.015991056, -0.0010358996, -0.27056405, -0.17327115, -0.26375458, 0.15256561) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0925604, -0.6768858, 0.2773762, -0.08592462, 0.21227786, -0.3272338, 0.28516817, -0.0053066663, 0.07247946, -0.17570315, 0.110224426, 0.082740985, -0.46612817, -0.21800405, -0.11385267, 0.19699293) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.021668294, -0.09259359, 0.16670872, -0.0927213, -0.25200853, -0.41592106, 0.021535203, 0.010825024, -0.01398483, -0.067846395, 0.10399805, -0.03906872, -0.28775126, -0.13886914, -0.027622519, 0.23124366) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

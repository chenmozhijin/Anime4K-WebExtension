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

  var result: vec4f = vec4f(0.41943178, -0.27461773, 0.044086013, -0.075867705);
      result += mat4x4<f32>(-0.13263054, 0.12644596, 0.19158944, 0.32630467, -0.037218176, -0.0764658, -0.13645683, -0.048218716, 0.04452093, -0.19486505, 0.20133919, -0.1872084, -0.08852629, -0.39627618, -0.1300863, 0.2898933) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.24921158, -0.26219064, -0.22349197, 0.39500055, -0.044655826, -0.26424292, -0.20775597, 0.03593904, 0.14495933, 0.16013367, 0.27004334, 0.05081194, 0.16956614, -0.39621145, 0.014366711, 0.3021676) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.01800822, -0.30556756, 0.051225208, 0.31909126, -0.015429495, -0.0411237, -0.053126793, -0.015806932, 0.22080365, -0.009344297, -0.036774125, -0.0017990591, 0.03792179, 0.21916117, -0.027317675, 0.02682172) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.046912745, 0.086164676, 0.017149873, -0.49437118, 0.23480803, 0.14699101, -0.5499393, 0.22771955, -0.089234866, 0.24938762, -0.53056103, 0.27926832, -0.10265787, -0.07170254, 0.12614655, 0.4068019) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.015317384, 0.039968055, -0.4032142, -0.27150556, -0.86411387, 1.0152918, -0.11028887, 0.22784773, -0.39794603, -0.10023207, 0.8530914, -0.35661885, -0.26761246, -0.8496676, -0.53043056, 0.4372103) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1551733, 0.095668145, 0.06554249, 0.27128085, 0.24774706, 0.039567262, 0.12201317, 0.10124331, 0.22077134, -0.048475042, 0.15962742, 0.065424986, 0.3123181, 0.020435032, 0.09450954, -0.4726822) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.09365269, 0.56188583, 0.13987178, -0.29461956, -0.026716406, 0.06513259, 0.10735345, -0.1011671, -0.081936054, 0.06384506, -0.058657564, 0.085929275, 0.09201138, -0.08004678, 0.40716153, 0.24362168) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.03149907, -0.17989497, -0.18008223, -0.3062343, -0.117373645, -0.0495457, -0.017468153, 0.0032928023, 0.16481732, 0.15097328, 0.12393697, -0.005314422, -0.18585834, 0.42240712, 0.08557957, -0.11065518) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11987349, 0.018609773, -0.10255727, -0.27682126, 0.13545994, 0.049885396, 0.020852238, 0.066342205, 0.13105094, -0.17753552, 0.13639146, 0.074147835, -0.05979957, 0.32268766, -0.007218018, -0.47945595) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.12585086, 0.08921594, 0.14921778, -0.104986385, 0.07762528, 0.06817746, 0.10827691, -0.018190961, 0.21096699, 0.11993425, 0.10279051, -0.0056687873, -0.031755954, 0.20759149, -0.06772609, 0.0713739) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.04935331, -0.05225549, 0.032708224, -0.14426966, -0.07760243, 0.038482662, -0.10893012, 0.014441952, -0.103425026, -0.15519525, -0.33808538, 0.01202311, -0.08348769, -0.07986029, -0.09147358, -0.12886862) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08779014, -0.018106773, -0.13142361, 0.033312973, 0.018034372, -0.03607223, 0.16985986, -0.011349993, -0.0887614, -0.1803859, -0.17037576, 0.00944825, 0.09233271, -0.07435574, 0.06474546, -0.0022464055) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.005492992, -0.26312548, 0.10994389, 0.019200178, 0.025958536, 0.07947297, -0.35853165, 0.042307347, 0.031023445, 0.10949114, -0.10632902, 0.13322954, 0.14799185, 0.29125556, 0.1211322, 0.03481531) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-1.0811774, 0.7113148, -0.06996287, -0.43221077, 1.0632117, -0.4857992, 0.62262475, 0.0978118, 0.5561735, 0.7733514, 0.7768581, -0.10953064, 0.34025013, -0.12328892, 0.49666688, -0.3996506) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.45890087, -0.47243065, -0.07563604, 0.08087216, -0.14770083, 0.3351262, 0.06513274, -0.016842648, -0.7062217, 0.2995395, -0.46549603, 0.0858817, 0.054061536, 0.1892187, 0.21617335, 0.21793768) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.018397762, 0.19703873, -0.27276966, 0.0696635, 0.04894342, -0.076865256, 0.26489756, 0.057175886, 0.038794987, 0.12806574, 0.08217323, -0.08751389, -0.13930042, -0.45939252, -0.011102636, -0.12884666) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10082957, -0.17623241, 0.061179146, -0.16836783, 0.094295464, 0.2070426, 0.17421974, 0.17118387, -0.031257417, -0.2691583, 0.025814312, -0.008051324, -0.6686177, -0.5034029, -0.6605257, 0.23182337) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2501871, 0.10654172, -0.0010805298, 0.002486083, -0.053526387, 0.15124366, 0.039159294, -0.20573746, -0.05113533, -0.16775632, -0.22530602, -0.2555322, -0.08442692, 0.028650647, 0.04922247, 0.16014406) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.5572383, -0.10480477, 0.13446908, -0.27021736);
      result += mat4x4<f32>(0.049673785, 0.06875035, -0.07331412, -0.10512457, -0.015892949, 0.01899517, -0.059461944, -0.032884117, 0.017725594, -0.0071224407, -0.037924275, 0.012155415, 0.031852186, 0.012381152, 0.015455965, 0.05158613) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.26602378, -0.029193576, 0.19617452, 0.037565026, 0.10784182, 0.13469447, -0.2702927, 0.0019474522, -0.0014547625, 0.08714448, -0.091478005, 0.110722266, -0.26283655, 0.020825412, -0.26668078, -0.004833008) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0056068916, -0.002874118, 0.11970506, 0.013797177, 0.12636712, 0.09267033, 0.113550425, 0.0816348, 0.056914907, -0.014624845, -0.027192237, -0.058770187, 0.11393519, -0.025511744, 0.15608461, 0.011195211) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.19283405, 0.08198978, -0.1540468, -0.105671875, -0.18083753, -0.07461475, 0.24369732, 0.038048066, 0.1935195, -0.052982125, 0.03254073, -0.041183755, 0.05754727, -0.08041072, -0.11964145, 0.007004645) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2871308, 0.39865398, 0.8546103, 0.23101205, 0.15937212, -0.24191828, 0.019459685, 0.08387731, 0.3840813, -0.18642846, 0.056941845, 0.095157236, -0.5921639, -0.33950776, 0.14934956, 0.1947915) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.115472496, 0.036756355, 0.011543486, -0.031149996, 0.32337314, 0.23651208, 0.16744003, 0.10073366, -0.30210677, 0.014919476, -0.33355793, -0.066712946, -0.2892317, -0.0022710296, 0.33679932, 0.21109718) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.3120666, -0.10715174, 0.093873024, -0.070548534, 0.025706312, 0.038650703, -0.01133868, -0.0068081436, -0.123441316, 0.0048767957, -0.10921592, 0.0524382, -0.8361068, -0.16814795, 0.56365997, 0.19851689) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.32284054, 0.17118849, -0.16794911, 0.003906254, -0.14411409, 0.06579166, -0.014748773, 0.029153619, 0.07908217, -0.5730708, 0.0936183, -0.2831636, -1.1329355, -0.28024274, 1.0987042, 0.047931615) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1250692, 0.1958615, -0.08734565, 0.00846378, -0.078625984, 0.014831741, 0.026224654, 0.0031503893, -0.08191805, 0.47656447, -0.46847755, -0.26547286, -0.42380503, -0.03942941, 0.6052593, 0.26432604) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07266265, 0.052821748, -0.18022506, 0.065603994, -0.06710116, -0.18356945, -0.06489012, -0.07583269, -0.059138343, 0.04463405, 0.0025031802, 0.033356197, -0.0026832882, 0.081678055, -0.04468426, 0.033631377) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10657963, -0.15169469, 0.09349157, -0.09603833, -0.13602717, 0.008095473, -0.0363266, -0.027258629, 0.2176672, -0.19936934, 0.08503335, -0.060249656, 0.24450949, 0.008050259, -0.33073884, 0.055981185) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.22829957, -0.017018327, 0.10627633, -0.03985725, -0.17567563, -0.058839746, 0.11815658, 0.033735275, 0.09389474, -0.051586736, 0.10338475, 0.014596095, 0.16419132, 0.1575383, -0.043850638, -0.08827594) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17910707, -0.02210116, 0.29639575, -0.05344516, 0.46297118, 0.17713746, 0.47063944, 0.40926963, 0.24827865, 0.1120193, -0.30538458, 0.045413747, -0.08139617, -0.076647095, -0.16507281, -0.1207422) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.51209366, 0.69015384, 0.7361858, 0.30045062, -0.45706502, -0.1280305, 0.19617654, 0.05836123, -0.1470426, 0.057391267, -0.23627512, -0.13546593, -0.22956447, -0.01876571, -0.20516475, 0.17736913) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.40078926, 0.031139433, 0.2222247, -0.14357945, -0.27241543, 0.09127246, 0.1525286, 0.13997808, -0.10552371, 0.030433835, 0.012051612, 0.09629871, -0.14571145, 0.0044869604, -0.0044784835, 0.039620604) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16722699, 0.0690874, -0.20103738, 0.019333955, -0.06610127, 0.047364395, -0.1551452, -0.06855427, -0.09945402, -0.14638335, -0.053607915, -0.0032956707, 0.035105787, 0.0019838745, -0.11861559, 0.0099876905) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0264467, 0.163197, -0.32206762, -0.0037888105, -0.043560658, 0.009223917, 0.027042057, 0.016246181, -0.478952, -0.08583142, 0.17600545, -0.4891703, 0.05374813, 0.16733351, -0.16010693, 0.009980589) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.013348935, 0.117738746, -0.19467694, -0.0033763507, -0.09942671, -0.012213973, 0.013913113, -0.016893014, -0.20919886, 0.033233635, 0.06294314, 0.051921926, -0.20933597, 0.20500748, 0.043373447, 0.10781299) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

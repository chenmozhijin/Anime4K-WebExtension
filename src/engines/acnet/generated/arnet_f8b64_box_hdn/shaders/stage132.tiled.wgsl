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

  var result: vec4f = vec4f(0.05299173, -0.011779991, -0.005291311, -0.07186243);
      result += mat4x4<f32>(0.33412465, -0.3120326, -0.20334, 0.30286893, -0.01976087, -0.14698254, -0.18000841, -0.09156979, -0.105539694, 0.23325127, 0.104987085, -0.1431916, -0.17133704, -0.038288515, 0.07680438, -0.23773488) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.7915521, -0.24875483, -0.4496308, -0.06280981, 0.14776334, -0.07939065, -0.0627922, -0.06294343, -0.36063924, 0.041440524, 0.94182587, -0.20145822, -0.66523886, 0.11386692, 0.027949717, -0.49334693) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.022026097, 0.18383168, -0.22692208, 0.2531586, 0.05050099, -0.08752271, -0.045149263, -0.14643942, -0.35375786, 0.18579838, 0.22855689, 0.05736517, 0.18378842, -0.07753595, 0.072951, -0.17492384) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.01834045, -0.07257484, -0.14039671, 0.23680732, -0.09858814, -0.14503089, -0.036219817, -0.49752864, -0.12603113, 0.1973452, -0.099892616, -0.19090527, 0.19337344, 0.13728872, 0.092502125, 0.054748125) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.16941564, -0.028030705, -0.057818916, 0.18683039, 0.10262718, -0.15044016, -0.3174473, -0.30620986, 0.30267876, 0.3998725, 0.3302494, -0.35852215, 0.10543272, 0.10678774, -0.40272412, 0.5029334) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06740137, -0.015489351, -0.2685512, 0.0747408, -0.13052857, 0.4455368, 0.6829421, 0.5645318, -0.2486283, -0.068759024, -0.070595235, 0.005116219, 0.02768558, -0.1294804, -0.112131685, 0.14357223) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.02224835, 0.1604668, -0.11899574, 0.05211793, -0.008467831, -0.0854238, -0.13884182, -0.21222378, -0.058706913, 0.14846137, -0.06287075, -0.24736205, 0.0781726, 0.083059974, 0.005803859, 0.2131929) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.5568763, -0.182615, 0.7134177, 0.75027627, -0.51197046, -0.3798407, -0.26188713, 0.1403423, 0.3787113, 0.39441493, 0.80036163, -0.49771827, 0.18434113, 0.18875583, -0.09237818, 0.06784277) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12631005, -0.0603322, -0.13722889, 0.074381314, 0.30266732, -0.0037143629, -0.5060203, 0.05008408, 0.26022485, -0.083827645, -0.11716659, -0.19083856, 0.24386752, 0.041433755, -0.31196523, 0.1479099) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.03594318, 0.052688234, 0.14577685, 0.07810032, 0.09340054, -0.14212531, -0.053416703, -0.19812408, -0.38855144, 0.25647137, 0.1487651, -0.05432203, -0.33201754, 0.107543275, 0.024272302, -0.15510342) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10506986, -0.058483876, 0.19911075, -0.17991088, 0.20967264, -0.15262708, -0.28258136, 0.19067056, -0.20030794, -0.06356454, -0.34196025, -0.110387936, 0.12004967, -0.039481614, -0.2035323, 0.08445795) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.033302166, 0.033245653, 0.026766177, -0.17828415, 0.19464424, -0.05678147, 0.32123324, -0.20845525, 0.2601007, -0.04726681, -0.027322233, -0.15929931, 0.121367365, -0.17665929, 0.1809179, -0.035534486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1865646, 0.0061667305, 0.46967953, 0.017273014, -0.2773524, 0.061984424, -0.17477678, -0.19520356, -0.44718045, -0.10448202, 0.7500943, -0.18920258, -0.11003222, -0.1524817, -0.007341336, 0.31412762) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.116008356, -0.0068332436, 0.43474913, -0.1963079, 0.18773796, -0.028170362, -0.15121074, -0.26619875, 0.024196897, -0.14921078, -0.44445148, 0.42744416, 0.24205911, 0.27199864, 0.09353936, -0.9636786) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10659581, 0.086158164, 0.25770047, -0.25896636, -0.07447149, -0.10097907, 0.095301874, 0.03600084, 0.1251699, 0.15108384, 0.5565946, 0.20225956, -0.3459941, 0.005685579, -0.053839587, -0.05922331) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.26683435, -0.08207728, 0.36831692, 0.11606515, -0.027842522, -0.2272461, 0.16833366, 0.20834722, -0.14802481, -0.06379728, -0.2105102, -0.23033737, 0.12727809, -0.010135924, 0.2728618, -0.06767653) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.37012357, 0.003914941, 0.17231481, -0.1465776, 0.14392386, -0.06306826, -0.5827251, -0.16892095, -0.08470148, -0.55834943, -1.6590818, 0.50730443, -0.51128715, -0.039134838, -0.16229515, -0.14392506) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08795482, -0.0011650377, -0.058600068, -0.04287999, 0.16733502, -0.111002006, -0.13477212, -0.2787065, -0.19798248, 0.05849562, 0.05263583, 0.060169775, -0.113309346, -0.017601851, -0.20748764, -0.18870582) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

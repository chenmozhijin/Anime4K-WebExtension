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

  var result: vec4f = vec4f(-0.11422924, -0.06838157, 0.12209409, -0.013262491);
      result += mat4x4<f32>(0.048322536, 0.02206613, -0.15165691, -0.20559531, 0.06308003, 0.2799705, -0.0150558, -0.047606338, -0.23783356, 0.3014345, -0.19297922, 0.05247301, 0.03944671, 0.16884291, 0.017501691, 0.42152655) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0036683728, 0.02744742, 0.06468883, -0.1175818, -0.022144461, 0.1738953, -0.016694982, -0.18244852, -0.23067255, -0.17874478, -0.18914706, 0.015013564, -0.2717679, -0.00013964274, -0.25834256, 0.076550655) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.027681466, -0.051432613, 0.04521528, 0.12078698, 0.0020000911, -0.14416577, 0.13741735, -0.0069346293, -0.009325905, -0.07697277, 0.086113036, 0.051812433, -0.022415988, -0.21298884, -0.07668131, 0.18462406) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.011549207, 0.027517913, -0.11379732, -0.39918768, 0.051007684, 0.48595807, -0.140525, 0.07827813, 0.13824053, -0.14615025, 0.13280709, 0.5625997, 0.13474381, 0.3364409, -0.10176669, 0.3308767) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.05494714, -0.45057726, -0.5169294, -0.15486516, -0.034051694, -0.011416959, 0.08955705, 0.36768797, 0.109089255, 0.28481638, -0.2341027, 0.03819651, 0.23958202, 0.3654259, -0.46325588, -0.10495896) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13008171, 0.15284814, -0.26309732, 0.0444901, -0.13623369, -0.10629415, -0.17155641, 0.29586366, -0.13172367, -0.1790266, 0.20484021, 0.101090275, 0.18785042, -0.05013482, 0.040907875, 0.28864053) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07580955, 0.15173204, 0.04485715, -0.15484586, 0.18172026, 0.14322998, -0.031167908, 0.048699476, 0.07374172, 0.091466464, -0.216606, -0.34804407, -0.17117892, -0.021759888, -0.19932868, -0.016411886) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.021955192, 0.055140372, 0.10431481, -0.25605357, -0.15730743, 0.3071118, 0.43700802, 0.19746265, -0.37105238, -0.09934076, 0.086484, -0.14880985, -0.08670178, -0.01610564, -0.13479726, 0.34344804) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.007933413, 0.37599435, 0.16952336, -0.19668894, -0.13710691, -0.032243427, 0.085613735, 0.28061333, -0.08388822, 0.005825924, 0.14595595, -0.40464956, 0.057508953, -0.23174925, -0.14538941, 0.35941237) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0951611, 0.05273919, -0.026530229, 0.17723344, -0.050109707, 0.1260477, 0.145333, -0.10832116, -0.069339946, 0.02506214, -0.038847227, 0.08813773, 0.020614278, -0.1668823, -0.10513175, -0.049101338) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.042874396, -0.24052125, 0.15275393, 0.12806107, 0.13123102, 0.096970886, -0.25300732, -0.6618706, -0.06692011, 0.19884588, -0.13505627, -0.16372879, 0.1215603, 0.16393493, -0.021668147, -0.3358513) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12631336, -0.0044918484, 0.04447209, 0.14470382, 0.059170302, 0.20809741, 0.1431192, -0.09667153, 0.03165427, 0.027633829, 0.073239736, -0.19417125, 0.06292977, 0.089564085, 0.077487916, 0.056935254) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.007857495, 0.2859913, 0.05363481, 0.24713595, -0.08486806, -0.024932843, 0.23381062, 0.0035843465, -0.1110842, -0.22314453, -0.35204658, -0.39902553, 0.0806162, -0.0758511, 0.44360673, 0.3427585) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.29109192, 0.3211723, -0.06378079, -0.60463536, -0.11271605, -0.020022765, 0.31164882, -0.12708308, 0.13209262, 0.43307427, -0.020609079, 0.4192484, 0.21605812, 0.36449054, -0.08153567, -0.36538634) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.007180724, -0.28189543, -0.075750664, -0.11966011, 0.056776386, 0.26233077, -0.025455313, -0.37217706, 0.029308094, 0.439675, -0.032528296, -0.06029624, -0.056583427, -0.16646962, 0.024972185, 0.066233225) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07777848, 0.0990909, -0.3383613, -0.1827235, 0.095872745, 0.06142897, 0.16183658, 0.19270611, -0.03912207, 0.06690588, 0.18265823, 0.18976775, 0.20326304, 0.002289781, -0.28025746, -0.20871584) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24468926, -0.01618561, -0.3877964, 0.14573577, 0.22458456, 0.0063313125, -0.109323084, 0.052595392, 0.20505424, -0.02602432, -0.40416506, 0.19003783, -0.164578, 0.12980925, 0.2257436, -0.73343676) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.008654618, 0.13442601, -0.046887703, 0.19394712, 0.10190939, -0.15629499, -0.024337096, -0.27229902, -0.16821066, -0.4564094, -0.223773, 0.47321332, -0.27425024, 0.02525111, 0.16876344, -0.014123358) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.20060438, 0.2276099, -0.032526743, 0.0039115194);
      result += mat4x4<f32>(0.12645745, 0.17491728, -0.17750303, -0.07036088, 0.17118151, -0.029129097, 0.18058336, 0.029092876, -0.12167129, 0.14244704, -0.32581303, 0.011687867, 0.29841557, -0.46844745, 0.43105602, 0.25275815) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15628602, 0.16803263, -0.11298361, -0.21453145, -0.004968663, 0.19784307, -0.036269154, -0.109894924, 0.045117356, -0.18817145, 0.23302458, 0.050217226, -0.89762133, 0.2469654, 0.14090648, -0.3364595) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.053524997, -0.054676097, -0.08902305, 0.04696142, -0.10465689, 0.24173953, 0.17731132, -0.033332136, 0.12971102, 0.09353599, 0.12056365, -0.05453476, 0.024760094, -0.0039756508, -0.027522432, 0.10631658) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.26410052, 0.16469765, -0.44450292, 0.08470343, 0.017870381, 0.2668766, -0.32507527, 0.0041662357, 0.42882192, -0.06652697, 0.6209394, -0.15754908, -0.32073322, -0.29831958, -0.1934721, 0.49125433) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5814713, -0.2593556, -0.042254318, -0.27111417, 0.18758874, 0.91074616, -0.16378796, -0.66699994, -0.40492243, 0.014438541, 0.17153051, 0.21759593, 0.95435977, -0.2797003, 0.53665715, -0.380479) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.23626992, -0.1977396, -0.07916088, 0.16607311, -0.20183286, 0.05114398, 0.5573436, 0.01973438, -0.6616604, 0.46907508, -0.07437584, -0.17635548, -0.06944952, 0.32310045, -0.0059516295, -0.07933052) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.021635693, 0.028233266, -0.20898367, -0.0017763627, 0.007911272, 0.12665477, -0.09978326, -0.03413195, -0.27342692, -0.0022563227, 0.40480265, -0.04889561, -0.06982439, -0.1923243, -0.20494153, 0.22737685) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2928852, -0.1476091, 0.008396695, 0.058360636, 0.2700004, 0.07806068, 0.4761219, -0.108730555, -0.052147303, 0.18925494, -0.50841504, 0.20437185, -0.26731485, -0.05530793, -0.2625822, 0.109321244) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.2655245, 0.21464974, 0.013323627, 0.10818131, -0.31767708, 0.01311495, 0.3286945, 0.09207869, 0.6254731, -0.3024753, 0.18041739, -0.12831059, -0.034568004, 0.03856839, 0.049275104, -0.04298861) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.09354548, -0.20123845, -0.1777154, 0.10685009, 0.35087246, 0.22633177, 0.052982926, -0.2892043, 0.006934958, 0.1427363, 0.1699982, -0.062814675, 0.26568353, -0.03469131, -0.04971041, -0.029632976) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11572194, -0.36022222, -0.32696643, 0.13833581, 0.5039914, 0.08444584, -0.09543793, -0.010292048, 0.3930809, 0.095897764, 0.17906877, -0.03735008, 0.032202784, 0.14433761, -0.015449645, -0.094233185) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14071204, -0.30659854, -0.13064826, 0.07623577, -0.010471376, 0.021377593, 0.031503458, -0.04011397, -0.030806946, 0.14953315, 0.21168889, -0.05208779, 0.15274188, -0.30327663, -0.12560436, 0.23084891) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08512818, -0.25887764, -0.25091487, 0.16360271, 0.053922877, 0.1761992, -0.065922625, -0.00566865, 0.041708916, 0.2316149, 0.2121823, -0.17074774, 0.18703103, 0.16143382, -0.6974277, 0.05290236) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.11880275, -0.52792555, -0.022273906, 0.16755591, -0.077030726, 0.63840914, -0.40481406, -0.09335094, 0.009259992, 0.2407114, 0.17874561, 0.007932761, 0.3981216, 0.35371646, -0.11364104, -0.28885505) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20078711, -0.4681102, -0.23319533, 0.1973379, 0.21521418, -0.0030778127, -0.09359359, -0.035547633, -0.13884759, 0.11406352, 0.022349875, 0.06940237, 0.14162172, -0.0884453, -0.23564702, 0.22234088) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12633632, -0.20929223, -0.2306077, 0.10350584, -0.046436913, 7.0178015e-05, 0.123678744, 0.037099563, 0.02956393, 0.10730953, 0.22509782, -0.104553506, 0.20952669, 0.08528913, -0.5502007, 0.116244875) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08878866, -0.35504988, -0.42821193, 0.19883676, -0.23449337, 0.08475122, 0.16165814, 0.044129483, -0.20330617, 0.18362434, 0.29853284, -0.042052913, 0.76276195, 0.039090563, -0.25935304, -0.070643954) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.036802348, -0.19685778, -0.24913637, 0.10233887, 0.14739989, 0.052105013, -0.009106677, -0.06498664, -0.1510637, 0.010292869, -0.010038479, 0.122229256, 0.04722239, 0.14293715, -0.22685997, 0.05864069) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

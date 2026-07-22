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

  var result: vec4f = vec4f(-0.03773432, -0.021154111, 0.08369375, 0.08914351);
      result += mat4x4<f32>(-0.06454009, -0.11071578, -0.336649, 0.14585763, 0.017682888, -0.054979965, -0.05192642, 0.02359902, -0.071479306, 0.051506206, -0.3503482, -0.041664556, -0.4377533, 0.0827587, 0.28769717, -0.2160423) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08283063, 0.10197516, 0.27109292, -0.3016927, -0.16895299, -0.067454465, -0.46169904, 0.14003167, -0.07229714, 0.08398445, -0.413714, 0.19144697, -0.3409656, -0.009113653, -0.26030853, -0.21867125) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.31183612, -0.10342302, 0.15292837, -0.33096743, 0.079804085, -0.020527093, -0.33163813, 0.021736499, 0.39966848, -0.13051663, -0.17359963, 0.33768386, 0.05880207, -0.06962929, -0.016945148, 0.042353235) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15469477, 0.34157187, 0.39633518, 0.29134378, -0.055889037, 0.19533215, 0.22230904, 0.16638742, 0.056071457, 0.036987152, -0.032857116, 0.2553542, 0.28536737, 0.11186752, 0.20798577, -0.29761752) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6915132, 0.10639403, -0.31094372, 0.023689697, 0.18358612, 0.0645915, -0.28381887, 0.35906112, -0.3257604, 0.21539113, 0.09986021, 0.39424452, 0.12513404, -0.19957279, -0.08207403, -0.13601737) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20751649, -0.1916988, -0.66428727, 0.33139095, 0.06311577, -0.14107089, -0.35625833, 0.21680322, 0.10540964, -0.045244206, -0.26566085, 0.030440629, 0.2516003, -0.17073907, -0.0050925873, -0.1360756) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10230436, 0.1071317, 0.13223489, -0.019098712, -0.10461583, -0.06306304, -0.07491924, 0.007914992, 0.27841657, 0.008110069, -0.5569675, 0.25148505, -0.13302338, 0.029209957, 0.19718319, 0.011703043) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.00013055485, -0.12496158, -0.051970314, -0.08522065, 0.2161432, 0.13692088, 0.057277128, 0.16816714, 0.17678626, 0.030881478, -0.15485996, 0.3475229, -0.028040705, 0.057369396, 0.6135186, 0.16902456) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19020526, -0.15950988, -0.11178671, 0.09959641, -0.028010543, -0.19546223, -0.26145548, 0.16601409, 0.1131818, 0.051222946, 0.38642138, -0.08437648, 0.04573222, 0.1379569, 0.32761067, -0.31932837) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06880854, -0.19222191, -0.17638609, -0.16395529, -0.11649222, -0.027556283, -0.29691347, -0.133747, -0.36144397, 0.1867081, -0.2059052, -0.2007186, -0.25349605, -0.025785545, -0.5010363, 0.027887585) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07005281, -0.25291714, -0.29698056, 0.13716872, -0.3932725, 0.0056537953, -0.28972033, -0.2860071, -0.24596831, -0.25322714, 0.25329798, -0.07135898, -0.21629488, 0.063626274, -0.16088182, -0.25509617) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15234819, 0.044483587, 0.1425676, 0.2820612, 0.045579832, -0.18841948, -0.02314112, -0.15598065, -0.1410729, -0.1076542, -0.15070893, -0.17472029, -0.16710554, -0.031030957, 0.067028455, -0.12523703) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0046101473, 0.18707721, 0.10848642, 0.0317211, 0.19815129, 0.0319295, 0.26765615, -0.44303212, 0.1301498, -0.0024206568, 0.119155996, -0.003963853, -0.009127848, -0.043956302, -0.3034647, 0.22857049) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.18442672, -0.11083481, 0.43002254, -0.594606, -0.41692233, 0.17105277, 0.60953635, -0.22103766, 0.30352458, -0.13690238, -0.3458708, 0.20497115, 0.066009976, -0.1048134, -0.15812685, -0.13876472) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.37671253, -0.2393798, -0.24621831, -0.4811658, 0.31249604, 0.058470797, -0.008227551, -0.27408117, -0.15570043, -0.184776, -0.105853684, 0.18833072, -0.09297929, -0.2085042, -0.11241006, -0.29761457) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.058527168, -0.09987223, -0.31233618, 0.091043524, 0.15178192, -0.08122816, 0.022222832, -0.031008204, 0.24111672, 0.05081559, 0.3364898, -0.14210722, -0.026710985, -0.09074134, -0.2224796, 0.23078667) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12975664, -0.008365092, -0.05850688, -0.36049902, -0.1066169, 0.045623448, -0.04319561, 0.19442455, -0.07962184, 0.007750147, -0.443968, -0.119151615, -0.066846356, -0.07083758, -0.011478656, 0.15203483) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.22077428, -0.14447875, -0.2776586, -0.12104837, -0.09610897, 0.03526885, -0.14281698, -0.087656565, 0.09115534, -0.068820074, 0.08331995, -0.16855781, 0.11779607, 0.0044848984, -0.025470994, 0.022966163) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

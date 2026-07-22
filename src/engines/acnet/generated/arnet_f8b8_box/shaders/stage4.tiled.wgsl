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

@group(0) @binding(2) var tex_FEAT_TEX_0: texture_2d<f32>;

fn sample_FEAT_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_0: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_0[tileY][tileX] = sample_FEAT_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.3093504, -0.19633184, -0.33917496, 0.089841135);
      result += mat4x4<f32>(0.29833373, 0.3688518, -0.026186563, -0.20395498, -0.0064971875, -0.12514724, 0.27039775, 0.04902766, -0.06858772, 0.24692696, -0.26186723, -0.06714573, 0.09670368, -0.0032348686, -0.033593114, -0.029028801) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07434594, -0.2061777, 0.5380841, 0.031051775, -0.050637417, -0.34450358, 0.35724634, 0.25259128, 0.054918297, 0.17874645, -0.029301338, -0.0694704, -0.036082845, -0.13533895, -0.03421612, 0.014803477) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10615359, 0.014849524, -0.075924926, 0.08218753, 0.0041163866, 0.05200234, -0.024159038, 0.023619829, -0.06486336, -0.1553654, 0.090953335, 0.052774113, 0.05354182, -0.047702264, 0.11623938, -0.105207294) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.069210134, -0.06172054, -0.43781555, 0.3598191, -0.7401053, 0.075831756, 0.7730066, 0.08140505, 0.122818194, 0.38621166, -0.6254308, -0.06464877, 0.28423598, -0.08416608, -0.19916311, -0.15159097) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.44954386, -0.072851956, -0.49296704, 0.3101597, -0.22295493, -0.6126652, -0.036252998, 0.43123573, 0.7345303, 0.4467757, -0.08195651, -0.5273958, -0.68076617, -0.3133128, 0.1724574, -0.1750658) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15291263, 0.07926525, 0.120748855, 0.1692796, -0.09734388, -0.004958173, -0.091286525, 0.013517246, 0.06055265, -0.15056562, -0.0017969596, -0.032731578, -0.08653646, -0.11721812, 0.28618184, 0.10115005) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.111465804, -0.21545713, 0.17378272, -0.095310636, -0.095597394, 0.19282797, 0.2026261, -0.045224354, 0.081335925, 0.40874305, -0.23828626, -0.04428119, 0.08281035, 0.049062893, -0.44485185, -0.004851746) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.33021, 0.025719175, 0.33165053, -0.05641933, 0.00902337, -0.096940525, 0.25834736, 0.08411579, -0.031130018, 0.23812309, -0.025343118, 0.0228202, -0.68421453, -0.26657486, 0.7691214, -0.17081851) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07813997, 0.06111719, -0.024302855, 0.0108216, -0.044675093, -0.004163546, -0.021874415, 0.023583988, 0.08385665, 0.1630043, 0.009644327, -0.13008064, -0.26420954, 0.056566358, 0.26830682, -0.038570777) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.051078558, 0.40316898, -0.15492763, -0.13942224, -0.15989687, -0.20946893, -0.1768781, 0.21445532, -0.07109601, -0.12312465, 0.08030725, 0.10552355, -0.33502907, -0.21768916, 0.31931978, -0.096303925) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15354571, 0.0758187, 0.08903407, -0.06614132, 0.23477702, 0.020867938, 0.12499416, 0.05562309, 0.07751431, -0.04759002, 0.07080772, 0.12891692, -0.14997162, -0.29134607, 0.30477476, 0.1181305) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07895791, -0.025116865, 0.042839717, -0.017474443, 0.07920571, -0.038898274, -0.0328758, -0.028090518, 0.006008549, 0.06982408, -0.18187906, 0.13179685, -0.32336748, -0.1186151, -0.18190072, 0.03111485) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3255145, 0.19919692, -0.6041662, -0.09455068, 0.55488557, 0.5500359, -0.8554916, -0.12410166, -0.3367493, -0.11390708, 0.4106031, 0.15951829, -0.5842201, -0.25132987, 0.68274546, 0.041433614) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.51293314, 0.42248324, -0.27626622, -0.19730988, 0.21533819, -0.037358608, -0.24624789, 0.42317683, 0.16578582, -0.32269278, 0.40188256, 0.44640017, 1.277519, 0.9801834, -0.88541156, -0.31163594) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.015121619, 0.018862601, -0.030316297, 0.07876369, 0.34355897, -0.031555433, 0.2858094, 0.0047521065, -0.12569569, 0.106515706, -0.39671445, -0.03333777, -0.09083109, -0.027529607, -0.16467467, 0.34038794) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.31220114, 0.32391983, -0.5242695, -0.03424007, 0.13263328, 0.12362821, -0.511418, -0.06900322, -0.10903747, -0.24834165, 0.5678397, 0.06208604, -0.09596693, 0.16452022, 0.09271728, 0.11029443) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.5970259, 0.44589514, -0.4951123, -0.27718797, 0.071842566, 0.13486908, -0.44821292, -0.062947765, 0.42480835, -0.036524344, -0.2648456, -0.00735586, 0.09063962, 0.12711748, 0.35617852, -0.33608428) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19363056, -0.06722237, -0.051145516, 0.057342608, 0.123951264, 0.04953435, 0.14244129, -0.09109352, 0.041875437, -0.086602755, -0.28171715, 0.018862838, -0.14787023, 0.2908037, -0.23812926, 0.012028253) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

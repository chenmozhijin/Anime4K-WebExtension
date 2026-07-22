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

  var result: vec4f = vec4f(-0.06437029, 0.11413638, 0.23147035, -0.053778213);
      result += mat4x4<f32>(-0.16483667, 0.2949996, -0.61663616, 0.2969127, -0.017490884, 0.028372226, -0.026979752, -0.014956181, 0.028519873, 0.37969217, 0.15499029, 0.0035506918, 0.05835144, -0.099049464, 0.0320989, 0.26994115) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.29102814, 0.31271502, -0.6478266, 0.2389194, -0.06785875, -0.010642339, 0.0903149, -0.11026442, 0.00047156197, 0.0044486555, 0.052608434, -0.031520505, -0.06462297, -0.031789865, -0.058313806, 0.2947959) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.03204492, -0.23005007, 0.21255507, -0.19261844, 0.023726458, -0.0038474128, 0.049994886, -0.0055883997, -0.061269216, 0.29384392, 0.05671173, 0.07946303, 0.11636977, -0.0151838865, 0.03765379, 0.17451906) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06833883, 0.300911, -0.1107704, 0.003549841, -0.033673916, 0.10708325, -0.032338362, -0.259717, 0.017250534, -0.37756193, -0.13570495, 0.045238964, 0.25074327, 0.20104128, -0.24445319, -0.4597775) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23833255, -0.09464271, 0.19262747, 0.32782826, 0.13450877, -0.4566281, 0.37266472, -0.3504856, -0.12283707, -0.27489248, -0.21122038, -0.013939324, 0.6399843, 0.1680325, -0.78719455, 0.046749607) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.10076928, -0.18801437, 0.4057485, -0.06328166, 0.022722887, -0.028588483, -0.052936383, -0.25864527, 0.15052396, 0.017596312, 0.09313833, -0.13344136, 0.5275479, 0.05963015, -0.041273925, 0.11590625) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13789804, -0.20293842, 0.29029652, 0.018309813, 0.07010318, 0.03480622, -0.0012877056, 0.0046099625, -0.10831167, -0.61140937, -0.33056638, -0.20692903, 0.029203655, -0.087507986, -0.028981337, -0.0003074949) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.02462762, -0.21874008, 0.33133033, -0.26421386, 0.080079585, 0.02167454, -0.064745985, 0.101015344, 0.18319991, -0.38938683, -0.15218474, 0.02501486, 0.13106897, -0.19434753, 0.00024232775, 0.24150246) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07443664, 0.054748777, 0.21327665, 0.033564452, -0.0058653923, 0.015898356, -0.00489622, 0.007172727, -0.10992576, 0.36469698, 0.16482057, 0.055307075, 0.19633156, -0.0407326, -0.09352814, 0.16930182) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08698042, -0.18478431, 0.63031536, -0.20093934, 0.026405424, -0.23286588, -0.13087158, -0.06879345, 0.09367212, 0.098018825, 0.10408799, 0.10242029, 0.22396588, 0.083014496, -0.12054473, -0.13373406) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.40462717, -0.1484056, 0.7229962, -0.3136206, 0.02754169, 0.029284833, -0.008593348, -0.020695819, 0.22152466, -0.09585633, -0.029905157, 0.1427256, -0.07773673, 0.2507088, 0.14603671, -0.22624178) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.009522134, 0.080098286, -0.17598042, 0.094741754, -0.10018024, 0.0415874, 0.09742179, -0.18847616, -0.0172217, -0.0073982393, -0.007420504, -0.19505256, -0.04409097, -0.0037086972, 0.017048175, 0.086854935) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11622455, 0.039074443, -0.0145711545, -0.20363696, -0.06848163, -0.14220513, 0.1516817, -0.103710555, 0.08434171, -0.3092853, 0.23103744, 1.021021, 0.2480003, 0.15422742, 0.017543625, -0.18129553) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14124024, -0.30860507, 0.36144838, 0.24410173, 0.13051236, 0.39676628, -0.10133542, -0.052921355, 0.4050469, 0.41369817, -0.34197614, -0.2997023, -0.018582938, 0.0058938, 0.040504176, 0.5562199) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04312374, 0.16013184, -0.20092589, 0.13817334, 0.038964648, -0.28976807, 0.19277908, -0.32387805, -0.12050596, 0.20270424, -0.15365458, -0.01240341, 0.1744448, 0.0954952, -0.28501645, -0.08646657) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.011053192, 0.039570704, -0.052055072, 0.20893228, -0.13409032, -0.1076111, -0.050638314, -0.19928086, -0.16197069, -0.043050762, 0.119757235, 0.10683856, 0.04275377, 0.076768614, 0.14520541, -0.124231756) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.038678475, 0.37639198, -0.22256424, -0.00087826786, 0.13656984, 0.022133661, -0.09889542, -0.11045202, -0.15133004, 0.027181733, 0.02707939, -0.17392822, -0.095837496, -0.044365957, 0.2750092, 0.18482356) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09733517, 0.23155224, -0.0069635813, -0.07050367, 0.03293427, -0.09146086, -0.2036066, 0.038334586, 0.044567887, -0.064417616, -0.32684833, -0.2500356, -0.09309065, -0.019478893, 0.19739853, 0.0070329704) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

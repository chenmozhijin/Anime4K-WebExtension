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

  var result: vec4f = vec4f(0.025367374, -0.0051409355, 0.16421147, -0.10834977);
      result += mat4x4<f32>(-0.081473276, -0.15587482, 0.16870171, -0.049314234, -0.09780422, 0.1528184, 0.15014684, -0.31298706, 0.08570393, -0.0122941695, 0.11328447, 0.065281264, -0.085621916, -0.13163406, 0.16939244, 0.34024173) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.30768707, 0.04647123, 0.16688903, -0.18958928, 0.7479689, -0.2325586, -0.45398355, 0.23206665, 0.09085315, -0.016346177, 0.15749495, 0.020677887, -0.15672264, 0.20313261, -0.02840703, -0.049910344) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.17858393, 0.16992903, 0.22445847, 0.06555609, 0.0818802, 0.10535055, 0.06644215, 0.17613441, 0.1209065, 0.0816191, 0.22088441, 0.05713323, 0.35167283, 0.095797695, 0.15833628, 0.37391347) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17068599, -0.1202542, 0.1305598, 0.13241206, 0.048046652, -0.10113928, 0.10724346, 0.11136983, 0.15403605, -0.08759568, 0.21302737, 0.15599896, 0.00789579, 0.054167803, -0.025551863, -0.030087946) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.50612336, -0.027041657, -0.37273568, -0.31782892, -0.3016885, 0.19499403, 0.170782, -0.41124877, 0.104836665, -0.013064049, 0.23320547, 0.158301, 0.23812635, -0.041490626, 0.118149, -0.2791009) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1717773, 0.04100857, 0.10979846, 0.07310797, -0.39717364, 0.03509262, -0.099630676, -0.14259866, -0.057369813, 0.012860841, 0.22488359, -0.03891429, 0.17616327, -0.08550069, -0.21423334, -0.36425832) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.055993553, -0.07146692, -0.07367022, -0.050320994, -0.32733804, -0.09676523, -0.29543772, 0.12519665, 0.15694472, -0.04746384, 0.076584324, 0.07028804, -0.0024861197, -0.0025307767, -0.047261648, 0.10737659) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.095815696, -0.25255084, -0.22785605, 0.030094761, -0.16238728, 0.025836945, 0.29894906, 0.07795325, 0.24476968, -0.017975448, 0.25002, 0.20950833, 0.31490475, 0.072536394, 0.11817007, -0.09672123) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.004428022, 0.054237254, -0.16011788, -0.047508314, -0.013500663, -0.13957049, -0.16886576, -0.042158242, 0.092171855, 0.019589867, 0.1035517, 0.027667526, -0.03411587, 0.01600068, -0.023221271, 0.12259558) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.006332553, 0.09628717, 0.2249447, 0.0074251723, -0.03583049, -0.014562658, -0.12623273, -0.2849756, -0.1627268, 0.022098733, 0.32971936, 0.062687874, 0.06491942, -0.14187773, -0.27714938, 0.14090548) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.37310573, 0.16899157, 0.08979122, -0.20302692, 0.34610155, -0.13610832, -0.3503368, 0.013289481, -0.113322124, 0.4413931, -0.05691779, -0.23770998, 0.18059957, -0.03503392, -0.35134745, 0.0014882486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.005649064, 0.006937404, 0.09878696, -0.027398158, -0.110895544, -0.111151606, -0.23142843, -0.008733789, 0.15631269, -0.025709575, 0.18059124, -0.008374772, -0.16716544, 0.052639976, 0.16451709, 0.08700664) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.28433874, 0.042129412, -0.009219943, 0.107127815, 0.11909944, 0.030864242, -0.100141436, -0.19021024, 0.21087906, 0.04008267, 0.040796906, -0.033147417, 0.31150702, 0.12071369, -0.51743037, 0.10347624) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.16044831, 0.25185537, 0.29675338, 0.28016973, -0.110163204, -0.020075405, 0.030776383, -0.081877545, 0.43848574, -0.15025623, -0.37360576, -0.25747168, 0.3067104, 0.19489187, -0.021660717, 0.16829205) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09389055, -0.07589153, -0.28832364, -0.22643417, 0.0290523, -0.22165947, -0.065828554, -0.091131076, -0.16271698, 0.083052576, 0.079377666, -0.012833546, 0.11979089, 0.018943716, 0.10697123, 0.12402443) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04617344, 0.057998832, -0.20853636, -0.096625686, 0.033329558, 0.058550615, -0.09338581, 0.16357163, 0.1324844, -0.010814575, 0.14856184, -0.101495616, -0.24648279, -0.046803635, 0.007574521, 0.14304234) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15389904, 0.020099984, 0.17128782, -0.033007447, 0.13923253, 0.14455013, 0.0896652, -0.07131519, -0.3543869, -0.26405254, -0.12981336, -0.06398401, -0.33062753, 0.030545257, 0.138951, 0.11148559) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.099925585, -0.077822335, -0.12857758, -0.083439946, 0.19566038, 0.06419511, 0.047413256, -0.21686524, -0.026959106, 0.06619375, 0.080053926, 0.13937776, 0.001677662, -0.048962135, 0.11497131, -0.06234489) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

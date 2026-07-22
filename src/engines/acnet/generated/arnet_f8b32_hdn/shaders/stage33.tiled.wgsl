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

  var result: vec4f = vec4f(0.32622743, 0.19325526, 0.25819078, -0.07474028);
      result += mat4x4<f32>(-0.031156555, -0.28098458, -0.021219114, -0.014282277, 0.11783118, -0.03834777, 0.32954875, 0.15479393, -0.14982001, 0.27657253, -0.38525644, -0.18683445, -0.10044035, 0.08637466, -0.08810884, -0.03136324) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.009909438, -0.1080582, -0.53060013, 0.054706708, -0.2343371, -0.16239646, 0.19681676, 0.21098825, -0.21374318, -0.19122523, -0.35037068, -0.058770698, -0.042441368, 0.1337331, 0.031510066, 0.23977275) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10911429, 0.22168064, -0.19178952, -0.16643444, 0.061934683, -0.36034957, 0.17802487, -0.22288404, -0.09357651, -0.13439043, -0.30123824, -0.14155057, 0.3518831, 0.03471575, -0.14000544, 0.053095892) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.029898379, -0.031344023, 0.10581594, -0.19512439, 0.08043683, -0.28313953, 0.15735012, 0.23936571, -0.9086729, -0.3707172, 0.037572015, -0.23025532, -0.32606897, 0.2077948, 0.09160301, -0.25978798) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.40632528, -0.18457818, 0.012132648, 0.12563686, 0.14514674, -0.26673967, 0.39635646, 0.29685116, -0.82597053, -0.17101774, -0.05499555, -0.13791102, -0.49829453, -0.15764208, 0.32604197, 0.22971787) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.5177908, 0.31019258, -0.25174758, 0.39953172, -0.025236508, -0.21085641, -0.12826765, 0.15651403, -0.3159672, -0.3197344, -0.15758882, -0.13895015, 0.03369528, 0.2985762, 0.11366789, 0.06507903) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.30211636, 0.0034238258, 0.067644626, -0.18315968, 0.039363302, -0.28115594, 0.012124721, -0.16162394, 0.043593336, -0.2818775, -0.02057922, 0.11139744, -0.16165058, 0.14976811, 0.16534273, -0.08217811) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.27302608, 0.0709023, 0.0013015097, -0.061541077, 0.25908583, -0.05543186, 0.211426, 0.14907946, 0.056793347, -0.07713221, -0.17730619, 0.08895427, -0.3917411, 0.002419969, 0.20418403, -0.38933203) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.3064141, 0.052222803, 0.027818892, -0.24679205, -0.08527969, -0.022869345, -0.03208943, 0.038069453, -0.11659447, -0.32382452, -0.17346618, -0.08839243, -0.26702166, 0.28729346, 0.10888206, -0.15738305) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.012244137, -0.2782717, 0.29633823, 0.27400005, 0.19717802, -0.13648123, 0.22524089, 0.09249676, -0.044091184, -0.20905967, 0.22107156, 0.08871148, 0.4165777, 0.2023341, 0.10964661, 0.015070223) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21311514, 0.042819154, 0.07334259, 0.12568498, 0.60899144, -0.038541112, 0.8363484, 0.33094752, 0.05316464, 0.47182348, -0.46045294, 0.051358435, 0.18502069, -0.000558937, -0.14485143, -0.04516841) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.042149626, -0.19659495, 0.11736984, 0.00976642, 0.12896332, 0.27292857, -0.177492, 0.50702703, -0.11002009, 0.032825228, 0.071507104, 0.2218203, 0.112493426, -0.24722196, 0.33893633, -0.116696596) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.030420685, 0.510187, -0.21210131, 0.2043709, 0.22420378, -0.17908697, -0.19264154, 0.51798874, -0.24435282, 0.61191225, -0.17771234, -0.053228267, -0.13302955, 0.30407932, 0.15998712, -0.15011178) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.19434854, -0.40356985, 0.14013714, 0.16546533, -0.040434696, -0.13737829, -0.32328537, 0.3099822, -0.013706565, 0.19236323, -0.00030568748, 0.36066636, -0.10437506, -0.028394595, -0.59295434, 0.016039446) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.062215686, 0.18061548, -0.019997898, 0.17234242, 0.09087569, 0.19663447, -0.08267214, 0.08998964, 0.10588681, -0.21726678, -0.027896058, -0.30893943, 0.39329973, -0.028746294, 0.10320608, 0.0627031) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13345504, -0.3367962, -0.15989965, 0.16880979, 0.03465067, 0.112150945, 0.18510479, -0.021358762, -0.7529058, -0.25135508, -0.058189046, -0.020017244, 0.057679042, 0.25776482, -0.029009435, -0.041981027) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06786212, -0.13775074, 0.03660011, 0.23634614, 0.028175334, 0.098296784, -0.07724593, -0.01975106, -0.392838, 0.15455908, 0.0524268, 0.15718974, -0.6118888, 0.16071613, 0.15254988, -0.3359023) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.021292113, 0.16788349, -0.041631155, 0.22571167, -0.10182498, 0.035615668, -0.0011066115, 0.029201776, -0.025662553, -0.170822, 0.15670457, -0.1738041, -0.043562543, 0.13853204, -0.037259605, 0.15081199) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

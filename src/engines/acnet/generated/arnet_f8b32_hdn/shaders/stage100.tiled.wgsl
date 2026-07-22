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

  var result: vec4f = vec4f(0.30531436, 0.39950368, -0.0067771813, -0.03348325);
      result += mat4x4<f32>(-0.016311327, -0.2221611, 0.092355706, 0.120018445, 0.029033907, -0.34552166, -0.05731939, -0.16445486, -0.012217642, -0.3120044, 0.09494753, -0.21261217, 0.23577838, 0.121619046, -0.11722023, -0.08952089) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10887952, -0.102912046, -0.038294684, 0.27372748, -0.01577913, -0.07012327, -0.033159792, -0.05027683, 0.10766976, 0.19872423, -0.16549508, 0.12653495, 0.18972018, 0.53744483, -0.21272495, 0.50531894) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.024616584, 0.15554969, -0.017259104, 0.28230748, -0.026394514, -0.12875797, -0.24681479, -0.057996117, 0.09785584, -0.29232576, 0.114428535, -0.17238648, -0.2307113, 0.8863598, -0.16956761, 0.8832368) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07096237, -0.02077664, 0.09989035, 0.06747493, -0.17287032, -0.21346825, -0.07324478, 0.07794574, -0.17160282, 0.038884502, -0.37647778, 0.07551999, 0.0044563133, -0.5542097, 0.0840829, -0.63049394) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2856216, -0.10058132, 1.1781025, -0.61772233, 0.15533257, -0.3628754, 0.1338228, 0.14092612, 0.04405547, -0.44428623, 0.6037886, 0.07098411, 0.15950914, 0.26872173, -0.015224753, 0.11974783) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.016304748, -0.056027204, -0.05222391, 0.12252216, -0.015779806, -0.13632196, -0.047615163, 0.087403536, 0.29392135, -0.18292643, 0.23633425, 0.15548429, -0.18502608, 0.46990559, 0.040927462, 0.9383371) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.009116443, -0.12883262, 0.11204481, 0.16728151, -0.08153104, -0.29317543, -0.099408425, 0.050710384, -0.0293237, -0.14759043, -0.008802067, -0.0013348868, 0.2857012, -0.73239976, 0.031112673, -1.0386229) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.21603203, -0.01103794, 0.058159623, -0.024805028, -0.101722375, 0.20324028, -0.29694718, 0.14381012, 0.056749646, 0.15032418, 0.23474406, 0.1174807, -0.06774544, -0.569278, 0.18213429, -0.6703572) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.035327483, -0.01696224, 0.06514762, 0.24641383, -0.09240329, -0.10349321, -0.17148376, 0.12296748, -0.03180657, 0.0093530575, 0.21826419, 0.14116508, -0.3620404, -0.17871435, 0.33360457, 0.2402406) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0772198, -0.88198054, 0.2918029, -1.0872838, 0.08088086, 0.58579445, 0.016564168, -0.1476077, -0.072838336, -0.15402395, 0.17179209, 0.029909074, -0.4404606, -0.31600684, -1.3037351, 0.32245296) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.24082196, -0.33354133, 0.10623492, -0.5149139, 0.02156474, -0.33262658, -0.11903439, -0.63773435, 0.07030512, -0.11900314, -0.0054501086, 0.009795817, 0.08013686, 0.17968151, 0.3963221, 0.092028484) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.30040926, 0.073783495, -0.12488643, -0.29042155, 0.1027095, 0.028828137, -0.07015845, -0.2402645, 0.04324756, 0.062215734, -0.02377279, -0.10707142, 0.092506036, 0.20735879, 0.09503805, -0.13077222) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0591882, -0.7138761, 0.077528894, -0.69752073, 0.16914338, 0.041077238, 0.33955348, 0.06357149, -0.21162868, 0.039677914, 0.25382793, 0.008734545, 0.24337052, -0.18440744, 0.40970954, -0.22568437) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.018045843, -0.0585817, -0.07029542, 0.11789711, -0.19447568, -0.23053099, -0.076434165, -0.21527594, 0.258023, -0.8422656, -0.31917176, -0.3139834, -0.11032593, 0.13723162, -0.15356168, -0.015342698) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07725342, 0.7867083, -0.2994798, 0.5116899, 0.05369824, -0.26486543, -0.08946542, 0.1026227, -0.11186472, -0.39506727, -0.46402878, 0.061456785, -0.038753442, 0.19910932, -0.20956092, 0.26506925) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24901536, -0.16838954, 0.15179059, 0.15054451, -0.042296957, 0.3540363, 0.16392007, -0.20705579, -0.074180946, -0.16240907, 0.036893453, 0.13288754, 0.017893568, -0.03699596, 0.08376845, -0.32304454) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18299372, 0.3521966, 0.2093559, 0.4076384, 0.017652443, -0.18561405, 0.13864939, 0.0781862, 0.14654505, 0.010066126, 0.090625286, 0.09274874, 0.07362506, 0.011232061, -0.19114956, -0.07935649) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.21803941, 0.7618743, -0.16335768, 1.2865381, -0.101685695, -0.20952146, 0.15318428, -0.27232033, -0.026822627, 0.26173455, -0.2986482, 0.0150437895, -0.06654562, -0.16571093, 0.03830473, -0.14646335) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.09280127, -0.16203597, -0.14093481, 0.18330742);
      result += mat4x4<f32>(-0.032753825, 0.095654346, 0.022350525, -0.023789272, -0.101095065, -0.038546093, 0.016253421, -0.0039738296, 0.010797482, -0.0024727725, 0.046139877, 0.06707954, -0.10107839, 0.106404275, -0.08545054, -0.11314873) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08625392, 0.16088626, -0.067827046, -0.010696589, -0.04106113, -0.14890361, 0.0155395, 0.05638045, -0.042434547, 0.1324171, 0.074669115, 0.006910599, -0.055328574, 0.051150225, 0.0462134, 0.0364359) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.036563735, 0.2073635, -0.08271473, -0.012500089, -0.025130529, 0.23961018, 0.0068346793, -0.076683976, 0.06573353, -0.025152365, 0.03211003, 0.035726387, 0.06418548, -0.13676967, -0.0923487, 0.027079828) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.073545225, 0.14274864, 0.032920342, -0.11103149, -0.024686778, -0.06317832, 0.044545017, 0.1128638, 0.0409458, -0.036484677, -0.01568048, -0.006102687, -0.27116483, -0.011625073, -0.2683965, 0.057894014) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.33234042, 0.20662859, 0.08113277, -0.20900209, -0.108739644, 1.0207943, -0.26944497, -0.34964538, -0.3109918, 0.06776805, -0.07700563, -0.028861713, -0.25912148, 0.18434855, -0.26971176, 0.9174911) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.21498577, 0.29535976, 0.186419, 0.12421005, -0.12721086, 0.06674292, 0.2268623, -0.13377702, 0.1519508, 0.024768671, 0.16291465, -0.0065025915, -0.0724716, -0.07813048, -0.18498208, 0.296248) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10782862, 0.023993893, 0.013608509, -0.07754615, 0.021670813, 0.030156506, -0.053924993, -0.0827059, 0.041836385, -0.11305424, 0.03905912, 0.105119325, 0.007354184, 0.025274338, -0.07379822, 0.015179686) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22304301, -0.07358472, 0.08508263, -0.21956639, -0.1532806, 0.063001744, 0.008854337, -0.17482325, -0.19207361, 0.1156776, 0.050346334, 0.073415875, -0.0182195, 0.025504392, -0.047654357, 0.05354815) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.5937414, 0.19104059, -0.105519466, -0.06456248, -0.018978128, 0.10565568, -0.021844706, -0.08894471, 0.21085255, 0.05653761, 0.08450193, 0.13782068, -0.0062431255, -0.10510485, -0.013530377, 0.027226493) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16989587, 0.10050203, -0.17051308, -0.20338927, -0.021528028, -0.16143118, 0.060728278, 0.10951317, 0.034559205, -0.006845568, 0.0009587812, 0.007815727, 0.0009223594, -0.12673777, -0.026470555, -0.00403372) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.18421365, 0.08491334, -0.08164082, 0.099233806, 0.048278898, 0.2809478, -0.10102511, -0.12641476, -0.029310422, 0.026624544, 0.04254272, 0.033217084, -0.10269015, 0.018427106, -0.027003914, -0.04885101) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05805289, -0.0667677, 0.096628495, -0.10906152, -0.001015826, 0.024086408, -0.0857776, -0.06828521, -0.107593015, 0.10251919, 0.048522837, -0.043788627, -0.042075094, -0.09972922, -0.05933468, 0.026008645) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14903912, -0.1245567, -0.04348877, 0.080115445, 0.043318667, -0.07647848, 0.22937468, 0.18991895, 0.047222313, -0.27729574, 0.010344136, -0.02095104, 0.058320843, 0.003592191, -0.092211835, -0.10676552) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.004002241, 0.062780835, 0.28885028, -0.4630025, 0.22510332, 0.07530099, 0.41855896, -0.6405495, -0.057060733, -0.13216202, -0.20086291, 0.34190625, -0.57427186, 0.08845994, -0.6763622, 0.66886127) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04759655, 0.26823235, -0.27201498, -0.049073502, 0.10598252, -0.037449643, 0.06341321, -0.050068684, -0.17929421, 0.050259337, -0.06383017, -0.29607707, -0.09180871, -0.043687053, -0.094810635, 0.08989063) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0630194, -0.009536655, 0.0031188421, -0.084204726, 0.013209361, -0.046762545, -0.0759056, 0.0029404592, 0.061443515, 0.017942596, -0.08623076, -0.050069094, 0.030021768, -0.14802822, -0.030122481, 0.12702224) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.015004414, 0.04010763, -0.0121320905, 0.002144673, -0.022530338, 0.16207951, 0.010840304, -0.11784974, 0.035091337, -0.058106758, 0.03821386, 0.109933026, -0.10056717, 0.026438128, -0.02900215, -0.05988175) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07152132, 0.017560504, -0.042288948, -0.016374359, -0.026885428, 0.0034953756, -0.021608662, -0.0020238098, -0.039889283, 0.016217161, 0.016503822, -0.13632698, -0.044788133, -0.23955435, 0.095281474, 0.028607732) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

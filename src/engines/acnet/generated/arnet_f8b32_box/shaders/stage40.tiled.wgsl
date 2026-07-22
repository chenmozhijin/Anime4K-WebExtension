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

  var result: vec4f = vec4f(0.04166089, -0.019138366, 0.188554, -0.01078836);
      result += mat4x4<f32>(0.029110389, 0.15297726, 0.0015616479, -0.03381868, -0.042421024, -0.40434372, -0.094764866, -0.12121783, -0.085309245, -0.025940023, -0.03565116, 0.34939688, 0.015581076, -0.18567446, -0.13594505, -0.17021896) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.03878242, 0.16193424, -0.026426904, -0.31217748, 0.36410916, 0.28286937, 0.53939426, 0.32212242, -0.12774038, -0.20636982, -0.2025171, 0.12388713, 0.18791546, 0.012175612, 0.28212324, 0.1369108) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.079732835, 0.137995, 0.09053382, -0.027782943, 0.041039586, 0.15743348, 0.09630873, 0.17164831, -0.044650104, -0.18740982, -0.16654833, 0.040660027, 0.17905214, -0.059867837, 0.10993021, -0.047249157) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17003739, 0.015202044, -0.18961583, -0.44080925, -0.08150411, 0.40389338, -0.3197816, -0.07163702, 0.057970557, -0.32999867, 0.04766671, 0.4193122, -0.22620268, 0.11832174, 0.1231037, -0.16712625) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.056777623, 0.23896213, -0.27437806, -0.6353987, 0.028078763, 0.5443158, -0.24272703, 0.33767927, -0.08727169, -0.55902797, -0.025504047, 0.03790054, -0.24230783, -0.59689885, 0.035003506, 0.37892124) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.026060743, 0.2940818, 0.09630139, -0.14788054, 0.017238159, -0.15149316, -0.08817556, -0.07216277, 0.010982951, -0.29275894, -0.102427, 0.15922561, -0.021021752, -0.30263245, 0.06999224, 0.28870013) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.045939665, 0.15301022, 0.06839577, -0.24577259, 0.35212696, 0.058845647, -0.039623402, 0.06621042, 0.023598438, -0.2121422, -0.2348783, 0.1822261, 0.15748073, 0.12959965, -0.30426002, -0.0041339803) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15303126, 0.093723476, 0.13738404, -0.30917054, 0.08622151, -0.10509984, -0.21165946, 0.2761672, 0.04618709, 0.17321168, -0.49809015, 0.26659274, 0.13496307, -0.017237745, -0.27634573, -0.052282467) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07971746, 0.05573529, 0.054014985, -0.14579445, -0.045184392, -0.22399563, -0.21164045, 0.35972226, 0.021982074, -0.0921991, -0.124089785, 0.21539693, 0.04320163, 0.12772153, 0.02541869, 0.036419176) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.015709661, 0.30757898, -0.16806647, -0.18834832, 0.055828586, 0.029165927, -0.0012466991, -0.17327678, 0.12857963, -0.27036026, -0.07538724, 0.14630182, -0.08526821, 0.070517644, -0.1373515, 0.10587797) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3296896, -0.16131692, -0.11312886, 0.18267162, 0.051266793, 0.007099899, 0.09789154, -0.1940546, 0.1857795, -0.41368377, 0.06328294, 0.248392, -0.12957574, -0.09757485, -0.2021169, 0.110495746) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15950862, 0.20215373, 0.0117035955, -0.47467443, -0.08841506, -0.029431285, 0.14209718, 0.13272424, 0.037339967, -0.25101525, -0.17576475, 0.22221714, 0.007636202, 0.098360255, -0.09152124, -0.0163435) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.03385739, 0.36105832, 0.099509925, 0.5050656, 0.09851362, 0.074736625, 0.18972647, -0.19597606, -0.07167765, -0.08361539, -0.016761586, 0.21224931, -0.12628178, 0.31483343, -0.2261661, 0.33429727) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.20283784, -0.5419845, -0.003964552, 0.14088266, 0.096709505, -0.05333674, 0.09328479, 0.3365925, 0.18031684, -0.5645015, -0.27383286, 0.37664062, -0.53545314, -0.007996384, -0.47586846, 0.2530949) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.05232251, -0.110184066, -0.10020776, -0.09558679, -0.117435105, 0.2081481, 0.0169262, 0.05718288, 0.087498225, -0.27363324, -0.13254564, 0.18573707, -0.23163252, -0.050860345, 0.092525415, 0.04690413) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06225062, 0.21460249, -0.06237532, 0.23723799, 0.07752809, -0.12294257, 0.13016342, 0.09712197, -0.06086936, -0.11946197, -0.06432896, 0.27987343, -0.21812709, -0.056335866, -0.09678857, 0.2502407) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.28813314, 0.09558487, -0.22404137, 0.17766328, -0.114015386, -0.09412742, 0.0827254, 0.017791491, -0.029039495, -0.21449307, -0.10274348, 0.06783101, -0.29129308, -0.18514532, -0.10882064, 0.45217657) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20918642, 0.27273878, -0.24781828, -0.13826226, -0.15308473, -0.13478753, 0.63683474, -0.23518743, 0.013221475, -0.04244099, -0.049472652, 0.01963835, -0.21222742, -0.077519804, 0.04950029, 0.2927924) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

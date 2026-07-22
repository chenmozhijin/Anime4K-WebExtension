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

  var result: vec4f = vec4f(-0.25972354, 0.10182786, 0.2001937, -0.07816997);
      result += mat4x4<f32>(0.019491173, -0.07765975, -0.018603759, -0.10309588, -0.16469452, -0.0013918256, 0.067040466, 0.20125215, -0.056240413, 0.19856147, 0.05470101, -0.06865282, 0.021677319, 0.3105247, 0.051839955, 0.106807895) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.095185496, 0.21491796, -0.037656084, 0.23423931, 0.020667093, 0.07545179, -0.23909159, 0.03062328, -0.07803932, 0.06152768, -0.21733202, 0.081894144, 0.64019585, 0.24661992, 0.57690966, 0.30473033) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02133574, -0.02073308, -0.10326651, 0.04376502, -0.14977501, -0.05382131, -0.2284428, 0.03268369, 0.086420916, -0.27221417, -0.7208159, -0.16565122, 0.11345974, -0.34858063, 0.20505835, -0.028356781) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06075449, 0.02647643, 0.10093171, 0.32047275, 0.12259832, -0.20931196, -0.24905995, -0.1304817, 0.121029824, 0.07382244, -0.3859706, -0.43736678, 0.14826873, -0.03857496, -0.015124395, -0.17536555) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.056033257, -0.3242194, 0.033843573, 0.23704687, 0.1593781, -0.551969, -0.37552488, 0.3415205, -0.057338074, 0.31696308, -0.9219501, -0.40109023, 0.44294283, 0.2019858, -0.6737923, 0.049942933) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.021736728, -0.16611709, -0.24140331, 0.052724905, -0.01852773, -0.39035785, -0.21018042, -0.636355, -0.18477777, 0.30569842, -0.82551324, -0.06650124, 0.15613538, -0.31754917, -0.115557946, 0.22696911) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03001284, 0.28417984, 0.0980987, 0.018430404, -0.022299869, -0.18707895, 0.036553822, -0.070616, 0.020840334, 0.048989493, -0.04560782, -0.13446297, 0.06605926, 0.18535636, 0.16781549, -0.013434851) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.27345544, 0.2542775, 0.029302265, 0.18762143, 0.0104903905, -0.18577747, -0.19212466, -0.27875748, 0.11985081, 0.03738945, -0.16525373, -0.43759924, -0.054104123, -0.16988407, -0.15565093, -0.11225673) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08155239, -0.24971311, -0.08308166, 0.11290683, 0.08937634, -0.10266078, -1.0012305, 0.1572375, -0.076177254, -0.42342773, -0.42532432, -0.12303726, 0.058506772, -0.051030204, -0.16078097, 0.13416147) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08854572, -0.13977224, 0.23401213, 0.05679903, -0.016556663, -0.020921241, -0.13729768, 0.15075225, 0.009533548, -0.18871406, -0.3906402, -0.2957846, 0.08006741, -0.094602264, -0.0892762, 0.051931627) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.41860256, 0.071888, 0.32991543, 0.04814135, -0.09525517, 0.03393434, 0.096754946, 0.1559515, -0.0045153205, 0.041581597, -0.011403434, -0.0009670556, -0.040569298, 0.11336308, 0.24411887, 0.16539948) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.014785871, -0.021954577, 0.20213759, 0.038508113, -0.03747002, 0.117679685, 0.44348237, 0.16109331, -0.120813146, 0.06161559, 0.10327722, -0.092333, 0.029963413, -0.07450062, -0.101630025, -0.10774384) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14333902, -0.25079504, -0.12195845, -0.1267124, -0.09537071, -0.13243271, 0.07250303, -0.014866665, -0.035764772, -0.18940064, -0.09383061, -0.17854653, -0.08515863, -0.1499195, -0.12640136, -0.05177804) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.07526438, 0.08626085, -0.20949672, -0.22427285, -0.113583416, -0.98693717, 0.35934317, -0.534573, 0.036033813, 0.29237953, 0.8819114, 0.042472478, 0.29115504, -0.2734992, -0.6279762, -0.7123769) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.056203157, 0.20546791, 0.048915446, -0.26629043, 0.092194006, -0.34088168, -0.32282135, 0.31622943, -0.16534197, 0.17939405, -0.0033503494, -0.14042607, -0.020964254, -0.54099625, 0.06612638, -0.38706362) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.096655615, 0.23459199, -0.15861948, 0.09366004, -0.07903558, -0.012219866, 0.083097614, 0.11062151, 0.069065884, 0.058422316, 0.11967599, 0.24065901, 0.1306945, 0.28900275, 0.0121310325, 0.06818648) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17645782, 0.17929758, -0.20853317, 0.17162304, -0.047586173, 0.11881544, 0.25226915, 0.22672808, 0.14755821, 0.2204594, 0.20423168, 0.17952561, -0.41176283, -0.43325114, 0.17642765, -0.5128948) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16883485, -0.15275691, 0.043253418, -0.032643106, 0.116187416, 0.27727535, 0.19826166, 0.07679035, -0.024257716, -0.123589434, 0.12294208, -0.11420965, 0.15288621, -0.1358311, -0.12480438, -0.027030976) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

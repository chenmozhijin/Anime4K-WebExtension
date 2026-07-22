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

  var result: vec4f = vec4f(0.03152622, -0.057936355, 0.17022252, 0.10429973);
      result += mat4x4<f32>(-0.028934022, -0.097699, 0.14497884, -0.19607249, 0.030027868, -0.06893444, -0.07890377, 0.17148197, 0.15085335, -0.065115005, 0.033031568, -0.11080225, 0.03914685, 0.18203524, 0.0011956885, 0.19316892) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.027203169, 0.11194109, 0.053026073, 0.16726257, 0.10597134, -0.12395555, 0.124561876, -0.15636855, 0.029997146, 0.15703617, 0.049083937, -0.035877246, 0.029578095, 0.23864427, 0.02586424, 0.2532038) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05725763, -0.17105044, 0.2727739, 0.10116327, -0.02265962, -0.1126662, 0.11592093, 0.10047769, -0.014336777, 0.027406191, 0.018717922, -0.09456944, 0.028751595, 0.25493068, -0.0373274, 0.30932453) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0086834915, -0.16441232, -0.36111757, -0.31958678, -0.024087425, -0.17424534, -0.5374105, -0.0677099, 0.10265686, -0.3101469, -0.23488693, 0.25212926, -0.05560591, 0.1659031, 0.06676093, 0.2665547) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.083628155, -0.31956506, -0.1412888, -0.3788492, 0.23230502, -0.4218641, 0.1404404, 0.07443524, 0.2073691, -0.33248368, -0.031430695, 0.35679576, -0.16534199, 0.45138133, -1.0450552, -0.042607192) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.25897348, -0.42421824, 0.25602025, 0.24996217, -0.2496222, -0.36247912, -0.046998996, 0.13329291, -0.052185655, 0.006912423, 0.16915269, 0.37345335, -0.16162108, -0.06974653, 0.14377367, 0.10643808) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08688157, -0.1345922, -0.059911974, 0.04843438, 0.024197038, 0.05310436, 0.20227589, 0.10339677, -0.17224915, -0.21022291, -0.07550345, -0.043558057, 0.16199537, 0.09285545, -0.009726752, 0.01949683) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18718278, -0.2685012, -0.005860524, -0.25582674, 0.013271747, -0.057271317, -0.104153275, -0.00043085724, -0.081742205, -0.12724406, -0.1060043, -0.06762429, -0.052824296, -0.21032642, -0.3224243, -0.32888424) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19356775, -0.07802458, -0.05531841, 0.19070998, -0.07810202, -0.08555697, -0.05632098, 0.0482775, -0.18756561, -0.14545459, -0.052674253, 0.16045077, 0.07893744, 0.19552444, 0.040350925, -0.19894217) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.041419867, -0.017472886, -0.12694637, -0.31271508, 0.05115224, -0.18136533, -0.6088166, -0.065934524, -0.05528902, 0.17940362, 0.11082786, 0.09406652, -0.17270212, -0.13206474, 0.028133074, 0.015815629) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21909493, 0.20031382, -0.40374795, -0.3136233, -0.0014754266, -0.19012453, 0.9445351, 0.8182498, -0.15770945, -0.14112853, -0.19050689, -0.35311532, -0.16638231, -0.44336584, 0.13477457, -0.1872497) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0811288, -0.0641937, -0.057760358, -0.016296089, -0.23214185, 0.24076845, 0.35808817, -0.07983602, 0.1902066, 0.102183774, 0.01641324, -0.21427979, -0.007535847, -0.18544444, -0.182105, -0.23766363) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.13213533, -0.08727632, -0.24319308, -0.2585619, 0.029030489, 0.2683715, 0.15834719, -0.31254712, -0.09652212, 0.38414228, -0.08946017, 0.26351428, -0.12513456, -0.23839007, 0.06696003, -0.24747656) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.326084, 0.14273055, -0.10654471, -0.61069757, -0.16758792, -0.022872442, 0.123861276, 0.11715498, 0.13994962, -0.46542412, -0.037267096, 0.12262324, -0.64042664, -0.44145527, -0.289462, 0.6724131) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.022928234, 0.109772705, -0.09501072, -0.14956756, -0.11217423, -0.12060582, 0.0019468684, 0.4012285, 0.029503837, 0.041855555, 0.040137585, -0.11388331, 0.1141942, 0.109310046, -0.029947205, -0.4104527) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07323968, 0.20288463, -0.02477881, 0.028041633, 0.0012929355, -0.06757749, -0.030523384, 0.112270996, -0.08937928, 0.20460305, -0.12376955, 0.06574044, 0.009395764, 0.08857988, 0.024691604, -0.094241574) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16090128, 0.12973145, 0.062657945, -0.072564155, -0.15579827, -0.03829455, -0.021280475, -0.008382006, 0.008035296, 0.018723248, 0.07476332, -0.1336152, -0.08405126, 0.14529255, -0.056585226, -0.10629419) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03321627, 0.17732884, -0.016300986, -0.13289085, -0.103585534, -0.079563685, -0.03857667, 0.119676374, 0.06405851, 0.03919678, 0.116530396, -0.26016647, -0.021534918, -0.072239, 0.049581163, -0.07338768) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

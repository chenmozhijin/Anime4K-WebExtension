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

  var result: vec4f = vec4f(0.23376471, 0.00043209287, 0.23823607, 0.05118317);
      result += mat4x4<f32>(0.14776641, -0.07568697, -0.2273693, -0.026167296, 0.021168718, 0.022349533, -0.24033892, 0.07231981, 0.02293576, -0.11961336, 0.16265564, 0.20941484, 0.041067574, -0.026650865, 0.22640924, 0.2681773) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1816918, 0.0080448445, -0.034384035, 0.3721913, 0.46330413, 0.03339463, -0.23233166, -0.003203956, 0.11260634, 0.05199887, 0.07076722, 0.030358009, -0.10304376, 0.10638253, 0.003592219, -0.082845666) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.033894435, 0.04824694, 0.0015360746, 0.32669148, 0.040790133, -0.040996514, -0.07608247, -0.020008244, -0.0009565497, -0.1550126, 0.02171453, -0.1828865, -0.14891937, -0.068631746, 0.04370724, -0.10173178) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1914947, 0.13654909, 0.080475956, 0.13568105, 0.2260229, -0.16453624, -0.3048439, 0.28221345, -0.5040222, 0.09767621, 0.102451295, -0.025661515, -0.46287802, -0.17570584, -0.1920483, 0.41881412) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7235624, 0.14337292, -0.16786313, -0.037336577, -0.21201551, -0.10002606, 0.29396296, -0.44319496, -0.12641977, -0.056325346, -0.2943066, -0.051725432, -0.3634286, -0.05094165, -0.5757707, 0.28669858) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.048641726, -0.025382742, 0.09654405, 0.21824373, -0.23739274, -0.004273849, 0.093629576, 0.07703272, -0.09123666, 0.14099048, 0.16053087, 0.06716903, -0.716037, 0.05375656, -0.0063672, 0.24221906) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.19566205, 0.036191463, 0.19856775, -0.066609934, -0.10726653, -0.041662566, -0.30333412, 0.18908247, -0.04122514, 0.07549475, -0.010635042, 0.27550527, -0.16228837, 0.017379025, -0.096373536, 0.23289315) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.21181843, 0.059815064, 0.17717892, -0.17345765, 0.14306517, -0.08343962, -0.06359231, 0.0763668, 0.1346421, -0.090183705, -0.3727612, 0.14799756, 0.39895034, 0.08593099, 0.06558138, 0.3149039) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.051901527, 0.0622644, 0.017743956, -0.039829087, -0.03943643, -0.01975697, -0.16305341, -0.056805346, 0.074920356, 0.18957086, 0.19661072, -0.04257505, -0.029857656, -0.030530322, 0.073271096, 0.07277134) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.31781313, 0.04689191, 0.20112433, -0.16434218, -0.05915719, -0.18403554, 0.053923998, 0.03299991, 0.004329057, 0.15011783, 0.035346996, -0.12063008, -0.049579058, -0.047948927, -0.2835311, 0.1502917) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16393383, -0.018488303, 0.08334912, -0.13475586, 0.1387106, 0.08123284, -0.20954303, 0.10434594, -0.027523434, 0.068394125, -0.01869072, -0.17825341, -0.18390127, 0.04003442, -0.08662326, 0.0031235479) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02943204, 0.044034597, 0.042780783, 0.031579234, -0.057418007, 0.106288835, -0.17216562, 0.09427815, -0.14647242, -0.049268242, -0.008332865, -0.3294482, -0.08821347, -0.034183796, -0.011636543, -0.20090574) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5599465, 0.121969596, 0.082662836, 0.13916475, 0.14464208, 0.12963523, -0.019517085, -0.27575985, -0.025162145, 0.07620956, 0.065895945, -0.08143775, -0.37124005, 0.07898843, -0.077373825, 0.05517749) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.758757, 0.21495466, 0.107105136, 0.026834048, -0.059370395, -0.029562332, 0.06316213, -0.30232587, 0.39600828, -0.14120944, -0.2329491, -0.3985931, -0.48096162, 0.2862572, 0.14216226, 0.17200063) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06749431, 0.029156497, -0.03447022, -0.12241504, -0.03569438, -0.21290384, -0.2914203, -0.5375774, 0.33369702, -0.075274415, -0.07244789, -0.0067956196, -0.24181683, 0.03635672, 0.15036729, -0.055404946) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.018471258, 0.017086405, 0.0017142274, 0.0041230093, 0.033349358, 0.14836724, -0.061230134, 0.14853537, 0.033800244, 0.13939063, 0.16293977, 0.023038696, -0.3472438, -0.034833085, -0.26923975, 0.027234817) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19855495, 0.09932657, -0.027586984, -0.070214614, 0.57765114, 0.12187464, -0.51501054, -0.1871049, 0.113317326, -0.0016507625, 0.30569458, 0.0025552872, -0.41824803, -0.05983845, -0.33617187, 0.10999288) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09251789, 0.06628506, -0.006386388, 0.03959591, 0.010496694, -0.14041123, 0.1336495, -0.20365591, -0.18576467, 0.09058255, 0.2018152, 0.08647773, 0.06612788, 0.016539183, -0.16091518, -0.059829745) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.43448642, -0.12301044, 0.3757074, -0.3521034);
      result += mat4x4<f32>(0.044429187, -0.0813524, 0.16548583, -0.050070707, -0.13377567, 0.041579593, 0.023483705, -0.003970342, -0.11314434, 0.025684642, -0.018379988, 0.028405111, -0.19673564, 0.0781857, 0.025285812, 0.0536629) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20035718, 0.010654955, -0.025436297, -0.06046927, -0.0073727444, -0.13871646, -0.34683388, 0.10650107, 0.0029657218, 0.01440416, -0.037941318, 0.00091534056, -0.037708573, -0.2056659, 0.054230556, 0.008830925) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03133968, -0.0115914475, 0.062664755, 0.0043546692, 0.011099756, -0.082215466, 0.080366865, -0.1383988, 0.20968637, -0.00040026082, -0.02845496, -0.011799935, 0.3143607, -0.053114355, -0.04023105, -0.042476367) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.029057013, -0.004716099, -0.36459056, 0.034187518, -0.13796155, -0.062616594, 0.27369875, 0.096242316, 0.106147945, -0.13376759, 0.11996597, 0.01636166, -0.012851211, -0.06911231, 0.24053474, -0.06008759) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4238511, 0.40790135, 0.36323127, 0.22751747, 0.14122531, 0.064023525, -0.31166032, 0.11797803, 0.34092152, -0.2198629, 0.026304025, 0.090427294, -0.16464159, -0.017290624, 0.01445886, 0.37553132) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13427737, 0.11364063, 0.22525027, 0.062314354, 0.4571471, 0.40817827, -0.12401452, -0.17091729, -0.21297123, 0.031742137, -0.13643599, 0.07007187, -0.07155568, 0.30824044, 0.16148213, 0.0927721) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.24306771, -0.13982521, 0.09935935, 0.045479227, 0.11031775, -0.0042111687, -0.107983, -0.049149856, 0.31685653, -0.074452005, 0.30677456, -0.1064963, -0.06114917, -0.027268127, 0.28759167, 0.06594111) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2070719, 0.051282544, 0.049482815, 0.015694693, 0.004993463, 0.03197803, 0.051559445, 0.0010350154, 0.01410357, -0.6191488, 0.6506191, -0.39605913, -0.23776342, -0.22023737, 1.0673069, 0.5584359) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.13599722, 0.22474402, -0.04141426, 0.032831017, -0.19017899, -0.09055012, 0.24022336, -0.005660453, -0.21465558, 0.2449891, -0.6636034, -0.04271815, -0.2544421, 0.14973763, 0.3659803, 0.063061915) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.063997544, -0.035338532, 0.032344542, -0.060154554, -0.015810937, -0.17813855, -0.037186947, 0.0076695182, 0.00428411, 0.056652397, -0.031242952, -0.031606574, 0.0009011647, 0.08937263, -0.07147258, -0.046398938) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.17675333, -0.009462434, 0.15948634, -0.050632544, -0.31482634, -0.0677272, 0.10743205, 0.123599015, -0.05084866, 0.020532534, -0.040988892, -0.0014473236, 0.043873664, -0.11458243, -0.040164027, 0.04388304) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.111753985, -0.111910224, 0.021526538, 0.015475662, -0.038453825, 0.037777744, 0.20258789, 0.060060803, 0.042400844, -0.048840992, -0.07269839, -0.027672166, -0.013730072, 0.030265907, -0.04114383, 0.0004235512) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.268568, -0.048765272, 0.067760944, 0.08662163, 0.2393454, -0.07255824, 0.51970714, 0.35031977, 0.18046151, 0.1586442, -0.24722368, -0.08014777, 0.23254555, -0.14392082, -0.0041665314, -0.054528728) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.39537156, 0.3739928, 0.008720565, 0.44200203, -0.15353307, -0.14068292, 0.49094394, 0.13642006, 0.05309363, -0.10205546, -0.07481765, 0.037899535, -0.6012495, -0.45016366, -0.12592962, 0.08062373) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.5642316, 0.08633449, 0.39919204, -0.009009271, -0.085648045, 0.07559612, 0.2666569, 0.016159013, 0.10826249, 0.019715056, -0.12416943, -0.08499299, -0.28791842, -0.1760217, 0.087832965, 0.0946587) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04832181, -0.017099064, -0.1467091, 0.006050375, -0.14698866, -0.036004696, 0.13033454, 0.07317707, 0.06470946, -0.00066081196, -0.1518912, -0.051236883, 0.024186872, -0.011763246, 0.07771399, 0.010662357) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19324113, 0.30161825, 0.26539493, 0.03651584, -0.046501495, 0.20355143, 0.25213662, -0.020150473, 0.18362345, 0.014891113, -0.2539255, -0.11699597, 0.042189356, 0.11168467, -0.22878307, 0.019116621) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.16789116, 0.043443233, 0.07780937, 0.08148886, -0.055409048, 0.023361264, -0.0021695758, -0.016912064, 0.10056452, -0.03153345, 0.089432664, -0.06315867, -0.22232667, 0.18944919, 0.25092164, 0.19168995) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

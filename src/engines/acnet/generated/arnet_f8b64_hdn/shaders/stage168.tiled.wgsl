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

  var result: vec4f = vec4f(0.21041249, 0.1603454, -0.0050781397, -0.14685507);
      result += mat4x4<f32>(-0.4569729, -0.0790362, 0.2678385, -0.3212481, -0.13560122, -0.022361254, 0.014109227, -0.122706495, 0.0355708, 0.5159162, 0.6113981, -0.4524581, 0.24687551, 0.041960653, 0.15471658, 0.9836718) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.01453469, -0.1254665, -0.13552833, -0.03302307, -0.061891634, -0.22417521, -0.1077264, -0.2914812, -0.0059778336, 0.17545694, -0.010859092, -0.33296457, -0.014289632, 0.034417745, 0.080511324, 0.017185828) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08073994, 0.022049535, 0.14860083, 0.066030405, -0.002523704, 0.0035593046, -0.018196778, -0.1010773, -0.17745572, -0.4577029, -0.53683317, -0.53858364, -0.13351977, 0.5132446, 0.37897453, -0.7741596) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.114964366, 0.07679561, 0.064694755, -0.1982269, -0.10623064, -0.102965586, -0.0385851, -0.20533703, 0.042042226, 0.39513448, 0.5155524, 0.4363328, 0.11000659, -0.18133706, -0.036597434, 0.9974415) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.30873954, -0.050738838, -0.43686023, -0.20472099, -0.29012325, -0.2841682, -0.3299308, -0.32874304, -0.010124097, 0.08413176, -0.20098951, 0.3953376, -0.07393016, -0.08036583, 0.07338464, -0.4959612) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.067903586, -0.014629984, 0.009042562, -0.012112479, -0.118584156, -0.08465216, -0.1554294, -0.46492928, -0.099409185, -0.6288699, -0.48379028, -0.16529626, -0.044079937, -0.07687073, -0.055651087, -0.60237736) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.19933653, 0.07314703, 0.1601307, -0.14628217, -0.030267779, -0.029257482, -0.0019175017, -0.15868393, 0.11482901, 0.35076308, 0.63670987, 0.35336414, 0.21870422, -0.3848878, -0.3617094, 0.8275254) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09923805, -0.022338869, -0.024974244, 0.051717963, -0.010441892, 0.028142544, -0.13597208, -0.2216724, -0.064007826, 0.06548075, 0.061990328, 0.2162708, 0.0058482545, -0.06752354, -0.22974023, -0.22771364) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.063015, -0.00865958, -0.002596091, -0.031105416, 0.050171133, -0.08436779, -0.11465228, -0.24195862, 0.18751426, -0.4965838, -0.5801665, 0.13803397, -0.3209892, 0.28433603, 0.05023043, -0.84176993) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.065276526, 0.020467501, 0.07493061, 0.023222584, 0.06343828, -0.011567154, -0.064531706, -0.049379878, 0.118311144, -0.15759075, -0.17056224, -0.0144008035, 0.20919847, 0.024470385, -0.6296818, 0.73621243) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.018343048, 0.10001235, 0.09575671, 0.2246906, 0.07151645, -0.116852164, -0.20333399, -0.33091754, -0.07654731, -0.010176728, -0.09066353, -0.5205214, 0.104645185, -0.056327492, -0.1133929, 0.14689294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06552885, 0.03734577, 0.047836024, 0.027532289, -0.034889713, -0.040069565, -0.03775565, -0.08105806, 0.15943004, -0.10252492, -0.09442067, -0.08766403, -0.13593085, -0.031685594, 0.09817135, -0.14622627) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.12173688, 0.060225125, 0.19009882, 0.1802518, 0.008725155, -0.12057033, -0.16593191, -0.2794269, -0.21101554, -0.03876199, -0.18320869, -0.29159784, 0.038614914, 0.15756468, -0.021675378, -0.18001282) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.112256326, 0.24549921, 0.2974356, 0.5665404, -0.1474262, -0.19061707, -0.22292693, -0.44499496, 0.0077189975, -0.23717245, -0.51302123, -0.3529243, -0.09189342, -0.18632486, -0.08394613, 0.0324513) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13632946, 0.11522805, 0.08441397, 0.23652041, 0.04116551, -0.04603104, -0.047639415, -0.1483142, 0.028282084, 0.119126886, -0.026565256, -0.37929538, 0.07357599, 0.020195896, 0.13039105, -0.041700084) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.038119424, 0.108431436, 0.12048977, 0.04466977, -0.053652767, 0.013421365, 0.021360781, -0.015987461, 0.014099667, 0.021533635, -0.0060355416, -0.1762568, -0.06648381, 0.02198886, 0.09519042, 0.007324744) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.049621638, 0.106448025, 0.117583916, 0.3620796, -0.07638255, 0.010498692, 0.07197552, -0.25109193, -0.13996391, -0.019016862, -0.1829434, 0.021092683, -0.021696609, -0.10175432, 0.10568451, -0.030854017) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.015867595, 0.16678767, 0.110306956, 8.12494e-05, -0.054823443, -0.03396019, -0.020883845, 0.025853688, -0.05557086, -0.037338443, -0.074262075, -0.09005107, -0.050398808, 0.039169986, 0.36406565, -0.29509288) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

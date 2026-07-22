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

  var result: vec4f = vec4f(0.14977093, 0.038938046, 0.09887464, 0.28025684);
      result += mat4x4<f32>(-0.13319103, 0.034618407, -0.065354355, -0.04034084, 0.13858452, 0.07379494, -0.040203117, 0.113772474, 0.100330696, 0.16549654, -0.08308999, 0.09987923, -0.11700393, 0.11229274, 0.0049040033, 0.040687684) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.029267116, -0.114938684, -0.04897295, -0.0045336187, -0.06136154, -0.07542154, -0.18351902, 0.14597762, -0.07500846, -0.023148045, -0.32809827, 0.12477909, -0.004514225, -0.21932606, 0.29382634, -0.16054235) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.10495237, 0.029338444, 0.1494566, -0.16561653, -0.01790419, 0.1052806, -0.28456, 0.12536135, 0.07377994, 0.068919666, -0.08262307, 0.12358875, 0.052679267, 0.16080141, -0.20259406, 0.15139186) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.053630017, -0.1351086, -0.2599506, 0.20700385, -0.1298429, 0.12636371, -0.1252989, 0.06454002, -0.08179213, 0.15608422, 0.27091032, 0.03321514, -0.24879928, -0.17181997, -0.4798739, 0.017601032) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12518315, 0.12308972, -0.22282429, 0.026231166, -0.09611773, 0.63053393, -0.12358328, 0.0067208586, -0.09128277, 0.7211746, -0.6170645, 0.42931908, 0.09697697, -0.14528856, -0.09996794, -0.33573285) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.050194535, -0.057746492, -0.09501323, -0.08098361, -0.15494041, -0.22919738, 0.15643312, 0.14952521, 0.15630738, 0.1608072, -0.038552925, 0.06679973, -0.10075555, 0.3783927, -0.3799414, 0.46596882) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2776695, -0.17073026, -0.23885965, -0.032601718, -0.0153360395, 0.06927716, -0.0284566, -0.00070167496, 0.12696745, 0.30119947, 0.253662, 0.033045687, -0.21043433, -0.08548014, -0.20372176, 0.046915274) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09436104, -0.15858695, -0.26304007, -0.017949902, 0.041999202, 0.14028645, -0.010167972, 0.20496842, -0.18819205, -0.15180817, -0.36171654, 0.47374475, -0.013296787, 0.43165785, 0.0613711, -0.22978705) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08203777, 0.0908215, 0.13445817, -0.14180727, 0.17368437, 0.13583365, 0.05990064, -0.047444146, 0.10422418, 0.28792372, -0.20090704, -0.09295799, 0.046477467, 0.016721018, -0.07253278, 0.09709557) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1944626, -0.25573486, 0.03556255, -0.2833065, 0.10212323, 0.27704507, -0.00804926, -0.013514093, 0.080640346, 0.0016963274, 0.068850294, 0.08191725, 0.14884584, 0.18426944, 0.03616308, 0.07775985) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.19358043, 0.093918785, 0.25245544, -0.075295106, 0.21274512, 0.09532914, -0.2435208, 0.34187034, -0.013448955, 0.12792175, -0.06296466, -0.019623872, -0.08329431, -0.033587176, 0.03542107, -0.27623454) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.037029676, -0.051660903, -0.16294834, 0.14242722, -0.20215353, 0.09503307, -0.14728077, -0.22157569, 0.11975673, 0.17177981, 0.045353506, 0.054502383, -0.012815494, 0.07977467, -0.10915111, 0.05362371) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07448089, 0.03757236, 0.11375863, -0.17428331, -0.15346915, -0.10738707, -0.003064746, 0.18967229, 0.20827161, 0.30790734, 0.14622432, -0.02896669, 0.028950946, -0.14943075, 0.19944845, -0.14538456) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07433811, 0.07154696, -0.36631683, 0.117870785, -0.22382721, -0.45941493, 0.20636824, 0.18098879, -0.038310252, -0.30079848, -0.14487624, -0.33583227, 0.07617601, -0.65710956, -0.104457796, 0.20543608) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.03324158, 0.44027898, -0.35508057, 0.1612837, 0.24184008, 0.052161552, 0.089592606, -0.3090891, 0.25591186, 0.21722844, -0.648741, -0.057270814, 0.015049771, -0.14705186, 0.12362309, -0.0669587) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.056236792, 0.03466667, 0.29326737, -0.15192543, 0.090019986, 0.17376232, 0.07500789, 0.039380953, 0.05843424, -0.01407648, 0.3280138, -0.036866494, -0.020165406, -0.012415323, -0.05870947, 0.033742234) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.31384304, 0.023639934, -0.64938474, -0.046491615, -0.21040422, -0.12052702, -0.061555706, 0.33112377, -0.1676452, -0.3498248, -0.46842387, -0.06596027, -0.030346572, -0.063012905, -0.16888654, 0.16603793) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12696722, 0.17483461, -0.031371072, 0.03581925, -0.05157205, -0.04258072, 0.21792479, -0.14026871, -0.023188071, 0.060157157, 0.00955249, -0.3300408, 0.09880167, -0.07628519, 0.34021407, -0.09789155) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

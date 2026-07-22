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

  var result: vec4f = vec4f(-0.066350706, 0.07368067, 0.0881174, 0.08211409);
      result += mat4x4<f32>(0.025288844, 0.044436976, 0.030839307, 0.063705, -0.020459864, 0.12022376, 0.01818546, 0.11472623, -0.00053144817, 0.051172044, -0.060000326, -0.09308792, -0.07245052, 0.10521892, -0.04689771, -0.17922328) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0055916663, -0.10000242, -0.06106412, -0.14660932, 0.06195672, 0.42232955, 0.19925648, -0.10684599, 0.053620026, 0.13921852, 0.058512066, 0.06457063, 0.05362257, 0.051386915, 0.03516277, 0.0033074636) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.058838125, 0.04456103, 0.0848342, 0.13711338, 0.15510796, 0.07713527, 0.017001411, -0.11404577, -0.08759715, -0.23340397, -0.1182061, -0.055413205, -0.0018647141, 0.028259587, 0.014483434, -0.034599803) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.012405509, 0.122604765, -0.05519147, 0.17520201, 0.08416394, 0.47046983, 0.06514699, -0.002105851, -0.056465, 0.14995903, -0.006738816, -0.23880959, -0.12815906, 0.07525983, 0.02758307, -0.47976935) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.54642016, 0.11822773, -0.5448241, 0.063148536, 0.110415705, -0.17916955, 0.3914876, -0.24877071, 0.37649205, -0.72470117, 0.37061265, -0.44882968, -0.45035073, 0.18384542, -0.03441672, 0.40915155) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07596728, -0.11264269, -0.103946306, -0.042703975, 0.039522808, -0.28083515, 0.10203342, -0.26367322, 0.17465253, -0.002531664, 0.042450927, 0.1925562, -0.032372728, 0.027474996, 0.062692024, 0.049981244) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.016939973, -0.14801063, -0.09312476, -0.1538431, -0.014757356, 0.022619393, 0.03696187, -0.024094673, -0.08027241, 0.06466125, -0.092843495, -0.112809666, 0.10482655, 0.23875858, 0.016173443, 0.3260556) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.011533503, 0.06064052, -0.055330575, -0.0036261987, 0.05867729, 0.15131633, 0.01907224, 0.105974145, -0.050680894, -0.22693944, -0.1290916, -0.23810545, -0.038740646, 0.12579113, 0.118483305, -0.32612973) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0038977647, -0.005545298, 0.026978372, 0.09002558, -0.014936329, 0.205918, 0.055401452, 0.104707286, 0.017998597, -0.2567532, -0.13259842, -0.15987155, -0.04582219, 0.073310636, -0.034837533, -0.09224891) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.05879919, -0.0770417, -0.09976864, -0.11717666, 0.006659909, -0.018820364, -0.026043558, -0.005062583, 0.029040527, -0.061404362, -0.06356554, -0.081489466, -0.050777525, 0.006482288, 0.011762535, -0.004719817) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06261235, 0.35928625, 0.3677568, 0.27658308, -0.042608302, -0.4417266, -0.08490508, -0.13540111, 0.06983036, -0.25314653, -0.0834739, 0.051016804, -0.036682166, -0.04595448, 0.014521922, 0.18494752) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.028454982, -0.12239838, -0.18726522, -0.31538752, -0.40076265, -0.10394109, -0.03787154, 0.26330692, 0.029673768, 0.25331357, 0.12112479, 0.1202569, -0.14284976, -0.06622175, 0.0050251274, -0.111446016) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07605056, 0.051121578, 0.04673769, 0.21716455, -0.11355301, -0.0924708, -0.07314471, -0.097163744, 0.010356201, 0.31551477, 0.06516969, 0.02470085, -0.06463665, -0.287409, -0.06086362, -0.05256679) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.01332656, 0.11205514, -0.119588666, 0.08352764, -0.07381462, -0.0109022735, -0.24053162, -0.42658633, 0.31943548, -0.14473625, -0.33054474, -0.41851655, -0.10451712, 0.5366745, -0.4738586, 0.07537096) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.16987786, 0.1734135, 0.19976743, 0.26085615, -0.05286786, 0.12222301, 0.054455422, -0.07740963, -0.14123742, -0.23749232, -0.053335536, -0.018097425, -0.31373322, -0.0869999, -0.105827674, 0.63060266) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0067676655, 0.100331984, 0.024937883, 0.06968947, 0.008313957, -0.092024766, -0.06059944, -0.07739833, -0.0755753, 0.1701699, -0.038836643, -0.12159534, 0.018959869, 0.031556673, -0.024321446, -0.064511515) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10083337, 0.26278672, 0.14194728, 0.22565812, -0.004578731, -0.2978598, -0.057946756, 0.0044352515, -0.07651837, -0.3195578, 0.033722024, -0.41831943, 0.017400412, -0.0032383958, 0.11330097, 0.07885255) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08461481, -0.12138806, -0.027358001, -0.009460219, -0.07722613, 0.24296339, 0.057215944, 0.0021226439, 0.010618373, 0.03544177, -0.1001402, -0.0045212046, 0.022332314, -0.039788224, -0.0051459745, -0.04320647) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

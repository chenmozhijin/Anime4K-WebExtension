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

  var result: vec4f = vec4f(0.17113289, 0.29877505, 0.2518935, 0.3389783);
      result += mat4x4<f32>(0.17033254, 0.06525583, -0.36800247, 0.22083633, -0.28074113, -0.079446584, -0.09871622, 0.17880382, 0.017009135, -0.056500517, -0.1452067, -0.16592915, -0.036317445, 0.11996889, -0.1432207, -0.0761433) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.5845676, 0.008874421, -0.17744724, -0.15627539, -0.03057265, -0.25563964, -0.11569067, -0.09056159, -0.1822086, -0.4375577, 0.15663216, 0.07781032, -0.16073085, 0.16962855, 0.11132336, -0.45816794) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.353528, -0.015498707, -0.26579425, -0.10771055, 0.09422553, -0.10175217, -0.34260672, 0.16306111, 0.10730044, 0.070865825, -0.15037927, -0.1340522, 0.10908013, 0.017712422, 0.010338717, 0.2945257) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.010191207, -0.19092202, -0.44655052, 0.45046097, -0.061863966, -0.103292875, -0.24107017, 0.042825043, 0.06292964, 0.39112023, 0.13274805, -0.4560078, -0.27904594, -0.28135994, -0.18474977, 0.50916225) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.06818749, -0.24047694, -0.124480546, -0.08027593, -0.061307553, -0.16896282, -0.3540884, -0.584871, -0.24382947, -0.11756491, -0.11002091, 1.0577074, 0.024024747, 0.1703689, -0.50539935, 0.4277181) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.51277196, 0.19440262, 0.66284996, 0.06930867, -0.07501052, 0.19970068, 0.20063418, 0.14837465, 0.39935654, -0.07145085, -0.2059454, -0.4202058, -0.049550194, -0.0814923, -0.29348585, 0.016989725) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.23043449, 0.2781869, -0.35847855, 0.16827649, -0.18345955, 0.25281426, -0.118719384, -0.0062041, 0.026434787, -0.029489307, -0.057383955, -0.0077974326, -0.34199947, -0.16608247, -0.14623393, 0.24263263) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17868066, -0.064883135, 0.17194104, 0.037135996, -0.0404848, -0.27350792, 0.057369582, -0.025777685, 0.029525736, 0.035591107, 0.14601476, -0.09665602, 0.16858774, -0.18178771, -0.894129, 0.768353) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.46242556, 0.17100398, -0.07784203, -0.29446465, -0.11111003, -0.04519806, -0.23320283, 0.16351567, 0.082906775, -0.02829384, 0.07651179, -0.046925727, 0.5733426, -0.18298072, -0.65906346, -0.25168675) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2790495, -0.014593367, 0.16730705, -0.04422068, -0.3366422, -0.15818682, -0.07039883, 0.041248232, 0.2796717, -0.24261612, -0.1600321, 0.04523927, 0.11164549, 0.07825773, 0.24737085, -0.2056608) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.2971189, 0.08842193, -0.22357138, 0.48398337, 0.020401938, 0.023373602, -0.4301271, 0.05859348, 0.12782674, 0.104972646, 0.07533528, 0.020360447, -0.32711416, -0.17166923, 0.23148276, -0.0380377) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.22812776, -0.041223057, -0.11655987, -0.054805927, 0.013767505, -0.10550788, -0.20240349, -0.16803928, -0.08319787, -0.09606276, 0.1403519, -0.1415296, 0.11299933, -0.067543074, 0.06789025, -0.20671135) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14267999, -0.23353657, -0.27708256, 0.3161591, -0.27287102, 0.05665276, -0.5591818, 0.95891124, -0.15213493, 0.103723235, -0.31117284, -0.27011815, 0.2188241, -0.2601069, -0.005784131, 0.2867729) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24663088, -0.15303922, -0.76924497, 0.2246398, -0.013457501, -0.06543099, -1.1070105, 0.1626653, 0.47147936, -0.0046444866, -0.51881725, -0.14302649, 0.18965204, 0.13224931, -0.09845407, 0.06964605) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14712945, -0.13395351, -0.07399597, -0.099948734, -0.052480288, -0.06797137, -0.4045774, -0.22755803, 0.23833781, 0.1402991, -0.20480728, 0.028356174, -0.043062314, 0.0012037216, 0.34646404, -0.050550707) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.012010531, 0.1168664, 0.13682157, -0.12173582, -0.35522062, -0.1516331, -0.030226894, 0.30549553, -0.26807702, -0.23035875, -0.17286976, 0.11987746, 0.22704706, -0.053046968, -0.06569883, 0.2510323) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12150889, -0.00046892068, -0.23444825, 0.020607442, 0.16303058, -0.086272836, -0.26172125, 0.30552682, 0.60831517, -0.007188563, -0.4389024, -0.14288197, 0.005320733, 0.54000723, -0.22922394, -0.09883928) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.055310927, -0.08159802, -0.0386946, -0.006502716, 0.1780444, 0.01883734, -0.10183556, -0.008358218, 0.47325867, 0.0123502705, -0.20074017, 0.03259228, -0.041582886, 0.15315148, 0.04346862, 0.041718345) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.1491138, 0.1405558, 0.042756405, -0.07210539);
      result += mat4x4<f32>(-0.08026778, 0.21634823, -0.1163571, -0.107115895, 0.15265848, 0.010385106, -0.102181286, -0.22573483, -0.63394135, -0.48367283, -0.059798304, 0.22720148, 0.10413817, -0.15456323, -0.25543842, -0.36084023) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0651158, -0.025922703, -0.3663767, 0.53721285, 0.2145342, -0.21627535, -0.059367802, -0.05199443, 0.09306327, -0.5648328, -0.44354457, 0.39281785, -0.002715025, -0.091769524, 0.19799298, -0.008420261) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.23472203, 0.117413424, 0.09521846, 0.22838917, 0.019577092, -0.30112457, 0.13439073, 0.0009605685, 0.30373183, -0.456175, -0.071365885, -0.739434, 0.07667019, -0.30589792, 0.33035916, -0.05663711) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.01295836, -0.42141792, 0.08292748, -0.7591875, -0.054456368, -0.24035327, 0.036089726, -0.09521086, -0.35834995, -0.2815314, -0.33441275, 0.2142312, 0.020152716, -0.27834398, -0.08706857, 0.32613355) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42705077, -0.0027601947, 0.14644527, -0.1985066, 0.19134405, 0.03181943, -0.48797834, -1.1032012, 0.95868784, 0.55472106, 0.059840363, -0.046752717, 0.056526743, 0.4029079, -0.659743, -0.46681282) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1706614, -0.02834568, -0.0751367, 0.23142572, 0.5205796, -0.28459918, 0.4042437, -0.20036687, 0.027408276, -0.22479373, 0.4283934, -0.34351358, -0.19877811, 0.47163337, 0.07472921, -0.14203738) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.038128443, -0.029114999, 0.037564315, -0.07082411, -0.059321005, 0.23443983, -0.18524711, 0.23697925, -0.09098609, 0.07328206, -0.22489382, 0.18116467, 0.20700628, 0.044367015, 0.046998303, -0.15574977) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.041282475, -0.12969951, 0.09936954, -0.08892016, 0.56604326, 0.87457484, -0.00023490068, 0.05181728, -0.47930774, 0.03160116, -0.21213739, 0.20337383, 0.20000704, -0.19484664, -0.17460197, 0.1618507) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0042530163, -0.12087555, -0.007612117, 0.3370234, -0.2887283, -0.105106376, 0.010690644, 0.18803631, -0.11418393, 0.26289135, 0.12714235, 0.044783246, -0.056667674, 0.17973185, -0.18576609, 0.13050398) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.31833217, 0.3981106, -0.13749091, -0.49272263, 0.06730635, 0.06984753, 0.048983913, 0.16343908, -0.063647546, -0.19663846, -0.104423724, 0.1165098, -0.07723358, -0.13328794, 0.1153356, 0.14199279) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.057156757, 0.43201092, -0.4698143, -0.42520055, 0.015886627, 0.001363246, 0.11170346, -0.13719338, -0.16288525, -0.41007158, -0.10198048, 0.20448485, -0.09231927, 0.40374917, -0.04858631, -0.115931496) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.2710634, 0.049009893, -0.12597471, -0.16723216, 0.010740167, 0.39871076, -0.3388061, 0.13766657, 0.043672603, -0.20880508, -0.26183146, -0.17544809, -0.17341062, -0.028160078, 0.0035610406, -0.06442703) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2408489, -0.057861313, -0.017915819, -0.65746397, 0.13286543, 0.16128612, -0.12988755, 0.24585871, 0.21250975, -0.28626537, 0.038500715, 0.2867698, -0.14711866, -0.046096426, -0.17714536, 0.20745184) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.45213297, 0.11592056, 0.23383784, 0.202513, 0.11908613, 0.6721767, 0.04435075, 0.38907805, -0.19591981, -0.59999716, 0.08155957, 0.400206, -0.5882205, 0.36866406, -0.8073616, 0.59773946) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.6042521, 0.21923982, 0.044131257, 0.5268821, -0.21425565, 0.22768445, -0.10227283, 0.37292534, -0.10745344, -0.33712584, -0.18082304, -0.053791, 0.11259, -0.19343111, 0.074421614, 0.12466225) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23754875, -0.75701696, 0.056190107, 0.12521265, 0.08000207, -0.040123425, 0.045267366, -0.033063933, 0.1290153, -0.037570395, 0.002008971, -0.03967366, -0.30396444, -0.7258007, 0.14141804, -0.1199475) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.03616239, -0.39228803, 0.475629, 0.40769175, 0.15871991, -0.19037452, 3.9341914e-05, -0.17920142, 0.23420613, -0.61966133, -0.12527916, 0.08558077, -0.38786814, 0.10027697, -0.039252598, 0.0520078) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.33726463, 0.363115, 0.14457929, 0.62660015, 0.30799574, -0.16418186, -0.15047902, -0.10039664, 0.061002392, -0.26897857, 0.006425539, -0.15509364, 0.14204296, -0.082235456, 0.0017220033, -0.17512415) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

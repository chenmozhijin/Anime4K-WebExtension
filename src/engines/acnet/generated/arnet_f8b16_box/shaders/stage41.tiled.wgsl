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

  var result: vec4f = vec4f(0.3311885, -0.26432607, 0.36710984, 0.5203973);
      result += mat4x4<f32>(-0.14831841, 0.14005478, -0.062823646, 0.016085196, 0.06859801, -0.08388208, -0.09717423, 0.011104693, -0.10333409, 0.06538264, 0.023796253, 0.16416152, 0.055951376, -0.22619025, 0.12124871, -0.02983611) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.144211, 0.21459167, -0.002465994, -0.03250436, 0.272697, -0.29645216, -0.14539586, 0.05930605, -0.14948234, 0.24030587, 0.06712228, 0.013225485, 0.02038569, 0.044887893, -0.14201702, -0.015716596) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.21766816, 0.1702811, -0.16907378, -0.06254092, -0.07501485, 0.2455691, 0.25948846, 0.13558112, 0.070098385, -0.037466772, 0.04334041, 0.04764082, 0.003902053, 0.07237082, 0.14158063, 0.043103885) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.055807784, -0.04022762, -0.16915916, 0.041105617, -0.28504196, 0.15259135, -0.009563944, 0.06387739, 0.26124886, -0.59619814, 0.048713043, -0.123419404, -0.21644191, -0.24918155, 0.040149353, -0.21392041) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2857221, 0.13890995, -0.5452072, -0.17393015, 0.465651, -0.072024785, -0.13726531, -0.077301465, 0.31214052, -0.45542282, -0.5049768, -0.35705426, -0.2838012, 0.51763666, -0.067824796, -0.23005858) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15893546, -0.011037041, -0.24648827, 0.040436924, 0.4473477, -0.12436966, 0.24880214, 0.19163042, 0.11950848, -0.14503446, 0.03386434, 0.023797529, -0.052815046, -0.17030095, -0.052123502, 0.11268052) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.24953467, -0.09394544, -0.1630662, -0.102334365, 0.11892884, 0.026385898, -0.023563083, -0.029129997, -0.40353137, -0.09920276, 0.04238938, 0.1598249, -0.58309764, 0.07364704, 0.009139717, 0.44461808) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.24042416, -0.11192306, -0.19133772, -0.010433925, 0.26155937, -0.03529787, -0.058914408, 0.05762609, -0.04102511, -0.338501, 0.23457974, 0.6409202, -0.35294783, 0.041123737, -0.17277904, -0.2209164) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0063911905, -0.042960037, 0.03513199, 0.04645875, -0.07261873, -0.074737534, -0.0153801935, 0.048688162, -0.038264036, 0.039489295, 0.22891162, 0.17620061, -0.063826516, 0.08860778, 0.03367386, -0.06496012) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.04081033, 0.16277409, -0.22526774, -0.09006429, -0.13866356, 0.012283297, -0.011536142, -0.001476395, -0.022248788, 0.05570434, 0.008958558, -0.07987438, 0.061783854, -0.033177424, -0.17426719, -0.13240838) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.2808477, -0.42697045, -0.18798853, -0.2665365, 0.09427796, -0.025091209, -0.14185916, -0.016900146, 0.08535449, -0.23095833, -0.34228805, -0.11495457, -0.12841426, 0.16572478, -0.14389805, -0.035447385) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.051522564, -0.021391038, -0.14996447, -0.040074747, -0.075504534, 0.057441074, 0.13376215, 0.08214764, -0.17136277, 0.08762123, -0.03650365, 0.060937032, -0.0045712837, -0.10645448, 0.033145405, 0.058409274) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3631275, 0.059153702, 0.09523777, 0.09604398, 0.061804052, -0.06474225, 0.005120686, -0.06273868, 0.10165984, -0.17752281, -0.038358867, -0.15296556, 0.009423223, -0.3386489, 0.18838005, -0.0025851447) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.10119303, -0.05462382, 0.17681594, 0.18126726, 0.25727257, 0.23024338, 0.25310978, 0.0470208, 0.5661268, 0.26710758, 0.49048272, 0.40645412, 0.0105541805, 0.46033853, -0.04297282, 0.030651763) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.117116205, 0.025690896, 0.012241057, 0.036498595, -0.2187301, -0.058174625, 0.08199816, 0.12703753, -0.24549893, 0.10112453, -0.12631796, 0.21624747, -0.4326684, 0.14558838, -0.052521862, 0.29027596) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.63947463, -0.11710448, -0.20681022, -0.3516322, -0.31804878, 0.276752, 0.07346154, 0.10301389, 0.21711338, -0.13490209, -0.057199918, -0.016837854, 0.10762955, 0.0851769, -0.21325871, -0.17299318) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.031610444, 0.4394125, 0.18499404, 0.20178102, 0.5826602, 0.09464887, -0.103596576, -0.56458527, -0.31610534, -0.12781967, -0.051200707, -0.048207648, 0.6940657, 0.01625442, -0.3090876, -0.096405566) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.022453342, -0.28081572, -0.076442234, -0.041609976, 0.033219647, 0.20686208, 0.12496929, -0.16635323, -0.019113218, 0.08610152, -0.18020323, 0.010386773, 0.21450828, -0.010826098, -0.13567385, -0.08235517) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

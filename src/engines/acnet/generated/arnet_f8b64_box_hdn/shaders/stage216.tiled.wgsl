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

  var result: vec4f = vec4f(-0.12110442, 0.018171873, 0.4193444, -0.1717174);
      result += mat4x4<f32>(-0.11752941, 0.019362567, 0.028123109, 0.06768667, -0.03203855, 0.0036932605, 0.030568793, -0.025328444, -0.058885276, 0.09145613, 0.054029997, -0.13414028, 0.19003808, 0.032585002, -0.1542337, 0.04325669) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.057512924, -0.06283441, 0.09739185, 0.049193066, -0.21138924, 0.007114216, 0.35926825, 0.0010551831, 0.074110046, 0.02330842, 0.094894655, 0.12094696, -0.1767421, 0.08433878, -0.060959596, 0.30329627) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0035043661, 0.010042212, -0.09592833, 0.07884587, 0.053953942, 0.12980713, 0.09317323, 0.013191856, -0.008595657, 0.046764676, 0.054707743, 0.16086146, 0.17030537, 0.08624868, -0.21410182, 0.11403465) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.026435465, 0.0838359, -0.008102028, 0.19556825, 0.13675527, 0.023003891, -0.030115325, 0.288189, 0.13599886, -0.13828255, 0.07895162, 0.19896549, -0.010750212, 0.10589888, 0.25711295, -0.051982343) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.047843542, -0.18732998, -0.004638609, -8.8766195e-05, -0.20846531, 0.100905456, 0.5574048, -0.21837804, 0.03682368, -0.27297541, -0.5816472, 0.39679572, 0.4338088, 0.18318559, 0.37591177, 0.20912452) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13888194, -0.12589303, -0.0032300407, -0.104900464, -0.14916761, 0.19369549, 0.12805313, -0.2672527, -0.12444784, -0.082300484, -0.12857638, 0.10782041, 0.07057613, 0.07608224, -0.18403861, -0.014212681) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12806855, -0.03708086, 0.085274555, 0.15612522, -0.3950246, -0.12731807, -0.15122126, 0.29374963, 0.07267984, 0.033910222, -0.045822382, -0.021739148, -0.114651315, 0.06879986, -0.02869455, -0.11628742) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.01517064, -0.05681845, -0.04145286, 0.008901419, -0.18569659, 0.020832833, -0.18914805, -0.10658206, -0.05256574, -0.11578023, 0.16322598, 0.24215649, 0.05732258, -0.07314026, 0.16657993, -0.001537508) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.01385571, -0.04838452, -0.055244487, -0.0025428422, 0.048713077, 0.22210908, -0.1459783, -0.2798487, -0.03126338, 0.09917588, -0.0025531978, -0.077501304, 0.089549385, 0.10178601, -0.030258343, -0.03250146) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.21398468, 0.011511398, -0.05867458, -0.26799178, -0.015834061, -0.05945207, 0.017537737, -0.04186661, 0.06903538, -0.09495861, 0.17504676, 0.25147083, 0.09198573, -0.009736294, 0.04877307, 0.046601117) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.99251914, 0.36426347, -0.8065554, 0.20396699, 0.1187879, -0.013673351, 0.087870374, -0.22135465, 0.80672574, -0.081849486, 0.37756777, 0.43467513, 0.007815535, 0.20649526, -0.10920255, -0.18303974) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.008989283, 0.08739824, -0.20323926, -0.09912193, -0.015929276, -0.037253935, 0.024923483, -0.11633798, 0.1335099, -0.21017267, -0.28325543, 0.027950434, -0.31403443, -0.75993043, -0.6821338, -0.26377553) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.15488507, 0.08893662, 0.14795968, 0.0691455, 0.0672187, -0.046930667, 0.050106373, -0.36123908, 0.14774238, -0.12898372, 0.18151504, 0.052072186, -0.0043922258, -0.051576376, 0.04751799, 0.037799563) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.378524, 0.47982153, 0.6534257, 0.44733626, 0.0015285952, -0.08343171, 0.5543327, -0.57789963, 0.014090312, -0.5046493, -0.17331092, -0.30527303, -0.14240985, 0.18978421, -0.06381572, -0.32741353) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.10207046, -0.011253029, -0.06538981, 0.22221458, 0.08932532, -0.17112997, 0.14127196, -0.20865594, 0.006847687, -0.07800431, -0.25700533, 0.015887478, 0.2663032, 0.22572897, 0.14289331, -0.49042752) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08403372, 0.059646882, -0.03432753, 0.0014507195, 0.0438003, -0.002190418, 0.01911082, -0.07427599, -0.04373003, 0.001289796, 0.14275701, 0.1466092, 0.002949249, -0.028183307, 0.044809297, 0.07913832) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07025526, -0.021978328, -0.023903603, -0.092911355, 0.16685547, -0.08314592, 0.055902194, -0.26961818, -0.14957711, -0.2202719, 0.012067297, 0.28469667, -0.00027210367, 0.06127015, 0.044886682, 0.08705539) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.015999844, 0.09474719, -0.12683886, -0.11366438, 0.093977645, -0.07182137, 0.09958582, -0.03843635, 0.010761676, -0.11058752, 0.025373125, 0.080574416, 0.068703845, -0.014371486, 0.14397766, 0.27285802) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

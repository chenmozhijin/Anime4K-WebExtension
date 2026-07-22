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

  var result: vec4f = vec4f(0.2504195, 0.07981241, -0.050378785, -0.36360627);
      result += mat4x4<f32>(0.037467673, 0.14926894, 0.052506723, -0.09532762, -0.05721076, -0.04567213, -0.081785485, -0.1845241, 0.10336583, 0.13245553, -0.06456211, -0.053158548, -0.13018577, -0.33934683, 0.1293774, 0.044992037) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3149495, 0.24397631, -0.141408, -0.33316833, -0.18212669, -0.1401626, 0.035024103, -0.10057126, 0.032852825, -0.04616724, -0.06745317, -0.2936498, 0.07698087, -0.05645138, -0.0027890895, -0.095525585) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.022075657, 0.071047, 0.20947903, 0.06031289, -0.09060647, -0.08666955, 0.04299895, -0.07275725, 0.0067675854, 0.27031744, 0.022401594, -0.14997962, -0.09536141, -0.032007247, -0.04151623, 0.24155046) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1792213, 0.2331184, -0.30275187, 0.26494297, 0.318724, -0.036419243, -0.52663624, -0.44221985, -0.03433845, 0.10798745, 0.14103577, 0.20359758, -0.11274182, 0.41790813, 0.15245363, -0.050188404) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.03022651, 0.5467172, 0.62815, 0.00027714562, 0.46636122, 0.21867119, 0.28261718, 0.12648536, -0.034269836, 0.29204318, -0.6592253, 0.38387415, 0.1270827, -0.1785704, 0.09133963, -0.8266561) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.060894504, -0.06901707, 0.3016102, -0.17031878, 0.01122108, 0.28726813, -0.22390161, -0.049107622, 0.11265818, 0.15950072, -0.17023025, 0.26419953, 0.41984028, -0.2459628, 0.32505974, -0.37083304) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.30688792, 0.087230876, -0.62690955, 0.1279227, 0.15334934, 0.15752164, -0.18267594, -0.25732788, -0.09927549, -0.15698496, 0.17613639, 0.014764651, 0.10244928, -0.13726383, -0.32544982, 0.11109413) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.003969713, 0.109916806, -0.10142772, 0.18052733, -0.10718387, 0.40675837, 0.30878624, -0.063674994, -0.080411, 0.04273443, 0.4481763, -0.044988345, -0.13947038, 0.34278965, -0.56949234, 0.2167239) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.06498688, -0.056268986, 0.06192174, -0.1502942, -0.025195079, -0.1189197, -0.32147163, -0.028943771, -0.07415503, -0.075178355, 0.14666723, -0.030414477, -0.19712116, -0.32616144, 0.25928488, 0.37632605) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.053631395, 0.12858017, -0.024380902, -0.040533952, -0.11431899, -0.19281556, 0.03496533, 0.271789, -0.17009257, -0.18377683, -0.035837926, 0.29588962, -0.1005045, 0.12615001, -0.056426723, -0.04174933) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.097873814, -0.07337467, -0.15645806, 0.015473518, -0.2697556, -0.19718482, 0.022594169, 0.48600733, -0.33359855, -0.26243678, 0.29288614, 0.44140533, -0.1279719, 0.10209204, 0.29245004, -0.28573805) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12293087, 0.13005556, 0.0980195, -0.017631788, -0.042221326, -0.09584915, -0.057131175, 0.20136082, -0.077127725, -0.20871945, -0.029149497, 0.21225835, -0.09018905, -0.13555944, -0.082762465, 0.020110726) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13968773, 0.008864363, -0.069003984, 0.18395035, -0.22084406, -0.19489081, 0.12397807, 0.40766728, -0.32676363, -0.35505423, 0.26253, 0.352744, -0.08544089, -0.21755476, -0.2460668, 0.0068546734) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28406057, 0.4120788, -0.19058545, -0.4273989, -0.28510565, -0.104389064, 0.22481582, 0.425187, -0.2613536, -0.25152558, 0.2365652, 0.47832978, 0.56638396, -0.1793347, -0.21021618, -0.31261203) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.043616123, -0.21659696, 0.10987348, -0.073585466, -0.14656779, -0.20609583, 0.16881461, 0.32772997, -0.24537055, -0.2188189, 0.21635397, 0.4780745, 0.2047498, 0.2542066, -0.41694745, -0.12877727) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.010788916, 0.05276675, -0.14164114, 0.051372487, -0.06271944, -0.0982645, 0.14507876, -0.019951504, -0.13918832, -0.1784642, 0.049065072, 0.08816154, -0.037517257, 0.20069608, -0.040081114, 0.25064906) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.07300667, -0.02731912, -0.7373054, -0.13711329, -0.22199999, -0.17508905, 0.3385452, 0.15096876, -0.21342762, -0.1180743, 0.29477367, 0.23036566, -0.18536912, 0.037321273, 0.38739172, -0.09343092) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.05214999, 0.28612038, -0.12153057, 0.077641234, 0.014535629, 0.082892224, 0.07747613, -0.016543977, -0.18968086, -0.15031819, 0.25660348, 0.127168, 0.0052830316, 0.05896637, 0.038986094, -0.093390934) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

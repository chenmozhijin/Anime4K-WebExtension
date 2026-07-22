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

  var result: vec4f = vec4f(-0.15058143, 0.20320477, 0.016122045, 0.051370736);
      result += mat4x4<f32>(0.14505136, -0.34371132, 0.03136354, -0.21750471, 0.004681029, 0.010923428, -0.15968423, -0.04065361, 0.067826994, -0.032811005, -0.09735095, -0.015274711, 0.12122616, -0.11132166, -0.042257704, -0.12008264) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20673354, -0.38825342, 0.4499956, -0.6231466, -0.013016166, -0.16993049, 0.054164995, 0.2393267, 0.04365931, 0.26507226, 0.027882429, -0.09558891, 0.1090567, -0.010272793, 0.24083224, -0.41343534) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.22653754, 0.011374239, -0.2853516, 0.29430065, 0.10485566, 0.052332472, 0.09164412, -0.07154408, -0.05627061, -0.2637587, 0.118237585, 0.13946705, -0.028068861, 0.017105304, -0.088091284, -0.036728177) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1747735, -0.53178054, -0.3728937, -0.24835287, 0.062263872, 0.2631672, 0.25201735, -0.042821188, -0.036792453, -0.01811265, -0.2930531, -0.16231033, 0.015793942, 0.3744544, 0.19056906, 0.5273482) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.041284245, 0.11608857, -0.034252748, -0.09696844, 0.35945174, 0.16704065, 0.16376151, 0.18766071, 0.4424054, -0.007938361, 0.028111666, 0.054576214, 0.14669867, 0.3253128, -0.40269104, 1.1151298) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1278486, 0.3666653, -0.17055684, 0.34511608, 0.13815868, -0.12662368, -0.07253171, 0.006001649, -0.28993714, -0.10165731, 0.25964385, 0.308967, -0.028964054, -0.22196095, 0.04933929, -0.24568412) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.020007381, 0.219148, -0.062705606, -0.029396547, 0.08903896, -0.0020645866, 0.10220572, 0.068573184, -0.13811792, -0.088163674, 0.07100411, 0.00036664397, 0.0713888, 0.021282101, -0.086496994, -0.023098627) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.038464334, 0.54614, 0.07909061, 0.042855717, 0.14172667, -0.1272435, 0.109014615, 0.044851135, 0.50994754, 0.5245902, 0.43900838, -0.17195868, -0.008275815, 0.13567196, -0.16373527, -0.24399695) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07783323, -0.17073433, 0.038731925, -0.099145785, 0.12542531, -0.031958383, 0.03834997, 0.14043765, 0.18665347, 0.06797844, -0.27375814, -0.03634694, 0.0183573, -0.06226874, 0.07223975, -0.2052179) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.022747803, -0.16989575, 0.123260275, 0.02626776, -0.008552945, -0.06744978, 0.13581249, -0.1357129, -0.027664088, 0.016582945, 0.020324666, -0.11661577, 0.058509316, -0.01712394, 0.15436609, -0.057547472) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.007876097, 0.0074078725, -0.10200293, -0.09088359, 0.08415746, 0.09210371, -0.09139488, 0.23730965, 0.062784314, 0.037766047, -0.1881725, -0.10030714, -0.09180009, -0.18011595, -0.031621374, 0.12162866) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.018516663, -0.015239307, 0.015550933, -0.037263446, -0.04005547, -0.23639256, 0.021822205, -0.029346569, 0.066974066, -0.027922628, -0.08015503, 0.16476572, 0.010394294, -0.12974136, 0.08497025, 0.28928766) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.027660936, -0.4690556, 0.07397891, -0.021858, 0.077405736, -0.108288154, 0.056649692, -0.25029963, 0.016505037, 0.18480533, 0.054527476, 0.30557972, -0.029172473, -0.25061426, 0.00841493, 0.030250804) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0029590519, -0.39231533, 0.09733709, 0.1799956, 0.15719101, -0.08672906, -0.2925799, 0.030565444, 0.42253518, -0.078051284, -0.21088715, -0.5600344, -0.15843661, -0.5899127, -0.100578, -0.6560219) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10590065, -0.43039477, -0.012670017, 0.10572324, -0.03776046, 0.15758137, -0.17324609, 0.2423961, 0.23247853, -0.011529549, 0.008834756, -0.10031759, 0.09521564, 0.36515835, -0.010376551, 0.41058454) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.040432844, -0.098131515, 0.026093975, 0.011777805, 0.066701844, -0.2735229, 0.023028472, -0.08523013, -0.044647668, 0.064409, -0.13272001, 0.5882136, 0.06451589, 0.26027444, 0.06509262, 0.28875753) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.03885351, -0.2320809, 0.02168531, -0.12167683, -0.15682924, -0.90616846, -0.3394359, -0.6335751, -0.06258694, -0.26662973, 0.21930867, 0.38480303, 0.10092742, 0.46288806, 0.041365188, 0.0856742) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.108715944, -0.3430435, -0.02449091, -0.023759516, -0.1350985, -0.30383876, -0.0016684014, 0.1449588, 0.10801482, -0.13789397, 0.047839385, 0.080800384, 0.16716832, 0.3582986, 0.13775039, 0.16241165) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

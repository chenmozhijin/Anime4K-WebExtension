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

  var result: vec4f = vec4f(0.24288785, -0.007281301, -0.24061882, 0.1889712);
      result += mat4x4<f32>(-0.015284674, 0.029457422, 0.033543635, -0.08637447, 0.16486068, 0.19504067, 0.01728496, -0.039816104, -0.013555154, 0.30618653, -0.14421336, 0.054275468, -0.0049422905, -0.07852533, -0.10738797, -0.036341064) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0857626, -0.17314844, -0.03712472, -0.054727852, 0.1578384, 0.052534766, -0.17948225, 0.072603054, -0.23743567, 0.15472099, -0.07173917, -0.026906969, -0.108032055, -0.083140396, -0.12948345, -0.038493354) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.052269727, -0.16880877, 0.071213305, 0.027527507, -0.014398836, -0.080856405, -0.06797074, 0.10115583, 0.022092173, 0.04858975, 0.006367246, 0.01748244, 0.02021999, -0.14383432, 0.13437569, 0.06862943) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.109779246, -0.0028692023, 0.22239804, 0.02286114, -0.20666315, -0.011343313, 0.061110593, -0.2757788, -0.10713041, 0.037266042, 0.2720411, 0.14108853, 0.0625442, -0.009775569, -0.17446432, 0.084888525) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07146627, -0.4458172, 0.2927746, 0.53046143, 0.067478046, -0.65864646, 0.29552272, 0.6709964, 0.052508526, -0.316678, -0.64189696, 0.42663458, -0.30662602, 0.29644766, 0.45440057, 0.42201865) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0071534086, -0.25894228, -0.03910305, 0.30930132, 0.14921926, -0.12179884, 0.19540785, 0.105616964, 0.10873778, 0.06673536, -0.45879537, 0.18526587, -0.027386224, -0.1146483, 0.25782174, -0.2793874) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07720679, 0.15813957, -0.04115361, -0.08212082, 0.040505003, 0.31846052, 0.03504164, -0.2834446, -0.15085088, -0.22383356, -0.27290073, 0.1900935, -0.011240202, 0.066958524, -0.04584176, 0.005082791) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.011646982, 0.20273986, -0.07350482, 0.108886935, -0.007841869, 0.21501532, -0.3356996, -0.062066976, 0.26050198, 0.13511628, 0.14116512, 0.013391414, 0.0035069662, -0.009074715, -0.11495199, -0.027274754) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.044553954, 0.07882104, -0.19367333, -0.08783272, 0.07238533, 0.07327406, -0.004916998, -0.051095925, 0.042733014, -0.01689242, -0.2240571, 0.10170753, 0.02161905, -0.1142636, -0.014732902, -0.15969117) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.15622379, -0.026101444, 0.16617408, -0.031998936, -0.13708046, 0.1721087, -0.1836851, 0.055591542, -0.091680765, -0.09535737, -0.083465576, 0.088023596, 0.15432985, 0.009664478, 0.043621495, -0.012509214) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.013811855, 0.3256974, 0.11190601, -0.064020455, -0.020091955, -0.12142738, -0.068810605, 0.18556039, -0.19798364, 0.37198845, -0.27286234, -0.02966057, 0.15936452, -0.15227783, 0.2292205, -0.11123853) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.09416346, -0.080924906, 0.077291995, -0.0057359394, 0.087269835, 0.008603998, -0.1725553, 0.12731844, 0.018274855, -0.009348592, 0.08818991, -0.036640577, 0.006495788, 0.086664364, 0.25686994, -0.029708907) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17540519, 0.1293725, 0.5157777, -0.35754398, 0.03881916, 0.06620522, 0.060327318, 0.10355889, 0.02325983, -0.25163198, -0.079925746, 0.08794888, 0.004088528, 0.036148317, -0.051965985, -0.040140964) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.033659823, -0.2453898, -0.20613483, -0.008721884, 0.14940424, -0.3440207, 0.16942509, -0.020778682, 0.24486275, 0.26443747, 0.8394145, -0.13553736, -0.026091196, -0.20739116, 0.3358105, -0.013551993) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2014624, 0.5202024, -0.39844412, 0.10189848, -0.007844537, 0.016975103, 0.13444954, -0.033610653, 0.07541187, -0.16338386, 0.07816921, 0.15625419, -0.08742659, -0.25338036, 0.04400533, -0.41148567) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18221429, 0.104184724, 0.01928109, 0.021933831, -0.1457154, 0.16941233, 0.091162525, -0.15568227, 0.08793944, 0.24082947, 0.12674741, -0.069786005, -0.0070006712, 0.023859689, -0.021735132, 0.019131104) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.051542215, -0.4753065, 0.07664418, 0.23450178, -0.48781902, -0.2490253, -0.20024826, -0.22298312, -0.14911106, -0.13919841, -0.059370693, 0.14748967, -0.015687063, -0.13886604, -0.03396357, 0.07358325) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11669912, -0.17452903, -0.11962389, -0.016539462, -0.0008805926, -0.30595103, 0.37395632, -0.17510681, -0.10054304, -0.0022796867, -0.034401726, -0.029708903, 0.009986355, 0.0071610417, 0.018985413, 0.015074331) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

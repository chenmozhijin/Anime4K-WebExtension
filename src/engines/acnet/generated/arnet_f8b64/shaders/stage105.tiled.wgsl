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

  var result: vec4f = vec4f(-0.14566006, 0.15522376, 0.17714444, 0.18909906);
      result += mat4x4<f32>(-0.029504277, -0.17519216, -0.00025040502, -0.106753476, -0.14963946, -0.11287186, 0.057964016, -0.12452642, -0.07585391, 0.13470137, -0.20215602, -0.16302675, 0.15251999, 0.012747845, -0.09802309, 0.01239639) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.020811347, -0.3160597, 0.18535697, 0.09694785, -0.056843527, 0.016500527, -0.38498935, 0.15370606, 0.048967384, 0.11519419, 0.029851817, -0.11515601, -0.0081088515, -0.20546289, 0.23863176, -0.27282792) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.029812481, -0.045008063, -0.2196261, 0.06105293, 0.070288725, -0.13393992, 0.2618973, -0.21152173, -0.060263153, -0.00014580262, 0.36750683, -0.43695387, 0.05554132, -0.00303631, -0.014445666, -0.040296204) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06713459, 0.015793921, -0.21317291, -0.2648998, 0.090363525, 0.42381698, 0.54357415, -0.05027674, -0.06254841, -0.050823037, 0.20441772, -0.24185161, 0.014067657, -0.28547713, 0.04516741, -0.22738163) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.051744353, -0.40619358, 0.026848735, 0.15536366, -0.34213775, 0.15147816, -0.33753276, -0.24947737, -0.35231152, -0.05961189, -0.11561761, 0.14689858, 0.49395376, -0.3585148, 0.29701906, -0.36739555) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0602238, -0.19668837, -0.24213853, -0.12053793, 0.037498318, 0.04528797, -0.01969526, 0.09868702, -0.11787388, -0.12077843, 0.25063643, -0.27039918, 0.28146356, 0.27391726, -0.083632685, 0.025263082) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03166114, 0.19481601, -0.1033382, -0.068353936, 0.1217219, -0.12426513, -0.02408962, 0.045745365, 0.083378516, -0.038352028, 0.5469289, -0.24462286, 0.11599042, 0.036188602, -0.026584066, -0.05092532) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.061762456, 0.50886226, 0.12304385, 0.20590718, -0.18885198, -0.0021437244, 0.032876246, -0.11848439, -0.26671302, -0.38512036, -0.42675823, -0.3363356, 0.2538732, 0.3490122, 0.045912374, -0.22747487) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.026623132, -0.19841498, 0.03990617, -0.09793408, -0.034967598, -0.124481045, -0.012399531, 0.038382433, -0.0015340339, 0.0190149, 0.17857416, -0.035572164, -0.0401865, -0.1103244, -0.0030477145, -0.09877077) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.05553851, -0.084991135, -0.03934801, -0.021228641, 0.033187635, -0.052268308, 0.012461203, 0.07891241, 0.1428075, 0.34722736, 0.108310476, 0.08314977, 0.09898554, -0.025886154, 0.1916193, -0.10046688) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0012019404, 0.09966719, -0.050179515, -0.06257025, -0.011540544, 0.14022358, 0.049677826, -0.09478641, -0.13071351, -0.13119036, -0.021703307, -0.056420736, -0.04639852, -0.06956758, -0.09977639, 0.089913815) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.03876094, -0.02059919, 0.15126662, -0.1346523, 0.040188782, 0.05526908, -0.12226464, 0.18111774, -0.04099718, 0.036268283, 0.021622797, -0.30522138, 0.13259137, 0.26607904, 0.28667477, 0.113923445) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09288, -0.2136618, -0.09665167, 0.10851733, 0.24062595, 0.084470086, -0.014476096, 0.40873682, -0.10109967, -0.16869852, 0.12824298, 0.0894401, -0.14955059, 0.0092896605, -0.10002737, -0.07211678) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.12426643, -0.057017904, -0.103407554, 0.2997973, 0.3162863, 0.38851485, -0.25070304, -0.030303538, -0.23533718, -0.29963434, -0.0020490678, -0.26327455, -0.14511272, -0.30042896, -0.08943901, -0.24521884) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.054547384, 0.040183708, 0.02275497, -0.013140464, 0.16145715, 0.17849551, -0.41538677, 0.2896379, -0.3188746, 0.096717715, -0.3513196, 0.22535132, -0.0720803, -0.15552205, -0.22778265, 0.1950165) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2418167, -0.42046228, -0.13083598, -0.11708918, -0.2856687, -0.23583671, -0.39317605, 0.32229936, 0.32577083, 0.3239241, 0.18574719, -0.13992475, -0.18653162, -0.2525721, -0.21803969, 0.06346725) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.040817708, -0.02400459, 0.019343646, -0.04609395, 0.0035536697, -0.1861924, -0.09971145, 0.08246119, 0.01678016, 0.06329273, -0.8954851, -0.46317834, 0.21173713, -0.031269703, 0.29267505, 0.005292725) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.031252697, 0.06360007, 0.12369899, -0.04479819, 0.027873108, 0.066438496, -0.1662291, 0.06952215, -0.016688682, 0.007971054, 0.1144658, 0.34930953, 0.016904248, 0.07765929, -0.18016939, -0.04971688) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

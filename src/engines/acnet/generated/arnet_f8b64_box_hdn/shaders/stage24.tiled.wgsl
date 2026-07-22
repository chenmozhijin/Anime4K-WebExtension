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

  var result: vec4f = vec4f(0.16771194, 0.15072994, 0.18521324, -0.112867795);
      result += mat4x4<f32>(-0.09036285, -0.03707867, -0.016143706, -0.079559684, -0.109772354, 0.05891382, -0.48446602, 0.276625, 0.062326778, -0.12690459, -0.51967996, 0.23484384, 0.15511605, -0.1358714, -0.17774327, 0.10837742) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.033947468, -0.020367995, -0.119765624, 0.14497231, 0.27501383, -0.058634836, -0.41103482, 0.30386257, -0.17176004, -0.3088489, -0.21657565, -0.40054983, 0.3033078, -0.0906164, 0.09911031, -0.06962104) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.20202161, 0.06909219, 0.04783743, 0.18283041, -0.2339374, 0.06360451, -0.049246646, -0.08571863, -0.30136225, 0.1922228, 0.48345932, 0.34281054, 0.30997998, -0.011547353, -0.13645843, -0.28732932) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18715806, -0.32609633, -0.12165777, 0.22236978, 0.2036572, 0.099741176, -0.06483662, -0.046539247, -0.1543466, 0.3281102, -0.18186368, 0.3601144, -0.42400017, 0.31325504, 0.17199166, 0.05674935) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5821702, -0.030694008, 0.090404235, 1.3640766, 1.5521501, -0.45928735, -0.3716901, -0.11222374, -0.4132266, 0.36728814, -0.30465996, 0.37495908, -0.27906948, 0.6926768, 0.031388193, -0.49828413) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.38961405, 0.26968622, 0.26624146, 0.35348764, -0.43099612, 0.18774374, -0.14629558, -0.04889539, 0.29261884, -0.4347129, -0.007029604, -0.48131904, -0.2707148, 0.13763604, 0.16423517, -0.21741876) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06252073, 0.10047594, 0.13161528, -0.085511096, -0.09278464, -0.0028992547, -0.12375521, 0.055430155, -0.0011842748, 0.05202127, 0.106534116, -0.12076563, 0.037233546, -0.1937536, 0.03224414, 0.13782254) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3746782, -0.3155599, 0.043470543, -0.03031422, 0.039319325, -0.10634044, -0.3589913, 0.003920137, 0.21068697, 0.10944614, -0.05858236, -0.2929598, -0.04530946, -0.043710552, 0.10409728, 0.0035235898) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.20499726, 0.017939927, -0.065303974, -0.086283006, 0.06724172, 0.022653667, 0.080514625, 0.11967881, -0.046036415, -0.027568035, 0.13663048, -0.26273197, 0.04188266, -0.048084956, 0.00568937, -0.06765243) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2640661, -0.048028484, -0.011356511, -0.26359877, -0.02647814, -0.21817228, -0.6205611, 0.44690475, 0.060064998, 0.031401463, -0.072470196, 0.09129009, -0.016051002, -0.27465782, -0.13761467, -0.28348514) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.54369074, -0.1641624, 0.030084755, -0.2530942, -0.1967121, 0.4498324, -0.114850715, 0.5634971, -0.096919045, -0.023869615, -0.08148938, -0.30254102, 0.4619153, 0.08522221, -0.0006329983, -0.2755693) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3413407, -0.15619947, -0.07637643, -0.4217472, -0.87166893, -0.060128056, -0.5591169, -0.40590787, 0.07507002, -0.06481605, 0.02333176, -0.12560901, 0.3194166, -0.10497081, -0.25434464, -0.27464405) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14504035, 0.4975123, -0.041236937, 0.26592922, -0.46523046, 0.43639952, -0.11813825, 0.02213626, -0.08246389, 0.02429364, 0.064676076, -0.2149002, 0.12640971, 0.36067197, -0.1563249, -0.14828682) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.06579258, -0.76271963, 0.9188446, 0.8327773, 0.1978532, 0.13865328, 0.13818917, 0.10109554, -0.6814772, -0.19265728, -0.27602708, -0.9798331, 0.6591947, -0.21971758, -0.2166897, -0.13240027) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1459064, -0.14819717, -0.1473546, 0.051324178, 0.6609798, -0.33187342, -0.2599613, -0.32062247, 0.24043068, -0.14733694, -0.05041245, -0.16231047, 0.7828188, -0.0401035, -0.21153653, -0.38758236) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.037385434, 0.09045316, 0.23426452, 0.119300395, 0.6349229, -0.3659049, -0.0993765, -0.38348064, 0.047894917, 0.050148062, -0.10071869, 0.12958826, -0.07133586, 0.21445048, 0.21031447, -0.08954453) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.37385622, -0.026246259, 0.028566632, 0.21211267, 0.24815932, -0.032335695, 0.038648434, -0.42292723, -0.36400607, 0.26190022, 0.16600825, 0.12207131, -0.11090588, -0.17595363, -0.04941349, -0.1395695) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11706502, -0.23645373, -0.12317202, 0.20829585, -0.6574349, 0.13015683, 0.18838477, 0.056303293, 0.020397874, -0.036732167, 0.0045669307, 0.23018238, 0.028311132, 0.014025263, 0.005316817, -0.4335468) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.02092532, 0.31084904, 0.13172922, -0.26453862);
      result += mat4x4<f32>(-0.018319529, -0.12253793, -0.19293332, -0.024714442, -0.07678034, -0.1637598, 0.19347513, 0.25700858, 0.14638856, 0.06846391, -0.15896429, 0.07426475, 0.1274689, -0.17616878, 0.045206755, -0.60638165) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.14183597, 0.17565787, 0.23654187, -0.060785685, -0.15610267, -0.18231116, 0.2720686, 0.3009706, -0.09745622, -0.21196221, 0.09491071, -0.06366736, 0.069397464, -0.116876505, 0.060510628, -0.12858914) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.040284272, 0.057040587, 0.012879174, -0.012331995, -0.16971533, -0.2512899, 0.20157816, 0.32704154, 0.094667256, -0.015674196, -0.10241615, -0.23326136, 0.22117114, -0.072923385, -0.067622304, -0.5352907) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.034242943, -0.15807648, 0.10955806, -0.20046607, 0.009003645, -0.09808615, 0.17361313, 0.10523039, 0.11483935, -0.021917172, -0.34621695, 0.13965741, -0.15829459, 0.03969247, -0.079112306, 0.61533475) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.65683705, -0.3972161, 0.9953428, -0.1511512, -0.11991795, -0.67763114, 0.23679441, 0.26130113, 0.37368363, 0.3370387, -0.34743693, 0.083206005, -0.5031805, -0.07479432, -0.0771877, 0.9992665) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.037815526, 0.35782725, -0.08729963, -0.06871052, -0.19373587, -0.42663157, 0.22077164, 0.3154796, -0.08780534, -0.030270053, -0.20670715, -0.0058329282, 0.040655572, -0.060025554, 0.16482276, -0.121643245) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04121773, 0.083561115, 0.21414737, -0.06936842, -0.12714188, -0.1759489, -0.056876842, 0.23696281, 0.030806988, -0.062007975, -0.0044626137, -0.027826391, -0.22039849, -0.055334233, 0.008804716, 0.4271834) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14821246, -0.19248259, 0.15972263, -0.12996522, -0.1108726, -0.033956476, 0.21789375, 0.21685994, -0.033722956, 0.025232775, 0.22552785, -0.23301841, -0.12796482, 0.04262474, -0.040309403, 0.59884727) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.059441406, 0.046395402, 0.07427264, -0.06534797, -0.118482575, -0.3041004, 0.14159954, 0.09856634, 0.02785987, -0.11500251, 0.039182663, -0.008319738, 0.253385, 0.2992474, -0.1256882, -0.41172415) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.14714864, 0.35816652, -0.16328189, -0.063121766, 0.027817355, 0.24750498, -0.07886472, 0.17843762, 0.011158099, -0.09389533, -0.16097496, -0.20861632, -0.061647814, 0.051286284, -0.22039688, 0.4702518) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.020479377, -0.37624538, -0.35057476, -0.43122855, 0.12787955, -0.42005903, -0.40718734, -0.25084296, 0.17488576, 0.4449233, -0.10188625, -0.11132764, 6.3254497e-06, -0.019934691, 0.011154907, 0.261325) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11574813, 0.2784423, -0.2868735, -0.14420122, 0.039023634, 0.2475448, 0.0042295964, -0.03567118, -0.008623306, 0.14954293, 0.06127587, 0.14170597, -0.057778925, -0.34430492, 0.10761713, 0.14531769) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.24049433, 0.230455, -0.30090228, 0.16326328, -0.018677102, 0.13980334, 0.24347515, -0.11740763, -0.0115829315, 0.0548886, -0.16031247, -0.41593263, -0.051447984, -0.47160906, -0.030317076, 0.27065286) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.124182194, -0.10866205, 0.40438503, -0.25281546, -0.3751383, 0.18805622, 0.2765854, 0.07747996, -0.228562, 0.9571034, 0.4176767, 0.44086015, -0.007384762, -0.78289115, -0.08413276, 0.10232353) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19506344, 0.30481723, -0.36271706, -0.13678621, -0.097380586, 0.2722927, 0.0030454844, 0.14206347, 0.14502041, 0.31623122, 0.041402873, -0.11980433, -0.00902492, -0.10524584, -0.21252955, 0.053971868) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11407145, 0.067207545, -0.03483144, -0.39845306, -0.095435694, -0.08069846, 0.074031, 0.05513893, 0.104756, 0.09568847, -0.17539947, -0.015412209, 0.047035713, 0.22157674, 0.32850856, 0.025428744) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.016556883, 0.30109438, -0.003947375, -0.01112202, 0.11181562, -0.07214732, -0.3042187, 0.013949578, 0.27915886, 0.16861364, -0.4427588, 0.056967534, -0.190599, -0.31195977, 0.31208405, 0.14013726) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14179604, 0.044999734, 0.19613115, -0.039877333, 0.11820234, 0.24085166, -0.21158557, 0.12503847, 0.050709832, 0.13036162, -0.14956936, -0.056478273, -0.08078192, -0.11971009, -0.052158043, -0.061683122) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.082856424, 0.06230243, 0.06785804, -0.22283967);
      result += mat4x4<f32>(0.17656784, 0.10402744, 0.037541974, 0.33287913, 0.30900928, -0.034063492, 0.18927391, 0.31636345, 0.29667443, 0.024975456, 0.332595, 0.23324063, -0.111064605, 0.104912356, 0.084833644, -0.12958069) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.29933092, -0.15230899, -0.17179516, 0.02850859, -0.08243006, 0.23078229, -0.014388955, 0.103378005, 0.20625517, -0.12003209, 0.12941001, 0.2730516, -0.3546462, -0.1233625, 0.10217461, -0.3691398) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0731468, -0.14157219, -0.11656425, -0.036605652, 0.011186335, 0.01043721, 0.011286491, 0.07017273, 0.17614268, -0.06857838, 0.17827626, 0.06513713, 0.04160077, -0.068088524, -0.15953149, -0.07844175) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14447698, 0.11596839, 0.034404747, -0.20375979, -0.03603658, 0.0042765876, -0.0902467, -0.055563435, 0.09311019, -0.08093347, 0.17907237, 0.021133622, 0.058511775, 0.26550522, -0.19158456, -0.012277187) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.08507819, 0.0888544, -0.038144294, -0.5919791, -0.58119243, -0.058603, 0.14987859, -0.05037831, 0.3539762, -0.048595347, 0.34520298, -0.07666672, 0.23409466, -0.013060497, 0.24027069, -0.22264881) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.35728717, -0.11817261, -0.11684076, -0.19324407, 0.023820836, 0.073274545, 0.26036674, -0.032241493, 0.29919168, -0.13712879, 0.2070919, 0.017724572, 0.05130373, 0.01901857, -0.01940076, -0.0073385644) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04147703, 0.030234283, 0.04083118, 0.0015883307, -0.025677754, 0.043035503, 0.043274995, -0.04283491, 0.24113648, 0.03294321, 0.16823268, 0.047911257, -0.17136884, 0.19055283, 0.003513097, -0.17293343) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1599685, -0.064473785, -0.20977692, 0.10051889, -0.00560219, 0.06979242, 0.1447328, 0.1351023, 0.43530107, -0.10522645, 0.18407765, -0.079239324, 0.16901575, -0.1362913, -0.21126246, 0.02587639) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.00560947, -0.06515624, -0.051354773, -0.064975865, 0.14464831, 0.06487529, -0.11476347, 0.053673666, 0.19166046, -0.13014542, 0.0151932435, -0.033498306, 0.09327558, -0.16297099, -0.5364654, -0.06885705) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.30789497, -0.03252325, 0.36509243, 0.18420404, 0.0886268, 0.23370264, -0.07231977, -0.21550772, -0.07927182, -0.07061045, -0.10095525, -0.17690367, -0.1962309, 0.11289399, 0.26294377, 0.08663086) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.03728426, 0.14222908, 0.049733173, -0.44256285, -0.19090201, -0.47392732, -0.41206127, 0.21147822, -0.07255131, -0.09391729, 0.16645545, -0.26109222, -0.14615236, 0.11915954, 0.36655697, -0.12941147) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2544454, -0.124709226, 0.15018871, 0.039259713, -0.092413634, 0.046922255, -0.27737677, -0.08645625, -0.14279477, -0.006447714, 0.036965966, -0.05186749, -0.054668076, -0.003986099, 0.3418612, 0.17796542) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18977423, 0.09294417, 0.18584543, -0.021915149, -0.13660386, -0.16553126, 0.0026056163, -0.24621323, -0.15332313, -0.05756069, -0.028959703, -0.17031829, 0.3990442, -0.1036536, 0.3316105, 0.25635508) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.59018207, -0.13220693, 0.408081, 0.11424429, 0.04318513, 0.14180593, -0.021689288, -0.23756534, 0.5845805, 0.090192564, -0.1717257, 0.37267697, -0.017441764, 0.1439384, 0.06747023, 0.44633475) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14221439, -0.028783709, 0.0060044606, 0.040076837, -0.025310675, -0.054691818, -0.13318858, -0.35656196, 0.1764375, 0.0042415867, 0.00187153, 0.32814163, -0.04838476, 0.29038134, 0.41648155, 0.08032805) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05742032, -0.027705774, 0.030068604, 0.07983883, -0.094921544, -0.10755884, -0.19479363, -0.32134175, -0.07228348, -0.030462233, 0.008981043, -0.040174566, 0.008079489, 0.16433144, 0.023917733, 0.43628094) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.13357367, 0.0117488615, 0.20942068, 0.19946459, 0.47572577, -0.0042551365, 0.19935112, -0.4060646, -0.1368259, -0.013716134, -0.03646129, 0.034272335, 0.027264368, 0.15483578, -0.03713117, -0.12955962) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.009522324, -0.009679813, 0.10832636, 0.12576328, 0.10522362, -0.124465704, 0.07017912, -0.12988324, -0.09457443, -0.11101221, 0.22569829, 0.06637929, 0.122684054, 0.023953909, 0.29695788, 0.051525094) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

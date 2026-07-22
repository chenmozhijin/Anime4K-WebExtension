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

  var result: vec4f = vec4f(0.26780173, 0.0812519, 0.084348984, -0.12243742);
      result += mat4x4<f32>(-0.083235204, 0.20286366, 0.14145336, -0.2673613, -0.17289531, -0.0054946016, 0.29064342, 0.17724107, 0.06858939, -0.03432449, -0.116605125, -0.15513372, 0.056242414, -0.07949521, -0.09681601, 0.11182838) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.030457044, 0.18644561, 0.44893077, 0.06797065, 0.0953914, 0.108182356, 0.27857104, 0.06433957, 0.20852439, -0.06291061, -0.05396737, 0.10865981, -0.034248393, -0.083158724, -0.06804756, 0.13168925) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.059523452, 0.25626558, 0.24677026, -0.11055721, -0.06161468, 0.032844983, 0.15244484, -0.066119105, -0.05922027, 0.040455557, 0.065721646, -0.09372552, -0.09959826, 0.07633388, 0.23020722, -0.04759075) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.079193376, 0.32409966, 0.17750986, -0.4173546, -0.30492422, 0.09377228, 0.27376083, 0.2664206, -0.050876033, 0.1778066, 0.10751893, 0.06618269, 0.033284526, -0.017185392, -0.018310666, -0.027269926) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13365701, 0.5072654, 0.36677337, -0.41694024, -0.19935012, -0.82652414, -0.42547515, 0.2363477, 0.6054766, 0.4590093, 0.37747437, 0.08637563, -0.18675633, 0.41182464, 0.57408917, -0.7420899) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.030473003, 0.3218279, 0.23319143, -0.26796773, -0.0065684663, 0.0995728, 0.050975308, -0.014552215, -0.047386892, -0.14420933, -0.03853573, 0.11271861, -0.5930371, 0.053784877, -0.30586725, 0.17165658) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04131471, 0.18854964, 0.06878589, -0.25954276, 0.13972236, 0.03146701, 0.031416602, -0.2504425, 0.052561894, 0.040304273, -0.023783471, 0.040573206, -0.01957776, -0.08637796, -0.041618302, 0.19874611) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.051743012, 0.30419612, 0.14522913, -0.3546704, -0.047384996, -0.068451844, -0.007893751, -0.04546103, -0.08599615, 0.14979951, -0.011364355, 0.041918885, -0.14157046, -0.059913136, 0.06965959, -0.09541297) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0021213642, 0.16014984, 0.0662187, -0.23555681, 0.024851236, -0.00023657594, 0.021179924, 0.05580402, -0.033070322, 0.008360932, 0.005090947, -0.05803475, 0.2591047, 0.052087728, 0.0766971, -0.14797358) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.044715054, 0.095394425, -0.17684272, -0.10826111, -0.02617733, 0.017630802, 0.06070337, 0.071822494, -0.09414194, 0.011678496, -0.08102987, 0.11928502, 0.04086955, -0.06049309, -0.0037477333, 0.05880347) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.021838758, 0.2075508, -0.27498883, 0.0054336167, -0.0807912, -0.096945785, 0.011026127, -0.0343825, 0.09125053, 0.10060097, 0.20051853, 0.20211525, -0.3013709, 0.015373029, 0.09537633, 0.070050776) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0037181473, 0.21720558, -0.109546974, -0.10350265, 0.04584454, 0.0757065, 0.22264826, 0.09225384, 0.13508967, -0.19052766, -0.21456969, 0.0297808, -0.036090717, 0.12504452, 0.23800763, 0.03196082) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3149594, -0.16686764, -0.31806603, -0.22550489, 0.114770114, 0.009147136, 0.05422289, 0.12247821, 0.2700529, 0.020940028, -0.03211302, -0.14967808, 0.16816382, 0.008981398, -0.040869836, -0.08771704) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.6214179, -0.43966863, 0.014908524, -0.85291636, -0.40622956, -0.006795031, -0.48592412, -0.7149121, 0.59334314, 0.5300873, 0.31983292, 0.1168825, -0.32876226, 0.818584, 0.29433072, 0.11705078) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08225339, -0.07641935, -0.055955984, 0.1273226, 0.11143602, 0.09076128, 0.06387326, 0.1497473, -0.10584346, -0.25139886, -0.22961429, 0.246477, -0.2861469, 0.14666921, 0.1707961, 0.13485649) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.043725427, 0.07698263, 0.049734227, -0.13981184, 0.055021238, -0.102100484, -0.11619768, -0.06045398, -0.043207794, 0.18897228, -0.16335477, -0.07581547, -0.09400771, 0.047973454, 0.06569035, 0.16147813) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4541324, 0.035780918, 0.030832488, 0.04972074, 0.23482192, 0.19557343, -0.0106567005, -0.044144634, -0.30870184, -0.0310491, -0.28485715, -0.008534304, 0.07575018, 0.045920476, 0.02680739, 0.040503737) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.23766217, 0.16426297, 0.07464162, 0.19971164, 0.04559854, 0.0064621177, -0.019488344, -0.0022118199, -0.03031194, 0.006658445, -0.005251746, 0.16060095, 0.102358274, 0.04511213, -0.015063715, -0.2418508) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

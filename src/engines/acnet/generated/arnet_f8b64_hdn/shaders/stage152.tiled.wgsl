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

  var result: vec4f = vec4f(-0.03627911, 0.21457863, -0.09658043, -0.31453937);
      result += mat4x4<f32>(-0.19555318, -0.17600389, -0.73399323, -0.04151199, 0.105981104, -0.16564308, 0.008683697, 0.20285861, -0.15781969, -0.0770338, 0.012651354, 0.09045456, 0.2507842, -0.14813627, 0.6017362, 0.09195817) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0004487177, 0.08263602, 0.116790734, -0.032256477, -0.13218302, -0.28387856, -0.2602997, 0.19090714, -0.06597938, 0.05714764, 0.043311033, 0.23591149, 0.042432092, 0.03434258, 0.41434735, 0.1425264) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07447474, -0.11445721, -0.27124092, -0.03992664, 0.21284883, -0.15194736, 0.047938697, -0.043963775, 0.02438699, 0.044616967, 0.027846426, 0.24697392, -0.13704577, 0.02670803, -0.25537053, -0.07115254) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.029609365, 0.087355316, 0.10323525, 0.009730931, 0.17847794, -0.049569514, 0.12024583, 0.069958694, 0.06977237, -0.07677181, 0.014184212, 0.22149666, 0.068590015, -0.07338361, 0.21420708, -0.117604785) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13035707, 0.05054864, 0.2894173, 0.059446305, -0.2989286, -0.2409131, 0.03077444, 0.12278431, 0.040955342, 0.18107727, 0.04017504, 0.14504106, 0.1252661, 0.091167234, 0.5261302, -0.035697993) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06321503, 0.12645511, 0.3011058, 0.0030795534, 0.2099797, -0.045825563, 0.017248949, -0.1305273, -0.12534189, 0.17792903, -0.042619955, -0.13879173, -0.013912812, 0.1611814, 0.15286112, -0.04568416) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.033356953, -0.027141454, 0.023664368, -0.039105427, -0.19472289, -0.1488347, 0.043729506, 0.2939825, -0.5006487, 0.1433677, -0.043948006, -0.040462688, 0.121566206, 0.1420844, 0.30677375, 0.09314134) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.00026742116, 0.2630474, 0.25285095, 0.09261993, 0.040901396, -0.047682945, 0.010337504, 0.46320602, -0.48477012, -0.13430557, 0.25849465, 0.19485871, 0.072993055, 0.18797615, 0.49998915, 0.22758827) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.40894353, 0.14228763, 1.2050748, 0.18078895, 0.19412664, 0.15695864, -0.025788216, 0.06573363, -0.109786995, 0.061261103, 0.03964346, 0.06654654, -0.12777296, 0.3644808, 0.049712297, 0.017828219) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1289794, -0.113567755, -0.0106178215, 0.2189181, 0.19456787, 0.02994959, 0.034359366, -0.32226577, -0.08995872, -0.07405971, -0.061631348, -0.058769483, -0.12151516, -0.15268032, -0.5173476, -0.007013787) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.043224655, 0.0075450027, -0.040328957, -0.063937634, 0.49482915, -0.16535951, -0.15080647, 0.16001135, 0.08809817, -0.1021417, -0.17187248, 0.016496735, -0.11127246, -0.07787718, -0.35541633, -0.07818259) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.069096275, 0.065956615, 0.09148147, -0.052272007, 0.14021169, -0.22016029, -0.17161153, -0.13483143, -0.07948067, 0.032073848, 0.054386936, -0.020694198, -0.09953499, -0.061137225, -0.47215185, -0.006908965) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.15938169, 0.29069462, -0.022784472, -0.25353572, 0.5880471, -0.29403746, -0.3603528, 0.21700625, -0.38555017, 0.53102, 0.55937314, -0.33317876, -0.08145663, -0.20075841, -0.4136011, -0.047328867) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.17513144, -0.37164804, -0.41274655, 0.13318007, -0.24890408, -0.5348655, -0.16035321, -0.18456419, -0.5930719, 0.07311694, 0.2314548, -0.11563324, -0.0690891, -0.14085633, -0.37278548, -0.010547721) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.27212644, -0.22227435, -0.07176047, 0.6869103, -0.35664746, -0.36659372, -0.08651352, -0.19142425, -0.0525915, 0.24937572, 0.26145437, -0.23353025, -0.13491482, -0.10623227, -0.36979634, 0.06230301) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17407615, 0.01959571, -0.23057301, -0.37722018, -0.42078742, -0.16618308, 0.17153575, -0.16876237, 0.08843028, -0.14113204, -0.03411899, 0.11886298, -0.08734301, -0.08408642, -0.36495808, -0.006848245) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.024792045, -0.07902623, 0.060564704, -0.28697106, 0.31021893, -0.119998686, 0.09001586, 0.061179683, 0.46889278, 0.21364689, -0.09334822, 0.049430534, -0.062618054, -0.102397405, -0.3495793, 0.012354417) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.061257236, 0.031884216, 0.37455457, 0.23888901, 0.3389208, -0.18442735, -0.26667994, 0.044566445, -0.07193178, -0.022398662, -0.16970335, 0.272637, -0.08853152, -0.085192844, -0.32239014, -0.06123983) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

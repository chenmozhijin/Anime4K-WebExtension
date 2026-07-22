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

  var result: vec4f = vec4f(0.47972894, -0.12595561, 0.0076192874, 0.030127406);
      result += mat4x4<f32>(0.05669329, 0.07315613, 0.039424308, -0.2541082, -0.07249218, 0.26175272, -0.08881558, -0.118083045, 0.030772537, 0.16434018, -0.14866322, -0.18502471, -0.059117336, 0.08964473, -0.1782852, 0.052625313) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14389558, -0.065042995, -0.2950918, 0.4112333, -0.12861899, 0.258217, -0.031949118, -0.034143265, -0.11428257, 0.19247526, 0.07463659, 0.01839147, 0.009496701, 0.10846997, -0.12912787, -0.07279317) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03144594, 0.09140674, 0.06408843, -0.03414273, -0.12383837, 0.27004653, -0.009350919, -0.121839635, 0.099756666, -0.22924185, 0.014007349, 0.11446652, -0.010318026, 0.10010035, -0.25228918, 0.0003661669) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.026042435, 0.18795371, -0.0072437176, -0.10814703, 0.07985567, 0.20097938, -0.08487675, -0.106285594, 0.09707458, 0.03007273, -0.15000972, -0.43722683, -0.018664554, -0.008389023, 0.1654793, -0.13030206) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.44395566, -0.56511146, 0.66143507, -0.60104567, 0.13964528, 0.46794432, -0.089096956, -0.036978636, 0.3099659, -0.33782876, -0.20154743, 0.93005365, 0.031612076, -0.14991514, 0.58222, 0.13497819) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08714582, -0.29097143, 0.14383219, 0.03233456, -0.112939656, 0.5298559, -0.031214345, -0.21342169, -0.0091303615, 0.032940812, 0.2205512, 0.029974734, -0.094156325, 0.012824447, -0.1393054, -0.059670888) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08953138, -0.26114967, 0.010011165, 0.2358396, -0.08124566, 0.24884318, 0.036261503, -0.06165394, 0.026386073, 0.15839286, -0.044731468, -0.20554255, 0.010061076, 0.0019572282, 0.22426902, 0.08777197) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14257748, -0.09197529, 0.13358067, -0.037522234, 0.06024754, 0.25225255, 0.066104144, 0.015078542, 0.047949493, -0.18777491, 0.06691249, 0.29977927, -0.00487038, -0.05590136, 0.08878582, -0.19810142) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.026162645, -0.117423795, 0.12538214, 0.15949303, -0.16905032, 0.39578322, -0.09063542, -0.14214055, -0.015270332, -0.005083409, -0.08455155, 0.033921577, 0.12795745, -0.09451096, -0.1266083, 0.06940864) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.22385012, -0.33965832, 0.065689474, 0.114988424, 0.24671838, -0.20999265, 0.15365225, 0.20833229, 0.0690258, -0.11794976, 0.007372708, 0.11878442, 0.11250572, 0.020703577, 0.107532166, -0.06389372) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.17703258, -0.34769353, 0.21057537, -0.065440185, 0.14677191, -0.028087035, -0.17634447, -0.4064688, -0.02806667, -0.16469377, -0.119349875, 0.11174374, 0.028918805, -0.33163846, -0.07259594, -0.086798154) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.3096298, -0.18349265, 0.16579035, -0.037452627, 0.024048898, 0.16631834, 0.021211086, -0.041924585, 0.024848834, 0.11014154, 0.00631171, 0.10350366, -0.07236994, 0.2044514, -0.045401093, -0.19224702) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.26323333, -0.075991966, -0.10719386, -0.20329621, 0.08265197, 0.056784503, 0.011410616, -0.30782765, -0.048666727, 0.05019364, 0.16627388, 0.3590602, 0.10613875, 0.33532232, -0.062078543, -0.37519804) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.16206564, 0.24540965, 0.18950756, -0.360017, -0.551692, -0.78239375, 0.38530654, 0.6579247, -0.47283742, 0.36568493, 0.24292865, -0.3670167, 0.41284454, -0.24387984, -0.03254048, -0.018685695) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.31169248, -0.2655073, 0.0747915, 0.109487206, -0.031733565, 0.23250957, 0.23558825, -0.16572464, 0.0017788525, -0.18028545, -0.17200927, 0.028172726, 0.070380226, -0.2702175, 0.13572605, -0.27639595) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.15000193, -0.18601346, -0.004303691, 0.31852263, -0.003971246, -0.06477847, 0.08195318, 0.117634684, 0.064652786, -0.08044626, -0.011418961, 0.15140016, 0.19943193, 0.042755328, 0.018692015, -0.03151068) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18450215, -0.8378772, 0.13724457, 0.29837617, 0.1394845, 0.29189417, -0.07846061, -0.12485211, 0.20189336, -0.18768942, -0.06950993, -0.4061385, -0.054434035, 0.09698275, 0.05824335, 0.07530624) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.18368134, 0.27173626, 0.0802287, 0.30710486, 0.103175566, -0.0061353073, -0.0035416405, -0.26731282, 0.047188826, 0.09900232, 0.024074, -0.13305503, -0.030665481, -0.0903751, 0.061394546, 0.15501407) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

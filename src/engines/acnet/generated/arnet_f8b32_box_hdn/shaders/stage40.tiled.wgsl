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

  var result: vec4f = vec4f(0.032844447, 0.050763067, 0.29507098, -0.018211408);
      result += mat4x4<f32>(-0.02254916, 0.14143988, 0.025309488, -0.0026772828, 0.005064567, -0.42467704, -0.2917025, -0.3624842, -0.030493716, -0.01881573, -0.01570964, 0.32515827, -0.081959344, -0.12565862, -0.4596332, -0.14742498) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.020118266, 0.17637089, -0.0659364, -0.35679346, 0.35890836, 0.43593982, 0.71038586, 0.5164035, -0.15701799, -0.100418635, -0.09859991, 0.060247533, 0.112037726, 0.26489818, 0.16959822, 0.036451425) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0058105714, 0.15627031, 0.09102759, -0.024529202, 0.010675983, -0.031395257, 0.0959318, 0.34019724, 0.02423846, -0.20363209, -0.070409015, 0.22932291, 0.035925794, -0.09549098, 0.049416773, 0.19751652) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.031585086, -0.17485566, 0.07577024, -0.40155807, -0.15738602, 0.28502926, -0.44795156, 0.08557443, 0.02222879, -0.3295447, 0.071426876, 0.29967853, -0.27301928, 0.19277927, 0.10484095, 0.009816714) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.07161207, 0.24638511, -0.29639956, -0.66999453, -0.17681617, 0.24771114, -0.44601777, 0.7192636, -0.0840066, -0.5276156, -0.022144424, -0.09227041, -0.13467751, -0.38454533, 0.2555927, 0.38132438) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.009908657, 0.26894745, -0.071797244, -0.19402373, 0.01718042, -0.06602215, -0.07162581, -0.11577335, 0.05427458, -0.25775492, 0.13020234, 0.1466031, 0.15090546, -0.16536245, -0.13775827, 0.0026802835) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.006236168, 0.13493936, 0.07077328, -0.26129776, 0.23336463, 0.15095639, -0.27363324, 0.21062095, -0.04818276, -0.37810278, -0.34469092, 0.40001017, 0.14951581, 0.17987442, -0.4848584, -0.22182314) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10637712, 0.061012782, 0.09491166, -0.2750641, -0.014509683, 0.036379848, -0.34136936, 0.2851849, 0.026886707, 0.071676835, -0.6613555, 0.3292099, 0.19585638, 0.021091921, -0.29195872, 0.17307821) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11195367, 0.19399548, -0.076005876, -0.23112194, 0.1246309, -0.23480797, -0.30478024, 0.27403826, -0.057529267, -0.2597996, -0.018424783, 0.38296452, 0.04870795, -0.018229192, 0.059239276, -0.032534204) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.15479766, 0.26299667, -0.09153808, 0.03643185, 0.09463944, 0.076300204, 0.1351568, -2.6196436e-05, 0.06755397, -0.1487775, 0.028671566, 0.22623816, -0.12763421, 0.051548745, -0.0001906193, 0.20148394) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21690369, 0.095328905, -0.19918509, 0.096271284, 0.1585761, 0.29007837, 0.19241367, -0.013206931, 0.15566805, -0.34746397, -0.0055721225, 0.3133837, -0.2113329, -0.040614594, -0.1473139, 0.31485203) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13683744, 0.15072711, -0.09612646, -0.3778114, -0.04821849, 0.24036306, 0.21528724, -0.09938681, 0.062060438, -0.20917933, -0.021910354, 0.100551814, -0.1114709, -0.07800558, -0.06318261, 0.14507277) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.049313694, 0.13215128, 0.22905199, 0.59464616, 0.110136874, 0.10405263, 0.09852008, -0.13070922, -0.0037234325, -0.15396947, -0.10248208, 0.16091639, -0.12689967, -0.063793875, 0.014688437, 0.32623553) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23835233, -0.6548214, 0.05589729, 0.17729725, 0.11977901, 0.24234496, 0.09455428, 0.19451429, 0.17092203, -0.6593219, -0.24959256, 0.5256295, -0.44823858, -0.15975729, -0.47048762, 0.2361106) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.106505215, -0.080075294, -0.107553154, -0.4086319, -0.03058409, 0.029233674, 0.17338453, -0.20957541, 0.046102934, -0.4657161, -0.11366519, 0.21054554, -0.23318744, -0.3033927, 0.057393193, -0.0019874899) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0075871395, 0.16125593, -0.13312376, 0.110975094, 0.1976357, 0.20714897, 0.06557453, -0.11870976, 0.018923374, -0.17437811, -0.07885089, 0.19886826, -0.32552615, -0.18192641, 0.06782746, 0.13351099) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15712163, 0.045852456, -0.465208, 0.30836838, -0.003307919, 0.24483544, 0.28365892, -0.16430451, -0.013513775, -0.064278945, -0.11686371, 0.08874487, -0.38869512, -0.23693487, 0.0028963361, 0.37282634) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10162679, 0.22959542, -0.4704398, 0.06947065, -0.002821321, 0.39677292, 0.3266833, -0.4587859, 0.071630314, 0.010894149, 0.057442144, -0.12079138, -0.17762786, -0.08468676, -0.0064145247, 0.08955222) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

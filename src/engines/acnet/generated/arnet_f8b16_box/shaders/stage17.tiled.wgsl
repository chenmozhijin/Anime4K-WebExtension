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

  var result: vec4f = vec4f(0.1602705, 0.07300875, 0.119382754, 0.40166366);
      result += mat4x4<f32>(0.09962467, 0.1338799, -0.0610412, -0.030228948, 0.07242906, -0.10791199, -0.07284146, -0.116830334, -0.059306875, -0.04208019, 0.09005695, 0.051192645, -0.14354849, -0.031167895, 0.08803222, 0.15938342) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.044435233, -0.06322487, 0.04702145, 0.091100276, 0.038202822, -0.3350083, -0.018121202, -0.14442354, 0.02402437, 0.15273479, -0.13234656, -0.0275021, 0.124643415, 0.23276597, 0.23983932, 0.1603189) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.015510616, 0.26013228, 0.001775839, -0.035756774, -0.03635606, -0.13392855, -0.03862761, -0.013717125, 0.052756034, -0.10310541, -0.04615043, 0.0013656822, -0.025598766, 0.031831305, 0.08659301, 0.16886763) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.24736013, 0.15997536, 0.024328412, 0.017929638, -0.15588607, 0.01511515, -0.15864284, -0.021111706, -0.044693567, -0.11626157, 0.15060376, -0.08895963, -0.22590318, 0.116346225, 0.08739339, 0.15116893) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6840703, 0.11455234, -0.14757195, 0.02789914, -0.21191843, -1.0240728, -0.41947165, -0.21780887, -0.62638324, 0.744471, 0.0014910479, -0.35794646, 0.22663741, 0.46974954, 0.30649173, -0.06988822) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.046496976, -0.011023488, 0.11386634, 0.18733104, -0.36005044, -0.2105233, -0.11812258, -0.117551975, 0.27639714, 0.12001154, -0.012863768, -0.048753284, 0.115673006, 0.26248875, 0.31102937, 0.21499625) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06561361, 0.05679675, -0.10577457, -0.17349912, 0.13259593, -0.2598962, -0.12562047, -0.2664118, -0.2193032, 0.035896108, 0.11337028, 0.27625793, 0.26997933, 0.061813965, -0.040500607, -0.09956409) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3864985, 0.3533135, 0.0068252794, -0.14603026, -0.088441946, -0.1767704, -0.52324927, -0.32097793, -0.23612274, -0.4151328, 0.13832058, -0.21196494, -0.08752902, -0.083501674, 0.09775666, 0.23157285) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.23723313, 0.18259883, -0.019876238, -0.018520065, 0.016866952, -0.32083896, -0.004330831, -0.057538476, 0.09832629, 0.24875538, -0.00065189874, -0.024488363, 0.118625864, -0.14932883, 0.03604551, 0.23786114) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05914298, -0.13988951, 0.15880664, 0.13044667, -0.109780334, 0.09631665, -0.0487419, 0.030249422, 0.13475743, -0.13115028, 0.020095237, -0.08802924, 0.20634453, -0.089223385, 0.12595116, 0.0063702944) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.23389296, -0.09020583, 0.05241486, 0.06686968, -0.22412334, 0.16642064, -0.09749562, -0.03218396, 0.20123826, -0.2726558, -0.18653542, -0.16199948, 0.45867682, 0.067747496, 0.02707933, -0.06615151) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08313972, -0.044026162, 0.028039342, -0.030123351, -0.12270372, 0.23599558, 0.03683477, 0.06795011, 0.06162159, 0.014312215, 0.12308246, 0.106624, 0.40419263, -0.070973344, 0.1713086, 0.06655983) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.19580127, -0.32756984, 0.0410801, 0.10831551, 0.12598799, 0.21687171, -0.011330053, 0.022073861, 0.5465556, 0.07028593, 0.40681136, 0.048666064, 0.0152499955, -0.12056225, -0.042155903, -0.060907513) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.58462197, -0.41146642, -0.16709451, 0.20040111, 0.027269356, 0.4200585, 0.1941686, 0.17064436, 0.21329822, 0.4934402, 0.56536347, 0.035970405, 0.29143825, -0.048821583, -0.121528365, -0.3278858) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.017564157, -0.23585126, 0.13508394, 0.07756596, 0.052238423, 0.18805894, -0.008908074, 0.12678005, 0.18777636, 0.01724318, 0.08455248, 0.08848713, 0.31451076, -0.14303961, 0.18179056, 0.08807659) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.15548924, -0.11625776, 0.14800417, 0.2931811, -0.020394819, 0.22366983, 0.13826233, 0.16226515, 0.085985616, 0.012106943, 0.1632312, -0.007484284, -0.09264218, 0.076448776, 0.020967247, -0.005567515) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.5428421, -0.30560535, 0.14495972, 0.26196504, -0.16035853, 0.37172472, 0.10419695, 0.019534964, 0.06978077, 0.01887809, 0.07354377, -0.0024385538, 0.21506627, -0.0539668, -0.07152906, -0.1614998) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19029152, -0.5706446, -0.09958515, 0.14101955, -0.17457941, 0.024604198, 0.071152225, 0.048480794, 0.05211832, -0.15556495, 0.021905286, -0.004488118, 0.17003994, 0.09567225, 0.011385386, -0.010394089) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

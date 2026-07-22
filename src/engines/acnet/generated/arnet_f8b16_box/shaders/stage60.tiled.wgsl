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

  var result: vec4f = vec4f(0.094571725, -0.07212767, 0.10971717, -0.053645507);
      result += mat4x4<f32>(-0.019676518, -0.021842947, -0.00037281786, -0.003269566, 0.093840666, 0.043366075, 0.027328007, 0.043659855, -0.009757194, -0.108457975, -0.086351775, -0.055118933, 0.04941885, 0.032270286, -0.01152625, 0.012972411) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.27793238, 0.03991357, 0.24627656, -0.34840998, -0.16584548, -0.04327451, -0.1084562, -0.15690061, 0.08042239, -0.0042705494, 0.11750337, -0.0074591828, -0.06712493, 0.23636827, 0.097781844, -0.053290468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.017399423, -0.08142975, -0.026888302, -0.13119441, 0.019324195, -0.048270263, -0.06183672, 0.009318146, 0.07792539, 0.024414973, 0.08086402, 0.21444859, 0.03632639, 0.0052660345, -0.07245012, -0.07419352) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.20088659, -0.14062157, 0.33409956, -0.055222955, 0.020592853, 0.0033800956, 0.15970357, 0.22079837, 0.0056846254, 0.057100385, 0.027226172, 0.0050142743, 0.060439393, 0.061702352, 0.08961366, 0.075143114) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.09446458, 0.33412534, 0.33387235, 0.14854483, -0.33915308, 0.11026254, -0.6739253, 0.45811772, -0.31536734, 0.029428441, -0.47537178, 0.71951705, -0.35882878, -0.08385439, 0.27135417, -0.22674145) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.063763484, 0.111332834, -0.3986707, 0.030546505, 0.090719976, -0.038885184, -0.13385384, 0.008676601, -0.25350693, 0.04221006, 0.21630414, 0.10788423, 0.046007715, -0.05084824, -0.05694819, -0.056551326) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.024495188, -0.10869017, 0.089714356, -0.1299566, 0.0038983587, -0.06465747, -0.09497681, -0.049309153, 0.066784784, 0.04728496, 0.10105655, 0.1377531, -0.100428276, 0.015943475, -0.060378842, -0.17336401) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.13385774, -0.16921876, -0.18235746, 0.16979931, 0.28701654, -0.27783054, -0.09067212, 0.4195954, 0.016576163, -0.03579624, 0.290626, 0.16577657, -0.1641108, 0.21339916, 0.016854558, -0.26122156) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.022787431, -0.19899487, -0.036029335, -0.051287655, 0.028365528, -0.028332556, 0.0023757957, 0.060861014, -0.0028044905, -0.17109373, -0.18708621, 0.041265614, -0.009293697, 0.005668768, 0.0030245401, 0.047330815) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.006016295, 0.049124755, 0.053548295, -0.020359376, -0.08826531, -0.07394296, -0.118396744, -0.15816289, -0.037638847, -0.15675445, -0.22890042, 0.2568184, 0.076438144, -0.09498327, 0.006134335, 0.16756399) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.014688581, 0.057645682, 0.06754611, -0.07659575, -0.019143483, 0.02318349, -0.01121636, -0.009936877, 0.10619993, -0.12468649, -0.06526694, -0.21654977, 0.013948088, 0.10016881, -0.032638717, 0.11162147) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.045576625, -0.1668212, -0.14991811, -0.0004071221, -0.06397059, -0.053118624, -0.03909907, -0.16249064, -0.083855376, -0.0070430017, 0.020739553, -0.024647126, 0.052260533, 0.07229002, 0.02178754, -0.01910126) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.037602585, -0.009170356, 0.025152693, 0.062366553, 0.050894868, -0.09857413, -0.10159827, -0.11967143, 0.013377041, -0.59514296, -0.31806302, 0.4482067, -0.19379345, 0.2544541, 0.1615517, 0.025327198) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07271634, -0.20903519, -0.15763171, -0.2328294, 0.31843776, -0.012807942, 0.45606267, -0.46500093, 0.2667916, -0.06529967, -0.10942739, -0.109493345, 0.51158947, -0.318623, 0.3405794, -0.47057492) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.7092115, 0.13412264, -0.6820451, -0.17714141, 0.1937687, 0.5904523, 0.15777123, 0.33305243, -0.041568287, -0.13433862, -0.052168738, -0.08412551, -0.08674246, 0.04250487, 0.07158514, -0.028052792) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.00087791996, 0.019536182, 0.0120437, -0.021477107, 0.0560179, -0.018229386, 0.01676921, 0.09296276, 0.04711113, -0.039214358, 0.08283031, 0.2558612, -0.023938125, -0.06615556, -0.03952322, -0.19558503) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.032576546, -0.13087273, -0.012042164, 0.022600498, -0.111404054, -0.15768841, 0.022141667, -0.052445516, 0.087765135, 0.13654634, -0.018248808, 0.0024466577, -0.010758197, 0.16097216, -0.0022161193, -0.04127665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.022018526, -0.14286615, -0.053976107, -0.0780107, -0.2055087, 0.3965234, 0.040744275, -0.5364792, 0.027361447, -0.07911839, -0.041042935, -0.02451964, 0.029044216, 0.01322893, -0.011917966, 0.08244096) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.07991916, -0.098631285, 0.07052626, -0.29552108);
      result += mat4x4<f32>(0.070903495, -0.1577285, 0.2388406, 0.18850861, -0.021314627, -0.10653579, 0.035034183, -0.031065188, 0.046281137, 0.069949396, -0.0059137554, -0.08845691, -0.022224627, -0.17647979, 0.22812065, 0.13843556) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0647687, -0.14879528, 0.22744176, 0.24963471, 0.07774564, -0.20455149, -0.0349895, 0.10701348, -0.024335893, 0.15741831, 0.13271597, 0.032299902, 0.065062255, 0.022648685, -0.09025852, -0.17260733) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20566003, 0.06660198, 0.43245378, -0.21559715, 0.08362546, -0.061485056, 0.053153764, 0.020273251, 0.049024478, -0.07728122, 0.034973856, -0.06860096, 0.01989297, 0.15226318, 0.07172992, -0.1154969) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06064679, 0.35906947, -0.28220263, -0.22015265, 0.008761267, 0.12254758, 0.002974396, -0.19488284, 0.069514066, -0.23508023, 0.2932939, 0.45162648, 0.079356275, -0.20470434, 0.08521733, 0.08522491) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.124902025, -0.17023565, -0.068390414, 0.0021031762, 0.42602828, 0.007023983, 0.15826248, 0.02266655, 0.10274186, -0.34628305, -0.54089624, 0.26072568, -0.15134415, 0.58812946, -0.38708505, -0.4952491) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.17507578, -0.24693441, 0.17849231, -0.33939075, -0.012414534, 0.06939359, -0.14593673, -0.047776677, 0.05873449, 0.19209473, -0.0008496842, -0.16494925, -0.059097197, 0.15914477, -0.20297584, -0.19083887) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.020304443, 0.20335244, -0.15493423, -0.13692579, 0.12903227, 0.15272702, -0.09727663, 0.10202553, 0.05158213, 0.09995796, -0.30836603, 0.08203748, 0.08362398, -0.07377217, 0.15726572, 0.11022949) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.059936494, 0.39315417, -0.21125576, -0.3234453, 0.34478235, 0.36643973, -0.26874134, -0.105630346, -0.06957446, -0.05091796, -0.3134848, 0.27158505, 0.05217956, -0.065991364, 0.3434018, 0.46295768) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11193864, 0.08833506, -0.022960244, -0.1109114, -0.08372566, -0.13963893, -0.13817264, 0.024626961, 0.03333057, 0.032386336, -0.017827867, 0.07726807, -0.2421165, 0.20506947, -0.15826625, 0.18727158) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-6.8881505e-05, 0.225799, 0.0117237065, -0.052275803, -0.051090248, 0.07653938, 0.041999076, -0.08927956, -0.010599483, -0.021088006, 0.06605404, 0.063056216, -0.03483125, -0.013791117, -0.018328793, -0.013839531) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.012509222, -0.12139784, 0.2752784, 0.23327112, 0.061628975, 0.045599643, 0.19120902, -0.028119404, -0.060911782, 0.19162358, 0.06633846, 0.06766098, -0.09748655, 0.05997024, -0.16190377, 0.038591966) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.015189091, -0.20669033, -0.041639566, -0.030835368, 0.079554476, 0.064499624, 0.067333385, -0.4062882, -0.20440198, 0.42284042, 0.45453995, -0.16026911, 0.048797246, -0.11853262, 0.09076838, 0.10159626) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.074525125, -0.021031067, 0.14152911, 0.18205783, -0.031520072, 0.20926473, -0.11143146, -0.26000217, -0.19418383, 0.09237678, -0.15825441, -0.18663281, -0.056917667, 0.05720521, -0.13363615, -0.10629985) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.35052416, 0.15689307, -0.15589741, -0.3202738, -0.042562768, 0.0895141, -0.31703517, 0.10558765, -0.11805454, -0.25520548, 0.48912364, -0.008336243, 0.053630807, -0.61914283, -0.7092681, 0.28144222) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09204104, 0.19895877, 0.101332426, -0.10578147, 0.20741577, -0.13324767, 0.10346665, -0.2580462, -0.11416482, 0.14818239, -0.2222764, 0.36777768, -0.028449839, -0.08041732, 0.027157474, 0.11262308) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.032035287, -0.20387234, 0.04932906, -0.0064319484, -0.022717528, 0.056946725, -0.10003088, 0.04607113, 0.018055473, -0.0077107167, -0.0068488615, -0.007318523, -0.14161944, -0.10373453, -0.065979436, 0.10396706) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19238786, 0.012134103, -0.08791164, 0.09902332, 0.04985483, 0.21369015, -0.022092042, -0.0796018, -0.07850544, 0.30540034, -0.19833834, 0.011670104, -0.054052334, 0.22617313, 0.091719255, -0.22907709) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.045181252, -0.0011546278, -0.0148120215, 0.13497207, -0.11332132, 0.054283034, -0.06291041, -0.05264188, 0.03710741, -0.1977775, -0.007662517, -0.03388605, -0.13150543, -0.08314972, 0.064104035, 0.052243326) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

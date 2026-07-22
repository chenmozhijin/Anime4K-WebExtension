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

  var result: vec4f = vec4f(-0.037294008, 0.094073266, -0.0014478131, 0.099864215);
      result += mat4x4<f32>(0.04729244, 0.0048467475, 0.036170572, 0.049587645, 0.107629314, -0.05624512, -0.09151745, -0.09160011, -0.016100228, -0.015734054, 0.0012409171, -0.061640013, 0.007251337, -0.0061759385, 0.0072491565, -0.13146454) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.029726757, -0.07799768, -0.04676528, -0.0820713, 0.19049685, 0.15851633, -0.11079194, 0.024719948, -0.1291055, -0.1087595, 0.14648388, 0.08101045, 0.1149005, 0.073823534, -0.011743729, 0.06337972) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04085989, 0.083673544, 0.12316756, 0.26150244, 0.06658185, 0.081873715, 0.03273329, 0.008745702, -0.016607702, -0.3021075, -0.32305914, -0.40031445, 0.048334606, 0.07173764, 0.07741923, 0.2127255) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.039615054, 0.041918837, -0.28501102, -0.04077627, -0.0035253777, 0.23698445, -0.08400143, 0.076978356, 0.043057643, 0.04244604, 0.033997197, 0.012063635, -0.15310775, 0.12154582, -0.15341264, -0.1705913) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.35201135, 0.17712787, -0.45586213, -0.14198725, 0.32761085, 0.13885388, -0.3706744, -0.40628615, 0.26428396, -0.5493914, 0.46297082, -0.21590932, 0.23723784, 0.23856324, -0.4354247, -0.5348471) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.055787, -0.10405425, -0.11951176, -0.15103413, 0.06454629, 0.08208688, 0.027112424, 0.039137535, 0.031068074, -0.54573965, -0.07874612, -0.4556822, 0.0974217, 0.17125225, 0.09312073, -0.03626432) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.14724371, 0.047031663, -0.08262933, -0.08231923, 0.03959888, 0.13487363, -0.0008151574, -0.03996579, -0.08682461, -0.022588942, -0.032301176, -0.08744167, 0.13792431, 0.20435165, 0.16036442, 0.23466699) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11840445, 0.01972079, -0.20609581, -0.19060405, 0.009125153, -0.051446527, 0.021603193, 0.05798302, 0.080036744, 0.21692418, -0.044033837, -0.07273576, 0.06562333, 0.017685572, -0.030259086, -0.2869222) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0665472, 0.013995923, 0.025963837, 0.15216193, 0.050580643, -0.057918772, -0.07038779, -0.058474664, 0.006960651, -0.10881132, -0.13739993, -0.10579117, -0.026989771, 0.0820282, 0.06127319, 0.06469565) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.060288537, 0.14011423, 0.096242584, 0.1905214, -0.00639638, 0.023585819, -0.052870505, -0.10414703, 0.02857281, -0.078003734, -0.20088379, -0.20247185, -0.082019515, -0.036516365, -0.029959055, -0.025983894) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0026990455, 0.026170941, 0.2927609, 0.31650513, 0.03720347, -0.0857467, -0.24494755, -0.55544615, 0.03133837, -0.24874577, -0.15246263, -0.16353475, 0.06556471, 0.09755523, 0.19626573, 0.42895722) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05320972, -0.01449006, -0.18913794, -0.2240733, -0.6124042, -0.13273692, -0.09132857, -0.10803808, 0.060116846, 0.050255574, 0.05928073, 0.031349197, 0.053745467, -0.0335991, -0.18885127, -0.23646154) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0663891, 0.056403987, 0.1358108, 0.2783717, -0.008758257, -0.033687968, 0.033253543, 0.07944016, 0.10285657, 0.10053156, 0.024719292, -0.17592762, -0.057022966, -0.26996803, 0.028731434, -0.047751818) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.011699244, 0.04243743, -0.14688537, -0.09203923, -0.029078726, 0.035675757, -0.17990154, -0.41344425, 0.45944226, -0.13309132, 0.19324672, -0.52819675, 0.054268118, 0.41712797, -0.44600004, 0.0080310935) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.26475102, -0.023739755, 0.14608039, 0.37240583, -0.00050070556, 0.192652, -0.032737184, -0.29954976, 0.05883956, -0.013284729, -0.14893477, -0.09651712, -0.21123783, -0.08768339, -0.09260706, 0.42285872) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0026638054, 0.035392158, -0.039589822, -0.06507272, -0.05392399, -0.08627895, -0.079529576, -0.14164212, 0.10033998, 0.21478479, 0.1645571, 0.11184488, -0.10263854, -0.12502696, -0.04499914, -0.046290707) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07749022, -0.117044896, -0.0018099195, 0.024264475, -0.09480104, -0.22425899, -0.0139916865, 0.09537019, -0.02868739, 0.0064179827, 0.07720827, -0.32750893, -0.0030198, 0.04927345, 0.22290972, 0.36022347) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.029805098, -0.037919916, 0.13109323, 0.26091036, 0.0057144864, 0.17135221, 0.08207636, 0.12566824, 0.06475197, 0.01214, -0.039622508, 0.055476405, -0.009865924, -0.01882364, -0.049570736, -0.120270595) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

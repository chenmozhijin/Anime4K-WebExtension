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

  var result: vec4f = vec4f(-0.03636173, 0.16416384, -0.098625235, 0.062015932);
      result += mat4x4<f32>(0.05246458, -0.074253894, -0.21140036, 0.060658187, 0.28364086, 0.08109755, 0.20432143, -0.07504685, -0.2720428, -0.038311258, -0.16838394, -0.023890456, -0.03016492, -0.057565674, -0.011785706, -0.003832493) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1281293, 0.07511671, -0.23886612, 0.028553735, 0.039746974, 0.10568093, 0.7504653, -0.07218467, 0.33435392, -0.08887045, -0.28549328, 0.26697978, -0.08366593, -0.2510636, -0.050265096, -0.0028849598) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14909956, 0.18565992, -0.16723968, 0.020739406, -0.05797994, 0.12025694, 0.018171258, 0.05416817, 0.06195611, -0.22168127, 0.16715086, -0.08608405, -0.033583347, -0.034122672, -0.26890382, -0.13335007) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.02848637, 0.18496963, -0.17879154, 0.029710827, 0.04718179, 0.14412786, 0.11185336, -0.011434699, 0.117529005, -0.061156947, 0.38396505, -0.18005349, 0.0041452874, 0.15704045, -0.072714485, -0.025573732) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.058511704, -0.5449893, -0.5845294, 0.10290341, 0.081524655, 0.44276717, 0.5388031, 0.088279456, 0.28411195, 0.4132828, 0.13149187, 0.066387095, -0.4567324, -1.0081418, -0.14796925, -0.082540415) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11077395, -0.31780416, -0.08398815, -0.21848015, 0.010964352, 0.53290814, -0.077947594, 0.021169191, 0.01955705, -0.18113005, 0.04908528, 0.053424682, 0.026546003, -0.56792194, -0.13016419, -0.41266388) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13980539, -0.14758095, -0.2644581, -0.020487024, 0.08055172, 0.31707987, 0.4381427, -0.0030830621, -0.15647873, -0.5386154, -0.21433291, 0.08551996, 0.05421753, -0.2147842, 0.09861967, -0.14745434) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.080838725, 0.1962696, -0.046990033, -0.2981327, 0.2535391, 0.26254666, 0.07725648, 0.72228646, 0.29492727, 0.014946819, 0.054892868, -0.5857913, 0.05617179, -0.42049938, 0.061657995, -0.1134224) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.055546526, 0.115187235, -0.21784088, -0.018907985, 0.27432644, -0.13278377, 0.5118355, -0.08284639, -0.33205387, 0.32397592, -0.39104778, 0.15137187, 0.17254353, -0.38015532, -0.03348887, -0.13160403) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.11095307, 0.06889935, 0.31307763, 0.09418969, -0.004202773, -0.020126224, -0.11899989, 0.11105476, 0.21437293, -0.20487936, -0.35688156, 0.1689722, 0.0879105, 0.08354922, 0.14038245, -0.16024907) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.17214577, 0.035638027, 0.27601117, 0.0392735, -0.18464188, -0.20639764, -0.4723969, 0.03726674, 0.6453709, 0.0031993953, 0.128875, 0.08001116, 0.110324115, 0.37150553, -0.16578151, 0.251773) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.049587242, 0.110326014, 0.10014807, -0.008324511, -0.012500045, -0.14720991, -0.19898301, 0.013912057, -0.13857716, -0.46550688, -0.0041625095, -0.1096379, 0.37763914, -0.39393067, 0.29890206, -0.28720078) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2501153, 0.019797787, 0.2380893, 0.1491529, 0.013500462, -0.11341976, -0.3094135, 0.1258606, 0.21066026, -0.13286668, 0.36516815, -0.64647067, 0.20789929, -0.12735216, -0.2443634, -0.072484255) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1962919, -0.07787492, 0.02942471, 0.18284166, -0.20678169, 0.05252839, -0.43738312, -0.19255666, -0.4134499, -0.19825184, -0.11062729, 0.4599261, 0.1925628, 0.040017266, 0.3511867, -0.15345778) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14831536, -0.17583317, 0.15417524, 0.057563912, -0.063684314, -0.14022171, -0.5126268, 0.058680892, 0.14689687, -0.042148154, -0.1383763, 0.058308262, 0.13000993, 0.3376543, 0.20905434, -0.23390643) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.036081515, -0.10588836, 0.060331635, 0.12336892, 0.15151644, 0.04251758, -0.20454398, -0.02043186, -0.11469038, -0.34537625, 0.057383567, 0.008932643, 0.025215272, 0.15925555, -0.14295654, 0.03674131) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.041709498, -0.15189691, 0.108351015, 0.085965015, 0.032265626, -0.19474953, -0.19147539, -0.14697379, 0.022325736, 0.18307152, -0.063747026, -0.0015708789, 0.13064504, -0.19137125, 0.25386375, 0.0641529) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12413213, -0.1488705, 0.014711531, 0.10359097, -0.049046654, -0.080263324, -0.10763501, -0.14838289, 0.027200008, -0.16819347, 0.025710804, 0.03346, 0.1288333, 0.03138815, 0.044020586, -0.013190241) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

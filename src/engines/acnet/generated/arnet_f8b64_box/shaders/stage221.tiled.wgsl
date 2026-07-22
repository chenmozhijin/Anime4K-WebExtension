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

  var result: vec4f = vec4f(0.026349364, -0.27470663, 0.16088763, 0.025533853);
      result += mat4x4<f32>(0.051116023, -0.024806937, 0.04137771, 0.03679835, 0.003222912, -0.03323464, -0.0640026, 0.09836729, -0.012648229, 0.052490547, 0.08485864, 0.05774548, -0.10494302, 0.07923602, -0.005786126, -0.021970326) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.005789122, 0.055010125, -0.0646325, -0.046361826, 0.02080264, 0.098183624, -0.15691322, -0.022035113, -0.15351745, -0.2885008, -0.47460583, 0.057516336, -0.010658329, 0.006545108, 0.008024832, 0.024085185) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.021733403, 0.012148976, 0.019427737, 0.078597955, 0.1159282, 0.021322398, 0.012164261, -0.06395698, 0.006498891, 0.1455481, 0.13798843, -0.12379779, -0.040141817, 0.03636246, -0.02555657, -0.10789284) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0031846308, -0.04577741, -0.09526964, 0.03229435, 0.2025445, 0.072336905, -0.038939282, -0.07732081, -0.022891339, -0.1500103, -0.10865335, 0.09886672, -0.09011174, -0.005406483, 0.01583931, 0.18381579) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16063021, -0.24512461, -0.25854358, -0.118857, 0.30996296, 0.07701919, -0.06590199, -0.15150549, 0.034350794, 0.19240472, 0.21015713, -0.043594994, -0.15970223, -0.023488576, -0.13596052, -0.085829526) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19354, -0.060558796, 0.06912703, 0.1408244, 0.22952504, 0.0036416182, 0.123179674, -0.22000943, 0.1216653, -0.1067461, -0.050098058, 0.23466745, -0.033175502, 0.0321751, -0.06735228, 0.051228266) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05228963, -0.055626336, -0.0062722606, 0.09642912, 0.105633445, 0.033125065, 0.047351196, -0.009872019, 0.07865353, 0.14698724, -0.024623122, -0.043478318, -0.13828284, 0.22967142, -0.35898504, 0.009342992) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09435109, -0.056633804, -0.0004223649, 0.032827772, 0.1554392, -0.12578578, 0.043350317, -0.11596799, 0.1209974, -0.13102849, 0.16505435, 0.4308184, -0.059747163, 0.07510395, 0.10995048, -0.15913367) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07444465, -0.0015894256, 0.054022104, 0.010852867, 0.054035652, -0.04463146, -0.018769156, -0.0002876076, 0.031886667, -0.22010456, 0.14643134, 0.018598128, -0.053133883, 0.0071672536, 0.064412124, -0.14117354) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16593628, 0.026413914, -0.020029465, -0.18353328, -0.08896822, 0.012324302, -0.03538367, 0.02940083, -0.034181025, 0.031424716, 0.0015750036, -0.061764393, -0.024422832, 0.044599168, -0.0028722584, -0.009701263) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.06072871, -0.49628326, 0.5910302, -0.08182219, -0.17706695, 0.014122373, -0.057132766, 0.0025624225, 0.17032468, 0.055719167, 0.15653844, -0.1782778, 0.07911316, -0.09786127, -0.13025343, 0.12913084) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.069090955, 0.085825585, -0.16937278, -0.09429086, -0.124421656, 0.088063225, 0.008560415, 0.03491904, -0.10239734, 0.10748278, -0.10680556, -0.07929372, 0.07111791, -0.11604048, -0.031115398, 0.040326487) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.10672364, -0.009659491, 0.31557563, -0.06939777, -0.08967474, 0.11428922, -0.0393504, -0.109078355, -0.053605117, 0.0020416812, 0.033136576, -0.059711516, 0.06844496, -0.031614028, 0.19582455, -0.09292163) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.10499099, -0.6550339, 0.89974546, -0.22880064, -0.42999992, 0.27733397, -0.2809299, 0.079509854, -0.24488442, -0.0108816335, -0.18259929, -0.059234634, 0.24572198, 0.19661596, -0.41720548, -0.026929913) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.05630247, -0.06681014, 0.07455035, 0.023818517, -0.20297138, 0.13410328, -0.3236477, 0.1428005, -0.083463095, -0.08859253, -0.04494561, -0.05435814, 0.02935, 0.06851476, 0.11646714, -0.17693335) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.15424809, -0.1509458, -0.16306424, 0.14573637, -0.12137647, 0.07084542, -0.064218365, -0.0015331183, 0.028085032, -0.006442831, -0.0035634409, -0.03176551, 0.0691204, -0.024562756, 0.030653113, -0.07636006) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07041078, 0.049655396, -0.03646102, -0.3001945, -0.16771798, 0.107847586, -0.10722602, 0.035816446, -0.036148608, 0.046227448, -0.017790234, -0.014354575, -2.963958e-06, -0.5529908, -0.16784245, 0.22643062) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.010370099, -0.024255082, -0.05170917, 0.13612768, -0.123751044, 0.035503745, -0.112252854, 0.124631844, -0.04669631, -0.021155778, -0.019715965, 0.012038801, -0.010096947, 0.007529043, -0.065486856, 0.11805242) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

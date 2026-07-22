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

  var result: vec4f = vec4f(0.41245967, 0.22508037, -0.2162224, 0.063098006);
      result += mat4x4<f32>(-0.09342162, -0.19443735, 0.053466085, -0.28265426, 0.00937769, -0.12282545, -0.008773583, -0.02558435, -0.34415734, -0.32353342, 0.37299836, 0.18070681, 0.0328865, 0.2654119, 0.031281125, -0.086269505) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.42580062, -0.57856745, 0.2823693, 0.47546506, 0.10093517, -0.2585536, -0.38301516, -0.030685373, -0.26244488, -0.13700545, 0.26828226, 0.67320114, 0.023313062, 0.2451811, -0.0012271749, 0.00070994755) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.4755776, -0.28016445, 0.2737167, 0.5240828, 0.027774341, -0.09064557, -0.18636765, -0.09172665, 0.28883153, 0.38657892, -0.176353, -0.061855044, 0.057689942, 0.10017048, 0.10020821, -0.03137155) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.19408102, 0.08734502, -0.12382513, -0.37127757, 0.053948246, -0.16059701, -0.019876411, 0.027288344, -0.3847091, -0.29819822, 0.00031060886, 0.09361233, -0.3152354, 0.75564575, 0.22606273, 0.07755417) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19090027, -0.4040928, 0.06178027, 0.120831646, 0.4085543, 0.04919844, 0.9327849, 0.053379595, -0.028561642, -0.22389488, -0.10561899, -0.34689897, -0.2270475, -0.5010787, -0.018184396, -0.21673925) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12162333, 0.1378938, 0.059134312, 0.039307963, 0.0510124, -0.33681634, -0.14930041, 0.046449006, 0.4049798, 0.54735756, -0.32538152, -0.09478331, -0.03656422, 0.22703888, 0.16968878, -0.035476018) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.3699802, 0.15464853, -0.11618943, -0.39791518, 0.11360378, 0.118674785, 0.09339674, -0.04860694, -0.24803273, -0.39360493, 0.29796943, 0.11258084, 0.0866328, 0.13932902, 0.26889485, -0.003488432) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09942636, 0.22916375, -0.28239733, -0.16097322, -0.092702515, 0.037676267, 0.20378228, 0.11865692, 0.06519733, -0.070098594, 0.12245297, -0.2713986, 0.106116846, 0.09716516, 0.054232083, 0.1293643) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.21305977, 0.37979555, -0.036857516, 0.2844336, 0.027789349, 0.10396575, -0.092150666, 0.023619374, 0.41818637, 0.07709721, -0.35790363, -0.48373586, -0.008425228, -0.044555143, 0.13277249, -0.045384098) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.41787127, -0.34101287, 0.12359958, 0.21508296, 0.0868165, -0.010178326, 0.09488392, 0.04451859, 0.17762473, 0.119108625, -0.09402443, -0.09545441, 0.062001422, 0.02765315, -0.050359864, 0.021075241) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.35554764, -0.26806772, -0.07949073, 0.52646846, 0.11361659, -0.18451512, -0.09383286, 0.056250837, 0.011574063, -0.02701967, -0.27947813, -0.24386267, -0.068068214, -0.14196002, -0.39881346, -0.10256637) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05058348, -0.013471857, -0.37775645, 0.149038, 0.035677057, -0.09970722, 0.096862085, 0.08696142, -0.0033875355, 0.06334581, 0.076418936, 0.029044267, -0.64487296, -0.79476076, -1.6567928, -0.0889237) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.12890342, -0.2352342, 0.19877023, 0.33638814, 0.08710886, -0.03699739, 0.7870439, -0.18252032, 0.12169569, 0.33753362, 0.12868065, -0.13201661, 0.036616668, 0.14378454, 0.07397691, 0.020134386) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.028281454, 0.17940624, -0.14614528, 0.18239476, -0.26809803, -0.07207573, 0.14659242, 0.15612149, -0.31979507, -0.6411021, -0.28901482, 0.63964444, 0.0541857, -0.20623682, -0.16463806, 0.22267596) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1409002, 0.17715722, -0.23228881, -0.030394401, 0.13693783, -0.032303646, -0.3775354, -0.020234622, 0.11252613, 0.26447374, -0.034708504, -0.17254087, 0.015041411, -0.3121714, -0.4696336, -0.20905383) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.29606548, 0.297205, 0.1481838, -0.07358, 0.13951546, -0.073510244, 0.11801938, 0.007250497, 0.07800882, 0.05678295, 0.16419455, -0.063811645, 0.024768678, 0.06630595, 0.005632192, -0.03474141) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3088036, 0.49291164, 0.10407033, 0.13099147, 0.004351735, 0.24063961, -0.111593865, -0.17251109, 0.074408054, -0.05530416, -0.3723405, -0.12436647, 0.10324715, 0.084094785, 0.13643855, -0.015500036) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15425934, 0.1592674, -0.17793544, 0.02277499, 0.079396494, 0.07378929, -0.30868807, -0.036954045, 0.0313856, 0.16216728, -0.0314563, -0.0047404985, 0.179626, 0.112317644, 0.005036558, 0.14045961) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

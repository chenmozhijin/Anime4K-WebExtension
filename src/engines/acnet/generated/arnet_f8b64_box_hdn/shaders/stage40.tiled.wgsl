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

  var result: vec4f = vec4f(0.51596284, 0.050142366, 0.24831405, 0.29982546);
      result += mat4x4<f32>(0.2020695, 0.06576836, 0.29927698, -0.0052472055, 0.087572195, -0.016745605, -0.14221111, 0.008985645, -0.042175964, -0.078233466, -0.27578002, 0.04600513, -0.17825148, 0.24855386, -0.02042264, -0.38109013) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.36436266, 0.006920718, 0.01964575, 0.8864865, -0.09298176, 0.2174977, -0.034376215, 0.0664384, -0.43951458, -0.029821787, 0.035006635, -0.38783425, -0.44721892, 0.07409354, 0.18297817, -0.6108635) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07044849, 0.16832973, 0.10066915, 0.035974115, -0.05391099, 0.044292875, -0.20414725, -0.10078026, 0.1706724, -0.1463587, -0.3240747, 0.48611203, -0.18635777, -0.029361347, -0.014505827, -0.44451424) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.100143485, 0.2026262, 0.28532916, 0.0203356, -0.33251628, -0.004869244, -0.2928779, 0.1377891, -0.2690479, -0.12372068, -0.10760584, 0.09575682, 0.08056515, -0.07232268, 0.07471868, -0.129365) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.20596546, -0.1994482, -0.24154615, -0.40442172, -1.040304, -0.9181335, -0.5026199, 0.33208716, -0.85655165, 0.64566594, 0.025730262, -0.15196082, -0.47697127, 0.043800436, -0.09556518, 0.037328623) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.46426284, -0.017663736, 0.16290848, 0.043847296, 0.059618212, -0.22995347, -0.1479662, -0.20343266, -1.3007742, 0.4374798, 0.24817722, 0.40811387, 0.45662135, 0.101800345, 0.16831443, 0.120658346) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.19697645, 0.11624935, 0.23860909, -0.13056447, 0.21839507, 0.15867966, 0.11609011, 0.0034706409, 0.16438735, -0.0441712, -0.233622, 0.0111088315, 0.08112421, 0.02827057, 0.23018324, -0.4178355) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0366302, 0.2896756, 0.22740826, -0.34063408, 0.057645384, 0.17554268, 0.07029342, 0.16092302, 0.11803151, -0.1950024, -0.03722338, 0.49352166, -0.5185533, 0.18562931, -0.16419287, -0.7330644) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2004497, 0.044192962, -0.09673715, -0.04659894, 0.13367698, -0.11702503, -0.26118857, 0.344499, -0.4624809, 0.109851904, 0.058063664, -0.10244755, -0.32440817, 0.18971203, 0.19222666, -0.4698179) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0036121479, -0.012312346, -0.08078476, -0.23520434, 0.14974351, 0.12924424, -0.05855733, -0.0034752507, 0.0040850104, -0.037455022, -0.054988932, 0.09684089, -0.13476704, 0.060486905, 0.23588695, 0.102782495) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.012588811, -0.0764711, 0.2635686, -0.53064185, 0.0438055, 0.14043324, 0.7916027, -0.40995574, -0.14839017, 0.0782503, 0.11608226, 0.08162503, -0.1203537, -0.058367454, 0.087784044, 0.4067283) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.25257584, 0.022567634, -0.1429714, -0.009671738, -0.11526857, -0.10047619, 0.20299053, -0.053069536, 0.033637557, 0.024395706, -0.06502161, 0.2631636, -0.19841737, -0.014485842, 0.3367539, -0.11502641) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.5497305, 0.18960233, 0.18094985, 0.06865305, -0.09849638, 0.2810773, 0.17935577, -0.22009557, -0.14646967, -0.33086923, -0.33149737, 0.29798755, 0.022353845, 0.16002326, -0.012751764, 0.1702999) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2932419, -0.23460823, 0.19478676, 0.03312253, 0.46255574, 0.22026318, 0.17050321, 0.23653033, -0.54024845, 0.1257921, -0.16963954, -0.26889378, 0.09248499, -0.4929173, 0.2630501, 0.5265172) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.38995972, -0.1422874, -0.47624192, -0.17004545, 0.23038828, -0.13996038, -0.41726023, -0.31144708, -0.1447329, 0.040674187, -0.0064604203, -0.0011864752, 0.012207633, -0.75775826, -0.3808312, -0.7927063) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.045798756, -0.2031471, -0.082968056, -0.005795844, -0.089327484, 0.025112553, 0.102447525, -0.20924367, -0.33277932, 0.0068134298, 0.032731317, -0.097077236, -0.16022433, 0.055859968, 0.021244159, 0.05842239) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.37950966, 0.19378142, 0.32205144, -0.17199723, 0.33451563, 0.05905805, 0.07238342, -0.00093814504, -0.23257683, 0.05496265, -0.29377562, 0.048138864, -0.16032241, 0.19586195, 0.013190073, -0.08283368) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.044336148, -0.16766815, -0.16011705, -0.05081826, 0.11021588, -0.052481566, 0.008772465, -0.043672882, -0.05607006, 0.061348673, 0.071746856, -0.16259025, -0.11338642, -0.3615073, 0.08708011, -0.22058888) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

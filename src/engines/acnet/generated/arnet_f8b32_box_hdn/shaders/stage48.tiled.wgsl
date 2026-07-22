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

  var result: vec4f = vec4f(-0.22324605, 0.14533545, 0.07981835, -0.16291569);
      result += mat4x4<f32>(0.09023844, 0.02352058, 0.19220045, -0.070888184, 0.0719253, 0.07117247, -0.015171411, -0.26598573, -0.021703715, -0.01494303, -0.015647756, -0.0047763884, -0.10642582, -0.027465524, 0.28907806, 0.26445) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06834639, -0.09210993, -0.28484723, -0.083869115, -0.119114906, -0.1553754, -0.3240868, 0.22903624, -0.031113522, 0.079832435, -0.18609697, -0.10100674, 0.106109135, 0.12790415, 0.19423813, -0.22069496) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.09401146, -0.22818083, 0.08930224, 0.3877917, -0.21502271, -0.071471825, -0.010459415, 0.37090898, 0.16086572, 0.09765405, -0.07738936, -0.13850406, 0.22173424, 0.08006843, 0.08096837, 0.09622655) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.058333438, -0.04935357, -0.23813862, -0.36655167, 0.21242562, -0.2623961, 0.5070515, -0.124669194, 0.031850856, 0.10027616, -0.09978207, 0.1288982, -0.06766941, 0.2883837, -0.071557544, 0.26006898) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.22168101, 0.38131076, -0.30730683, 0.18776241, -0.06002647, -0.37624046, 0.43131027, 0.2573489, 0.051800057, 0.33081794, 0.39011213, 0.13274662, -0.08747463, -0.1533594, -0.06549316, -1.0236975) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.4811468, -0.22337249, 0.13778827, 0.41746214, -0.19607009, 0.15181616, -0.22663654, -0.17305395, 0.13265419, -0.21773945, -0.14997433, 0.117935546, -0.030609034, 0.0148707945, 0.840773, -0.20809314) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.021738842, 0.24042913, 0.2488408, -0.1785793, 0.21306781, 0.3022063, -0.1688847, -0.20540324, 0.17464349, -0.072785586, 0.058643103, -0.0018790893, -0.24795699, 0.04771741, -0.10834325, 0.58819956) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1711064, 0.31223032, -0.06776057, -0.1348663, 0.16619323, -0.116883576, -0.20073093, 0.006113833, -0.15015349, -0.17662193, 0.2563993, 0.4140206, -0.11852331, -0.033150703, -0.8564818, 0.20335968) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09180001, -0.29248548, 0.002381916, 0.20516416, 0.038539827, -0.18556243, -0.019330543, 0.11125584, 0.04357673, -0.37390798, -0.04344111, 0.37114856, 0.1523886, -0.30686298, -0.41174996, 0.2939516) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.04614836, 0.27505514, 0.012633198, -0.35166913, 0.0490902, 0.050806627, -0.08354056, -0.4367255, 0.19777448, 0.025239676, 0.23024823, -0.17158398, 0.08007904, 0.0069972035, 0.11273664, -0.17857835) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16627538, 0.07345909, -0.27443266, 0.07055263, -0.01880025, -0.11175291, -0.22517742, -0.2996148, -0.22383766, -0.35064107, 0.14562608, 0.28642207, 0.004866958, 0.31090164, 0.12869115, 0.029924726) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.113435365, 0.095092855, -0.07839553, -0.13709748, 0.24477139, 0.4785753, 0.14742325, -0.72825754, -0.153217, -0.32424957, -0.02777784, 0.16155656, -0.004589556, 0.134478, 0.15917891, -0.27793217) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0055430387, 0.13813391, -0.15471481, -0.4319908, -0.08511441, 0.23508136, 0.26385346, -0.2892079, 0.32328993, 0.060394257, 0.1073329, -0.004519803, 0.075840816, -0.08562313, 0.19565307, -0.14957054) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.17062162, -0.91204196, 0.25605655, 1.1648623, -0.10189507, 0.36330742, -0.735963, 0.26901826, 0.21621624, -0.016153255, -0.01956639, 0.2951974, 0.09615962, -0.06421097, -0.1999905, -0.46375668) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.26247248, -0.6352314, -0.15315126, 0.6205695, -0.07672184, 0.11577977, 0.12454798, 0.060763344, -0.29936218, 0.31085312, 0.13828012, -0.06766533, 0.079106666, 0.15955514, 0.06312925, 0.09653592) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.2524751, 0.079680495, 0.0888871, -0.13782996, 0.023060229, -0.098802365, 0.19261526, 0.19212034, 0.012652995, -0.060731642, 0.09328727, 0.019993912, -0.07642226, -0.09539539, 0.3646169, 0.08524181) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1139128, 0.035649676, -0.14877445, -0.22852904, -0.044933397, -0.5391895, 0.5588065, 0.5696778, -0.16871563, -0.31018677, 0.30478036, 0.12067236, 0.16407585, 0.120301425, -0.08744323, 0.18205619) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2003587, 0.16391341, 0.32124493, -0.36722887, 0.08584552, -0.18561804, 0.013569867, 0.40582997, -0.14722992, -0.0650352, -0.11354674, 0.03993107, 0.000598938, -0.05297478, -0.024371631, 0.09928516) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

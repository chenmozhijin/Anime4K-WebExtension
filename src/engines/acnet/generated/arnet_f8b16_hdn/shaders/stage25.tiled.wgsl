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

  var result: vec4f = vec4f(-0.33821356, 0.29016787, -0.08771836, 0.07880817);
      result += mat4x4<f32>(0.17017429, -0.20828234, -0.02342581, -0.1430458, 0.007356701, 0.06989802, 0.073537745, 0.0034166055, -0.23487629, -0.16870014, 0.012354333, -0.111749254, -0.059017297, -0.19534096, 0.12912533, -0.16763929) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16727635, -0.04794183, -0.11671423, -0.17419533, -0.33527005, -0.009923868, -0.13875927, 0.020454116, 0.1617245, -0.32363865, -0.22686395, 0.0170433, -0.17603804, 0.055519957, 0.06826638, 0.100927874) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.03595277, -0.033041812, 0.17446703, 0.1342207, 0.08323682, -0.10348655, -0.12664577, -0.1250287, -0.17240334, 0.46740934, 0.08781078, 0.0799649, 0.33538404, -0.58737016, 0.16325404, 0.23006187) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.025141243, 0.08059018, 0.029082399, -0.15951478, 0.21349862, -0.07586479, 0.13821441, 0.09814925, 0.3680633, 0.2658346, -0.05017637, -0.58063126, 0.19732739, -0.11880017, 0.08268967, 0.21843016) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.73951155, -0.4248064, 0.3892666, 0.56662214, -0.14961228, 0.28728655, 0.092272185, -0.063429795, 0.36961213, -0.1414434, 0.02512131, -0.3577257, -0.65373653, 0.36501575, 0.088523425, -0.22307014) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.12465582, 0.6373125, 0.08154954, -0.2515812, 0.30422598, -0.91449136, -0.14219211, -0.22751708, 0.10117861, -0.19377954, 0.07826498, 0.19373074, -0.2935247, -0.51523966, 0.23976189, 0.07960888) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03229997, -0.48464316, 0.047963392, 0.35185507, 0.24607897, -0.23658814, 0.12012998, 0.06629096, -0.098850034, 0.054205347, 0.15190554, 0.052309845, 0.43496168, -0.07779019, 0.17421113, 0.22926673) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.010113977, 0.011069608, 0.15206333, 0.15585499, 0.4622669, -0.1844584, 0.046566296, -0.21711403, -0.078993805, 0.028274057, 0.031675167, 0.013482247, 0.48627803, -0.033272155, 0.33751243, 0.17618443) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.23553504, 0.027869478, 0.030573828, -0.068529576, 0.028159805, -0.07750195, 0.077455096, -0.087242134, -0.14737405, -0.038663015, -0.05821446, -0.07819788, 0.1915049, 0.040788412, -0.04798581, 0.1535355) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.19333492, -0.0056753433, -0.024696723, -0.0059381537, -0.1908323, -0.07374647, 0.008016323, -0.042617355, -0.034295, 0.05823127, -0.1348888, -0.0064049195, -0.14416812, 0.10084405, -0.063575834, -0.2599253) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.23248963, -0.70667255, -0.26263615, 0.39148968, 0.17138325, -0.19153155, -0.09180113, -0.03293048, 0.0933283, -0.051251788, 0.085167885, 0.13549422, -0.58030725, -0.029970983, 0.18723105, -0.26801684) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.071357444, -0.57931304, 0.05550628, -0.065769054, 0.044813883, 0.0348701, -0.027453313, 0.045897298, 0.22746661, -0.040878586, -0.13047072, -0.16600995, 0.11038472, -0.18733706, -0.16819015, -0.24945922) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.28424126, 0.13043106, -0.2304224, -0.14369448, -0.13967913, -0.24283351, -0.0030694907, 0.27431, 0.16968262, -0.061785538, -0.03710814, 0.3944751, 0.13306724, -0.09102753, 0.077619754, -0.0036872113) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.04342575, -0.07296402, -0.2591026, -0.18894362, 0.06185907, -0.9500832, 0.56622124, 0.5104139, 0.6683256, 0.3083965, 0.7549529, -0.05542621, 0.64595294, -0.5268549, -0.017838957, -0.02277066) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09887353, 0.08896384, 0.093007505, 0.064577736, -0.4129477, 0.23742339, 0.22539112, 0.08875097, 0.4789142, -0.22397411, -0.064919665, 0.011480228, 0.052620772, -0.28862095, -0.1651463, -0.14952973) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.043795113, 0.2091492, -0.0679523, -0.3715, 0.009832622, -0.0025316358, 0.062101107, 0.33947513, -0.069845416, 0.10080805, -0.039696675, -0.08636175, -0.079204045, 0.17273936, 0.12529841, 0.022152156) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.46813345, 0.26856908, -0.12310852, -0.31059754, 0.29233965, -0.12836492, 0.20306733, 0.060749687, -0.32860187, -0.17512201, -0.0773204, 0.18511651, 0.16593441, 0.29087088, -0.044618353, -0.05607677) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14764325, 0.19991927, 0.034890234, -0.037538346, 0.28212506, 0.24871698, 0.00012424047, -0.16826305, -0.06486188, -0.04205104, -0.0667114, 0.09614696, -0.16855943, 0.24339584, -0.13864763, -0.019812929) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

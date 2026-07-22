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

  var result: vec4f = vec4f(-0.23781815, -0.122917384, -0.2505009, -0.03393189);
      result += mat4x4<f32>(-0.0816997, 0.002548584, -0.062491994, -0.04018238, 0.2431775, -0.14247684, -0.11364526, -0.008753667, -0.14940499, -0.12538359, 0.08368494, 0.017685551, 0.078140266, 0.11605937, -0.14615507, -0.08272636) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09093727, 0.06600517, -0.13130465, -0.058258757, -0.24163179, -0.42074227, 0.12701882, -0.16654544, 0.18175687, 0.17831115, -0.03879574, 0.015651833, -0.021645306, -0.43355268, 0.0647838, 0.022471566) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.23464195, 0.042719893, -0.010240615, 0.07679115, -0.1736378, -0.028877039, 0.04923828, -0.038461912, -0.1113348, 0.03612876, 0.01849374, -0.056831177, -0.1303419, -0.06986815, -0.00013247445, -0.02389075) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.43563208, 0.5672474, -0.12550212, 0.035239153, 0.20646511, -0.15615454, -0.17476253, 0.13604482, -0.15490824, 0.023854034, -0.012364282, -0.09447193, 0.13455065, 0.07886981, -0.07804828, -0.12987596) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6158558, 0.38820317, -0.19819088, -0.1968199, -0.29209438, -0.120617114, -0.13837577, 0.5254271, -0.013070372, 0.39550656, 0.062378477, 0.053170044, -0.021526216, -0.16204931, -0.5185969, 0.048370697) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.375793, 0.23464225, -0.08884877, -0.075324856, -0.41740707, 0.045626815, 0.009076156, -0.05613082, -0.057926375, -0.12589908, 0.04071649, -0.059824258, -0.36943159, -0.18776546, 0.08182395, 0.06505069) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23908646, 0.08614047, -0.056445066, -0.08643838, -0.07181759, -0.056990832, 0.030439576, -0.010824979, -0.1658395, 0.08078109, 0.0021266828, -0.07373659, 0.1956279, 0.15639544, -0.021378625, 0.045828015) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.36419705, -0.045583166, -0.031720035, -0.25421754, -0.07263843, -0.0015918831, -0.011598009, 0.0035440256, 0.34946683, 0.13752148, 0.14717405, -0.21236378, 0.095611535, 0.064256765, -0.112214014, -0.20244823) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.016162187, -0.023229524, 0.017436981, -0.041052178, 0.13894905, -0.091031745, -0.031734943, 0.070424005, 0.033520997, -0.087083176, -0.031862207, 0.1926405, -0.013137337, 0.19799261, -0.13244702, -0.07938423) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.13143323, 0.018323014, 0.15570135, 0.03370693, 0.058383744, 0.14889842, -0.058910973, -0.066464484, -0.110601194, -0.015505302, 0.04027775, -0.029332709, 0.0025389548, -0.1192688, 0.018790234, 0.0027426577) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.034032043, 0.021552086, -0.051133215, 0.03893098, -0.0061217765, 0.039099816, -0.06085538, 0.054980546, 0.32512355, -0.06556829, -0.071894675, 0.044944413, 0.10798306, 0.11039226, -0.04586873, 0.061874162) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.19634058, 0.03544419, 0.041968398, 0.052783135, -0.15446077, 0.13010117, -0.08432139, -0.15874515, 0.15183753, -0.07595366, -0.17133093, 0.02759889, -0.19424173, -0.09057785, -0.0480111, -0.09001483) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2801375, -0.055942222, 0.1102617, -0.09849856, 0.17637627, 0.14316514, -0.015922645, -0.13672246, -0.06432815, -0.015067742, 0.13707623, 0.056407627, -0.07810418, -0.074570164, -0.039818842, -0.063501574) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2539969, 0.47928667, 0.11815446, -0.43190786, -0.017486993, -0.09209983, -0.3194124, 0.347603, -0.16449863, -0.1130623, -0.21958953, -0.037156038, 0.27111366, 0.17924227, 0.20338719, -0.3606341) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.037619013, -0.010241842, -0.16554138, 0.0027094276, -0.20177035, -0.16910543, 0.0072680027, -0.006839178, 0.17838356, -0.03577505, -0.058692418, -0.17958823, -0.31466505, -0.0005848514, -0.13248125, 0.004008014) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.030029459, -0.15277095, -0.1115662, 0.06056305, 0.0074424203, 0.03356689, 0.02764049, 0.031727247, -0.029295042, -0.09804277, 0.022251831, 0.041380767, -0.080732614, -0.01515279, -0.01265748, -0.0923342) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.25841975, 0.025198046, -0.010409253, -0.046897307, 0.21879378, 0.07099379, -0.19509591, -0.118538775, 0.08022753, 0.013371925, -0.046291664, 0.03786849, 0.19822316, 0.20583282, -0.1981015, -0.11624519) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15717812, 0.0045330464, 0.09457744, -0.013222249, 0.13603784, -0.06260159, -0.083733775, 0.036879636, -0.11102786, 0.005514537, 0.096624784, 0.004590728, 0.04423897, -0.07917365, -0.12677234, 0.05073258) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

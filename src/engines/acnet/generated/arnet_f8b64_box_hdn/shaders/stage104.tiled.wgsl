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

  var result: vec4f = vec4f(0.28796998, -0.16373444, 0.22774045, -0.07582337);
      result += mat4x4<f32>(-0.11155559, 0.11637586, -0.046840493, -0.0041226326, -0.015480109, -0.11161552, 0.34745732, 0.26752248, -0.06794641, -0.09735422, 0.21585284, -0.18282174, -0.009494391, 0.25776142, -0.039990555, -0.268309) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21569791, 0.09515221, -0.24177335, -0.0087208785, -0.34676236, -0.10959853, -0.17657375, 0.5401015, 0.17041546, -0.07942839, 0.0550604, 0.21344729, -0.41672266, 0.0063646366, -0.09134837, -0.52397823) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3908557, 0.08764796, -0.14735864, 0.08599411, -0.020406881, 0.0051105684, 0.057529308, 0.11098178, -0.5927785, -0.31498805, -0.1639829, 0.026841143, -0.08105472, 0.036742706, 0.16741346, 0.031817) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.03708457, -0.11366496, 0.023551023, 0.1035596, 0.000792845, -0.19089723, -0.18649589, 0.29467002, 0.30638516, -0.120258175, -0.30845925, 0.37961337, -0.1219448, 0.17595387, 0.42016953, -0.09813675) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.037880756, -0.13924308, -0.054892372, 0.03837622, -0.10579006, -0.47675067, -0.526223, -0.06554807, -0.8907138, -0.3818251, 0.5281915, -0.5008537, -0.14615455, 0.44709274, -0.3189544, -0.27138746) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.008491856, -0.241511, -0.1552558, 0.11500248, 0.030859439, -0.00961701, -0.24269302, -0.07251885, 0.64714205, -0.23467572, -0.13894798, -0.3180337, -0.00065601646, 0.17146866, -0.005395201, -0.045078285) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.3719446, -0.013113553, -0.099023476, -0.038493615, 0.04945552, 0.00059333036, -0.07595458, -0.06011219, 0.013388975, -0.25955898, -0.26081586, 0.086761996, 0.07705032, 0.051417, 0.031319406, -0.059179034) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10597588, 0.15573356, 0.12658815, -0.009969637, 0.35152417, 0.06319866, 0.4660845, -0.52461654, 0.24922411, -0.13493381, 0.3282459, -0.19217956, -0.2796, 0.11576399, 0.14013933, -0.12477968) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.34465542, -0.18703915, -0.072486475, -0.0833116, 0.0147179635, 2.9460641e-06, -0.14436297, 0.005474581, 0.4109017, 0.055077877, 0.0371924, -0.2881095, 0.0055466457, -0.0064172978, 0.05865, 0.18774377) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.10360505, -0.09022544, -0.13773413, -0.1360659, -0.25240105, 0.014360435, -0.07679943, 0.043656886, -0.22938414, 0.047933828, 0.053616792, -0.32359084, 0.15823603, 0.0033871378, 0.006640503, 0.040296547) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.057111464, -0.07068691, -0.099400245, -0.050394684, 0.22511537, -0.08860724, 0.027216151, 0.121240534, 0.19483368, 0.119593315, 0.07617566, -0.5519648, 0.22914468, -0.14070468, -0.0071313865, 0.07757509) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12839544, 0.018786285, 0.017222928, 0.040087603, 0.16604064, 0.098817304, 0.13260199, 0.098551884, -0.16083011, -0.11152407, -0.0734713, -0.37573093, -0.16813895, -0.0768615, 0.04712195, 0.020707443) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5727194, 0.0849547, -0.012935239, -0.34238654, -0.27480057, 0.13940158, -0.011567064, -0.46533117, 0.43386847, -0.3105256, 0.08100797, 0.2521006, -0.070478864, -0.34870583, -0.08121489, 0.093567766) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16178982, 0.21953353, 0.22073692, 0.5712808, -0.49770796, 0.24177009, 0.1501547, 0.15383877, 0.6950232, 0.16564545, 0.9254987, -0.031169364, 0.07865948, 0.053608224, -0.19454561, -0.56936353) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0963553, 0.063091785, -0.07330691, 0.00539112, -0.34109876, 0.16076592, 0.061954644, 0.24752411, -0.17297491, 0.025909318, 0.32597256, -0.3012038, -0.23760827, 0.00056350295, 0.26798633, 0.2236352) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08977533, -0.017541556, -0.024864774, 0.1500161, 0.04881302, 0.15254864, 0.22746348, 0.014943263, -0.44946584, -0.09438643, -0.37758055, -0.5005141, 0.020781418, 0.17078249, 0.20191304, 0.19589575) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12142674, 0.02111786, 0.1496652, 0.094508804, -0.06513327, 0.23364758, 0.11212402, 0.315874, -0.023061346, -0.07657415, 0.2869661, -0.21815634, -0.18174458, 0.19756716, 0.056721173, -0.07268286) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03274685, -0.011530336, 0.03587626, -0.15883036, -0.40500218, 0.0971673, 0.30852857, 0.2960544, 0.12687299, -0.104774825, 0.09972546, -0.069474295, -0.29948032, -0.10517648, 0.068260565, -0.06909252) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

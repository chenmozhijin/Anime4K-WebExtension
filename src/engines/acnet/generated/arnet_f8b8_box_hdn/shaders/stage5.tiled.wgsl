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

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_1[tileY][tileX] = sample_FEAT_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.19437908, 0.23972577, 0.11479329, 0.18318874);
      result += mat4x4<f32>(-0.30730647, 0.23236649, -0.18829355, 0.041766718, -0.22550303, 0.18473789, -0.1423692, -0.20665987, -0.22026813, 0.04041695, -0.042988352, -0.124476075, 0.0023888429, 0.054287735, 0.012505667, -0.23690228) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.2183781, 0.06567494, 0.21209067, 0.28276852, -0.25412518, -0.049100984, -0.12565482, 0.056757633, 0.2402778, -0.0301683, 0.15345563, 0.05050022, 0.29794025, 0.16154131, -0.22615828, 0.04565705) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.015272725, -0.024609106, -0.06299427, -0.070903264, -0.030499386, -0.16574654, -0.18044981, -0.09345694, -0.15900914, 0.2929629, 0.106573835, 0.010019596, -0.15102117, 0.10487734, 0.21749347, -0.010370337) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.45520514, 0.026961435, 0.02872561, 0.17003436, -0.7470497, 0.113846764, -0.71637195, -0.7858805, -0.67202365, 0.45677462, -0.22275755, 0.012802201, 0.14293808, 0.0828863, 0.111090146, -0.086627916) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5241807, -0.15987067, 0.46798372, 0.2360738, -0.35176766, -0.3619259, -0.92201126, -0.64718854, 0.106440336, 0.46230194, -0.39677933, 0.60868686, 0.2424252, -0.013403064, -0.9835489, 0.7264316) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06197535, -0.09147483, -0.28019896, -0.0062045357, -0.024601782, -0.099469125, -0.29838473, 0.011310287, 0.10368592, 0.1519386, 0.57477105, -0.03979766, 0.17386894, 0.46965605, 0.039614856, 0.008662742) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.5485957, 0.052148208, -0.18390763, 0.37258056, -0.64871037, 0.16124275, -0.12035699, -0.45807758, -0.42133778, -0.13212673, -0.062770605, 0.036087945, -0.31418177, 0.1977114, 0.038413435, 2.1624614e-05) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17136939, -0.45450756, -0.44510317, 0.17214967, -0.2458018, 0.15240791, 0.09114966, -0.14470091, 0.920258, -0.04166431, 0.14776513, 0.1021507, 0.54119223, 0.262754, 0.053062495, -0.55625045) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.21784008, 0.06667967, -0.18700285, -0.20885706, -0.025714455, -0.0504186, -0.14797121, -0.049003296, -0.09671847, 0.035128865, -0.038893886, 0.20827043, 0.080348335, 0.3177259, 0.2230452, -0.11555003) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.19476841, -0.21527025, -0.3671441, -0.1357415, -0.14490059, -0.26135448, -0.05349463, 0.17725156, 0.21430613, -0.10105893, 0.07966465, 0.29312924, -0.10195808, -0.63572687, -0.061689682, -0.2929554) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.22959474, -0.42012623, -0.22972505, 0.0053171376, -0.36440682, 0.07375869, -0.03749662, -0.07628777, -0.33163598, -0.20557143, 0.24607402, -0.20017886, 0.60366696, -0.64072657, 0.34816214, 0.16082053) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0799768, -0.26611868, -0.2588484, 0.011197788, -0.041122545, 0.22983691, 0.21522586, 0.19153632, 0.12786706, -0.19360702, -0.26430115, -0.060027894, -0.15106091, -0.18039416, -0.0015161113, 0.1573733) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.38251972, 0.08647599, -0.004491739, 0.230362, -0.04938909, 0.22133803, 0.84805185, 1.1915834, 0.20438536, -0.3194305, 0.037656125, 0.11521852, -0.42041567, -0.33414873, 0.021320242, -0.22209544) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.05479545, -0.08165759, -0.1923397, -0.013951992, -0.23651668, 0.5730191, -0.23312885, 0.20180629, -0.2999186, -0.06348877, 0.6013582, -1.2429572, 0.23492017, 0.72196877, 1.856131, 1.2454773) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07310336, 0.38930383, 0.00018088083, -0.12423494, -0.06426818, 0.10673808, 0.1978535, -0.19419271, -0.14047879, -0.73025644, -0.4353141, 0.037843507, -0.023741046, 0.78216314, -0.42182475, -0.6681039) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.47063228, 0.27803242, -0.26921073, 0.2203668, -0.048126053, -0.0013489691, -0.4206753, 0.26076862, 0.42269638, -0.30841878, -0.015636282, -0.05383388, -0.3109592, -0.23456116, -0.6296193, 0.0057956427) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.07070013, -0.2215002, 0.043001592, 0.24202852, 0.12925486, -0.127694, -0.18027982, -0.03803072, -0.42509013, -0.46567145, -0.22840081, 0.20718691, 0.19164297, 0.41115957, -0.24088253, -0.052859306) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.052561294, -0.024899503, 0.13337898, 0.03375621, 0.14596416, -0.028907415, -0.0047860495, -0.09737449, -0.13339278, -0.3990461, -0.34888986, 0.08210362, 0.11528307, -0.13857512, -0.6247625, -0.30900046) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

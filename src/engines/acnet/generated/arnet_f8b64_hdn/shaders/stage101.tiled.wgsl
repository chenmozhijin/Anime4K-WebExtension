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

  var result: vec4f = vec4f(-0.077225775, 0.20926332, 0.33375835, 0.40398148);
      result += mat4x4<f32>(0.17391853, 0.20394854, 0.011937542, 0.03233226, -0.09452776, 0.24047332, -0.09698278, -0.1994371, 0.023131344, 0.0015049058, 0.06364439, -0.075167626, 0.079867095, 0.06802142, 0.045179423, 0.08065644) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.004355601, -0.09776562, 0.28827938, -0.03812065, -0.09242558, 0.20788136, 0.14199163, -0.25580564, 0.052054323, 0.1143879, -0.08894956, 0.013746946, 0.006662312, 0.13901863, -0.1582064, 0.0053818286) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15140456, 0.010054271, -0.25891194, 0.14479607, -0.026859645, 0.18551293, 0.2034666, -0.0330042, -0.008676612, 0.086310074, -0.11270041, -0.012354607, -0.030896284, -0.031788617, -0.04997575, 0.03777112) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.03215237, -0.029281845, 0.037533134, -0.41270977, 0.11064016, 0.6197303, 0.35836232, -0.29386854, 0.0013237011, 0.22042374, -0.07046796, -0.14722332, -0.14009768, -0.33459628, -0.32016098, 0.3193185) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.20566104, -0.2227976, -0.08003622, -0.35923293, -0.011040454, 0.20821092, -0.237128, 0.21407251, 0.11012305, 0.16368073, -0.26494372, 0.051802028, -0.14953195, -0.08202796, -0.017646974, 0.58690244) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1115963, 0.08119157, -0.08943057, 0.77294964, 0.15500015, 0.29696313, -0.123134874, 0.15916005, -0.068375014, 0.39861554, 0.056947645, -0.26745412, -0.1728338, -0.528117, 0.26811966, -0.10030138) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.32475254, 0.4731218, 0.41755325, 0.09228717, -0.051510178, -0.2537099, 0.036109824, -0.019684808, -0.20912594, -0.08236176, -0.35066202, -0.006589424, 0.15968181, 0.17803773, 0.1709824, 0.16200547) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09788689, -0.38758603, -0.19798179, -0.28370315, 0.16203348, 0.1638419, 0.12157781, 0.2596126, -0.016195102, -0.48417926, -0.28124294, -0.23647358, -0.03080874, 0.15811054, -0.05871847, -0.013848188) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.17788129, -0.025559535, -0.176639, -0.26467276, 0.020875692, -0.12903966, 0.043229356, -0.09717736, 0.10973749, 0.31086886, 0.05534559, 0.02365142, 0.028303958, 0.0065620136, -0.04565697, -0.29962173) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.099088594, -0.06696717, -0.14619379, -0.007451769, -0.08566673, -0.082795724, -0.00025948702, -0.007795469, -0.19081788, 0.12537552, -0.19513784, 0.030849123, 0.013716439, -0.19184135, 0.1337348, -0.0037749547) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0035409823, -0.08616802, 0.027961457, 0.007830253, -0.05661244, 0.052873813, 0.0981342, -0.13575527, -0.0007820937, 0.06472822, -0.24876526, -0.20267072, -0.09504278, -0.13197409, -0.061602175, 0.08056766) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.090734355, -0.10002755, -0.28290623, 0.12849565, -0.04455356, -0.031520758, -0.025051622, 0.032639157, 0.021632813, 0.028418062, -0.42218074, -0.008367356, 0.025359493, 0.15505774, -0.08010124, -0.059223566) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11288981, -0.27540514, 0.0042991475, -0.30085182, -0.030357605, 0.03410722, 0.1710896, 0.19741203, -0.15163094, 0.023581095, -0.36995548, -0.08942113, 0.016598647, 0.20412724, -0.19744892, -0.050421517) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.11402504, -0.28934604, 0.550311, 0.1274255, -0.17002253, -0.63912517, 0.100801945, 0.23712899, 0.11443492, 0.015350131, 0.22684638, -0.25385213, -0.10059377, -0.26096907, 0.13256215, -0.54860836) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.21281026, -0.31222254, 0.33190933, -0.18315911, 0.06617394, -0.057654392, 0.14117223, -0.24329257, -0.3477559, -0.33978307, 0.13483131, 0.2456437, 0.09220695, 0.31027752, -0.24179643, -0.049856283) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11198587, -0.082879424, 0.019726532, 0.1234002, 0.119396724, 0.65483636, 0.19282074, 0.31932172, 0.0064045563, 0.3041018, -0.38730836, 0.002203125, -0.038548518, 0.11520106, -0.081393555, 0.21790613) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11462239, 0.35027933, 0.12599212, 0.04977555, 0.11009788, 0.15835746, 0.06187406, 0.3226934, -0.2531858, -0.069460616, -0.6878749, -0.06570474, 0.12391482, 0.0066449144, 0.06499808, -0.1756526) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.046577662, -0.17641732, -0.1276334, -0.22466686, -0.073703066, -0.17978515, -0.08540843, -0.19761384, -0.09435388, 0.12818785, -0.35803312, 0.24167097, 0.032634344, 0.12061652, 0.030608917, 0.16755006) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

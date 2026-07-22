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

  var result: vec4f = vec4f(0.3750383, -0.4622882, 0.24282682, -0.033214044);
      result += mat4x4<f32>(0.019957352, 0.19159965, 0.005222743, 0.38316023, 0.08474445, 0.14436257, 0.06481043, 0.10995478, 0.019044302, 0.052107356, 0.0002969436, 0.09268141, 0.14126377, 0.06466121, 0.080357224, 0.121789984) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.055036288, -0.1279458, -0.14158748, -0.053530887, -0.19431838, -0.14951502, -0.0055370447, 0.011114737, -0.08875194, -0.0652478, -0.089027226, -0.35792226, 0.45637247, 0.06918773, 0.07109585, 0.47279975) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.032208655, 0.34430212, 0.26655173, 0.13707538, 0.052574232, 0.069402926, -0.020408768, 0.11545218, 0.10269391, 0.0048440453, 0.0063813776, 0.032705992, 0.022663772, -0.08414308, 0.037435696, -0.12456426) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.40257242, -0.0522113, -0.5771028, -0.17966127, 0.003471258, 0.010572315, -0.392091, -0.11245061, 0.02897307, 0.03051647, 0.0997273, -0.04153411, 0.19045562, 0.053266466, 0.07958349, 0.18886286) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24423158, -0.24727492, -0.3584848, -0.4228936, -0.5698925, 0.6222801, -0.4723784, 0.492629, -0.058595814, 0.57261074, 0.15541732, -0.6319006, 0.34910074, -0.0781839, 0.08060233, -0.027558744) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.035339125, -0.05330111, 0.07448523, 0.10869375, 0.018993162, -0.15903449, 0.04900488, -0.20015553, -0.18282162, -0.23374853, -0.063250974, 0.064641975, 0.100815564, 0.372089, 0.4783945, 0.09057095) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.19948432, 0.23862885, 0.28556845, 0.46243903, 0.053554058, 0.17705677, 0.056322277, 0.08229384, 0.041627705, 0.036934007, 0.04335284, -0.03045125, 0.026752032, -0.06696613, -0.00347113, 0.017243452) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.039834317, 0.16968533, -0.079352446, 0.17134175, -0.23491924, -0.08312637, -0.017163822, -0.093149595, -0.062374797, 0.22452354, -0.035297096, -0.031394266, -0.088754945, -0.045444693, -0.20780171, -0.289438) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.05833018, 0.25506014, 0.159668, 0.25549123, -0.03808625, 0.15826324, 0.07306876, -0.062528126, -0.08585511, 0.043771274, 0.024584256, 0.053652816, 0.07970833, 0.059651993, -0.122969985, 0.10343423) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.23814501, -0.2168248, -0.23498884, -0.26517934, 0.104738064, 0.06847574, -0.106698684, 0.14025268, -0.060489923, -0.005366183, -0.019671643, -0.062486492, -0.015020494, 0.12061639, 0.09431174, 0.111600175) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09555611, -0.022104338, -0.07295315, -0.081976965, -0.103828624, 0.06014193, 0.028561214, 0.03002581, 0.046764374, -0.0082051465, -0.07424822, 0.14717238, -0.2734189, 0.049731996, 0.27766, -0.26069438) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06667416, -0.055937506, -0.10292532, -0.0064023347, 0.07554697, 0.1383036, -0.004477578, 0.046054166, 0.016832255, -0.10543427, -0.02905988, 0.119174756, -0.09003306, 0.05036218, 0.069255345, -0.18621314) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.23988652, -0.089088604, -0.5090956, -0.25154254, 0.07743323, -0.2225402, 0.09763723, 0.11916305, -0.02153749, 0.0037215739, -0.078405194, 0.011361803, 0.026472041, 0.029079879, 0.33770666, -0.054855775) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.4323804, 0.22712666, -0.9597685, 0.4501634, 0.43655908, -0.71733004, -0.31427523, 0.48344117, -0.24697042, -0.32246226, -0.70589054, 0.02966817, -0.12930562, 0.30562344, 0.8818995, 0.95750695) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18939178, 0.20387304, -0.20546947, 0.6818108, 0.05450859, -0.005066881, -0.015565518, 0.105285995, 0.13709708, 0.45113546, 0.4751577, -0.5475602, 0.1578489, -0.00050063845, -0.06815254, 0.25631353) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14688829, -0.17238575, -0.2037063, -0.11479555, 0.07316905, 0.09032355, -0.052933645, 0.07511187, 0.012264373, 0.030537061, -0.05614702, -0.020399662, 0.054761097, 0.12717871, 0.13232794, 0.13552405) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13067937, 0.105390474, -0.18293004, -0.016965521, 0.1246767, -0.1516597, -0.063125655, 0.01982424, -0.01113718, 0.13548993, -0.15209611, -0.15540075, 0.11521916, 0.009723288, 0.19970444, 0.20051473) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13606597, 0.19660783, -0.10746411, 0.21847706, 0.002899497, 0.04508926, 0.0003158859, -0.0050423713, -0.070885345, -0.15017538, 0.09082125, -0.11291555, -0.053844083, 0.1034822, 0.1658274, -0.17442307) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

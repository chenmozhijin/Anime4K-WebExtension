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

  var result: vec4f = vec4f(-0.108316176, -0.040011514, 0.19022553, 0.07804733);
      result += mat4x4<f32>(0.12845859, 0.037432417, -0.06928027, -0.13890754, 0.18904753, 0.22382638, 0.034910828, -0.31026042, -0.27506652, 0.26742887, 0.04831142, -0.0031159236, -0.04126629, 0.10241316, 0.111892335, 0.5355976) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.029839, 0.033757005, -0.050141133, -0.04997847, 0.15616828, 0.12290268, -0.08188979, -0.17494392, -0.13704218, -0.09149856, -0.19905297, -0.00017263585, -0.21067066, 0.044419505, -0.21128939, -0.01514477) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09395141, -0.23396148, 0.05739076, 0.31205928, 0.08409172, -0.029444601, 0.03024739, -0.12876227, 0.011296385, -0.03041912, -0.14648443, -0.177623, -0.036000416, -0.025650019, 0.03430667, 0.055555634) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.033961143, -0.097074844, -0.14323044, -0.12184006, 0.11438418, 0.75685525, -0.5072228, -0.1262184, 0.005098502, -0.037511252, -0.038135394, 0.8100189, 0.18390772, 0.3265818, -0.08397871, 0.6015764) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.078673206, -0.19832492, -0.5824542, -0.5133991, 0.05198365, 0.02598557, -0.30343124, 0.20487775, 0.0382306, 0.110318795, -0.3067136, 0.3873647, 0.08383933, 0.15908849, -0.82553744, -0.011454351) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1170129, 0.15360321, -0.23557599, -0.11490398, -0.035507277, -0.012752434, 0.05627712, 0.34154543, 0.023998102, -0.14850472, 0.18966813, 0.11391917, 0.1460491, 0.14016706, 0.07908954, 0.18681672) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1125701, 0.21103261, 0.20393583, -0.1111773, 0.2804971, 0.1908737, -0.15841895, -0.0030360024, 0.04043489, 0.0298093, -0.32008433, -0.2682413, -0.22925627, 0.084783345, -0.24158007, -0.10841667) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.01773543, 0.054786824, 0.14221177, -0.3993718, -0.057685062, 0.2591481, 0.2665148, -0.027385706, -0.368186, -0.2346271, 0.35880125, -0.15255585, -0.14388731, 0.3598652, -0.16844808, 0.027100762) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.008101525, 0.2992537, -0.0046930052, 0.03666578, -0.21032524, -0.09786101, 0.0439757, 0.29444864, -0.10716752, 0.035710298, 0.25736418, -0.35002106, -0.062054556, -0.15766424, 0.15353465, 0.1158516) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0053196345, -0.036537837, 0.0380135, -0.04675417, -0.030481378, 0.19817194, -0.0013400066, -0.11230421, 0.03651896, -0.06556132, 0.039755415, 0.15860018, -0.06424401, -0.16049738, 0.14419982, 0.11242954) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07833684, 0.02744923, 0.2413622, -0.16517267, 0.14672466, 0.21820328, -0.25205866, -0.4909373, 0.08121732, 0.15905535, -0.2838888, -0.14552678, 0.316184, 0.008972418, -0.18732558, -0.470166) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08086271, 0.04691077, 0.051943496, 0.042453833, -0.01848965, 0.1780314, -0.15144719, 0.20817535, 0.14312361, 0.00022583255, 0.12001772, -0.046059597, 0.085302524, 0.14958353, 0.025655258, -0.14812507) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08096081, 0.24316469, 0.27655247, 0.3097051, -0.021746915, -0.2738777, 0.11830929, -0.3658353, -0.16758284, -0.2861798, -0.3684348, -0.47290576, 0.14284682, -0.10982679, 0.3360506, 0.43089443) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24314682, 0.07869585, 0.23951261, -0.37080592, 0.038422205, 0.40191367, 0.45384055, -0.31843346, 0.102201216, 0.9972544, -0.3687962, 0.2613185, 0.21677276, 0.69060224, 0.2770476, -0.47339892) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13830444, -0.096319735, -0.12496267, -0.3692921, 0.033612378, 0.14193201, 0.140355, -0.3464205, -0.005996079, 0.4121124, -0.1544885, 0.013245884, -0.0030482754, -0.19993745, 0.21985121, 0.02372505) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.095703974, 0.047721315, -0.41098088, -0.24140894, -0.03701613, -0.18224782, 0.2870888, 0.028954709, -0.06983038, -0.013598018, 0.22725332, 0.013276278, 0.24747907, 0.42555898, -0.2948381, -0.09501521) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.23773757, 0.1272917, -0.441215, 0.039573345, 0.16435802, -0.062263124, 0.30755836, 0.026700271, 0.01890703, 0.06527941, -0.459778, 0.12971713, -0.24961984, -0.14834002, 0.13468261, -0.44037747) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.044301048, 0.18916701, 0.05144715, -0.060361903, -0.013194539, -0.23487143, 0.271186, -0.1113058, -0.17242928, -0.37758788, -0.06634985, 0.3832744, -0.27750444, 0.028230906, 0.18144354, 0.05014081) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

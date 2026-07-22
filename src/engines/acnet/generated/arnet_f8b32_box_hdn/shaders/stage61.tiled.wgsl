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

  var result: vec4f = vec4f(0.29231954, -0.052971564, 0.17088892, 0.2562127);
      result += mat4x4<f32>(0.17098542, 0.0033270374, -0.11005373, -0.11734194, 0.03806851, -0.15336882, 0.013138158, 0.16673422, 0.037540384, 0.0016474284, -0.022824733, 0.04649199, 0.0523425, -0.019989936, -0.08497487, 0.08126467) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0280463, 0.03963065, -0.16026728, -0.019635143, -0.101985134, -0.033474807, 0.4094702, 0.24730961, 0.03761566, -0.05070303, 0.06285949, -0.19136176, 0.15297878, 0.18163405, -0.2285739, -0.23715985) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.089968964, 0.27339467, 0.14028534, -0.038121123, 0.0060629766, 0.17831317, 0.19460419, 0.09271543, -0.08516463, -0.05580455, -0.12831165, -0.048568323, -0.22595413, -0.020293467, -0.09764352, -0.066460125) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.26595306, 0.1522154, 0.13022836, -0.21908595, 0.06777765, -0.21559472, 0.035279363, -0.4780549, -0.13624026, -0.13867564, -0.07785926, 0.13582106, -0.105037294, -0.021547731, -0.22830026, 0.07256051) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.60872865, -0.43330675, 0.26811346, -0.2183934, -0.014773443, 0.24757522, -0.21020369, -1.1007345, -0.5414192, -0.28957936, 0.440973, 0.052606292, -0.66397715, 0.392387, 0.053508863, -0.23146245) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11027666, 0.08058631, 0.1760046, 0.054951802, -0.58118856, 0.5745111, 0.088098355, 0.13224503, 0.06783183, -0.022823174, -0.05896474, 0.16729242, -0.08002664, 0.21131167, -0.14035614, 0.38590258) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.054395806, 0.12533425, 0.028220767, -0.014332486, -0.24904732, 0.27747154, 0.22984342, 0.0715808, -0.0029787128, -0.10384704, 0.00015469799, -0.09547663, 0.05136671, 0.036632665, -0.11805212, 0.10741692) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.26695973, -0.13546005, 0.059091896, -0.09116857, -0.13122083, 0.31669235, 0.09712798, 0.21098244, -0.50235677, -0.39147937, -0.09446089, 0.13363706, -0.007867398, -0.051870134, -0.10272882, -0.060950633) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.011739346, 0.108519144, 0.044608675, 0.15625763, -0.104380295, -0.3115525, 0.1059594, -0.16284478, -0.25786564, -0.09645107, -0.091682434, 0.06586327, 0.012426669, 0.12748958, -0.027024087, 0.20520619) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.04718785, -0.06375362, -0.027972352, 0.00855399, 0.05808348, -0.34761485, -0.03346577, 0.18907155, -0.15182069, -0.11023495, 0.03853081, -0.15155526, 0.12292139, -0.030610109, -0.29398268, -0.33948445) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.18771087, -0.118204534, -0.09953503, -0.17650566, 0.31146353, -0.024659261, 0.048917092, 0.06408243, -0.22614905, 0.09200254, 0.070165984, 0.1902187, 0.19084924, 0.011539563, -0.4886244, -0.37477162) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0049844794, -0.07176935, -0.12569036, 0.15605673, 0.22058994, 0.17257705, -0.05007482, 0.26599833, -0.054099854, 0.31966338, 0.21012485, -0.2384627, 0.046117924, 0.22363934, -0.27617565, 0.10093628) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.08763957, 0.2855526, 0.04861036, -0.23638633, 0.10968595, -0.14051935, 0.07934286, 0.3901336, -0.24911231, 0.1413928, 0.00036483046, -0.14508426, -0.11245119, 0.04714521, 0.0032431744, -0.586261) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23708104, -0.032526515, 0.59038347, -0.25730625, 0.51046985, -0.4824254, -0.1891206, -0.2381831, -0.6063989, 0.27308026, 0.20241699, 0.045785457, -0.23882113, 0.30855867, 0.2763625, -0.62327516) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15506165, 0.023967702, -0.1021104, 0.16563132, -0.101057366, 0.31173885, -0.20613039, 0.73003966, 0.0017275285, 0.31579566, 0.19540331, 0.2260932, -0.13637091, 0.06217923, 0.3451095, -0.20165333) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16072826, -0.1955744, 0.11417322, -0.3452607, 0.017155584, 0.16495948, 0.05746277, -0.080707975, 0.008824387, 0.095535375, -0.0043879473, 0.066520415, -0.22181952, 0.24477445, -0.06731457, 0.050523847) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.092721984, 0.52103335, -0.21452267, 0.40952858, -0.31748718, -0.073153205, 0.18445607, -0.15506712, 0.02543059, 0.19004662, 0.044598006, -0.05280189, 0.16632007, 0.078132, -0.23691738, 0.08813329) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.034127116, -0.03112006, -0.09157982, 0.10402836, -0.13250703, 0.30353814, 0.11505663, 0.09063663, 0.10919131, 0.031908765, 0.032495078, 0.12219225, 0.030304538, -0.20398197, -0.17167054, -0.2583621) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.294202, 0.101733975, 0.14325657, -0.07847818);
      result += mat4x4<f32>(0.009195325, -0.11253843, -0.037604034, 0.2472385, -0.17795436, 0.07768747, 0.13422057, -0.08941111, -0.048802916, 0.13460211, 0.21494192, 0.23734273, -0.17990544, 0.255999, -0.1044648, 0.273229) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10286846, -0.11486558, 0.011722244, 0.052875586, 0.13613455, -0.2020612, -0.14192568, 0.21076018, 0.03943485, 0.10527626, 0.1670011, 0.042116217, -0.07050622, 0.19767919, -0.10883371, 0.25192207) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030523468, 0.043377396, 0.078895554, 0.26011616, 0.025970727, 0.07616909, 0.040976427, -0.004594238, 0.20608081, 0.23722517, 0.15447298, -0.019459978, -0.07626336, 0.2002146, -0.046006557, 0.2412262) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12683532, -0.051210515, -0.049790084, 0.16803756, -0.22165659, 0.08479647, 0.2791564, -0.21263714, -0.029560743, 0.25014362, 0.33751044, -0.051404614, -0.008564998, 0.10989582, -0.031793848, 0.070540965) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.22328255, -0.35908777, -0.103526376, 0.31166545, -0.46205166, -0.24271679, -0.6709151, -0.2540042, 0.19536763, 0.066930495, -0.19275573, -0.30202752, -0.4491255, -0.0033493014, -0.9195583, 0.247003) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08113083, -0.10504763, 0.025534516, 0.2124673, -0.068727545, 0.08376502, 0.14042792, 0.15519442, -0.32178637, 0.3585255, 0.55167955, 0.78452784, -0.03332477, 0.13128166, 0.01789653, 0.20854725) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11926324, -0.26532242, -0.11039552, 0.33963618, -0.18426047, 0.0403387, 0.07876215, 0.024298701, 0.03388727, 0.14228705, 0.17291988, 0.3494139, -0.066456616, 0.14848164, 0.027821364, -0.11672692) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.19382448, -0.2524205, -0.08155565, 0.31256816, 0.06270693, -0.011887271, -0.09785583, 0.16897254, -0.07536311, 0.15813653, 0.16724555, 0.18029813, -0.067833506, 0.03121462, -0.21530248, 0.053657707) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.051207967, -0.14327678, -0.016768197, 0.2229102, 0.027580045, 0.17695089, 0.1808695, -0.0027829115, 0.13133368, 0.32128447, 0.16965792, -0.23458351, -0.08544149, 0.11724232, -0.15748662, 0.04272303) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.1849245, -0.20998736, -0.16391887, 0.15203688, 0.15089574, -0.15588866, -0.17351855, 0.113101795, 0.055103462, -0.022511244, -0.02597137, -0.0019413442, 0.08445646, -0.15248056, -0.028026382, -0.040787783) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09621742, -0.1275014, -0.08898821, 0.26177883, -0.012185702, -0.03186177, 0.03081846, -0.058809992, 0.31142202, 0.058387376, 0.2158777, 0.21235614, -0.16630675, 0.15645432, 0.022463037, -0.17693448) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.092885174, -0.15250815, -0.040970404, 0.3439567, 0.012918134, 0.09917659, 0.19304027, 0.25830123, 0.027676264, 0.1688698, 0.25949997, -0.07857056, 0.19353218, -0.12980913, -0.0069803474, -0.08764103) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08234749, -0.2901467, -0.20059349, 0.2732198, 0.08141943, 0.07803326, -0.24020414, -0.025397107, 0.03772811, -0.039872594, 0.03475436, 0.1015415, -0.10477782, -0.1615111, -0.32889017, -0.05707531) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20265208, -0.20557341, -0.12961374, 0.28960288, -0.10128243, -0.08494825, -0.081992514, 0.06900422, -0.28589958, 0.007591468, -0.020646235, -0.35127223, 0.16077977, 0.36958688, 0.721638, -0.76460963) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.040027294, -0.36295265, -0.2226629, 0.40383878, -0.073168345, -0.19656922, 0.168721, 0.22715758, -0.35182703, 0.21662155, 0.49662003, 0.20336659, -0.010315022, -0.10387886, -0.25483626, -0.19055131) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.039416056, -0.28757146, -0.23892137, 0.107669786, 0.1783023, -0.25476214, -0.28245705, 0.033747382, -0.034248963, 0.09831642, 0.23146743, -0.102308, 0.014781779, -0.02463926, -0.15464838, 0.03326792) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08630528, -0.22263236, -0.20080128, 0.21003196, 0.20818847, -0.13168338, -0.25034076, 0.04339198, -0.10844603, 0.25876334, 0.51741034, -0.2531535, -0.23480928, 0.08776562, -0.17204282, 0.002976615) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08115029, -0.15395927, -0.02096499, 0.21864061, 0.12582001, -0.058339298, -0.04015679, 0.05914066, 0.12589803, 0.13920386, 0.2079871, 0.13813697, 0.04082951, -0.08990339, -0.29217345, 0.22052252) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

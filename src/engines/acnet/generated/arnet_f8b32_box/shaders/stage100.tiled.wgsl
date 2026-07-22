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

  var result: vec4f = vec4f(0.34861642, 0.28841946, 0.22600439, -0.18420903);
      result += mat4x4<f32>(-0.028496625, -0.081655785, -0.080136105, 0.10083467, 0.11105053, 0.031185785, -0.0761755, -0.09637799, 0.009045113, -0.071192354, -0.10729064, -0.1149235, 0.27319592, -0.07652078, -0.30599356, -0.46011668) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.22684143, -0.5929684, -0.40661752, -0.2894787, -0.0007412024, -0.19336435, -0.30785477, -0.16595225, 0.10010109, 0.34102994, 0.11189194, 0.16203707, 0.18199685, 0.36952826, -0.12907436, -0.12394737) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.048992474, -0.18116118, -0.18006784, 0.19265042, 0.032193545, -0.06441312, -0.15613759, -0.13929377, -0.069626145, -0.09231245, 0.10953271, 0.12635602, -0.2435295, 0.11356577, 0.28856114, 0.3841718) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.031562816, 0.21498217, -0.3410724, 0.021909595, 0.02063935, 0.06042719, -0.13144632, 0.09233391, -0.11033049, 0.013112413, 0.10407175, 0.3411204, -0.087131776, -0.060025893, 0.04285722, 0.010480171) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.09951394, -0.086397946, -0.44197664, -0.29770246, 0.3280888, -0.23734874, 0.054498274, 0.17456655, -0.14420821, -0.36014172, 0.5743054, 0.12538418, -0.024692914, 0.068437606, -0.001554601, 0.20368451) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0022629201, -0.5696666, 0.03465102, -0.30392557, -0.03521403, -0.11708159, -0.2114292, 0.22959833, 0.13815734, 0.05552455, -0.05507464, -0.058440432, -0.121374555, 0.45213374, -0.09516612, 0.54237556) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07943076, 0.18065254, -0.09472056, 0.11860668, -0.054454688, -0.06509801, -0.0965521, 0.0901827, 0.011316301, 0.084342934, 0.23149376, 0.12705813, 0.17703804, -0.35740513, 0.062352687, -0.49282682) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19213331, -0.08232184, 0.24640891, -0.111659326, -0.08630547, -0.08912916, -0.24585378, -0.21655926, 0.041297432, 0.1799477, 0.2882257, -0.08671243, -0.0037502258, -0.43510327, 0.034262147, -0.27736714) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07007278, -0.14394936, -0.28725073, -0.188054, -0.015378256, -0.13662098, -0.10626244, -0.15753667, -0.057031218, -0.036970854, 0.09507896, 0.02044714, -0.20216313, -0.28227645, 0.2653506, -0.010998094) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.10274558, -0.5746076, 0.07460761, -0.16513553, -0.008815786, 0.09679875, -0.034593757, 0.16877376, -0.028888866, 0.03206853, 0.14086503, 0.052177135, 0.048530966, 0.13309664, 0.003473112, 0.17128162) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.27147275, 0.053231653, -0.21505697, -0.3553263, -0.042961095, -0.46841794, -0.45240647, -0.19822106, 0.050041776, 0.08201475, -0.11823943, -0.082273334, 0.0016422413, -0.5006812, -0.3178502, -0.12743336) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11817419, -0.21046403, -0.24437138, -0.23869304, 0.10335313, 0.06467865, -0.12471285, -0.13682644, -0.062218685, -0.027216487, -0.07082932, -0.0041202013, -0.0509577, 0.06619515, 0.19784419, 0.24900107) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11711352, -0.42028868, 0.15754636, -0.04292151, 0.005624863, 0.12404069, 0.12117552, 0.23491724, -0.047393836, 0.08334052, -0.16609703, 0.33337685, 0.18382187, 0.29861972, 0.2178733, -0.17859076) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.010518128, -0.21138966, 0.16924182, -0.114755295, -0.016294545, -0.6258314, 0.3242515, -0.2710746, 0.015193567, -0.5291544, -0.18899386, -0.3252035, 0.15944386, 0.00027345834, -0.45050582, 0.34999746) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08051967, 0.43341875, -0.1548812, 0.17973727, -0.12306302, 0.14755785, 0.087054975, 0.31077725, -0.06374641, -0.50028926, -0.30942997, -0.04756787, -0.09898156, -0.027371906, -0.02726485, 0.028408904) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11657608, -0.13298348, 0.3186897, 0.30226752, -0.018733803, -0.024018405, -0.038465746, -0.22701219, 0.0043616365, 0.12842552, -0.09474773, 0.2589022, -0.1268171, -0.20631637, -0.10589385, -0.08508449) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.31796294, -0.2575555, 0.11947908, 0.282508, 0.008004697, -0.15428562, 0.007239874, -0.24057682, 0.045289315, 0.23021436, 0.17172928, -0.19495977, -0.030888582, -0.15614429, 0.04023113, -0.122746505) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12394096, 0.5042676, 0.045108043, 0.6623935, 0.035676487, -0.0065814783, -0.016724877, 0.032909524, -0.10594153, -0.033198804, 0.09038828, -0.15069608, -0.021062892, -0.07527621, 0.1679243, 0.0059621665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

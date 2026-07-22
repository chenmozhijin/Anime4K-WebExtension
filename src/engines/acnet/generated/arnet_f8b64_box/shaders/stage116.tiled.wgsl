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

  var result: vec4f = vec4f(0.017993575, -0.03174005, 0.114778936, -0.15256716);
      result += mat4x4<f32>(-0.06343082, 0.09707142, 0.30170134, -0.10916579, -0.09730566, -0.120240495, 0.078393936, 0.388956, 0.071848996, -0.014055227, -0.019680971, 0.13863872, 0.12442885, -0.05648579, 0.0008306608, 0.038824994) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.111532204, -0.060788877, 0.39074996, -0.05923392, -0.37370944, -0.024305444, 0.082124956, -0.05709175, -0.13436991, 0.11676609, 0.033649914, 0.10682739, -0.42014727, 0.17413747, 0.44158146, -0.62127113) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.01285658, 0.08273923, -0.10330169, 0.046524778, -0.019663563, -0.010868839, -0.0927469, -0.023803337, -0.08224482, -0.12399082, 0.1093198, 0.10392955, -0.1397341, -0.0778335, 0.05114476, 0.079344876) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12195601, 0.0052991505, -0.037828006, 0.07815213, -0.03524907, -0.25340438, -0.46905234, 0.46746004, -0.05883411, -0.065881416, -0.097106, 0.2954013, 0.038151395, 0.22647795, 0.49497014, 0.17523244) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15882005, 0.050709896, -0.18592039, 0.10153934, -0.39563462, -0.1115767, -0.46357772, 0.25834763, -0.19991213, 0.30433497, 0.19078198, -0.5067156, 0.48554233, -0.06027025, 0.10391586, -0.6052217) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.051362142, 0.07850262, -0.006197119, 0.1543379, 0.12517652, -0.09086132, -0.23923041, 0.029431574, -0.08530318, 0.02151704, 0.24313292, -0.36630708, -0.023866821, -0.15632574, 0.049349222, -0.30644873) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16129339, -0.09011379, 0.03991395, -0.07353573, -0.13057092, -0.05024835, -0.1471182, 0.09242804, 0.06585155, 0.0533066, 0.11151889, -0.02796749, 0.14168695, 0.040659804, 0.006848588, -0.24196412) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.023256931, 0.23273309, 0.04093754, -0.10374316, -0.21313833, -0.013851892, 0.025129912, 0.17907196, -0.22952935, 0.12023002, 0.06690902, 0.042247247, 0.20447153, -0.0744409, -0.000857125, 0.051353335) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.03433651, -0.067450374, -0.026278498, -0.013454872, 0.06672403, -0.023542797, -0.13643116, -0.01223526, 0.012956503, 0.4303768, 0.34362176, -0.013148451, -0.03046669, -0.17921957, -0.0506518, 0.028216125) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.09666471, 0.02480724, 0.20109661, 0.19680353, -0.33660382, 0.05717995, -0.32062727, -0.25046578, 0.031247737, 0.032602187, 0.0961024, -0.1442809, 0.17601773, -0.06899783, -0.076806456, 0.059241723) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.15475196, 0.07802311, 0.25353375, 0.38555735, 0.23340869, -0.048334915, -0.20158827, 0.25974172, -0.0769611, 0.123182975, 0.109715246, 0.004969273, 0.028990641, -0.039590083, 0.114554115, 0.021388963) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.005590332, 0.08923076, 0.020564996, -0.107289225, -0.11645292, 0.03142673, -0.26958367, 0.05433062, -0.07049535, 0.015360608, 0.18086214, 0.029576313, -0.061100986, 0.08355104, 0.2802974, 0.040717788) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1755364, 0.10136629, -0.005598606, 0.02913387, -0.24709016, 0.08292858, -0.11544263, -0.05791615, -0.017519187, 0.065396, 0.18984869, -0.18703297, 0.4355525, 0.010706779, -0.0902337, 0.32138556) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0066977045, 0.19649592, -0.33036366, -0.14605303, 0.2424508, 0.10249054, 0.06490776, 0.067300454, 0.10562498, -0.22366077, 0.26297885, 0.38520467, 0.32363096, -0.06940351, -0.2757933, 0.5594575) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.075439185, 0.022204984, 0.36690003, -0.15173066, -0.37153673, 0.08473698, -0.11919508, 0.046779234, 0.2640813, -0.043148488, 0.10836931, -0.27877787, 0.04448261, 0.075653, 0.25885043, 0.39121076) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.005583411, 0.156295, 0.06686756, 0.1835388, -0.13744122, -0.18516114, -0.35596374, 0.06579775, -0.16072574, -0.026902314, -0.36125594, 0.041291766, -0.03761481, 0.084348276, 0.31430954, 0.08959163) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.060716245, 0.16475177, 0.15812026, 0.20752826, -0.021567171, -0.05579441, -0.5467895, 0.28354394, -0.408035, -0.13205123, 0.05637247, 0.28046918, -0.07893388, 0.104642056, 0.00072863355, 0.17856976) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.032500487, -0.013495679, -0.049696162, -0.073440716, 0.12013886, 0.026454529, -0.23237488, 0.13443244, 0.1242693, -0.009874192, -0.20259848, 0.10665804, -0.31326947, -0.05159512, 0.13309976, 0.2784105) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

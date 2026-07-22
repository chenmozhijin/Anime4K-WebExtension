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

  var result: vec4f = vec4f(0.20631146, 0.045609355, 0.11327672, 0.006456689);
      result += mat4x4<f32>(-0.05814065, 0.32097173, -0.0006842401, -0.13749072, -0.02776851, -0.008697059, -0.02494948, 0.07015755, -0.19010857, -0.26728657, 0.30662337, 0.14134198, -0.07133877, -0.30992573, -0.19137824, 0.1717562) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.28240633, -0.18847029, 0.12873735, 0.25909105, 0.25362158, 0.009554893, 0.17603578, 0.14143062, -0.15780556, 0.019067245, 0.27734748, -0.13986833, 0.0003490187, -0.1583652, 0.39208344, -0.13098456) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16301961, 0.18459989, 0.037964206, -0.024532875, 0.081975766, 0.0812441, -0.044554006, 0.15901716, -0.039479334, 0.16877979, -0.10422401, 0.04175787, 0.09634502, 0.26992378, -0.03128727, 0.118990526) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1863154, 0.11413795, 0.07627686, -0.3336193, -0.35992804, 0.06698759, -0.09153736, -0.0007512874, 0.16665915, -0.13264477, -0.40676045, 0.25630224, -0.050424643, -0.56716776, -0.22733131, 0.23544236) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.31819016, 0.15842041, -0.23319429, 0.43812403, 0.2587606, 0.26438603, 0.075142555, 0.2298415, -0.15256742, -0.09992954, -0.06033507, -0.22745271, -0.19360279, -0.41553515, -0.20935187, 0.07904018) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.072057255, -0.19440427, -0.07600884, -0.20145875, -0.03423604, 0.0930363, 0.12821661, 0.087236986, -0.28487328, 0.267938, -0.10539465, 0.29312852, 0.017382292, 0.10018871, -0.36764798, 0.020670557) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23328982, 0.08962137, 0.027012086, 0.099109165, 0.0968497, 0.054154698, -0.22382472, 0.06729895, 0.07292343, 0.114766024, 0.08334498, -0.20078045, -0.3322878, -0.062647484, 0.17616305, -0.23844965) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.02475085, -0.106647335, -0.02561005, -0.019590126, -0.2659924, -0.10914075, 0.080035895, -0.13475001, -0.3181516, 0.0024228455, 0.45480594, -0.44822165, -0.039757524, 0.10645128, 0.104430795, 0.055962496) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.015845904, 0.08411865, 0.106561765, -0.07013072, -0.08217645, -0.090019755, 0.06432187, -0.0700229, -0.00021127872, 0.40346673, 0.124004416, 0.22072679, 0.10244786, -0.042757597, -0.10148135, -0.24776119) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.011339929, -0.020134967, 0.045388356, 0.15962681, -0.0443625, 0.2092868, 0.12324569, -0.2062767, -0.08602254, 0.12928239, 0.014371378, -0.08340416, -0.13420749, -0.28504217, -0.04127855, -0.06340057) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10679824, 0.2356612, -0.122437574, -0.24571745, -0.29808447, -0.036254704, -0.16165283, 0.07675106, 0.12300592, -0.21484712, 0.1600696, 0.022161186, 0.22516927, 0.23236106, 0.14015163, -0.21797618) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15599269, -0.05810256, -0.19108038, -0.18474102, 0.09590049, -0.2880697, 0.024361992, -0.3985443, 0.14466234, 0.101940654, 0.053450536, 0.1831945, 0.0923416, 0.04456055, -0.022027144, -0.10371097) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.27232403, 0.20332517, -0.15029618, 0.009409542, 0.299883, 0.104696035, 0.1771465, 0.084457785, -0.27155614, -0.124663256, 0.22243626, -0.29625624, 0.27241895, -0.45322365, -0.10587886, 0.35790458) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.20334144, -0.65325654, 0.53938264, 0.1468666, 0.3878067, 0.08992892, 0.35105383, -0.30761024, -0.19541736, 0.7188682, -0.2273075, -0.43336016, -0.5065246, 0.5760363, -0.25314832, 0.010485576) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.38620862, 0.073249854, 0.17735168, -0.47542882, -0.043626014, 0.014157313, 0.011669272, -0.17114983, -0.4135878, 0.05792586, -0.09224702, 0.32185024, -0.30471218, -0.0047237966, -0.10105719, 0.05053119) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17323235, -0.00920275, -0.086168125, -0.15791412, 0.20250492, -0.0001523634, -0.10297043, 0.1080464, 0.13190936, 0.09425723, 0.04523853, 0.39660913, 0.16279781, 0.19216354, -0.12983534, 0.03955539) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.81716156, -0.35003787, 0.041690975, -0.14459032, 0.60599697, -0.24120626, -0.082855485, -0.09743317, 0.029943876, 0.26042977, -0.40761366, 0.33769268, -0.7217205, -0.34607285, 0.107892476, -0.035270594) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04667603, -0.12201184, -0.013794361, -0.1744591, -0.05101346, -0.018980244, -0.15011711, 0.15940537, -0.105640784, -0.33514127, 0.013252265, -0.16490905, -0.36009195, 0.088221945, 0.19633456, 0.07499994) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

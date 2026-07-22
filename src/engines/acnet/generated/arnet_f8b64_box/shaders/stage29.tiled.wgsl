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

  var result: vec4f = vec4f(-0.13298649, 0.0017019865, 0.08990147, -0.006719012);
      result += mat4x4<f32>(-0.03098865, -0.13401361, -0.08777361, -0.11677178, -0.014882171, -0.042173315, 0.0069270954, 0.10076767, -0.19290085, -0.07723315, -0.07543859, 0.11104736, 0.21937194, 0.1487004, -0.1493582, 0.17240468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.023140611, -0.057350006, -0.5850323, -0.13057043, -0.49038583, -0.22861263, -0.058045596, -0.5165283, 0.15407236, -0.29631364, 0.11938131, 0.1713628, 0.21200329, -0.004994344, 0.22089973, -0.015305142) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08358835, -0.13065737, -0.074477986, 0.032392375, -0.10770823, 0.3767617, 0.18506871, -0.10607378, -0.18605126, 0.12655957, -0.29003927, 0.039201777, -0.021782888, -0.1405501, -0.116178244, -0.005936281) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2067615, -0.14957784, 0.19109054, -0.09386974, 0.028601492, -0.1021264, -0.0988611, 0.11394802, 0.082950614, 0.1760967, -0.20462355, 0.15597948, -0.30530605, 0.29495344, 0.054592777, -0.5056027) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.46361887, -0.11762168, 0.0941199, 0.31373382, 0.038883295, 0.45030808, 0.3560016, -0.43497553, 0.37716419, 0.73558694, -0.3664883, 0.59224284, 0.12928955, 0.5669376, 0.24775308, -0.17551343) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.15946783, 0.0053093005, -0.090494074, -0.023059692, -0.38544893, -0.008519483, -0.029140241, -0.100532785, -0.09008052, 0.007944958, 0.049468424, 0.024119211, -0.0809529, 0.12107018, -0.19402261, -0.09043718) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.21206786, 0.1681216, 0.08904116, 0.04533709, -0.0074250363, 0.016715176, -0.068010636, -0.10372643, 0.16457373, 0.005724641, 0.13677584, 0.12148065, 0.049343403, 0.25540105, -0.061817, 0.038756542) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.24861714, 0.58617175, 0.25971076, 0.10594511, -0.08564617, -0.14044294, 0.0051248865, -0.07317907, -0.19888827, 0.0138660455, -0.17151308, 0.26045233, 0.30950424, 0.4193579, 0.09495029, 0.23053715) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.033773508, 0.038001873, 0.080500826, 0.09803236, -0.12360484, -0.19041166, -0.10386366, -0.103882916, -0.009160519, 0.25308907, 0.08768576, 0.6338228, -0.13447988, 0.00025836623, -0.09620286, -0.14748013) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.025456188, 0.20007242, -0.18936986, -0.15661304, -0.05147374, -0.098212294, 0.095440514, -0.03672789, -0.052494694, 0.06278197, 0.10112869, 0.032669432, 0.2917176, 0.040171843, -0.027420945, -0.014968426) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.009521608, 0.0947036, -0.17481804, 0.033500355, -0.17904978, -0.017985096, -0.35771596, -0.28582475, 0.13937443, 0.118979186, 0.29975346, 0.03089344, 0.457555, -0.113298, 1.0109432, -0.2639423) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.019049212, 0.079022996, -0.04352879, -0.19227737, 0.028152484, -0.06001489, 0.010760164, 0.12878644, -0.026451236, -0.18000768, 0.16018423, -0.057972785, -0.09112854, 0.12121349, -0.13026299, -0.26873013) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.042692464, 0.018475397, -0.1924749, 0.01870762, 0.19167483, -0.10260548, 0.035990663, 0.028770447, 0.07423074, -0.37728798, -0.08665133, 0.11087817, 0.19130011, 0.24818592, 0.27695602, -0.1504707) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.48553637, 0.5579299, 0.1642737, 0.19685902, 0.45566854, -0.49181867, -0.4432539, -0.6201949, -0.2833433, -0.3493298, -0.023557551, 0.18319686, 0.396124, 0.28707623, -0.0011898753, -0.3454638) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.28962085, -0.2259933, 0.00072975666, 0.31758505, 0.124226786, -0.29680353, -0.06664476, 0.38646284, -0.22607219, 0.48744488, -0.08598103, -0.3529645, 0.22066377, -0.012271128, 0.20983163, -0.009778074) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.005512419, 0.0313881, 0.010721879, -0.021729488, -0.03287399, 0.1336352, 0.2010416, -0.42117321, -0.017548857, -0.007111147, 0.080294564, -0.11854506, -0.1451254, -0.17853509, -0.09376403, -0.14686066) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.060846914, -0.076639935, 0.03002873, 0.14909817, -0.15973088, -0.5267581, -0.17515145, -0.40389884, -0.18144383, -0.094799146, -0.18689609, 0.08082987, -0.08156942, -0.23713854, -0.05589517, 0.08107418) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10858069, -0.10745692, 0.09061574, 0.11054776, 0.20067948, -0.018670527, -0.035018064, -0.03992981, -0.0027743047, -0.16097856, -0.08520113, 0.066262566, -0.14996754, -0.1809422, -0.011201319, -0.11161765) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

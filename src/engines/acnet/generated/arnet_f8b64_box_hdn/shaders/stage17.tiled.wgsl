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

  var result: vec4f = vec4f(-0.23047504, 0.041280292, 0.08945028, -0.079465985);
      result += mat4x4<f32>(-0.084688954, 0.27201054, -0.27311656, -0.4346894, -0.2939256, 0.11630526, -0.25273693, -0.2897128, -0.06335886, -0.023381341, -0.07643397, -0.013559449, -0.015254418, -0.04574521, -0.26842764, 0.0160664) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16923195, 0.11792135, 0.17332004, -0.3773063, -0.32378682, -0.17274258, -0.5428982, -0.26827008, -0.073170654, 0.25543684, -0.21687368, -0.097886585, 0.06142802, -0.14787103, 0.4295677, 0.055507176) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.050538123, 0.13179679, -0.3613561, 0.26974785, -0.17808628, -0.21539417, -0.036973335, 0.2346153, -0.11381083, -0.114870705, -0.079881534, 0.13374962, 0.03700912, -0.003268559, 0.043375127, -0.009776466) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.063351065, 0.13606451, -0.221351, 0.27127966, -0.4382468, 0.2771482, 0.2511856, -0.13504827, 0.07082502, -0.010148994, 0.0630596, 0.5862052, -0.039878327, -0.32071674, 0.06599507, 0.5370653) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.44528216, -0.043220155, 0.20554316, 0.9222577, -1.2229564, -0.020237038, 0.52904755, 0.49305767, 0.038055986, -0.06077312, 1.5212729, 0.54849905, 0.1567005, -0.41206795, 1.7669703, -0.19660878) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24481419, -0.3029743, 0.48882183, 0.27125692, 0.37163132, -0.6543399, -0.01861168, 0.19626816, 0.04300547, 0.34355137, 0.107014894, -0.2710486, 0.015368202, -0.2113747, -0.08285143, -0.32894722) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.006374, 0.19408613, 0.17623971, -0.213129, -0.08725847, 0.10489888, 0.1369392, -0.05930893, 0.20353845, 0.42565653, 0.40118188, -0.44843882, 0.061522465, 0.07936488, 0.03606557, 0.40693983) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.29514426, -0.12993832, -0.3073549, 0.04384746, 0.123291336, 0.036701508, 0.3493245, -0.037260316, 0.45609817, 0.25143504, 0.7061612, 0.037057076, 0.37175727, 0.061499346, 0.68269026, -0.14734396) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.06446835, -0.046917457, 0.17002162, -0.26389933, 0.04807229, -0.19873825, 0.100571595, 0.10946316, 0.12906091, -0.029122, 0.05622524, 0.0401614, 0.05337654, -0.17689139, -0.062113702, 0.10914731) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.03394735, -0.06600391, 0.15056351, 0.17399843, 0.005851267, -0.20596197, -0.08771402, -0.103799544, -0.04719948, -0.07841127, -0.34653306, -0.16367589, 0.087656, -0.014773717, 0.11059189, 0.37350038) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21339445, -0.0067040334, 0.44615588, 0.11748099, 0.06352709, 0.013029716, -0.22235908, -0.13204864, 0.011734796, -0.15718405, 0.49554113, 0.02688902, -0.10124131, -0.27344367, -0.3996703, 0.2518485) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12884745, 0.0060019684, 0.21174625, -0.01048426, -0.02258274, 0.19122288, -0.0052542794, -0.28832465, 0.0017886308, -0.10211076, 0.13248518, 0.060502797, -0.048834883, 0.1757572, 0.22037055, 0.003770733) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.28384346, -0.25620496, -0.14936008, -0.082355246, 0.6031921, -1.1671845, -0.4372383, 0.60886747, -0.4074893, 0.5898857, 0.3446393, -0.6465105, -0.07658089, -0.032725014, 0.019677147, 0.120708965) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5489507, -0.13684897, -0.3571801, -0.057716515, 0.45053267, -1.1186529, -0.07831225, 0.29360637, -0.3238893, 0.4959355, -0.09288386, -0.3106451, -0.09420456, -0.4936369, 0.39183694, 0.8809523) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.23838685, 0.4438406, 0.23182, 0.038589906, 0.0030859942, -0.053634837, 0.07652869, 0.0027244315, 0.030201526, -0.08275952, -0.043022394, -0.06445678, 0.024043012, -0.263918, -0.17592722, -0.22641437) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.021287644, -0.11376488, -0.14340632, 0.118663065, -0.06580915, -0.76876, -0.15258257, -0.019058768, 0.020387767, 0.3070375, 0.1136979, -0.11594164, 0.18569346, 0.004859659, -0.099249385, 0.1963693) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.04019337, -0.034737166, -0.19678405, 0.098317415, 0.35127428, -0.12987466, -0.020009581, -0.09521137, -0.43441996, 0.12913182, -0.26357687, -0.06871995, 0.18402956, -0.05065721, 0.29342982, -0.5870629) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.2353673, -0.16267794, -0.08067087, -0.053884998, 0.045127254, 0.12080142, 0.052682802, -0.16361947, -0.02986465, 0.05934958, -0.124571465, -0.13388772, 0.035473805, -0.16855384, -0.047186866, -0.2724104) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

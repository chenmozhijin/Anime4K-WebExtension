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

  var result: vec4f = vec4f(-0.0036976936, 0.1361208, 0.11187361, -0.020968681);
      result += mat4x4<f32>(0.06874066, 0.11211078, 0.044478144, 0.08245733, 0.15274084, -0.06522237, 0.07624267, 0.06315402, 0.03197936, 0.06709084, 0.035209298, 0.21670663, 0.07977113, 0.03566588, -0.025140917, -0.24672173) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0052691577, -0.062051143, -0.01893335, -0.16101266, 0.2995892, 0.38101435, 0.15030703, 0.4180504, -0.1504159, -0.3080554, 0.10055366, 0.19016857, 0.08422565, -0.07861276, -0.0677783, 0.030155323) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.03880202, 0.0738148, 0.14496666, 0.35360292, 0.040657785, 0.16036533, 0.072976805, 0.17257485, -0.08455495, -0.30188608, -0.32374218, -0.6038208, 0.06615206, 0.06870515, 0.027826637, -0.08793515) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.022655014, 0.017892936, -0.23996818, 0.047904737, 0.0020748698, 0.22990023, 0.07244165, 0.3147859, -0.006725729, 0.07313084, 0.11395542, 0.49957836, -0.05258542, 0.19278981, -0.2577395, -0.31946) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5509455, -0.06624635, -0.4971581, -0.12701237, 0.36504796, 0.35979, -0.27273798, -0.057569817, 0.09170809, -0.7931685, 0.47048342, -0.122312956, 0.10813578, 0.047569893, -0.44218287, -0.49527556) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1970043, -0.15541402, -0.10692903, -0.28509516, 0.18884902, 0.14503619, -0.008530181, -0.15489511, -0.06021345, -0.53202116, -0.10868646, -0.3877101, 0.12014943, 0.19024856, 0.054306604, -0.09159394) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.034650158, 0.023242312, -0.0710262, -0.029371047, 0.11452035, 0.16803046, 0.15510382, 0.16715366, 0.09423003, 0.05798443, 0.06805017, 0.031919416, 0.13858771, 0.2514581, 0.15829162, 0.24738109) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.059355002, -0.00423369, -0.24130914, -0.3150462, 0.28968853, 0.30283225, 0.041484296, -0.21521285, 0.1282302, 0.23803456, -0.10773219, -0.2061281, 0.0059436713, 0.04945614, -0.016728895, -0.17276731) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.102044046, 0.02840383, 0.00071805035, 0.18035258, -0.023690468, 0.03028545, -0.07958896, -0.25408393, -0.13862522, -0.1800597, -0.0689199, -0.0076435274, 0.07048292, 0.17521167, 0.07513758, 0.08086385) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.03961139, 0.2069694, 0.105709635, 0.25895694, -0.06651841, -0.059503656, -0.067444175, -0.25488085, -0.0034476293, -0.14248769, -0.05105884, -0.027379742, -0.1002784, -0.0666633, 0.046396453, 0.009066542) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.103479855, 0.059795965, 0.24402791, 0.19870989, 0.09618832, -0.09861863, -0.2905222, -0.6438494, 0.107431054, -0.09947809, -0.14327751, -0.2298604, 0.010231867, 0.17192043, 0.21277612, 0.5783419) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.20329535, -0.18942128, -0.1424548, -0.09622951, -0.60525596, -0.2410475, -0.0061174985, -0.11993484, 0.108745866, 0.056538884, 0.057051647, 0.12887971, -0.015662875, 0.074226715, -0.0680441, -0.17354725) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.05325644, 0.09862363, 0.13318633, 0.31724703, -0.045759797, -0.08820628, 0.019211384, -0.064241804, 0.1601563, 0.20342149, 0.01805971, -0.22187677, 0.010368537, -0.2534259, 0.039467316, -0.25775272) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.044228647, 0.17287816, -0.1512208, 0.10558088, -0.025243597, 0.116587654, -0.22822446, -0.64544743, 0.8062988, 0.022355806, 0.07497892, -0.80689067, -0.0048352904, 0.46388423, -0.44590336, 0.086041614) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.34299833, 0.025763985, 0.19481806, 0.6375508, 0.04551729, 0.24044424, -0.01784806, -0.30786738, 0.0328803, 0.018354286, -0.09099305, -0.07587172, -0.4775753, -0.07768613, -0.02034858, 0.42921945) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.042193465, 0.065411605, 0.025585223, 0.0957948, -0.055898882, -0.09193039, -0.083153, -0.15716012, 0.13906857, 0.2694219, 0.11138233, 0.057354786, -0.07203417, -0.02410335, 0.0016205985, 0.07441678) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.029041044, -0.12100689, 0.05716573, 0.18988577, -0.14092304, -0.24260572, -0.046036337, 0.022078702, 0.03910612, 0.299333, 0.11946604, -0.27752623, 0.0144702885, 0.104331166, 0.24244592, 0.47755808) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10582396, -0.022033423, 0.12374798, 0.22812806, -0.07436819, 0.22640039, 0.01927166, 0.024380533, 0.0058521335, -0.018972289, -0.058032636, -0.045962453, 0.03933148, 0.12892994, -0.0066298605, -0.06384784) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

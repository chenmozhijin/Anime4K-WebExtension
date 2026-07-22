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

  var result: vec4f = vec4f(0.5552491, -0.29002523, -0.29110366, -0.14859998);
      result += mat4x4<f32>(0.0016864195, 0.03163146, 0.32049206, -0.018259665, 0.032035746, 0.043613475, -0.018858014, 0.10656804, 0.07527551, 0.21339872, -0.22804838, 0.29488543, -0.18669131, 0.04006757, 0.030141175, 0.04263428) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.01641518, -0.3360248, 0.18736814, 0.028548816, -0.16855675, 0.032699622, 0.30590016, -0.1265799, 0.10691886, 0.26477045, 0.1613243, 0.003304545, -0.29493314, 0.06463159, -0.19458756, 0.11945824) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.13299954, -0.10832293, 0.026326792, 0.0059406203, -0.1519696, 0.037948024, -0.115163594, 0.16846396, -0.104578145, 0.115040675, -0.07181176, -0.079071045, -0.25293615, 0.04836951, 0.058302533, -0.046127502) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.23128127, 0.03864727, -0.28426385, 0.48276773, 0.022918433, 0.14968713, 0.06137814, 0.075584, -0.05902372, -0.10221083, -0.2567853, -0.07035839, 0.02090659, -0.38979983, 0.353957, -0.115775555) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19982406, -0.49008164, -0.20604889, 0.12991998, 0.42066947, -0.3387009, -0.16007957, 0.31629884, -0.815202, 0.1071241, -0.081781685, -0.09655598, -0.11974331, -0.22695899, -0.4029642, 0.2847252) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1928984, -0.12760434, -0.4711362, 0.1762934, 0.04090335, 0.16741256, -0.35089928, 0.30596456, 0.5934194, -0.36664227, 0.15068255, -0.04973387, 0.1944499, -0.11887721, 0.30735952, -0.22449794) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.078360215, 0.20638509, -0.2390234, 0.15941723, -0.116237044, -0.29821977, 0.16580753, -0.20821315, 0.3255546, -0.40084967, 0.15034412, 0.008629606, -0.08641373, -0.111805044, 0.07081574, 0.06401832) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10474667, -0.37726876, -0.015315455, -0.25635993, -0.52366424, 0.0640019, -0.23520471, 0.22810782, -0.23055951, 0.02673258, -0.09237621, -0.116049245, -0.2051236, 0.4886121, -0.06438138, 0.058642123) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.25681978, -0.11075103, 0.017223986, -0.03630283, 0.0027502484, -0.3578961, 0.09310829, -0.23081379, -0.07342688, 0.0379807, 0.028334575, -0.14829916, -0.0023513336, 0.2575877, -0.02133247, 0.068634406) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.04438754, 0.19483855, -0.07995854, -0.039325643, -0.028270116, -0.20762883, -0.02653462, -0.034124434, -0.15180612, -0.07334459, -0.051710814, 0.16559297, -0.28285187, -0.110111654, 0.03745789, 0.21874733) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0123572, 0.23955032, 0.23679079, -0.23786159, 0.07713475, -0.13707675, -0.15436763, -0.05662561, -0.14553523, -0.22910865, -0.098056406, 0.06300067, -0.23274519, -0.2435807, 0.18296395, 0.2374374) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14100057, -0.22678797, 0.08210315, 0.025403803, 0.26090905, 0.13657384, 0.06429815, -0.23442814, -0.17850178, 0.016866332, -0.049527206, 0.03342229, -0.031977512, -0.26678392, 0.1570909, 0.25809833) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.025802271, -0.43076998, -0.389942, -0.019090405, -0.29303086, 0.05499596, -0.23933327, 0.28364125, -0.12794758, 0.19084413, -0.17835496, 0.085944295, -0.16429716, -0.2195763, 0.04886704, 0.16144107) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5978284, 0.3422849, 0.3763944, -0.029099897, -1.0283656, -0.83313584, -0.1377302, 0.5882148, 0.13918495, -0.40045014, 0.14632721, -0.061433543, -0.039195184, -0.39733744, 0.27867365, 0.44871253) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2695487, 0.6618567, 0.16592821, -0.04158593, 0.20970187, 0.0999244, 0.24331683, -0.3258855, -0.22342075, 0.018637441, -0.018214285, 0.06726497, -0.021185966, -0.039746583, 0.001895645, 0.50010973) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.18300782, 0.05430367, -0.0069947904, -0.12957425, 0.08953641, -0.20499508, 0.07501327, -0.11142548, -0.21018438, 0.15953703, -0.18423113, 0.13896923, -0.51945096, -0.09712344, -0.18502544, 0.15800771) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.099347636, -0.00897852, 0.29389322, -0.1500517, -0.13410398, 0.12738116, -0.017443003, 0.022655603, -0.23772785, 0.07965458, 0.021389032, -0.014847724, -0.17170902, -0.10563139, -0.2007815, 0.59219265) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.3563691, 0.4555131, -0.22986503, 0.2186759, 0.41832113, 0.32997566, 0.021967718, -0.19344628, -0.15779814, 0.12161602, -0.0991073, 0.034274828, 0.083273776, -0.21606885, 0.027705388, 0.36375332) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

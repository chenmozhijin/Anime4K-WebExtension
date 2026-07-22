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

  var result: vec4f = vec4f(0.11349687, -0.15045588, -0.111010246, -0.087969825);
      result += mat4x4<f32>(0.2568414, 0.10710551, 0.14867675, -0.0621017, -0.1838854, -0.08230567, 0.23118024, -0.14301693, 0.38659295, -0.051480047, 0.13082345, 0.105413675, -1.0003369, -0.011025165, -0.46967468, -0.07864049) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.060080893, 0.04235238, 0.12265213, 0.15421762, 0.24238297, 0.30248642, -0.00672779, -0.20980379, -0.44639397, 0.035862427, -0.24858305, 0.13434805, 0.15537126, -0.0734445, -0.3850101, 0.6081858) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.24649765, 0.05583379, -0.11523884, -0.038977206, -0.15661034, -0.024520151, 0.13163188, -0.003221907, 0.13224402, 0.059090223, 0.027483275, -0.06476588, 0.36451215, 0.27157968, -0.30958885, -0.025201203) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.031313106, 0.31436074, -0.26422176, -0.10705098, -0.097182795, 0.23847748, -0.23018168, -0.13752678, -0.7899136, -0.33383694, -0.20849526, 0.039613485, -0.02051826, 0.36060008, 0.36017942, 0.27556667) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.74969894, -0.45993894, -0.13738841, 0.040880796, -0.20993745, 0.061517555, 0.9218086, 0.37161565, 0.74238425, -0.09704629, 0.6723198, -0.07179828, -0.091728024, -0.44038844, -0.15414256, -0.07967251) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08552055, -0.02175466, 0.06126153, -0.053305063, -0.17223054, 0.15960412, 0.3587503, 0.178662, -0.034262847, -0.08532491, -0.22273648, 0.24462463, 0.027211342, 0.21120138, -0.118789375, -0.16590032) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.067349985, -0.11545142, -0.031268783, -0.029823324, -0.19833638, 0.06574007, -0.38383353, 0.044865303, 0.0749738, -0.06911395, 0.32774585, 0.029450884, -0.3420233, 0.15453772, -0.35196376, 0.07545173) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08494612, -0.30345726, 0.058893993, 0.036076613, -0.0830396, -0.4295388, -0.24742107, 0.0066282274, 0.24044983, 0.21596085, -0.3130537, -0.030926837, 0.088793844, -0.049107313, 0.0037853282, 0.013687389) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19795519, 0.19201411, -0.014197584, -0.08084386, -0.090623505, -0.02828686, -0.10519691, -0.010337774, -0.45882607, -0.35938126, 0.2838784, 0.054066066, 0.1280651, 0.12130101, -0.13545841, 0.025356345) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.023089357, 0.02734579, 0.030369325, -0.040395625, 0.18726581, 0.06996793, -0.07485686, -0.019226022, -0.030910809, -0.05550983, -0.02258337, -0.0056651216, 0.071986035, 0.14065242, -0.01407011, -0.15428232) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.31642106, -0.37007585, 0.020761162, 0.08416752, 0.56986487, 0.15130913, 0.03706367, -0.080253765, 0.24170013, -0.019731732, -0.15621231, -0.04338773, -0.4019283, -0.13141948, 0.05654796, 0.043298833) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02103625, -0.20596765, -0.1420412, -0.020763446, 0.14550972, 0.19271237, -0.13656704, -0.050352685, -0.36667347, -0.19513716, -0.06584763, -0.047175888, 0.106146395, -0.06992786, -0.029275967, -0.050491072) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.015904061, -0.05203782, 0.16519253, -0.16405065, 0.083777614, 0.14901903, -0.1758149, -0.039304685, -0.09424974, -0.42614365, 0.06936143, 0.008462953, 0.17498545, 0.31461206, 0.36208624, -0.06018936) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.72071964, -0.08418291, 0.7189613, -0.74141043, -0.21995391, 0.83783334, 0.42102277, 0.19475879, 0.42810786, 0.89817053, -0.2058731, -0.78422695, -0.26309153, 0.09729611, 0.8816244, -0.03287674) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14499052, 0.34825584, 0.25496072, -0.2692956, 0.16473176, 0.15172729, -0.24426143, -0.056987345, 0.29546598, 0.18321577, -0.13618545, -0.20070094, 0.18841752, 0.16811055, 0.27986488, -0.007287508) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1160931, -0.1877861, 0.16233726, -0.09936944, 0.17102411, 0.09376483, 0.049526934, -0.1627296, 0.07754861, -0.03089835, 0.07760862, -0.01684293, -0.21931563, 0.3147731, -0.0675053, 0.008695626) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15678364, 0.36537138, 0.29289278, -0.36264315, 0.21544749, 0.21625403, -0.07440743, -0.12493001, 0.14252685, 0.38809484, 0.11033406, -0.3547475, -0.48151612, 0.10514615, 0.7340949, 0.001196953) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.016726283, 0.11913552, -0.04259825, -0.03521193, -0.009656292, 0.06737877, 0.096626125, -0.029929, 0.073544756, -0.02047585, -0.24392392, -0.004848214, -0.23150206, -0.125599, 0.31828514, 0.10328745) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

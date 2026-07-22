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

  var result: vec4f = vec4f(-0.078030705, -0.034394175, 0.1878114, -0.072348036);
      result += mat4x4<f32>(0.05161853, 0.15874392, -0.23399003, -0.4557964, -0.15263283, 0.11635355, 0.26043633, 0.028784348, 0.106681764, 0.014149704, -0.124294154, -0.15585314, 0.010437585, -0.0323428, -0.122624025, -0.024644636) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.074372225, 0.004372586, 0.07129145, -0.08672092, 0.074129544, -0.099579886, 0.15202506, 0.16378796, -0.07387959, -0.014619337, -0.02009284, -0.10308207, 0.19688925, 0.026689343, -0.11520254, -0.09754923) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.076650426, 0.21682167, 0.007542287, -0.23461981, -0.049814172, -0.114312135, -0.012281848, 0.032373887, -0.0503146, 0.0137207005, -0.066822395, -0.031564035, 0.034177106, -0.019741226, -0.0831365, -0.071037136) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07679854, 0.19743088, -0.008045404, -0.3027368, -0.30255398, 0.24314588, 0.22538412, 0.099871874, 0.015342648, -0.0140507035, -0.07147388, -0.051289372, -0.06705328, -0.021749055, 0.083362214, 0.038364377) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19111577, 0.32600132, -0.15059893, -0.47120398, -0.14738022, -0.79633605, -0.41009435, 0.22293693, 0.4667475, 0.30956444, 0.5388474, 0.61060286, -0.42457134, 0.69549584, 0.56702286, -0.26462817) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.021450743, 0.18948555, 0.031218737, -0.30964622, -0.11060412, 0.07798814, -0.16089411, -0.024163956, -0.023926806, -0.038675573, -0.019491244, 0.13973089, -0.5264051, 0.023654569, -0.40310523, 0.022742793) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0013378868, 0.040858667, -0.006112768, -0.10800605, 0.035677902, 0.035023164, 0.05870226, -0.19316703, 0.08477941, -0.124165446, -0.08142529, -0.037628327, -0.010400976, -0.042574618, -0.06001872, 0.19337721) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.05781411, 0.097699225, -0.004895037, -0.055430774, -0.101391464, 0.101448044, 0.099019215, -0.036139186, -0.1533041, 0.15436313, 0.01090297, -0.06220678, -0.17276295, 0.09592024, -0.07309811, 0.069114104) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.011473799, 0.09135269, 0.00992329, -0.1294115, 0.072710834, -0.06893421, 0.08137338, 0.057913426, 0.009064548, -0.10755174, 0.06767991, 0.019910993, 0.09908333, 0.02664882, 0.07186289, -0.06679881) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.021829424, 0.04574187, -0.006987742, -0.13376045, -0.08145662, 0.07308776, 0.07764329, -0.13133754, -0.086411506, 0.014539166, -0.14146473, -0.2117278, 0.04407819, -0.11580478, -0.05907787, -0.016057499) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0530772, 0.15540397, -0.17653207, 0.063317336, -0.0641545, 0.033641726, 0.09440164, -0.25024107, -0.20457476, 0.11854095, -0.18967974, 0.015307997, -0.14300786, 0.16004996, -0.13497292, -0.07676278) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.004623796, 0.23078543, -0.2017525, -0.24789368, -0.035051536, 0.2446227, 0.17828295, -0.011187191, 0.037739985, -0.05115364, -0.2541137, -0.13367708, 0.07613445, -0.09416703, 0.17170696, 0.21804167) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.110366136, 0.041702285, -0.19413967, -0.08515557, -0.05534719, 0.1455148, 0.15522088, -0.107602246, 0.013814684, -0.12481166, -0.1623854, 0.020928495, 0.1960712, 0.03168532, -0.003903989, -0.13620363) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.445744, -0.30345973, 0.20544672, -0.30296826, -0.15148884, 0.1503549, -0.04422234, 0.33525974, 0.2526107, 0.47191635, -0.081894495, 0.03819463, -0.10005506, 0.92305386, 0.19038428, -0.22501233) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.054816656, -0.070575885, -0.16607414, 0.06479327, 0.17622194, 0.07170287, -0.03673101, -0.20432587, -0.033068344, -0.10293813, -0.2679078, -0.082522646, -0.03618873, -0.078291684, 0.24156097, 0.25976905) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.059578434, 0.10333069, -0.014843533, -0.15034232, 0.014304933, 0.059125386, -0.032426678, -0.2609884, -0.06385446, -0.06254782, -0.09973177, 0.0229025, -0.006554574, -0.00055089913, -0.0033156027, 0.13135752) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.014946541, -0.15009835, 0.0069776243, 0.25219563, 0.5800427, 0.24574299, -0.20419666, -0.13875774, -0.22305447, -0.15487178, -0.2997394, -0.028744172, 0.077195376, -0.023473987, 0.02694993, 0.04038737) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.13579758, 0.17562404, 0.08274604, 0.04482647, -0.030099785, 0.17049141, -0.07482217, -0.33000246, -0.09311881, -0.08349605, -0.04001301, 0.10352532, 0.02735341, 0.08417472, -0.042693514, -0.17821749) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

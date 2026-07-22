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

  var result: vec4f = vec4f(-0.36620557, 0.42653444, 0.33138508, 0.3403729);
      result += mat4x4<f32>(-0.09726819, 0.022751492, 0.19073829, 0.17000869, -0.09212118, -0.19630638, 0.19844669, 0.15481304, 0.23427476, -0.23371577, 0.18105836, 0.084952414, -0.18366179, -0.023898715, -0.08506551, 0.080148734) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21327291, 0.28245795, 0.25580838, -0.011327636, -0.14288077, -0.015392603, 0.22426376, -0.08101239, 0.17903368, -0.2921799, 0.2479096, 0.17444012, -0.36266106, 0.18643591, 0.040786926, -0.12018927) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04086441, -0.20953177, 0.14333661, 0.1340671, 0.5032879, -0.2873042, -0.13049056, -0.13012573, 0.13878164, -0.15216881, 0.09563373, 0.08727121, -0.12982309, 0.13123722, -0.0750334, -0.17629644) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.45373482, 0.16009936, -0.011864943, -0.2661088, 0.2105956, -0.2696156, 0.088150546, -0.31960315, 0.23550269, -0.44362584, 0.2326355, 0.0651252, 0.3239408, -0.31522143, 0.07287399, 0.047315117) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.19552699, 0.107922256, 0.4598891, 0.19761342, 0.3341308, 0.75896984, -0.16426605, -0.57373774, 0.27781576, -0.40235934, 0.2661559, 0.11083838, 0.0285022, -0.06305759, -0.60172427, -0.46679783) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.27984458, -0.09594277, -0.06872812, -0.14175092, 0.5641167, -0.22632572, 0.15850876, 0.0017419468, 0.13993467, -0.32890293, 0.25074822, 0.11648782, 0.093467325, -0.45458555, -0.31677294, -0.2803033) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12193163, -0.15584537, -0.071270436, -0.13923194, 0.39475107, 0.018608121, -0.06321784, 0.011630888, 0.18040133, -0.3595152, 0.3229976, 0.14919122, -0.31315732, 0.047943708, -0.026801333, 0.05887492) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14115342, 0.2824357, -0.024420327, 0.15055013, 0.20800419, 0.07362457, 0.04092382, 0.28770587, 0.18248163, -0.36696056, 0.13264464, -0.043136384, -0.45065293, -0.41102886, 0.17148735, 0.23153605) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03271287, -0.021587374, -0.12875892, -0.1477097, 0.56552154, 0.23733486, -0.25909057, -0.10525219, 0.1819088, -0.22423422, 0.17922243, -0.003391025, -0.08260352, -0.101293035, 0.06383291, -0.08538161) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.36410785, -0.22230557, -0.026919182, -0.19295804, 0.032022737, 0.012378313, 0.1388167, 0.1590836, -0.14982364, 0.2701645, -0.10955984, -0.01514756, 0.015890578, -0.12138848, 0.18538536, 0.13404053) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.03666202, -0.10803358, 0.09146246, -0.13302931, -0.40119955, -0.08591332, 0.2467166, 0.24733832, -0.23426564, 0.34629905, -0.29455784, -0.1507329, -0.13463713, -0.30281088, 0.12652731, 0.10155503) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03278497, -0.17054299, 0.048634365, -0.2539312, -0.04368062, -0.19708315, 0.16267358, 0.13402869, -0.14964965, 0.07557518, -0.091932036, 0.016785627, 0.24130987, -0.13618296, -0.10051843, -0.1741388) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.35181862, -0.27867034, 0.20171171, 0.54696643, -0.09740205, -0.24914095, 0.20227402, 0.13823447, -0.10038629, 0.2895124, -0.22429572, -0.0766226, 0.00085432996, -0.17617191, -0.0872429, -0.07098071) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.31748557, 0.2382818, -0.08361695, -0.48945257, -0.1450886, -0.093670234, -0.05519574, 0.03602011, -0.13867386, 0.46149522, -0.2143921, 0.008564283, -0.13576154, -0.08196341, -0.49709052, -0.4153208) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1390115, -0.1426972, 0.070978895, -0.014696662, 0.019556306, -0.4844153, 0.07337822, 0.17283131, -0.103640996, 0.25580868, -0.25037536, 0.004750251, 0.07994446, -0.18923903, -0.5228303, -0.42819434) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03162072, -0.17426269, 0.17293362, -0.04976128, -0.08510238, -0.13752708, 0.16699155, 0.015790336, -0.119851336, 0.2042878, -0.113742374, 0.05199521, -0.0881652, 0.2505813, -0.13844022, -0.21349423) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.3108407, -0.14227918, 0.06581586, 0.066439345, -0.5074122, -0.35520563, 0.1830074, 0.22154856, -0.21973546, 0.29169726, -0.19123998, 0.032343905, 0.3342035, 0.13017306, -0.043208998, -0.0945332) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.03438173, 0.03100858, -0.00024854124, -0.08144597, -0.32672232, -0.35278767, 0.25142878, 0.21756901, -0.12858592, 0.17158607, -0.083071664, 0.049329244, 0.075240105, 0.30317557, -0.114060186, -0.12087124) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

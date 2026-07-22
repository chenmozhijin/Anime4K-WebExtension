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

  var result: vec4f = vec4f(-0.04093093, 0.01579951, 0.1748477, 0.5445417);
      result += mat4x4<f32>(0.12396114, -0.30517128, 0.20829272, 0.19980542, -0.043769397, 0.053481434, -0.017927324, 0.07802001, -0.016047657, 0.11104438, -0.05062881, 0.08479746, 0.12313308, -0.11151491, -0.043157574, -0.14430618) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06698142, -0.04906408, 0.058049005, -0.059186097, -0.0291005, 0.031282675, 0.19000731, -0.2375625, 0.14007297, 0.18388839, -0.12117204, -0.107781745, 0.08669475, -0.08195485, -0.14361627, -0.22641292) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18015122, -0.04994248, 0.03033823, -0.20294063, -0.016572513, -0.04611645, -0.0006225011, -0.038782727, 0.08964051, 0.15175757, 0.0140522225, -0.00230162, 0.014481414, -0.052476153, 0.06669466, -0.16317971) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.015799759, -0.2960228, 0.15810792, 0.22047798, -0.089098245, 0.122155674, -0.183173, 0.09239164, -0.18608485, -0.040409144, 0.1236581, -0.27113968, 0.014381027, 0.017754363, 0.060999665, -0.08657489) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3064581, 0.06316912, -0.4131803, -0.1786316, 0.55655366, -0.027958967, -0.44045147, -0.51910883, -0.14962004, -0.10943925, -0.1831713, 0.009019485, -0.13844019, -0.04756308, 0.016060077, -0.1322021) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.22140893, 0.1219254, -0.032769438, -0.2062014, 0.21166676, 0.3475899, -0.062110316, -0.07163972, 0.100422285, 0.2451951, -0.24248646, -0.26083705, 0.038447123, -0.1944653, -0.12950698, -0.32723805) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16170506, -0.019411001, -0.0088766245, 0.07852112, -0.06866838, -0.01425131, -0.026300387, -0.08112185, 0.09575024, 0.030039812, 0.026028136, -0.0368385, 0.10186007, -0.048210308, 0.055187322, -0.0709202) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.033033907, 0.24653502, -0.26628074, -0.09459206, -0.026256628, -0.16925971, -0.018872334, -0.110093065, -0.18830912, 0.28200465, -0.10301428, -0.063833155, -0.21709056, -0.022878304, 0.084927335, -0.101297475) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.17019898, 0.27064794, -0.15527993, 0.012533104, -0.073136464, -0.032935925, 0.09228367, 0.022032628, 0.17947827, 0.024573173, -0.076078385, -0.04586876, -0.13705257, 0.0008893596, 0.069791585, 0.015248566) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.12507494, -0.076340154, 0.07939211, 0.23160414, -0.10448402, 0.019407457, -0.06835011, -0.008504082, -0.12594725, 0.156208, -0.10262286, 0.007904176, -0.004173136, -0.10552281, 0.016965916, 0.011734076) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.04997416, -0.0010337265, 0.061805487, 0.14996803, -0.06705507, 0.17866741, -0.15837874, 0.01619578, -0.20050879, 0.323963, -0.13937317, 0.046345666, -0.18691622, -0.23108827, 0.24964981, -0.15476866) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04134804, -0.23960504, 0.18598858, 0.1276533, -0.021271084, 0.06320898, -0.18077037, 6.7010006e-07, -0.055725563, 0.17016679, -0.064069666, 0.0839067, 0.64162505, -0.037768994, -0.1786523, -0.34985578) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.19660237, 0.29974636, -0.2859234, -0.17377125, -0.16453955, 0.023565106, -0.13542059, -0.018840743, -0.083589725, 0.09481662, 0.059363194, 0.108366296, -0.031380914, 0.019868072, -0.042304955, -0.12973799) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5288518, -0.30792084, 0.24606536, 0.45459577, -0.14614192, 0.12502092, -0.09597457, 0.038558874, -0.4587546, 0.27091527, 0.0387687, 0.31299683, 0.12045896, -0.27345943, 0.041976683, -0.6222569) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.005343269, -0.12136639, 0.22662424, -0.06269819, -0.16083927, -0.025174363, -0.07643351, -0.06424283, -0.31243366, 0.29115638, -0.07834647, 0.1908227, 0.13319756, -0.16025652, 0.0752828, -0.4383743) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06779485, 0.31057465, -0.14823094, -0.07433526, -0.04209545, 0.04506944, -0.07748491, 0.04734387, 0.005813717, 0.020544853, -0.016769856, 0.07216769, 0.04967995, 0.046536926, 0.020804323, -0.056936536) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.075951934, 0.07305592, -0.05357169, 0.05269857, -0.23641846, 0.15519682, -0.09230461, 0.11539401, -0.06145733, 0.1146738, -0.121624865, 0.18155192, -0.1683293, -0.009768039, 0.042265136, 0.11764181) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.34026474, 0.018472422, -0.076058805, -0.22086248, -0.11122142, 0.14519285, -0.03398742, 0.023942456, -0.08079581, 0.055888653, -0.14533833, -0.012143168, 0.10443114, 0.049319975, -0.029401762, -0.0168628) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.23175502, 0.25834894, 0.18442634, -0.04304855);
      result += mat4x4<f32>(0.053448822, 0.0762671, 0.024114352, -0.0051196986, -0.011255341, 0.13248898, -0.092593364, 0.060985543, -0.031690843, -0.42065555, 0.27633333, 0.07338092, -0.30101448, 0.34050748, -0.25293466, -0.1090523) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08404584, 0.1334153, 0.2762914, 0.0016127268, 0.1745112, -0.43123677, -0.13037893, 0.39230573, -0.40999857, -0.072390005, 0.3361714, -0.06466838, -0.0046308925, -0.031071248, 0.060789555, -0.04154105) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.025143147, 0.07703781, 0.05379748, -0.0035253994, -0.068272226, -0.11188789, -0.13377443, 0.12627137, -0.12493074, 0.07696727, -0.2729475, -0.094456166, -0.09639367, 0.21453647, -0.11508705, 0.09225143) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10951331, -0.12890974, -0.1334227, 0.30524313, -0.16738604, -0.05978833, -0.2338564, -0.5012075, 0.15181221, -0.17281446, 0.023455137, 0.33913955, -0.72005844, -0.11549482, -0.18626995, -0.23924543) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.17031059, 0.2120885, 0.07476191, -0.09330428, 0.67411166, -0.08169483, -0.0077860304, 0.08075391, -0.30025738, 0.18966706, 0.029246498, 0.065339215, -0.4450576, 0.40531412, 0.17430119, 0.0941784) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.05650611, 0.086035706, -0.05309586, 0.2245376, 0.2833669, 0.1269838, 0.12499875, -0.14618452, -0.08622318, 0.100120164, 0.103668556, -0.14927094, -0.25762266, 0.049900483, -0.3124021, 0.6223609) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.083938755, 0.038861655, -0.021186918, 0.096604496, -0.27403548, -0.40417802, -0.051372454, 0.0012683977, 0.14328282, -0.17576095, -0.04089725, -0.09433311, -0.20453389, 0.008411181, 0.10875809, -0.0043930905) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.061151966, -0.009991866, 0.09883173, -0.057285443, -0.11954043, -0.105631225, -0.13575345, 0.21997814, 0.0047120783, 0.09879958, 0.10250714, 0.081856735, -0.44275302, 0.04540408, -0.10226219, -0.100416) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.040382225, 0.06563761, 0.022381917, -0.0013487374, -0.0035744857, 0.05477262, -0.12307032, -0.09984948, 0.2741746, -0.10946953, -0.2690963, -0.13318962, -0.06894683, 0.12695682, -0.01888561, 0.10655345) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.1888958, 0.060454242, 0.15801315, -0.07863783, 0.031785816, 0.14960079, 0.0052973577, 0.1858181, -0.18075943, 0.21772596, -0.046120346, 0.06504739, -0.01711756, -0.07913983, -0.007344047, 0.082571) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07062377, -0.07406313, 0.22678933, -0.24564123, 0.21872786, 0.0013997183, -0.2888115, 0.1644157, -0.11867628, 0.0074474458, -0.14882609, 0.14001012, -0.0671154, -0.26821104, -0.19597791, -0.08462983) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20346244, -0.16807605, 0.16639614, -0.2929899, 0.082906835, -0.16362171, -0.19607677, 0.15776381, 0.18205804, -0.07316614, -0.035031516, -0.05361277, 0.08362457, -0.12038278, -0.118687876, -0.09831812) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07260389, -0.20923407, 0.06881555, -0.09530061, 0.10033215, -0.18616569, -0.038571376, 0.25525025, -0.05319084, 0.46948972, -0.089480594, -0.025206923, -0.2368438, -0.3543567, -0.21768822, -0.12084693) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42673355, 0.07156627, -0.24549085, -0.43616262, -0.0053849844, 0.21433243, -0.340304, 0.19925317, 0.5447342, -0.41430795, 0.27522987, 0.34616584, -0.5439835, -0.19661896, -0.22000813, 0.19759561) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.2404679, 0.011633009, 0.06249624, -0.15840162, 0.23297182, -0.19221476, -0.005813338, -0.21114112, -0.08039583, 0.095257066, -0.37161705, 0.23867907, 0.11912867, -0.2844021, -0.14170215, -0.34640178) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16777611, 0.1609638, 0.025399977, 0.07248811, -0.1482584, -0.09178009, 0.06027499, -0.38663843, 0.074237674, 0.1255918, -0.14494018, 0.07281105, -0.1304431, 0.01206137, -0.13654718, 0.026282942) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.3540647, -0.19510365, -0.31877092, 0.07256073, 0.2038883, -0.29070652, 0.06895578, 0.56885946, -0.05412735, -0.15556817, -0.07774579, 0.28308132, -0.27907103, -0.044455163, 0.042151596, 0.1396376) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03847822, -0.24989766, -0.023558807, -0.32666728, 0.2535973, 0.14499058, 0.0053442023, -0.42776668, -0.0032256115, 0.08222471, 0.011730933, 0.2151866, -0.17462753, 0.004203489, -0.020367742, 0.077459395) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

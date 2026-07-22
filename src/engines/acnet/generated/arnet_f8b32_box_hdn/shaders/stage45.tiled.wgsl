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

  var result: vec4f = vec4f(0.27865303, 0.0833329, 0.13688266, -0.22101024);
      result += mat4x4<f32>(0.16962199, -0.014316006, 0.17752878, 0.16574119, 0.047723256, -0.1205478, -0.042931415, 0.13246132, 0.11512936, 0.16010113, -0.112360865, 0.016408505, -0.057271004, 0.07973307, -0.026373439, -0.047090992) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.016077066, -0.26240018, -0.026351018, 0.23948725, 0.06674354, 0.13223314, -0.08463255, 0.038977794, -0.12838483, -0.29703078, 0.25111902, -0.016632482, 0.06419978, 0.12128485, -0.14901447, -0.31595084) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09336674, 0.04681407, -0.002318249, 0.037728693, 0.018095545, -0.0209243, 0.08469891, -0.05375388, -0.00899949, -0.124728054, 0.11300208, -0.0066696447, -0.024926191, -0.1726922, -0.13674852, 0.16773468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06668377, 0.200636, -0.04815688, 0.24375367, -0.32794428, -0.21311451, -0.11421846, 0.20846847, 0.4177099, -0.28414312, 0.008424124, 0.4867588, -0.33296165, 0.45265612, -0.10839391, -0.4307043) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2865996, -0.6976484, 0.21359746, 0.29484594, 0.3160755, -0.089063235, -0.11777171, -0.122524, -0.38645494, 0.67278284, 0.016139753, 0.101245224, -0.74489164, -0.14048232, 0.3888579, -0.47142443) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04997515, -0.10952326, -0.116808936, -0.19145499, 0.44500306, -0.15738234, -0.3408291, 0.40948847, 0.44328493, -0.26099938, 0.15747543, -0.27818775, -0.07621798, 0.025064325, 0.035331607, -0.027308507) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.09758845, 0.058007184, 0.014832975, -0.012204737, -0.0042670434, 0.16356318, -0.24801344, 0.21874191, 0.13295156, -0.28595814, -0.21631429, -0.10481439, -0.026352173, -0.099324, 0.016932547, -0.031538177) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11680036, -0.008955643, 0.23640451, 0.031092674, 0.21089563, 0.010350712, -0.060988523, 0.08655034, -0.106204495, 0.35756126, -0.08772896, 0.021083917, 0.15904863, -0.30212379, -0.26532593, -0.07542654) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.046305634, 0.23821688, -0.095502526, 0.35283217, 0.22511263, 0.0029137281, -0.15741718, 0.17502582, 0.41386354, -0.042341366, 0.08677703, -0.15999162, -0.046506986, 0.18321858, 0.037690487, 0.024869137) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.33003128, 0.319036, -0.04758916, -0.12029802, -0.04286261, 0.029673235, 0.063116975, 0.0064827073, -0.22940426, -0.03417799, 0.075972594, 0.078329764, 0.017789772, 0.011350916, -0.0051438073, -0.25913405) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1258854, 0.15117435, -0.47794476, -0.3085625, -0.049195893, 0.30128682, -0.17677219, -0.08355532, 0.049075466, 0.4016059, 0.12794578, -0.01845594, -0.12949811, -0.31260931, -0.1311503, 0.16330646) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.12729679, 0.72097635, 0.124017455, -0.5443435, -0.33303228, 0.05882173, 0.02378122, -0.052470315, 0.10875225, -0.08368612, -0.08002923, 0.014172125, 0.038217723, 0.17297229, 0.13845268, -0.20366187) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18375419, 0.18861851, 0.023079265, 0.4731051, -0.02042448, -0.03182986, -0.03958847, -0.0031518757, 0.0963326, 0.13656144, -0.0011570711, 0.026615134, 0.20758197, 0.07649347, -0.10726056, 0.24041139) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(1.6364665, 0.49917358, -0.7302915, 0.8845434, 0.5275133, -0.43643004, -0.01752295, -0.11865398, 0.31967467, 0.04958369, -0.038905498, 0.009174066, 0.3680314, 0.21144624, 0.19403744, 0.32353508) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.89025044, 0.21493971, 0.3659481, -0.07420738, 0.13781579, 0.017411051, -0.00919713, -0.22997557, 0.07173735, 0.2379213, -0.017083872, 0.005840321, 0.3371394, -0.03045289, -0.044575814, 0.1748148) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.46477875, -0.37145162, 0.18307145, -0.056512043, 0.09797532, -0.031795915, -0.19748685, -0.0076818783, 0.11710392, 0.119106025, 0.14283256, -0.024088243, 0.18916632, -0.04069224, -0.13410206, 0.13339986) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.38620645, 0.38441193, 0.1838923, 0.91999424, 0.12813218, 0.18693537, -0.21937563, -0.008636824, -0.717673, -0.26200077, 0.086489774, -0.046861686, 0.15022255, -0.09531638, -0.006988293, 0.112660915) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1017257, 0.08826067, 0.24366422, 0.1375823, 0.23084174, -0.3770696, -0.16370267, -0.42153597, -0.65494287, 0.010302552, -0.14925143, 0.15384036, -0.20426948, 0.15029764, 0.20104203, 0.30297035) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

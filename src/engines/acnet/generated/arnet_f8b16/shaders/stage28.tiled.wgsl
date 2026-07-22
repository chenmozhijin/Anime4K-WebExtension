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

  var result: vec4f = vec4f(0.06076515, -0.25947496, -0.21886772, 0.16654655);
      result += mat4x4<f32>(-0.05810832, -0.24735421, 0.022646686, 0.0049789376, -0.2172603, -0.20901972, -0.5220378, 0.14706449, 0.16642408, 0.304481, 0.031637784, -0.19892544, 0.03562843, 0.10331699, 0.3064828, 0.16571829) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16232209, -0.27778974, -0.024780294, 0.21335928, 0.45408827, -0.015124703, -0.14087428, 0.0030776327, 0.26743144, 0.43323946, 0.03857514, -0.29240242, -0.022638446, 0.15449019, 0.5229458, -0.13705117) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.22418055, -0.19183558, -0.007845732, 0.1214645, 0.048867375, 0.12277653, 0.21455777, -0.11090712, 0.14976437, 0.30865908, 0.0611621, -0.19548188, 0.093224496, -0.045257017, 0.17694534, -0.08821952) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17215039, -0.32065248, -0.10991686, 0.26776582, 0.026133047, 0.51464504, -0.053339265, -0.095391944, 0.25819197, 0.50295967, 0.07563551, -0.3516442, -0.027581839, -0.34888467, 0.4773479, -0.13232653) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.4260748, -0.42125738, -0.14460556, 0.3060615, -0.22348857, -0.54369307, -0.18267353, -0.2051199, 0.42990252, 0.58290946, 0.24222875, -0.61205655, -0.37516734, 0.05742789, -0.27659163, 0.38222903) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13164295, -0.3489107, -0.07909316, 0.28081784, 0.102399096, 0.1253847, -0.13878207, -0.25325185, 0.19382098, 0.30075344, 0.20833619, -0.39062345, -0.0800175, -0.1347395, 0.2580247, -0.07116404) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.115046166, -0.2044713, 0.021201199, 0.12815441, 0.2225292, -0.1746402, 0.021800002, 0.088526316, 0.13764693, 0.33910263, 0.13963795, -0.25362596, -0.12826467, 0.1985493, -0.011349422, -0.039230596) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15423155, -0.2515474, -0.14400579, 0.24879609, 0.2843972, 0.019739801, -0.011604685, -0.4123878, 0.18314461, 0.2365981, 0.27309012, -0.44319168, -0.17517233, 0.5136574, 0.040355947, -0.15036514) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.022302242, -0.16063605, -0.05321395, 0.09023439, -0.24744482, -0.28796673, -0.17839693, 0.63017476, 0.096904494, 0.07365961, 0.1675425, -0.2807579, -0.07695193, -0.028921943, 0.28845903, -0.18788064) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.01815009, 0.21044622, 0.16697022, -0.15516426, 0.09316345, 0.3167181, 0.034744304, -0.10233795, -0.13842253, -0.019419044, -0.11961777, 0.1373798, -0.0051503424, -0.12000268, 0.0897919, 0.072129324) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11535699, -0.08290558, -0.16884512, -0.25472972, 0.12795073, 0.38973364, 0.072522715, -0.18136011, -0.13362929, -0.10104926, -0.21354102, 0.10231145, -0.023991114, -0.3483562, -0.039689258, 0.093632005) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.102653325, 0.1492565, 0.036975365, -0.16285232, 0.11000566, 0.33000925, 0.048430875, -0.123098895, -0.081244, 0.4085913, -0.08547623, 0.12652037, 0.1398943, -0.19429548, 0.13838896, 0.090169705) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.25329885, 0.08050168, 0.09144433, 0.29846564, 0.10531269, 0.32586282, 0.17445515, -0.2343248, -0.2522352, 0.29760823, -0.14697559, 0.09328056, 0.06834249, -0.3224104, 0.040951863, 0.10687826) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.008805487, 0.03003337, -0.18615812, 0.036187414, 0.2087752, 0.45023677, 0.19304909, -0.3436717, -0.50915587, 0.14144616, -0.17637435, 0.09099505, 0.016194949, 0.11930635, -0.35691553, 0.4287327) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1553428, -0.06606465, -0.0075653633, -0.10240166, 0.18646023, 0.3678098, 0.17660296, -0.3096199, -0.055402387, 0.44493973, 0.265966, -0.21543321, 0.3796004, -0.11336051, -0.11223697, 0.38053674) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.025836896, -0.438149, -0.13459201, -0.15639584, 0.0781307, 0.21304661, 0.07556359, -0.16226245, -0.11096672, 0.35579807, -0.025630843, 0.08448138, -0.00043669433, -0.28059074, -0.15006675, 0.09553681) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21100467, -0.12722275, 0.052781306, -0.26344866, 0.06476564, 0.29961154, 0.20273593, -0.23447172, -0.061259896, 0.77849424, 0.02020237, -0.20670436, -0.010946562, -0.16177708, -0.27660757, 0.2734578) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1401564, -0.10961615, 0.07598317, -0.038053762, 0.10709809, 0.16769847, 0.13237432, -0.18139511, -0.031157799, 0.5491714, 0.09783968, 0.08587542, 0.13051878, 0.07512955, -0.20544855, 0.2358533) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.053223822, 0.014272482, 0.026381368, -0.35213876);
      result += mat4x4<f32>(0.09741842, 0.016755901, 0.26487085, -0.10458785, -0.01916864, 0.043483496, -0.08826235, -0.40361395, -0.106019795, -0.023844087, -0.47170657, -0.2984017, 0.048182037, -0.1166751, -0.04408459, -0.034541346) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1472424, -0.14399038, 0.0974942, 0.11320012, 0.3454887, -0.33100933, -0.26972252, 0.30487818, 0.23223193, -0.06896616, -0.11513754, 0.046855208, -0.3958476, -0.12980862, -0.31105885, -0.6602177) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10300532, 0.11014956, 0.059629235, -0.044005424, 0.19742705, 0.10036861, 0.13845849, 0.014287752, 0.15529671, -0.0073610083, -0.06413194, 0.10636417, -0.10509789, 0.041635886, 0.07334532, 0.09921515) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.01071504, -0.049725644, -0.23896894, -0.071014896, -0.021901874, -0.04365429, 0.14659832, -0.36910793, 0.21268576, -0.23293762, -0.12672949, -0.015461106, 0.15056239, 0.17246386, 0.19659959, -0.31639412) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.227697, 0.1932718, 0.014184444, -0.11491848, -0.060272805, -0.15837133, 0.12351112, -0.09413002, 0.017202286, -0.096059956, 0.21282493, -0.1569331, 0.47546875, 0.29141042, -0.056203, 0.085078984) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09695977, -0.045578077, -0.0853044, 0.108673245, -0.2947874, -0.23010924, -0.2515842, 0.05633444, -0.20101322, -0.12876382, -0.6099054, -0.15354468, -0.20421869, -0.17127715, 0.12583007, 0.14569938) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12218899, 0.05331922, -0.06120145, 0.12369669, 0.04662407, 0.03077288, 0.05072309, -0.0230835, 0.0519249, -0.04786041, -0.19723473, -0.026100459, -0.018744113, 0.004905521, 0.1084056, 0.091096096) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.39261475, -0.33973473, 0.22212085, 0.7564439, -0.057141762, 0.045045543, 0.029075345, -0.07341259, 0.15540002, -0.12722233, -0.40487406, 0.10145907, -0.10345408, -0.1929395, -0.072463974, -0.01874535) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16767605, 0.12542039, -0.027012214, -0.00025407382, -0.04141431, -0.050576303, -0.14623074, -0.04608626, 0.020284355, 0.07361259, 0.016102253, 0.05578836, 0.07643071, -0.102723606, -0.49206233, -0.24162373) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.30327612, -0.14695357, 0.051752504, 0.32591495, -0.122868925, 0.046725027, 0.186743, -0.10323502, -0.0103340335, -0.1644523, -0.20618047, -0.0520611, -0.0022251974, 0.082651615, 0.0032149025, -0.156294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.30543518, 0.20458403, 0.29245207, -0.32012755, -0.19536093, 0.1907055, 0.00071240246, -0.18095264, 0.030206645, -0.17892964, -0.09621669, -0.032375313, 0.26470855, -0.17932858, 0.32456237, 0.074177004) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.047950376, -0.0052526635, 0.19386178, 0.24330597, 0.189665, -0.0075981724, -0.012380838, -0.15791865, -0.015339157, 0.089566424, 0.10941955, -0.090664946, 0.041753378, 0.08917368, 0.1451315, 0.015715955) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.2885547, -0.029766336, 0.22588538, 0.50297844, -0.20245275, 0.06530336, 0.06749152, 0.07316952, 0.050815314, 0.18887976, -0.16671634, -0.27507752, 0.060694847, -0.30286545, -0.1792964, 0.2641942) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.083290346, -0.40370253, -0.383093, 0.011397381, -0.26862943, -0.15267497, 0.15960048, -0.29935312, 0.34647667, -0.049635746, 0.08950819, 0.55547225, -0.044280633, 0.40060464, 0.24975106, -0.5567828) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.20585981, -0.058294654, 0.08780579, 0.20398562, -0.085551165, 0.16889946, 0.111333214, -0.20007029, -0.056908805, 0.2529745, 0.04544538, 0.34245014, -0.15905164, 0.04670033, 0.012793743, 0.1393811) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.026212938, -0.11823774, -0.15933834, 0.10656061, -0.0058999904, -0.0053028516, 0.16849123, 0.21500793, -0.076743014, -0.05890717, -0.19795737, 0.067143336, -0.10490767, 0.035155434, 0.12277807, 0.24075793) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.20980416, -0.08806194, -0.004185157, 0.14902186, -0.09315284, 0.02447535, 0.5019751, 0.06425115, -0.31002373, 0.24604975, 0.045768667, 0.0014831317, -0.24019949, 0.058530834, -0.097549036, -0.03689709) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.023913978, 0.016316105, 0.2598185, 0.165822, -0.14188875, -0.23903997, 0.027183492, -0.012149884, -0.40382233, -0.036066685, -0.3951467, 0.028139984, 0.033680093, 0.0544058, 0.037206955, 0.1146414) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

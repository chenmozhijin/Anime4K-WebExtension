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

  var result: vec4f = vec4f(0.16877033, -0.04473916, 0.1765948, 0.048468422);
      result += mat4x4<f32>(0.23155345, -0.48597515, 0.15509741, -0.055333637, 0.040779836, -0.14979365, 0.06786673, -0.10919582, -0.070075125, -0.060373966, -0.0030527187, -0.08496612, 0.06470147, 0.07933741, -0.102295004, 0.029198024) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.029385943, -0.37682053, -0.18179785, 0.09212147, 0.09346087, 0.18569736, -0.11192563, -0.2250188, 0.069640435, 0.21100542, -0.2099586, -0.13476378, -0.0078546675, 0.005141662, 0.011654286, 0.06737796) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.32511055, -0.57147044, 0.17103226, -0.019019684, -0.0058375006, -0.13717663, 0.045206435, 0.10867527, -0.08277229, -0.058731984, 0.16628112, 0.059186608, 0.04037104, 0.25376824, -0.06834564, -0.08733503) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.31752324, 0.117224395, -0.356008, 0.14950278, 0.053663347, 0.008278983, 0.012362966, -0.15568216, 0.1794212, 0.14373156, -0.0060620448, -0.25788835, -0.040070612, 0.0520728, -0.06836701, 0.015722733) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3265365, 0.06606778, -0.3791751, 0.060489178, -0.0656296, -0.46810558, 0.70170367, 0.38057426, -0.031041674, -0.37392375, 0.32199886, 0.38593557, -0.011791088, -0.5088063, 0.12850554, 0.3108426) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30696636, 0.34505296, 0.26696533, 0.0975114, 0.033668518, -0.09294774, -0.14317124, -0.09990915, 0.023130389, -0.13070002, 0.16467957, 0.08507247, -0.14815108, -0.08436084, -0.068021, -0.21183215) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14372782, 0.22104158, -0.044322185, -0.02178612, 0.0632712, -0.18435104, -0.028273562, 0.10705416, -0.124997996, -0.14097726, 0.042553317, 0.27824306, -0.027298102, 0.019737586, -0.09549555, 0.06847043) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13542926, 0.3860366, 0.09640919, -0.15643749, -0.011048947, -0.0667056, -0.17113622, -0.06289993, -0.22074501, 0.04100196, -0.26826903, 0.11011436, -0.20683566, 0.066711575, -0.059282824, 0.21375495) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.010298377, 0.40080148, 0.20335194, -0.1317286, 0.04125747, -0.19089721, -0.03145209, -0.09634511, -0.10261978, -0.03205439, -0.112848654, 0.097499, -0.07174294, -0.3015839, 0.10224426, 0.2086099) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.21534316, 0.08076395, -0.28039393, 0.16079958, 0.07426822, -0.052329786, 0.02677088, -0.014887745, 0.036779303, -0.03500169, -0.05947203, -0.017712213, 0.36933133, -0.043005336, 0.23342381, -0.015920402) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.01913166, -0.18269782, 0.5466999, -0.92358404, 0.006848082, -0.15040372, 0.18382989, -0.067486174, -0.014396663, 0.3123522, -0.12814648, 0.20270191, 0.33464634, 0.17712387, 0.33741286, -0.061090384) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1103325, 0.15346916, -0.21542816, 0.32631093, 0.012876221, -0.0959431, -0.029606782, 0.11536804, -0.114591405, -0.045892708, 0.12954709, 0.03374732, 0.12635164, 0.40909857, 0.26495942, -0.12724179) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.093203716, 0.13981752, -0.033074226, -0.05718163, -0.034294408, -0.058300808, -0.019371146, -0.071611345, -0.06167923, -0.077252306, -0.045612995, -0.008120653, -0.005899214, -0.34508494, 0.27995238, -0.0820403) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.22000338, 0.18670951, -0.19968422, 0.16922875, 0.17502767, 0.14105092, 0.5941677, 0.10058376, -0.12633453, -0.0347397, -0.42103568, 0.4444347, 0.097298875, 0.55895734, 0.12325372, -0.00036712538) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.046783578, -0.063667916, 0.10110791, 0.026340308, -0.17774643, 0.042384062, 0.26605293, 0.10055803, -0.014222626, 0.06879248, -0.024365246, 0.022499168, -0.03185688, 0.10545023, 0.07728396, -0.011987353) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10336336, 0.05677949, 0.31582513, -0.2857868, 0.0017576474, 0.04044584, 0.10283793, -0.05789857, -0.03755338, 0.0143300155, -0.013418962, -0.008777349, -0.21791215, -0.35991406, -0.4984298, 0.13861682) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.08901151, -0.2530508, -0.5117302, 0.6820616, -0.014939909, -0.0521746, 0.055223357, 0.046869032, -0.014478825, -0.03421874, -0.07334786, 0.056703605, -0.21447888, -0.23054574, -0.2360511, 0.06814857) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.06509085, 0.30936754, 0.09499576, -0.3299626, 0.05430113, -0.067348056, 0.12385079, 0.0011269395, -0.0942979, 0.07993596, -0.16506308, 0.013144627, -0.388425, -0.08478281, -0.48158935, 0.08054496) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.22609977, 0.25790006, -0.2231659, -0.18311103);
      result += mat4x4<f32>(0.020654943, 0.013984317, -0.12703837, 0.032152724, -0.037636098, 0.14526464, 0.17126088, 0.046477646, 0.040792484, 0.13117146, -0.00905952, 0.28935176, -0.07529393, -0.19748741, -0.10533913, 0.041438222) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(1.8146651e-05, -0.080594376, -0.02990087, -0.050532784, -0.19141856, 0.25589827, 0.16734909, 0.12677652, 0.11177337, 0.09337354, -0.00394534, 0.14965717, 0.0068689515, -0.11691695, -0.18587747, 0.21926413) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03563977, 0.08255407, 0.041659404, -0.08604645, 0.015523051, 0.025530022, -0.08420497, 0.0155919455, -0.04236037, -0.16221078, -0.09163883, 0.09526362, -0.07476149, -0.09284328, -0.11692711, 0.089731134) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.24763304, 0.15678251, 0.091303244, 0.12326752, -0.11045934, 0.033298355, 0.04842482, -0.05495425, 0.2345763, 0.014795138, -0.15642448, 0.12737493, 0.10808248, -0.09045356, -0.07075676, -0.011105041) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.042275716, -0.24963146, 0.12749559, 0.108931676, -0.6585742, -1.400636, 0.30642608, -0.83480316, -0.16273354, -0.060780887, -0.09335705, 0.1582886, -0.8493674, 0.45498914, 0.09903512, -0.2672985) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2669981, -0.19913737, -0.029740762, 0.30008653, -0.05252429, 0.23173772, -0.16001727, 0.39444476, -0.04801475, 0.31076482, 0.11509548, 0.1697375, -0.016120793, -0.11618606, -0.0903207, -0.2894734) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.09765385, 0.066665724, 0.044992365, 0.14191388, 0.005436299, 0.06999372, -0.033533905, 0.17455602, 0.030458843, 0.14116332, 0.014586136, -0.06039913, -0.05999825, -0.13109376, -0.09430511, -0.010829175) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0075417273, -0.16134803, 0.2135654, 0.2513946, 0.10670141, 0.030442854, 0.10924368, -0.00781538, -0.44623792, 0.0060521164, 0.07546435, 0.4583626, 0.16384739, 0.0076481635, -0.24905652, 0.07451599) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0126771955, 0.06413503, 0.11202334, 0.2608163, -0.10809967, 0.0482061, -0.058071524, 0.06716596, -0.13683422, 0.10387055, -0.22167976, 0.02276579, 0.040179223, -0.09800654, -0.042952333, 0.01405453) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06263944, -0.08894519, -0.07086424, -0.06587192, 0.06571544, 0.14418672, 0.30696997, -0.03240106, 0.2070305, 0.0833714, -0.05920756, -0.15835524, 0.0919546, 0.11360541, -0.3369516, 0.07484129) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.25733605, -0.020265471, 0.285139, -0.1795741, 0.026228182, -0.26903453, -0.0375943, 0.13305153, 0.15471411, -0.08280901, 0.007920004, -0.12955041, 0.29782125, 0.34521097, 0.31408474, -0.0065321964) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.005573674, 0.1501465, -0.039439857, -0.06647974, 0.19772929, -0.10455706, 0.22193442, -0.2531531, 0.111388884, -0.03670274, -0.048509456, 0.051085085, -0.15144183, 0.30979705, 0.09989145, 0.061304707) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.042273566, -0.17650491, -0.0009329857, -0.37718412, -0.19724295, -0.07405878, 0.3997551, 0.08688371, 0.114753865, -0.2356895, 0.08031136, -0.1450158, 0.26099738, 0.16559954, -0.20612651, 0.1480247) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.37447107, -0.20759988, 0.043712985, 0.014575429, 0.20801024, -0.3517118, -0.0050010025, 0.4944309, 0.5205815, -0.027658012, 0.2343607, -0.35697967, 0.8684979, 0.35851815, 0.27419677, 0.41397905) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11038487, 0.08879388, -0.14980336, 0.0002153102, -0.11445531, -0.027107002, 0.34811088, -0.1891923, 0.24209931, -0.23859255, 0.14314422, -0.3742118, 0.24076447, 0.4757546, 0.8208432, 0.58801126) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10859345, 0.038859442, -0.21863729, -0.00945562, -0.0133912675, 0.0895809, 0.058528103, 0.14928488, 0.044537645, -0.13283439, -0.07870536, 0.04045893, -0.09201156, 0.015827136, -0.007660008, -0.102839455) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.45064706, 0.62318426, -0.109637216, -0.016634554, -0.16827871, -0.29239833, 0.013696455, 0.09894058, 0.16271137, 0.055456243, -0.10571294, 0.24972261, -0.15029858, -0.034700103, 0.18021198, -0.16682078) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10380728, 0.07615672, 0.055501375, -0.13988164, -0.24124886, -0.25363693, 0.026668038, 0.061620593, 0.011927044, -0.25092265, 0.047063284, -0.11229703, -0.26359165, 0.36698556, 0.17030996, -0.0157345) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

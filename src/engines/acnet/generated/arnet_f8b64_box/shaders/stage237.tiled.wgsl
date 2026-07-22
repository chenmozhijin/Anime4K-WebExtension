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

  var result: vec4f = vec4f(-0.18559182, -0.053948633, -0.100497946, -0.108861044);
      result += mat4x4<f32>(-0.005394683, -0.1247409, 0.04713269, 0.045912296, -0.050768442, 0.09058774, 0.033858057, -0.07277673, 0.006702956, -0.016565327, 0.09884745, -0.06217255, 0.06948809, 0.09278262, -0.04469538, -0.0081497505) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.05992873, -0.3419738, 0.007404462, 0.11439899, -0.18564425, 0.1818622, 0.13214448, -0.07492937, -0.13350467, 0.10477969, 0.14915022, -0.057363458, 0.24905522, 0.23227145, -0.03527082, 0.11205704) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.026500214, 0.08893927, 0.029462382, -0.030931713, 0.04414044, -0.09295689, 0.025601674, 0.11270281, 0.029479826, 0.005589801, -0.032730233, -0.0044286703, -0.063557655, 0.079919256, 0.10467395, -0.017225252) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.21237645, -0.1773134, -0.19268897, 0.055746075, 0.17548, 0.14436619, -0.003715699, -0.014806925, -0.5467512, -0.4265058, 0.009118026, 0.4528752, -0.049235463, 0.0121597415, -0.0043644053, 0.09483816) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.35408634, -0.51353896, 0.05500213, 0.24696945, 0.031983577, 0.511027, 0.12507102, 0.030603882, -0.38089463, -0.028129334, 0.075428784, -0.031118294, 0.119618, 0.38424036, 0.35246706, -0.2630337) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.035625186, 0.04463158, -0.054361552, -0.12844777, 0.003178491, 0.11498041, -0.12533519, -0.03666423, 0.019433903, 0.1356122, -0.023664258, -0.19906402, 0.2357403, 0.06364396, -0.22213963, 0.06838733) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07498131, -0.1899699, -0.09358156, 0.09681038, 0.0117498385, -0.055217125, 0.03502723, 0.020466637, -0.12878732, 0.009988382, -0.03088089, -0.12819405, 0.008059624, -0.019215254, 0.017872447, -0.030361077) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.111379996, -0.3021961, -0.056430466, 0.11218022, 0.007956201, -0.051062427, 0.042404745, 0.11957336, -0.042716213, 0.09210016, -0.0066805165, -0.012664851, -0.033666264, 0.10742596, -0.02988982, 0.055868834) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.081938185, 0.07382155, -0.06677883, -0.061284196, -0.017590027, -0.09179432, 0.004581097, 0.01150545, -0.035505258, 0.029895408, -0.0440844, -0.038999595, 0.035951447, 0.038166266, 0.07171908, -0.008588129) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.12897788, 0.010284501, 0.05620413, 0.071409635, 0.008703029, -0.086914055, -0.012942011, 0.05646067, -0.028180053, -0.00067882915, -0.012948476, -0.04881915, -0.060431108, -0.051834412, -0.016221158, 0.028811492) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16839893, 0.00816625, 0.09617167, 0.095534265, 0.02126781, 0.23006058, 0.0155446045, -0.039805133, -0.05441044, 0.015757766, 0.0073634605, 0.03973951, -0.03563569, -0.11950775, -0.013418379, 0.12390072) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.01087887, -0.11118529, 0.07557298, 0.037609387, -0.046714216, -0.12716189, 0.07654102, 0.06496942, 0.016065912, 0.08477283, 0.0012568232, -0.09637179, -0.08620009, 0.017045707, -0.06188865, -0.035374325) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.18486603, -0.40606257, -0.16304882, 0.4195697, 0.044423386, 0.14896649, -0.09196101, -0.11058106, -0.22136225, -0.1712477, -0.19043665, 0.19287445, -0.0868138, 0.11094714, -0.017548788, -0.0814773) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.08759607, 0.20407782, -0.11909376, -0.098359, 0.027916593, 0.39917085, 0.5246947, 0.3071978, 0.3478398, 0.2555094, -0.30676183, 0.23522633, 0.06973382, -0.017499711, -0.47107866, -0.31274664) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.027224422, -0.14517215, 0.44084346, -0.24576952, -0.050483316, 0.15100783, -0.039581127, -0.008965475, 0.08319186, -0.055329736, -0.27879637, 0.30318603, 0.0038575602, -0.042812537, 0.07537075, 0.06392473) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.030850116, 0.12627643, 0.0004901251, -0.07073229, -0.06897626, -0.06156054, -0.011698289, 0.017303895, -0.123784006, -0.1275471, -0.100862764, 0.066936225, 0.0293805, 0.12622887, -0.055978097, -0.08026021) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.018622782, 0.09069177, -0.15926002, -0.051781185, 0.09551415, 0.047055393, 0.13180123, -0.0071427436, -0.0867891, 0.184458, -0.025035065, -0.18758358, 0.0075395075, -0.2252726, 0.034044318, 0.0935124) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.06663311, 0.019756462, -0.090628125, 0.018429976, 0.031445067, -0.043949638, 0.00448125, 0.0651663, -0.036228124, -0.1075797, 0.1025758, -0.05270375, -0.035712365, 0.027535412, -0.005027584, -0.047680147) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

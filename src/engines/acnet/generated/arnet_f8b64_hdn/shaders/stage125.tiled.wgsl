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

  var result: vec4f = vec4f(0.32735303, 0.1565312, 0.26256144, 0.4238728);
      result += mat4x4<f32>(0.060893357, -0.07379533, 0.06806135, -0.07205821, -0.028519504, 0.36589324, -0.15527411, -0.20534353, 0.10628816, 0.049058106, 0.074674085, 0.10978798, 0.08967439, 0.015746204, 0.080639645, -0.06814231) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.010092216, -0.17157845, -0.17817639, 0.14679615, 0.15154052, 0.16207878, -0.35406816, 0.26374254, -0.17041126, -0.080253035, -0.1699692, -0.13928582, -0.079322584, 0.06081644, 0.3074368, -0.45679227) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.055113375, 0.00011179767, -0.11876095, 0.23696782, 0.09788845, -0.018279139, 0.0635827, 0.038964897, -0.06783467, 0.015718458, 0.16560194, -0.30115747, 0.14719996, -0.17199014, 0.084228165, 0.13566281) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04394234, -0.057166554, 0.15536577, -0.11978438, -0.011282388, 0.34520304, 0.08948408, -0.15819505, -0.3441371, 0.036025424, 0.202001, -0.39859587, 0.15109545, -0.20373908, -0.36389112, 0.21025538) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.25558066, 0.13538568, 0.20344304, 0.030541264, -0.09678524, 0.33244386, -0.21601854, -0.11380322, -0.15004915, -0.047730282, 0.095238045, -0.4201484, -0.108023755, -0.31520575, -0.3129196, 0.2850783) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04839342, -0.38620687, 0.36126122, 0.055958595, 0.005659244, 0.08300118, 0.21571892, -0.3153721, -0.1882211, -0.10029111, 0.0125558255, -0.21359722, -0.08463527, -0.124343656, 0.16007814, -0.27987006) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11113415, -0.29700112, -0.17840432, 0.063730404, 0.08961263, 0.021609975, 0.0982885, -0.022673776, -0.22488143, -0.20272623, -0.038239118, -0.3043116, 0.1371378, -0.015237682, 0.032526586, 0.06761943) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19921504, -0.35618603, -0.3082115, 0.3818793, -0.051717874, -0.18215287, -0.17013338, -0.04016478, -0.112024404, -0.14410432, -0.014406601, -0.2383026, -0.1472469, -0.49035978, -0.1743504, 0.15194552) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.065529145, -0.03242375, -0.080239534, -0.06263336, 0.11374046, -0.079300895, -0.04753097, 0.04798439, -0.17350957, 0.25247315, -0.3000028, -0.0007042934, 0.05585337, -0.3763258, 0.20524359, -0.10098065) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16101088, -0.08100538, 0.18966414, -0.3471364, 0.19475333, 0.22258973, -0.30074632, -0.12719439, 0.094590336, -0.15241759, 0.14137821, 0.2140376, 0.02119967, 0.111644454, -0.13636813, 0.14512439) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.12091301, -0.20740068, 0.522054, -0.38328943, -0.40525892, -0.008063142, -0.494971, -0.003844662, -0.17548203, -0.009142958, 0.09413492, -0.19146733, -0.066296004, -0.020080363, 0.03919308, -0.057844657) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17777668, -0.13082676, -0.024945451, -0.1808116, 0.013972624, -0.13094187, 0.064005025, 0.26333326, -0.1585828, 0.04348277, -0.04994293, -0.01764458, -0.18380108, -0.1906433, 0.21027057, -0.2487223) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07696759, -0.0730457, -0.12352151, -0.2160784, -0.21190506, 0.43552408, 0.18842237, -0.17096442, 0.10053466, -0.26034352, -0.103043586, 0.21426952, -0.18015215, -0.04420739, 0.2784486, -0.29006118) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.27289218, -0.10591939, 0.22329897, -0.46896288, 0.024438921, -0.43547836, 0.00938366, 0.16413614, 0.20228772, -0.003877741, 0.23795037, -0.6243061, -0.02684239, 0.019201482, -0.21603772, 0.30531016) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.22255164, -0.2557001, 0.057614002, -0.20930952, 0.05021338, 0.28962004, 0.049727377, 0.07329233, -0.09846944, 0.08968631, -0.43747672, 0.029789165, -0.048490822, -0.40195048, -0.11219334, -0.22209293) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03585883, -0.08361166, -0.050854195, 0.0063055283, 0.16475284, 0.19253808, 0.20028037, 0.10846293, -0.029662782, 0.05122237, -0.14142619, 0.046116482, 0.002125044, -0.49653715, -0.057351615, 0.122689106) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10797043, -0.117423564, 0.07290742, -0.18950197, 0.08757859, 0.37478197, 0.20937622, -0.060776178, 0.14148882, 0.7441773, 0.41013575, -0.33264336, 0.13578725, 0.18028429, -0.036176685, -0.051664382) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10642, -0.1507295, 0.14804217, -0.09893411, -0.17906064, 0.24421816, -0.076590866, -0.431976, -0.08029724, 0.44324195, 0.123232625, -0.018807275, -0.044468503, 0.2931017, 0.1806444, -0.29996884) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

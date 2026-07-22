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

  var result: vec4f = vec4f(0.0680177, 0.1642811, 0.11171897, 0.070761144);
      result += mat4x4<f32>(0.10185899, -0.11241492, 0.25173622, 0.20992555, 0.06216118, -0.11538033, 0.06305397, -0.03685599, -0.2265154, -0.08772833, -0.041941866, -0.15934543, -0.16058105, -0.21700542, -0.053688157, -0.13247044) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08822423, -0.25202537, -0.3527654, -0.14993499, 0.09822428, -0.27337614, 0.21434572, 0.12574223, 0.036864243, 0.041947737, 0.020325843, -0.026724536, 0.22314222, -0.09076124, 0.30546588, -0.03571578) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09759013, -0.09834152, -0.11243679, 0.1547426, -0.11408912, 0.047060102, -0.19964898, -0.052811325, -0.09698366, 0.2616161, -0.03719095, 0.17431036, -0.028473513, 0.13608643, 0.082207344, 0.02627816) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.084353745, -0.4186617, -0.36867112, 0.34109712, -0.00040031874, -0.1618987, -0.0799516, -0.04553285, 0.051155202, -0.07457889, -0.0037623784, -0.11844307, -0.13299027, -0.28782514, 0.20813242, -0.2581531) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.070738144, -0.5734984, -0.015641458, -0.4962109, -0.0037551734, -0.010623735, 0.30376172, 0.10200208, 0.15280844, 0.75810504, -0.09233135, -0.18875694, -0.06856865, -0.38699743, -0.18061857, -0.21049452) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09794309, 0.03078101, 0.10789984, 0.12844464, -0.05315319, 0.058699884, -0.13347696, 0.0047494667, 0.2371664, 0.35082123, -0.07015921, 0.17196773, -0.18478478, -0.19993752, -0.33218634, 0.024906704) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.124233015, -0.1273988, -0.06322336, 0.041033216, 0.10367996, -0.054686308, -0.016860597, 0.06794865, -0.1674964, -0.5818689, -0.2519695, -0.08591659, -0.03519496, -0.28432477, 0.03132112, -0.13194983) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.014733334, 0.08166387, 0.034703784, 0.009942175, -0.18677102, -0.31553257, -0.1528136, -0.09853555, 0.060223624, -0.18648262, 0.112174205, -0.114554755, -0.036658242, -0.32687157, -0.11857339, 0.054200787) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.035880208, 0.028864339, -0.11350982, -0.0138244815, -0.046674866, -0.03991198, -0.103781186, -0.04954559, 0.19667703, 0.15921977, 0.022800963, 0.012147998, -0.101324394, -0.17891477, 0.004293039, -0.07955453) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.006242348, 0.09228115, 0.074082576, 0.051530182, -0.24933179, -0.17674726, -0.019833898, -0.14073229, 0.027428199, -0.18137188, 0.03273633, -0.108815536, 0.055592034, 0.061393898, 0.021039935, -0.12716699) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.02675584, 0.31265166, -0.056290638, -0.025029516, 0.12706178, -0.13348281, -0.1865901, 0.15528354, -0.06382888, 0.18317614, -0.18782905, 0.42578173, 0.13811387, -0.005096906, 0.053274155, 0.12054059) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.014369414, -0.034205504, -0.00343221, -0.0066166236, 0.12273092, -0.18178001, -0.13309737, 0.118332595, -0.15797871, -0.05138927, 0.21294236, -0.31064534, -0.017496813, 0.114243336, -0.006049461, -0.10194324) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.08870202, -0.39260152, -0.02468091, -0.23869841, 0.16334654, 0.20591475, -0.13324696, -0.1824919, -0.09480757, -0.1362982, -0.0517036, 0.0085884, 0.14635584, -0.009684993, -0.065721996, 0.0967738) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.1658374, 0.25477034, -0.16786277, -0.12895793, -0.026207538, 0.45263323, -0.4780153, -0.18175615, -0.14477037, 0.08102482, 0.00057269336, 0.8625226, 0.21696174, 0.13822177, -0.38470858, 0.0052391994) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.042791255, 0.03114197, 0.038166426, -0.054997206, -0.08840222, 0.0453011, 0.15769556, -0.2146965, -0.2379505, -0.16872118, -0.092868686, -0.112847894, -0.0074229934, 0.06483279, -0.021905413, 0.041758146) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.006704718, -0.0032931683, -0.09200963, -0.018790636, 0.004993802, -0.79002637, -0.13723828, -0.11489249, -0.10612705, -0.12747498, -0.05011019, -0.0095354635, 0.13960555, 0.28169772, 0.097982325, -0.2600998) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.18626074, 0.19394556, 0.07018548, -0.1145055, 0.32734388, -0.11581675, -0.007987953, 0.32136807, -0.12280938, 0.31814355, 0.054602914, 0.06453015, 0.115654804, 0.22494978, -0.049732827, 0.21111263) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09051476, 0.02887672, 0.014432189, -0.038424917, -0.08171207, 0.24697907, -0.09772441, 0.19193478, -0.19315925, -0.17445841, -0.12640455, -0.32780755, 0.10126778, 0.15919225, -0.055056233, 0.017705703) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

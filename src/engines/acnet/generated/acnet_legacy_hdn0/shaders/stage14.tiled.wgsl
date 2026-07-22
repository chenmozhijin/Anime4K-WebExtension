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
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;

@group(0) @binding(2) var out_tex: texture_storage_2d<rgba16float, write>;

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
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-3.324558e-39, -0.014535975, -0.06336237, 8.5347e-41);
      result += mat4x4<f32>(-5.34298e-40, -0.059107617, -0.06522054, 3.07088e-40, 3.30164e-40, 0.04797229, 0.10684513, -1.89891e-40, 5.0575e-40, -0.61083597, -0.003971756, -9.4862e-41, -4.88554e-40, 6.03131e-40, 2.4428e-40, -6.00085e-40) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(2.5717e-41, 0.035468034, 0.088059336, -4.48804e-40, -7.6473e-41, 0.011622759, 0.2276259, -3.66309e-40, -2.62606e-40, -0.008567859, 0.046415888, 2.42559e-40, -4.88669e-40, 1.84038e-40, -3.01601e-40, -5.2386e-41) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(5.75037e-40, -0.028771527, 0.005793379, -2.753e-41, -1.83922e-40, -0.0021686694, 0.033796262, 4.13924e-40, -2.54863e-40, 0.009495555, 0.047357082, -3.704e-40, -5.0492e-40, -7.2006e-41, 2.31835e-40, -1.25038e-40) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(7.1679e-41, 0.6860188, -0.17280054, -1.26492e-40, 2.2773e-41, -0.4974448, 0.17629091, -3.90567e-40, -3.98856e-40, -0.45245528, 0.07369387, 1.63736e-40, -1.07062e-40, 6.06965e-40, -4.91141e-40, 2.92366e-40) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(6.20764e-40, 0.14232181, 0.15303352, -5.39363e-40, 1.20868e-40, 0.27751428, 0.3888151, -5.5599e-40, -6.06439e-40, -0.12125622, -0.1644373, 3.544e-42, 5.38265e-40, -9.12e-41, 5.6685e-40, -1.229e-40) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-8.4201e-41, 0.011953865, 0.1766276, 5.0995e-41, 1.15646e-40, 0.01786191, 0.06353977, 6.998e-41, 2.92636e-40, -0.03736815, 0.02478431, -1.0385e-40, -1.64134e-40, 5.89647e-40, -3.60202e-40, -1.15023e-40) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-4.21107e-40, -0.038233828, -0.12907626, 4.4003e-40, 6.519e-41, 0.0742864, 0.06470663, 3.8983e-40, 8.9627e-41, 0.025624435, -0.0030807815, 3.61452e-40, 1.47136e-40, 5.48297e-40, 2.26182e-40, -3.58867e-40) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(3.48509e-40, 0.071837105, -0.11748907, -2.12108e-40, 2.00746e-40, 0.0031309195, 0.10045629, 5.6737e-41, -3.05498e-40, 0.012086682, 0.027398532, -2.4342e-41, -3.40235e-40, 1.30144e-40, -2.81452e-40, -6.18099e-40) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(1.30085e-40, -0.018832413, 0.057887193, -6.64e-43, 2.57961e-40, 0.0011029604, -0.0819106, 2.39972e-40, -2.34559e-40, -0.015430645, -0.0002921565, -3.01152e-40, -4.48809e-40, 1.5585e-41, 2.1149e-40, -1.6289e-41) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(3.23614e-40, -0.036026515, 0.023559442, 2.5438e-41, 7.032e-42, 5.75271e-40, -1.6016e-40, -1.58281e-40, 5.26918e-40, 6.14478e-40, -4.07206e-40, 4.88547e-40, 3.1748e-41, 0.069875516, -0.124291554, -2.85185e-40) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(2.08576e-40, -0.006300434, -0.086948976, 5.1229e-40, -8.9973e-41, -5.06205e-40, -1.47597e-40, 2.19909e-40, -6.345e-41, 1.23468e-40, -4.17475e-40, -9.394e-41, -3.80523e-40, -0.029290335, -0.35061774, 3.55411e-40) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(3.8836e-40, 0.01523719, -0.038350023, -2.49154e-40, 5.87e-41, -2.903e-42, -2.1977e-40, -1.5628e-40, 1.20754e-40, -3.16734e-40, -4.3706e-40, -6.2534e-40, -2.43218e-40, 0.0032293673, -0.11418, 2.44852e-40) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(2.09487e-40, 0.60743016, -0.2954701, 1.35158e-40, 1.84107e-40, 3.81986e-40, 4.31798e-40, -5.311e-40, 7.5297e-41, 7.3214e-41, -4.28383e-40, -3.32748e-40, -5.79588e-40, -0.4263183, -0.040786676, -8.1435e-41) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(5.96331e-40, 0.09252274, 0.70186996, 3.35534e-40, -3.61e-42, -2.29129e-40, 4.17238e-40, 5.13946e-40, 8.9267e-41, 5.21433e-40, -4.55074e-40, -2.4982e-40, 6.19661e-40, 0.15788782, 0.6168983, -2.70907e-40) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-1.7878e-41, -0.0047369795, -0.083978824, 8.5831e-41, 2.73622e-40, -5.0895e-40, -1.29689e-40, -5.81619e-40, 4.91386e-40, -2.60707e-40, -4.60231e-40, -1.29557e-40, 3.49641e-40, 0.036809336, -0.10085389, 7.1206e-41) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-4.19795e-40, 0.03440655, -0.028576387, -8.5122e-41, 5.43412e-40, 4.00791e-40, -1.30228e-40, -3.15707e-40, -1.46088e-40, 1.61086e-40, -3.74348e-40, -6.0047e-40, -5.67761e-40, 0.021220421, 0.016097626, -5.9519e-41) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-4.43832e-40, -0.08382292, -0.16537851, 3.7625e-41, 6.0305e-40, 5.17435e-40, -1.00947e-40, -5.51386e-40, 3.182e-41, -2.02984e-40, -3.98888e-40, -1.8712e-41, -6.8327e-41, 0.00016530568, 0.08509953, -2.55518e-40) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(2.78585e-40, 0.016897561, -0.05246484, 2.55074e-40, 5.90042e-40, -3.30059e-40, -1.59654e-40, 1.2299e-40, 2.32882e-40, 9.5817e-41, -4.22486e-40, -7.327e-42, -3.3777e-41, 0.0068501765, -0.0116210375, -3.61891e-40) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

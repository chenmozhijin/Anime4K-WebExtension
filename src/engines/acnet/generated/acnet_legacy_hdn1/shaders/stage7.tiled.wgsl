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

  var result: vec4f = vec4f(-1.1321109e-07, -1.8907213e-23, -1.9769655e-25, -0.03239369);
      result += mat4x4<f32>(-1.893194e-06, -5.858098e-27, -2.926628e-29, 0.13732943, -4.7452317e-29, -5.63552e-40, 3.36916e-40, 2.9948274e-07, 3.88549e-40, 4.5073e-41, 1.20932e-40, -1.715e-41, -2.1902873e-37, -1.17015e-40, -2.07206e-40, 1.0496378e-06) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-1.8355889e-06, -8.8482714e-27, -4.5004836e-29, 0.18484797, -4.4894357e-29, -2.34685e-40, 1.00441e-40, 3.3402597e-07, 3.51523e-40, 5.00688e-40, -5.7191e-40, -2.4088e-41, -1.9173794e-37, -2.3137e-41, 2.01221e-40, 1.0916295e-06) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-1.6373203e-06, -8.11498e-27, -3.989056e-29, 0.076179415, -2.5363766e-29, -3.58853e-40, -6.6821e-41, 3.7618548e-07, -4.87075e-40, 2.61145e-40, 5.68281e-40, -1.55934e-40, -7.0784647e-38, -4.54053e-40, -5.9485e-40, 1.1376424e-06) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-1.9426775e-06, -7.4336335e-27, -3.8504552e-29, 0.08171919, -5.6267825e-29, -2.07555e-40, 9.291e-41, 3.4854045e-07, 4.3606e-41, -4.82254e-40, -2.31769e-40, 6.3817e-41, -2.714947e-37, -4.67965e-40, 3.88432e-40, 1.136407e-06) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-1.911336e-06, -1.2035895e-26, -6.336969e-29, 0.33343402, -5.436251e-29, 2.0377e-40, 6.21368e-40, 3.8223502e-07, -1.78862e-40, -4.83169e-40, -2.16475e-40, 4.8004e-41, -2.4810193e-37, 6.5582e-41, -6.0861e-41, 1.1756124e-06) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-1.7027852e-06, -1.1908657e-26, -6.001673e-29, 0.029856661, -3.087596e-29, 3.22586e-40, -3.56255e-40, 4.150657e-07, 5.19698e-40, -5.43162e-40, 5.3642e-40, -1.10529e-40, -9.561889e-38, 1.81112e-40, -4.05417e-40, 1.205147e-06) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-1.8843298e-06, -6.600559e-27, -3.2761453e-29, -0.0042752665, -4.380792e-29, -5.39466e-40, 1.8601e-40, 3.7511495e-07, 6.28642e-40, -5.43348e-40, 4.88264e-40, -2.52248e-40, -1.8462983e-37, 6.14769e-40, -3.43081e-40, 1.1762091e-06) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-1.861643e-06, -1.0685411e-26, -5.414513e-29, 0.2095735, -4.2767098e-29, 4.2747e-41, 3.16525e-40, 4.0397674e-07, 5.99722e-40, -5.29943e-40, 5.27596e-40, -2.71108e-40, -1.7135576e-37, -1.68274e-40, -4.28223e-40, 1.2105338e-06) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-1.6817919e-06, -1.0809097e-26, -5.1812114e-29, 0.018582111, -2.4573077e-29, 4.8967e-41, -1.15055e-40, 4.3742676e-07, 2.21966e-40, 2.62948e-40, -4.9059e-40, -4.29704e-40, -6.7162576e-38, -2.02883e-40, -3.9605e-40, 1.2358342e-06) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-2.9062243e-30, -2.422e-41, -5.74286e-40, 0.010036899, -6.3329e-41, -2.93819e-40, -1.83092e-40, 1.688e-41, -3.0737748e-25, -2.80808e-40, 4.79096e-40, -0.32966918, -8.5637105e-08, -4.0985152e-38, -3.65198e-40, -0.010122079) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-3.1324303e-30, 4.77745e-40, 4.92419e-40, 0.14957331, -3.8604e-41, 2.38e-41, 2.91567e-40, -2.0352e-41, -8.230499e-24, -5.2929e-40, -1.408e-40, -0.25981304, -8.4714856e-08, -6.9101777e-38, 4.32224e-40, 0.074127205) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-1.0876112e-30, 5.105e-40, -5.9141e-40, -0.049009535, -2.82723e-40, 1.58498e-40, -7.7367e-41, -4.186e-42, -2.145062e-23, -4.07859e-40, 1.92198e-40, -0.13015875, -7.7597456e-08, -5.4450075e-38, -5.28662e-40, -0.07155386) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-2.7434236e-30, 4.9844e-40, 4.62674e-40, 0.02687701, -3.33505e-40, -4.52898e-40, -5.89224e-40, 2.0926e-40, -1.4469556e-24, -3.0303e-41, -3.56702e-40, -0.26506764, -8.73264e-08, -6.2744277e-38, -6.07031e-40, 0.07786889) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-3.7035648e-30, 5.6437e-41, -2.49526e-40, 0.19067414, -1.52104e-40, -5.226e-41, 3.2359e-40, -2.1394e-41, -4.513135e-23, 3.13356e-40, 3.42044e-40, 0.32282168, -8.7480345e-08, -1.1525548e-37, -4.0896e-40, 0.15733637) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-1.282075e-30, 4.77487e-40, -2.92999e-40, -0.0019338559, -4.262e-41, 2.37257e-40, -6.12928e-40, -5.4341e-40, -1.2176923e-22, -5.84498e-40, -5.0215e-40, 0.43204364, -8.0290064e-08, -9.937421e-38, -1.25214e-40, 0.13286611) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-6.8828e-31, -6.8037e-41, 5.3466e-40, -0.022080544, -1.7669e-41, -1.9232e-40, 6.11382e-40, 4.68237e-40, -4.2841324e-24, -1.50906e-40, 1.1877e-41, -0.0709356, -8.452459e-08, -4.858656e-38, -4.19808e-40, -0.09543067) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-9.870815e-31, -5.5944e-41, -5.24028e-40, -0.1513694, 5.22913e-40, -2.35019e-40, 2.21215e-40, 6.26822e-40, -1.3077191e-22, -2.7371e-40, 2.31137e-40, 0.19799593, -8.4963034e-08, -9.181922e-38, 5.4404e-41, 0.10984284) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-3.7930255e-31, -5.22478e-40, 3.51783e-40, -0.16087961, -3.32052e-40, -2.97361e-40, -5.066e-42, 4.98652e-40, -3.5945781e-22, -4.59274e-40, -4.77938e-40, 0.0949161, -7.858225e-08, -8.059262e-38, 3.33373e-40, -0.07675896) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

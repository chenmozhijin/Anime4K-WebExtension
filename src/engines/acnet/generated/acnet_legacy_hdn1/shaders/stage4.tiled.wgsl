const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}
var<workgroup> tile_TMP2_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_TMP2_TEX_0[tileY][tileX] = sample_TMP2_TEX_0(
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

  var result: vec4f = vec4f(-0.17700684, -1.3417011e-06, -3.0706e-40, -1.9022406e-06);
      result += mat4x4<f32>(-5.2307655e-12, -2.13593e-40, -3.34466e-40, -3.65746e-40, 0.057994157, -2.65811e-40, -6.4982e-41, 2.88195e-40, 2.0132428e-07, -3.2847572e-22, -5.44102e-40, -1.6272495e-25, 0.02933633, -1.174896e-08, 5.7249e-40, -5.5471143e-09) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-5.4023873e-12, -1.42497e-40, -3.99355e-40, -3.5707e-40, 0.100509994, 1.3006e-40, 5.0849e-41, 4.94604e-40, 2.0907432e-07, -3.669658e-22, 2.30701e-40, -1.8801935e-25, 0.054426856, -1.1601681e-08, 5.35548e-40, -5.686191e-09) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-5.0038606e-12, -4.7123e-40, 2.46491e-40, -3.053e-41, -0.10618387, -1.42009e-40, 5.7873e-40, 6.14607e-40, 2.1344113e-07, -3.4147378e-22, 2.16896e-40, -1.7228921e-25, -0.12081614, -1.1494006e-08, -4.9107e-41, -5.704268e-09) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-5.4553046e-12, -5.9433e-41, 2.0207e-40, 4.2531e-40, 0.06808993, 5.42639e-40, 1.43272e-40, 8.9118e-41, 2.1178944e-07, -3.5779757e-22, -1.59643e-40, -1.7849917e-25, 0.058399227, -1.212478e-08, 1.75382e-40, -5.8726615e-09) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-5.6927835e-12, 1.9903e-41, -3.02446e-40, -1.22552e-40, 0.12788579, 2.38484e-40, -4.2163e-40, -4.65792e-40, 2.2017606e-07, -3.9435336e-22, -2.27809e-40, -2.0338282e-25, 0.2226083, -1.1917957e-08, -1.23122e-40, -5.9822947e-09) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-5.2812494e-12, -1.77012e-40, -7.1986e-41, -3.96071e-40, 0.113795586, 5.64115e-40, 1.38067e-40, -2.41724e-40, 2.2380706e-07, -3.5988738e-22, 5.67663e-40, -1.8235476e-25, 0.111652225, -1.1718304e-08, 5.00768e-40, -5.8983107e-09) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-5.023005e-12, -5.99408e-40, 6.29376e-40, 3.59025e-40, -0.15881513, -2.6378e-41, 2.8569e-40, -5.54745e-40, 2.1094876e-07, -3.1212358e-22, 2.253e-42, -1.4714523e-25, -0.09609848, -1.177927e-08, 6.15003e-40, -5.8040044e-09) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-5.2149582e-12, -5.85621e-40, -3.69223e-40, -5.46303e-40, 0.008232297, -5.71322e-40, 1.91394e-40, -8.1848e-41, 2.1919914e-07, -3.430481e-22, -2.5532e-40, -1.673313e-25, 0.083174735, -1.16232295e-08, 1.99797e-40, -5.866989e-09) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-4.913282e-12, -5.02256e-40, 1.52964e-40, -3.14597e-40, -0.091424264, -4.13426e-40, 3.29849e-40, -1.69102e-40, 2.2150094e-07, -3.0669794e-22, -5.58216e-40, -1.468061e-25, -0.06590936, -1.1558901e-08, 6.29529e-40, -5.738804e-09) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.12007096, -5.0236565e-07, -7.5313567e-23, -9.725328e-07, -0.021117494, 5.6433e-41, 5.06125e-40, -4.50425e-40, -0.25623655, -6.114422e-27, 3.57274e-40, -1.3653338e-34, -0.048357088, -8.160423e-36, -2.2906e-41, -2.50569e-40) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.19775532, -4.917859e-07, -9.42989e-23, -9.724779e-07, -0.02019953, -3.05138e-40, 1.52241e-40, 2.67249e-40, 0.16049464, -9.2379735e-26, 4.27172e-40, -3.469025e-33, 0.25106576, -3.2927974e-37, 3.5923e-40, 7.2876e-41) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.077464186, -4.674351e-07, -7.1341785e-23, -9.462339e-07, 0.093703486, -5.45256e-40, -1.89772e-40, 2.3181e-40, -0.03326726, -2.4302477e-25, -3.59e-40, -1.1577677e-32, 0.048323058, -2.29938e-40, -4.44433e-40, 4.5731e-41) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06701798, -5.196741e-07, -8.51388e-23, -1.014866e-06, -0.04693156, 1.1125e-41, 2.4108e-41, -4.6274e-41, -0.23247741, -9.383428e-25, -4.48315e-40, -1.4444377e-31, 0.09724474, -3.9542876e-37, -4.66149e-40, -1.65251e-40) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.36535805, -5.0826446e-07, -1.1236752e-22, -1.0042015e-06, -0.1591025, 2.94853e-40, -5.17707e-40, -1.17985e-40, 0.54035777, -1.0288623e-23, 3.42605e-40, -2.1995399e-30, 0.55014825, -9.951345e-39, -2.11226e-40, 5.09868e-40) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13795796, -4.842115e-07, -9.04776e-23, -9.670933e-07, 0.08809427, 5.52823e-40, 6.2317e-40, 5.06845e-40, 0.10026647, -1.9512579e-23, -4.82931e-40, -4.8667573e-30, -0.3464134, 7.4616e-41, 4.57004e-40, -5.46826e-40) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.060723953, -5.0226106e-07, -6.2038445e-23, -1.013863e-06, -0.05664057, 3.02294e-40, 1.0465e-40, -1.07649e-40, -0.21680172, -4.37462e-24, -2.41327e-40, -1.2965262e-30, 0.012457578, -4.004398e-39, -4.63604e-40, 8.1836e-41) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.046160743, -4.966757e-07, -8.518042e-23, -9.993025e-07, -0.17146374, 1.59151e-40, 2.8816e-41, 3.33218e-40, -0.0070095654, -4.435914e-23, 3.11402e-40, -2.0188887e-29, -0.13625751, 4.43923e-40, -3.60523e-40, 6.27223e-40) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.23739712, -4.801939e-07, -7.3014864e-23, -9.529541e-07, -0.105023764, 5.37591e-40, 6.25002e-40, -6.1905e-40, -0.10692135, -7.0505157e-23, -2.07773e-40, -3.3962168e-29, -0.41992486, 4.88564e-40, -3.43192e-40, -3.10567e-40) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 2u];
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

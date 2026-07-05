// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv3: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv3_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv3)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv3, sourceCoord * packedScale + lane, 0);
}

@group(0) @binding(2) var linearSampler: sampler;
@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

fn sample_original_luma(coord: vec2i) -> f32 {
  let outputSize = textureDimensions(out_tex);
  let uv = (vec2f(coord) + vec2f(0.5)) / vec2f(outputSize);
  return luma709(textureSampleLevel(tex_LUMA, linearSampler, uv, 0.0).rgb);
}


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_LUMA);
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let outBase = vec2i(pixel.xy) * vec2i(2, 2);

  var s0_0_0: vec4f;
  var s0_0_1: vec4f;
  var s0_0_2: vec4f;
  var s0_1_0: vec4f;
  var s0_1_1: vec4f;
  var s0_1_2: vec4f;
  var s0_2_0: vec4f;
  var s0_2_1: vec4f;
  var s0_2_2: vec4f;
  var s1_0_0: vec4f;
  var s1_0_1: vec4f;
  var s1_0_2: vec4f;
  var s1_1_0: vec4f;
  var s1_1_1: vec4f;
  var s1_1_2: vec4f;
  var s1_2_0: vec4f;
  var s1_2_1: vec4f;
  var s1_2_2: vec4f;
  var r0: vec4f;
  r0 = vec4f(0.0);
  s0_0_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_1 = sample_conv3_vec4(pixel.xy, vec2i(0, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_2 = sample_conv3_vec4(pixel.xy, vec2i(1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_1_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_2_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 1), vec2i(0, 0), vec2i(3, 1));
  s1_0_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_1 = sample_conv3_vec4(pixel.xy, vec2i(0, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_2 = sample_conv3_vec4(pixel.xy, vec2i(1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_1_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_2_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 1), vec2i(1, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(-1.997e-02, 1.593e-02, -2.142e-02, 7.622e-04, -3.536e-02, 2.103e-03, 1.303e-02, -1.799e-03, -7.402e-02, 6.540e-03, -3.651e-02, 5.539e-03, 1.983e-02, 6.777e-03, -3.650e-03, 4.805e-03) * s0_0_0;
  r0 += mat4x4<f32>(7.902e-02, -1.173e-01, -2.952e-03, 2.966e-02, -1.938e-01, -1.946e-01, -6.755e-03, -6.502e-03, 3.750e-01, -2.842e-01, 1.714e-01, -1.670e-01, -3.480e-02, 1.401e-01, -7.627e-03, 2.983e-02) * s0_0_1;
  r0 += mat4x4<f32>(-9.827e-06, 8.648e-02, 5.681e-04, 1.421e-02, 7.311e-03, -3.528e-02, -2.757e-03, -3.441e-03, -2.976e-02, -6.379e-02, -1.534e-02, -3.162e-02, 1.302e-02, -6.079e-03, 3.418e-04, 8.850e-04) * s0_0_2;
  r0 += mat4x4<f32>(-3.943e-02, 3.901e-03, -2.970e-02, 1.213e-02, 4.213e-02, -9.102e-03, 1.316e-02, -1.873e-02, -1.531e-02, -6.819e-03, -4.968e-02, 3.036e-03, 6.084e-02, -1.935e-02, -7.472e-02, 2.745e-04) * s0_1_0;
  r0 += mat4x4<f32>(-7.007e-02, -1.478e-01, 1.102e-01, -3.643e-01, 2.456e-01, 1.712e-01, -1.057e-01, 7.243e-02, 9.262e-03, 7.300e-02, 1.632e-01, 3.768e-02, 6.763e-02, 3.095e-01, -1.974e-02, -6.307e-01) * s0_1_1;
  r0 += mat4x4<f32>(1.968e-02, 1.837e-01, 9.659e-03, 2.056e-01, -2.334e-02, 4.368e-02, 1.104e-02, -1.860e-02, -1.091e-02, -3.694e-03, -2.213e-02, -2.179e-02, 2.128e-03, 4.726e-03, -6.886e-03, 3.059e-03) * s0_1_2;
  r0 += mat4x4<f32>(-1.910e-03, -3.374e-03, -1.663e-02, -3.118e-04, -7.201e-03, -2.534e-03, 2.877e-03, -3.363e-03, -3.070e-03, 6.711e-03, -1.279e-02, 9.499e-03, -3.176e-03, -9.044e-04, 2.521e-02, 7.151e-03) * s0_2_0;
  r0 += mat4x4<f32>(8.323e-03, -1.064e-02, -5.213e-02, -2.899e-03, -4.474e-03, -3.807e-03, 9.883e-02, 4.822e-02, -1.508e-03, -6.790e-03, 1.486e-03, -1.581e-02, 4.014e-03, -1.972e-03, 4.285e-02, 7.056e-02) * s0_2_1;
  r0 += mat4x4<f32>(5.893e-03, -2.701e-03, 1.565e-02, 3.970e-02, -1.924e-03, -7.485e-04, -1.496e-02, 2.259e-02, 4.866e-04, -4.067e-03, -3.708e-03, -9.145e-03, -3.362e-05, -3.369e-03, -1.659e-03, 6.882e-03) * s0_2_2;
  r0 += mat4x4<f32>(-1.960e-04, 5.872e-03, 7.844e-03, -4.121e-04, 6.116e-04, 2.624e-03, -1.555e-03, 1.646e-04, -5.790e-03, -4.048e-03, -7.185e-05, -2.863e-04, 4.604e-03, 4.096e-03, -1.733e-03, -4.615e-03) * s1_0_0;
  r0 += mat4x4<f32>(-3.610e-02, -3.994e-03, -8.747e-03, -4.655e-03, 2.051e-02, -2.021e-02, 2.228e-02, -4.602e-03, 4.379e-03, 4.941e-03, 4.027e-03, 3.186e-03, -9.781e-02, -7.371e-02, -5.962e-02, -1.819e-02) * s1_0_1;
  r0 += mat4x4<f32>(-2.788e-02, 2.187e-02, -4.971e-03, 2.069e-02, -2.280e-01, 1.610e-01, 3.266e-04, 6.641e-04, -2.020e-03, -7.089e-04, 3.127e-03, 2.448e-03, 3.046e-02, -3.403e-03, 2.073e-02, 5.470e-03) * s1_0_2;
  r0 += mat4x4<f32>(-8.911e-02, -2.936e-03, -4.901e-02, 3.868e-03, 3.227e-03, 4.200e-03, 4.224e-03, 3.722e-03, -1.486e-02, -4.009e-05, -2.495e-03, 4.505e-03, -3.212e-02, -4.170e-03, -1.027e-02, 3.936e-03) * s1_1_0;
  r0 += mat4x4<f32>(4.320e-01, -1.701e-01, 2.161e-01, -8.004e-02, 1.988e-02, -8.646e-03, 2.634e-02, -1.403e-02, -1.947e-02, -2.643e-02, -3.308e-02, -1.529e-02, -1.929e-01, -1.002e-01, 4.013e-01, 1.489e-01) * s1_1_1;
  r0 += mat4x4<f32>(3.786e-02, -1.644e-01, -2.061e-03, -7.494e-02, -9.516e-02, 6.127e-02, -3.860e-01, 3.154e-01, -1.994e-02, -3.162e-02, -4.892e-03, -1.594e-02, -1.864e-02, -7.866e-02, -3.749e-02, 9.448e-02) * s1_1_2;
  r0 += mat4x4<f32>(-7.443e-04, -5.879e-04, -4.339e-02, -1.307e-03, -7.464e-07, 1.094e-03, 9.849e-04, 4.206e-03, 1.530e-02, -1.216e-02, -4.662e-03, 2.543e-04, 5.228e-03, 5.050e-03, -3.274e-03, 7.251e-03) * s1_2_0;
  r0 += mat4x4<f32>(-3.684e-02, -6.909e-03, 1.322e-01, -4.979e-02, 4.264e-03, 1.835e-03, 3.456e-03, -4.366e-03, -3.037e-01, -1.302e-02, 3.096e-01, 7.007e-02, -1.986e-03, -3.014e-03, -9.684e-02, -4.846e-02) * s1_2_1;
  r0 += mat4x4<f32>(-7.767e-03, 4.328e-02, 7.981e-03, -4.539e-02, -2.176e-03, 2.009e-02, 2.741e-02, -3.035e-03, 2.188e-02, -1.078e-01, -2.000e-02, 5.295e-02, -2.538e-03, -5.671e-03, 6.670e-05, -3.864e-02) * s1_2_2;
  s0_0_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_1 = sample_conv3_vec4(pixel.xy, vec2i(0, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_2 = sample_conv3_vec4(pixel.xy, vec2i(1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_1_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_2_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(-1.060e-02, -2.417e-03, -3.369e-03, 1.480e-02, 5.994e-02, -5.429e-03, 2.402e-03, 2.703e-03, 8.873e-03, -2.112e-03, -1.887e-03, 2.919e-03, 4.741e-04, -1.312e-03, 1.228e-03, 4.626e-03) * s0_0_0;
  r0 += mat4x4<f32>(-2.710e-03, -2.305e-03, -4.674e-02, -4.219e-02, 9.789e-02, 1.613e-01, 2.820e-03, -1.824e-04, 6.007e-02, 1.435e-02, 1.656e-02, 8.830e-03, -1.302e-02, -2.279e-03, -8.817e-03, -8.452e-03) * s0_0_1;
  r0 += mat4x4<f32>(-6.971e-03, -1.478e-02, 6.121e-03, -1.394e-02, -1.154e-02, -3.490e-04, -8.617e-04, -6.654e-03, -1.631e-02, -6.873e-03, 2.901e-03, 9.940e-03, 7.430e-03, -1.870e-03, 4.319e-03, 1.705e-03) * s0_0_2;
  r0 += mat4x4<f32>(-4.503e-03, -4.896e-02, -5.193e-03, -4.382e-02, -8.422e-02, 3.081e-02, 4.278e-02, -2.068e-02, 1.091e-01, 2.391e-04, 6.067e-02, -5.288e-03, -5.053e-04, 1.032e-02, -8.952e-03, 5.276e-04) * s0_1_0;
  r0 += mat4x4<f32>(1.380e-01, 1.265e-01, 1.372e-01, 1.228e-01, -1.409e-01, -3.525e-01, 1.968e-01, 3.135e-01, -2.881e-01, 2.308e-01, -1.155e-01, 1.105e-01, 2.600e-01, -1.081e-04, 4.038e-02, -2.889e-02) * s0_1_1;
  r0 += mat4x4<f32>(-2.483e-02, 1.872e-02, -2.569e-02, 2.053e-02, -7.188e-03, 2.944e-02, -1.394e-02, 7.372e-03, 1.913e-02, -1.840e-01, -1.666e-02, -1.460e-01, -1.489e-02, 6.679e-03, -3.915e-03, -3.907e-03) * s0_1_2;
  r0 += mat4x4<f32>(-6.747e-03, 1.047e-02, -1.259e-02, -1.197e-02, 5.572e-03, 7.804e-04, -2.943e-02, -8.698e-03, 1.529e-03, 3.779e-03, 5.330e-02, 3.234e-03, -1.139e-02, 6.493e-03, 1.925e-02, -6.306e-03) * s0_2_0;
  r0 += mat4x4<f32>(-4.016e-02, -3.574e-02, 8.974e-04, 4.319e-03, -9.350e-03, 4.734e-03, -6.455e-02, -9.546e-02, 3.710e-02, -1.051e-03, -5.462e-02, 6.518e-02, 8.670e-02, -4.548e-02, -5.918e-01, 1.432e-01) * s0_2_1;
  r0 += mat4x4<f32>(2.316e-03, -1.466e-02, -9.226e-03, -1.570e-02, 2.743e-03, 1.230e-03, -1.084e-03, -9.783e-03, -8.812e-03, -6.144e-03, 6.925e-03, -5.774e-02, -5.707e-04, -6.470e-02, 8.674e-03, -1.456e-02) * s0_2_2;
  r0 += vec4f(9.114e-10, 2.263e-11, 1.001e-09, 2.503e-11);
  r0 = r0;
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

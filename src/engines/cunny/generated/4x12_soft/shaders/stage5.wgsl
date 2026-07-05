// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv4: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv4_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv4)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv4, sourceCoord * packedScale + lane, 0);
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
  s0_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(0, 0), vec2i(3, 1));
  s1_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(1, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(8.381e-03, -5.337e-04, -9.637e-03, 2.370e-04, -3.788e-02, -7.526e-03, -2.010e-02, 2.584e-03, -5.980e-06, -6.376e-06, 2.881e-04, -4.844e-06, 5.442e-02, -2.618e-03, 5.506e-02, -3.089e-03) * s0_0_0;
  r0 += mat4x4<f32>(-1.519e-01, 3.500e-03, 1.139e-02, -4.555e-03, -7.608e-02, -9.172e-02, -8.467e-02, -7.249e-02, 2.588e-01, -1.100e-02, 1.444e-01, -8.324e-05, 4.199e-02, -9.560e-01, 7.323e-03, 1.141e-01) * s0_0_1;
  r0 += mat4x4<f32>(-2.762e-03, -2.367e-02, 2.233e-03, -2.144e-03, 4.594e-04, -2.394e-02, 5.215e-03, -1.114e-02, -6.538e-03, 5.193e-01, -5.215e-02, 8.818e-02, 8.528e-04, 2.690e-02, -3.972e-06, 5.147e-03) * s0_0_2;
  r0 += mat4x4<f32>(4.089e-02, 2.765e-03, 5.188e-02, 3.472e-03, -1.266e-02, -2.785e-02, -2.285e-02, -3.300e-02, -7.237e-07, -5.050e-06, -2.955e-04, 2.069e-05, -3.212e-03, 3.406e-03, 3.792e-02, -2.581e-03) * s0_1_0;
  r0 += mat4x4<f32>(-1.351e-01, 2.158e-01, -5.752e-01, 9.589e-02, 2.222e-01, 1.703e-01, 1.753e-01, 1.255e-01, 8.627e-04, -1.064e-03, 7.367e-02, -1.149e-03, -3.564e-03, -3.291e-03, 1.948e-03, -1.282e-02) * s0_1_1;
  r0 += mat4x4<f32>(2.775e-03, -5.529e-02, -1.788e-04, -2.666e-02, -2.559e-02, 2.714e-03, -4.446e-02, -8.291e-03, 3.263e-03, -6.336e-03, 1.997e-01, 2.229e-01, 3.700e-04, -2.392e-03, -8.699e-04, 2.948e-02) * s0_1_2;
  r0 += mat4x4<f32>(-2.865e-04, -2.977e-05, 1.682e-02, 8.777e-04, -6.114e-04, -5.408e-04, -1.016e-02, -7.532e-03, -1.440e-07, 9.155e-07, 2.887e-06, 5.509e-08, -2.590e-05, 8.857e-06, 2.010e-04, 1.499e-04) * s0_2_0;
  r0 += mat4x4<f32>(-3.860e-04, -4.749e-03, 3.747e-02, 4.636e-02, -1.657e-03, -1.134e-02, 1.239e-02, 9.712e-03, 7.930e-07, -5.469e-06, -9.479e-06, -3.160e-07, 2.889e-05, -1.613e-05, -2.628e-05, 4.986e-04) * s0_2_1;
  r0 += mat4x4<f32>(1.210e-03, -1.006e-03, -3.222e-04, -3.006e-02, 7.282e-04, -1.978e-03, -4.794e-04, -6.402e-03, -4.035e-06, 1.094e-05, -1.851e-04, -3.224e-04, 1.356e-06, -1.393e-08, 3.265e-05, -3.021e-04) * s0_2_2;
  r0 += mat4x4<f32>(1.373e-03, -8.676e-04, 1.236e-04, 2.623e-04, 6.814e-02, 1.823e-02, 4.164e-04, 3.275e-04, 1.607e-01, 1.338e-02, -7.112e-03, -2.358e-03, -4.494e-03, -3.196e-04, -4.995e-04, -2.058e-04) * s1_0_0;
  r0 += mat4x4<f32>(-1.103e-02, -2.700e-04, -5.051e-04, -2.087e-04, -3.135e-03, 5.636e-02, 1.259e-03, 1.324e-03, 2.192e-03, 5.323e-02, -2.679e-04, -3.847e-03, -6.637e-05, 1.071e-04, 5.012e-05, -1.936e-04) * s1_0_1;
  r0 += mat4x4<f32>(-1.252e-03, -1.260e-03, -1.463e-04, -4.087e-04, 9.170e-04, -6.782e-04, 3.729e-04, 1.390e-03, -2.714e-04, 8.577e-04, -1.332e-04, -6.069e-04, -2.919e-05, -1.657e-05, -6.048e-06, 2.733e-06) * s1_0_2;
  r0 += mat4x4<f32>(-1.386e-01, -2.206e-03, -1.812e-01, 1.075e-02, -9.003e-02, -1.747e-02, -2.738e-02, -4.402e-03, -8.890e-02, -2.316e-01, 6.133e-01, -1.119e-01, -5.315e-02, -4.190e-02, 6.775e-03, -2.593e-03) * s1_1_0;
  r0 += mat4x4<f32>(2.000e-01, 4.070e-01, 2.753e-02, -1.822e-01, -1.475e-01, 2.111e-01, -4.948e-02, 5.193e-01, 1.139e-02, 4.071e-02, 5.158e-03, 1.075e-01, -3.948e-03, -1.809e-02, 1.605e-04, 4.589e-03) * s1_1_1;
  r0 += mat4x4<f32>(7.022e-03, 4.761e-02, 6.135e-04, 3.339e-02, -5.708e-03, -3.821e-02, -9.693e-04, -3.210e-02, 5.091e-04, 7.779e-05, 1.067e-05, -8.435e-04, 3.538e-04, -9.539e-04, 1.884e-04, 1.050e-03) * s1_1_2;
  r0 += mat4x4<f32>(-3.169e-03, 4.554e-03, 7.057e-02, -5.446e-04, -3.407e-03, -5.521e-04, 2.238e-02, 2.842e-03, 4.899e-03, -6.446e-04, -2.873e-02, -6.271e-02, 5.456e-01, -1.123e-02, -2.007e-01, -1.630e-01) * s1_2_0;
  r0 += mat4x4<f32>(7.789e-04, 9.922e-04, 1.265e-01, 2.307e-01, 2.212e-04, -2.183e-03, -7.679e-02, -1.063e-03, -4.404e-04, 6.865e-03, 7.764e-03, 1.062e-02, 5.370e-04, 9.055e-02, -3.345e-03, 8.346e-03) * s1_2_1;
  r0 += mat4x4<f32>(-8.093e-05, 1.862e-03, 1.757e-03, 2.693e-02, 5.219e-05, -1.210e-03, -1.251e-03, -1.923e-02, -1.688e-05, 1.096e-03, 2.278e-04, 2.987e-03, 4.484e-04, 4.695e-03, 1.452e-05, 3.523e-03) * s1_2_2;
  s0_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(6.456e-02, 4.681e-04, 3.202e-04, -1.882e-05, -6.875e-06, -5.255e-05, 1.545e-04, 5.690e-06, 1.725e-03, 4.132e-05, 6.705e-06, -4.449e-06, -2.599e-03, -5.443e-05, -8.268e-05, 3.088e-06) * s0_0_0;
  r0 += mat4x4<f32>(5.872e-02, 1.685e-01, 3.258e-03, 2.991e-03, 1.007e-01, -3.312e-03, -8.997e-03, 2.455e-03, -4.427e-03, -2.153e-04, -4.509e-05, 1.085e-04, 1.187e-02, 4.558e-04, 5.171e-04, -9.367e-06) * s0_0_1;
  r0 += mat4x4<f32>(5.592e-03, 1.178e-02, -4.755e-04, 1.953e-04, 3.009e-02, 1.256e-01, -2.144e-03, 5.952e-04, 2.382e-03, -2.709e-05, 3.857e-05, -1.039e-04, -1.050e-03, 9.102e-04, 9.290e-05, 3.574e-04) * s0_0_2;
  r0 += mat4x4<f32>(1.351e-02, 7.860e-03, 1.081e-01, -2.916e-03, -6.245e-05, 2.346e-05, -7.056e-04, 1.589e-05, 1.186e-02, -2.904e-04, 2.542e-03, -1.232e-03, -4.194e-03, 3.500e-04, -3.853e-03, 5.538e-04) * s0_1_0;
  r0 += mat4x4<f32>(-2.272e-02, -2.793e-02, 1.567e-01, 4.697e-01, 2.549e-02, 1.413e-02, 1.131e-01, 4.555e-03, 4.007e-01, 1.808e-01, -8.867e-05, -5.964e-03, -6.432e-01, -9.839e-02, 2.160e-02, -7.575e-03) * s0_1_1;
  r0 += mat4x4<f32>(-1.781e-03, 5.410e-03, 8.707e-03, 2.142e-02, -9.048e-03, 1.859e-02, 7.006e-02, -8.383e-01, 2.393e-02, 2.344e-01, 2.089e-03, 3.004e-03, -3.117e-02, -3.487e-01, -5.075e-03, -1.443e-02) * s0_1_2;
  r0 += mat4x4<f32>(-2.369e-03, 2.750e-03, -6.362e-04, -5.306e-03, 6.061e-05, 1.398e-04, 4.214e-04, -3.922e-05, -6.393e-03, -1.922e-03, 4.114e-02, -4.092e-03, 3.135e-03, 1.042e-03, -2.162e-02, 2.755e-03) * s0_2_0;
  r0 += mat4x4<f32>(5.106e-04, -9.120e-04, -1.826e-02, -2.388e-02, 2.637e-04, -1.808e-04, 8.345e-03, 6.624e-04, 2.386e-05, -1.386e-02, -6.949e-01, 9.170e-03, -4.652e-04, -3.560e-03, -5.589e-02, -2.736e-03) * s0_2_1;
  r0 += mat4x4<f32>(-2.040e-04, -2.362e-03, -6.317e-04, -4.799e-03, -3.691e-05, -7.701e-05, -1.225e-02, -4.401e-03, -3.349e-03, -3.404e-03, 3.524e-02, -2.163e-02, 1.077e-03, 3.603e-03, -3.162e-02, -1.067e-01) * s0_2_2;
  r0 += vec4f(4.275e-11, 3.228e-10, 1.508e-08, 5.893e-11);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

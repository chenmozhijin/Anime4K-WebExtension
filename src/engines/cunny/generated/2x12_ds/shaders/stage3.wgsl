// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv2: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv2_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv2)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv2, sourceCoord * packedScale + lane, 0);
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
  s0_0_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_1 = sample_conv2_vec4(pixel.xy, vec2i(0, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_2 = sample_conv2_vec4(pixel.xy, vec2i(1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_1_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_2_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 1), vec2i(0, 0), vec2i(3, 1));
  s1_0_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_1 = sample_conv2_vec4(pixel.xy, vec2i(0, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_2 = sample_conv2_vec4(pixel.xy, vec2i(1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_1_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_2_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 1), vec2i(1, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(9.440e-03, 1.458e-03, -6.458e-03, -2.700e-03, 5.549e-03, -7.639e-04, 2.096e-03, -8.989e-04, 2.640e-02, -1.410e-03, 1.869e-02, 1.409e-03, 1.023e-01, 2.487e-02, -1.416e-02, 3.629e-02) * s0_0_0;
  r0 += mat4x4<f32>(1.509e-01, 8.438e-02, 1.143e-02, 7.978e-03, -5.750e-02, -4.674e-03, 3.891e-04, -1.231e-02, -1.345e-01, -1.840e-02, 2.323e-02, -1.079e-02, 1.333e-01, 1.919e-01, 1.433e-02, 2.509e-02) * s0_0_1;
  r0 += mat4x4<f32>(2.302e-03, 5.351e-02, 8.480e-03, 6.431e-03, 2.905e-03, 2.131e-02, 3.915e-03, -1.758e-02, 3.072e-03, -3.438e-02, -3.509e-05, 1.477e-02, 8.195e-03, 2.424e-02, 5.391e-04, 1.488e-02) * s0_0_2;
  r0 += mat4x4<f32>(7.642e-02, -1.506e-02, 4.578e-02, 6.141e-03, 4.553e-02, -7.810e-03, 3.074e-02, -1.146e-02, 2.712e-02, 4.883e-03, 4.200e-02, -2.749e-03, 8.652e-02, -5.921e-02, -1.753e-01, -3.594e-02) * s0_1_0;
  r0 += mat4x4<f32>(-3.115e-01, 1.107e-01, 1.518e-01, 2.172e-01, -3.271e-01, 1.567e-01, -3.639e-01, 7.900e-02, 1.036e-01, 1.448e-01, -1.876e-01, 1.294e-01, -1.135e-01, 1.738e-01, -6.591e-02, -4.482e-01) * s0_1_1;
  r0 += mat4x4<f32>(1.008e-02, -2.001e-01, -3.162e-02, -1.160e-01, 1.728e-02, 1.439e-01, 1.267e-02, 1.849e-01, -7.903e-03, -7.609e-02, -4.156e-03, -1.518e-01, 1.712e-02, -2.836e-02, -2.087e-02, 2.260e-02) * s0_1_2;
  r0 += mat4x4<f32>(1.232e-02, 1.138e-02, 1.824e-02, -4.395e-04, -2.328e-03, -2.045e-03, 2.178e-02, 1.811e-03, -2.592e-03, -1.386e-03, 4.552e-03, 4.235e-04, -3.959e-03, -3.804e-04, -1.466e-02, -1.121e-02) * s0_2_0;
  r0 += mat4x4<f32>(2.040e-02, -2.045e-02, -1.567e-01, -8.699e-02, 1.209e-02, -3.504e-02, -2.003e-02, 2.460e-02, 1.098e-03, -1.320e-03, 7.594e-02, 3.979e-02, 9.844e-03, -1.918e-02, 1.771e-02, 6.114e-02) * s0_2_1;
  r0 += mat4x4<f32>(4.157e-04, 7.436e-03, 2.223e-04, -2.286e-02, -2.104e-03, 9.648e-03, 1.889e-03, 1.958e-02, -1.945e-03, -3.176e-03, 1.402e-02, 5.585e-03, -4.020e-03, -3.422e-03, -1.357e-02, -1.231e-02) * s0_2_2;
  r0 += mat4x4<f32>(-9.219e-04, 1.067e-02, 6.003e-03, 4.274e-03, 1.317e-02, 1.407e-02, 1.695e-02, 5.354e-04, 7.108e-03, 1.250e-03, 3.536e-03, 1.130e-03, -2.529e-01, -5.931e-02, 2.179e-02, -6.267e-03) * s1_0_0;
  r0 += mat4x4<f32>(-1.188e-02, 3.071e-02, 5.405e-03, -9.395e-03, -7.347e-03, -1.450e-02, 3.142e-02, 3.383e-02, 6.958e-02, 6.564e-02, -2.168e-03, -6.023e-03, -3.457e-02, -2.212e-01, -3.443e-02, 2.412e-02) * s1_0_1;
  r0 += mat4x4<f32>(3.835e-03, -1.222e-03, -6.219e-04, -1.726e-03, 1.053e-02, 1.544e-02, -6.418e-03, 1.120e-02, -4.585e-03, 1.540e-02, -3.284e-03, -2.096e-03, -1.085e-02, -2.486e-02, 1.199e-03, -2.206e-02) * s1_0_2;
  r0 += mat4x4<f32>(1.880e-01, -2.005e-02, 9.356e-02, -6.820e-03, -1.041e-02, 2.891e-02, -1.238e-02, 2.985e-02, -8.709e-02, 2.214e-02, -8.611e-02, 9.603e-03, -7.273e-04, 1.492e-02, 2.154e-01, 8.375e-02) * s1_1_0;
  r0 += mat4x4<f32>(9.604e-02, -3.090e-01, -3.613e-03, -7.105e-02, -1.194e-01, -1.199e-01, -1.168e-01, -1.322e-01, 4.389e-02, -2.666e-01, 1.958e-01, 6.058e-03, 1.357e-02, -5.326e-03, 6.519e-02, 1.595e-01) * s1_1_1;
  r0 += mat4x4<f32>(-3.195e-03, -7.204e-03, 7.797e-04, -5.749e-03, 4.041e-02, 3.136e-03, 4.230e-02, 5.178e-03, 1.800e-02, 1.284e-01, 1.478e-02, 9.075e-02, -6.532e-04, 7.743e-03, 7.242e-03, 1.729e-02) * s1_1_2;
  r0 += mat4x4<f32>(4.188e-02, 1.297e-02, 1.209e-01, 4.563e-03, 2.177e-02, 3.521e-03, 1.837e-02, 1.764e-02, 8.617e-03, 1.867e-03, -2.678e-03, 1.357e-02, 1.339e-03, 7.034e-04, -4.800e-04, -3.468e-03) * s1_2_0;
  r0 += mat4x4<f32>(-4.626e-02, -1.761e-03, 3.884e-02, -1.890e-01, 3.670e-02, 4.163e-02, -3.976e-03, -6.805e-04, -2.983e-02, 2.953e-02, -1.042e-01, -1.275e-01, 4.059e-04, 6.681e-04, 1.813e-03, -2.442e-03) * s1_2_1;
  r0 += mat4x4<f32>(1.841e-04, 5.195e-03, -2.239e-04, 3.067e-03, -7.669e-03, 7.809e-03, 6.520e-03, 1.144e-02, 5.097e-03, -9.792e-03, 4.629e-03, 3.235e-02, -4.693e-04, 6.857e-04, 1.249e-03, 7.149e-03) * s1_2_2;
  s0_0_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_1 = sample_conv2_vec4(pixel.xy, vec2i(0, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_2 = sample_conv2_vec4(pixel.xy, vec2i(1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_1_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_2_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(-4.696e-03, -2.235e-03, -2.791e-03, -2.194e-03, -1.833e-02, -1.581e-02, 5.379e-04, -1.388e-02, 5.286e-02, -1.501e-02, -6.261e-02, -7.594e-03, -2.580e-02, 4.535e-03, -8.267e-03, 8.031e-03) * s0_0_0;
  r0 += mat4x4<f32>(6.454e-03, 2.442e-03, -8.540e-05, 8.841e-04, 2.841e-02, 6.067e-02, 3.903e-02, -1.573e-02, 2.436e-01, 2.725e-01, -3.018e-01, -3.434e-01, 1.569e-02, -1.343e-01, -2.169e-02, 2.065e-02) * s0_0_1;
  r0 += mat4x4<f32>(-5.644e-03, -2.650e-03, -2.462e-03, -4.319e-03, -4.638e-02, -6.754e-02, 2.064e-02, -2.172e-02, 9.204e-03, 6.314e-02, 1.391e-02, -1.852e-02, -6.803e-03, 2.286e-02, -8.599e-03, 5.785e-04) * s0_0_2;
  r0 += mat4x4<f32>(2.435e-02, 1.320e-03, -3.189e-03, 1.138e-03, -5.201e-02, 2.589e-02, 4.576e-02, -1.926e-02, 1.763e-03, 4.594e-03, 2.996e-02, 1.729e-02, -1.821e-01, -3.079e-03, -1.220e-01, 4.117e-03) * s0_1_0;
  r0 += mat4x4<f32>(-9.798e-03, 5.708e-03, -3.612e-03, -1.162e-02, 2.359e-01, -2.764e-01, -4.033e-01, 4.334e-02, -3.732e-03, -3.111e-03, 3.083e-02, 3.689e-02, 1.859e-01, 9.787e-02, 1.922e-01, -2.378e-01) * s0_1_1;
  r0 += mat4x4<f32>(1.447e-02, 3.129e-02, 3.177e-04, 5.861e-03, -9.554e-03, 1.665e-01, 2.331e-02, 1.331e-02, 1.948e-03, -7.511e-04, 1.151e-02, 3.967e-02, -2.507e-03, 3.308e-02, -2.168e-04, 5.515e-02) * s0_1_2;
  r0 += mat4x4<f32>(-4.432e-02, 7.455e-03, 9.602e-03, -1.349e-02, -1.484e-02, 1.011e-02, 1.215e-02, -8.993e-03, -1.493e-03, -1.009e-03, -5.513e-04, -9.491e-04, -1.443e-03, -5.219e-03, -5.041e-02, -1.353e-02) * s0_2_0;
  r0 += mat4x4<f32>(-2.705e-01, -3.268e-01, 2.529e-01, 2.607e-01, -1.693e-02, 3.220e-02, 1.566e-01, 4.674e-02, 1.344e-03, 7.439e-04, 8.556e-04, 1.329e-03, 1.046e-02, 8.395e-03, 4.775e-02, 1.428e-01) * s0_2_1;
  r0 += mat4x4<f32>(2.118e-02, -1.406e-02, -5.702e-04, 4.942e-02, -9.092e-04, -8.394e-04, -3.924e-04, 2.301e-03, -4.209e-04, -9.198e-04, -7.673e-04, -1.429e-03, -1.101e-03, -1.320e-03, -7.397e-04, 1.053e-02) * s0_2_2;
  r0 += vec4f(-4.856e-12, -1.403e-10, 5.258e-11, -1.187e-10);
  r0 = r0;
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

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
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
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
  r0 += mat4x4<f32>(5.536e-02, -4.016e-03, 2.585e-03, -5.604e-04, 5.359e-02, -1.904e-03, -4.353e-03, -8.628e-04, -1.334e-05, 1.528e-03, 9.130e-04, 3.965e-04, -1.274e-01, -9.920e-03, -1.558e-03, 1.109e-03) * s0_0_0;
  r0 += mat4x4<f32>(1.429e-01, 2.105e-02, -2.658e-03, 1.064e-03, 1.624e-01, 1.890e-01, 5.589e-04, -8.300e-03, -1.184e-03, -6.996e-03, -5.439e-04, -2.965e-04, 3.534e-03, 1.316e-01, 4.101e-03, 1.396e-02) * s0_0_1;
  r0 += mat4x4<f32>(-2.898e-04, 7.801e-03, -5.162e-04, -4.971e-03, -6.050e-03, 1.224e-03, 1.609e-03, -1.689e-03, 2.287e-04, 2.282e-03, -2.525e-05, 1.315e-04, 1.248e-04, 1.197e-03, 1.381e-04, 1.832e-03) * s0_0_2;
  r0 += mat4x4<f32>(1.166e-01, 2.748e-03, 6.888e-02, 1.613e-03, 1.431e-01, -1.061e-02, 1.703e-01, -8.430e-03, -3.956e-02, 1.436e-02, -7.332e-04, 3.803e-03, -2.992e-01, 8.243e-03, -4.720e-01, -1.308e-02) * s0_1_0;
  r0 += mat4x4<f32>(-1.267e-02, -2.034e-01, -1.401e-01, -8.315e-01, 1.610e-03, 1.890e-02, -1.588e-02, 4.589e-01, -3.740e-01, -4.455e-01, 1.833e-03, -1.304e-02, -4.794e-03, 2.627e-01, 5.121e-03, 3.089e-01) * s0_1_1;
  r0 += mat4x4<f32>(8.917e-04, -9.259e-03, -3.589e-03, -2.651e-02, -3.803e-03, 1.419e-02, -9.648e-03, -2.613e-02, 7.094e-03, -1.163e-02, -1.082e-03, 7.805e-03, -1.929e-04, -4.041e-03, 1.102e-04, -2.750e-03) * s0_1_2;
  r0 += mat4x4<f32>(1.589e-03, 6.034e-04, -2.218e-02, -2.793e-03, -1.781e-03, 4.077e-04, -1.943e-04, -6.053e-03, -4.239e-03, -1.245e-03, 1.460e-01, 1.470e-02, -4.503e-04, -1.908e-03, 3.483e-02, 1.103e-02) * s0_2_0;
  r0 += mat4x4<f32>(8.837e-04, -5.246e-04, -3.600e-03, -3.899e-02, -1.353e-03, -5.442e-03, 1.784e-02, -1.268e-02, 2.917e-04, 3.233e-03, 2.026e-01, 2.789e-01, 4.183e-04, 6.724e-03, -1.669e-02, 6.788e-02) * s0_2_1;
  r0 += mat4x4<f32>(2.707e-04, -1.812e-03, 4.570e-04, -4.994e-03, -3.174e-04, 4.956e-04, -6.908e-04, 5.812e-03, 2.928e-03, -4.311e-03, 1.661e-02, 7.037e-02, 6.701e-05, 2.791e-03, -2.448e-04, 8.622e-04) * s0_2_2;
  r0 += mat4x4<f32>(2.473e-03, 1.688e-04, 6.076e-04, 2.107e-04, 6.776e-01, -3.207e-01, -3.948e-01, -1.762e-02, -1.305e-02, 1.658e-03, 3.043e-03, 1.161e-03, 4.288e-02, 1.121e-03, 3.547e-02, 3.312e-04) * s1_0_0;
  r0 += mat4x4<f32>(1.611e-03, 3.590e-02, 1.813e-02, 1.043e-02, -1.250e-02, 4.802e-03, 7.519e-03, -7.370e-02, 4.907e-02, 3.992e-02, -6.265e-03, -2.309e-03, -1.767e-01, 6.163e-01, -2.640e-01, -2.668e-03) * s1_0_1;
  r0 += mat4x4<f32>(4.046e-03, -3.551e-02, 1.189e-03, 2.776e-04, 6.009e-05, -4.936e-04, -1.673e-04, -7.570e-04, 4.939e-04, 3.102e-02, -6.439e-04, 4.612e-04, 1.237e-02, -8.277e-02, -8.561e-03, -1.073e-01) * s1_0_2;
  r0 += mat4x4<f32>(1.381e-02, 6.220e-03, 7.448e-03, 5.965e-03, -6.904e-03, 1.199e-03, 1.292e-02, -1.011e-01, -5.317e-02, -4.654e-03, -3.493e-02, -4.372e-04, 3.622e-04, -4.991e-04, 3.478e-02, 1.374e-03) * s1_1_0;
  r0 += mat4x4<f32>(-4.287e-01, -1.516e-01, -2.309e-01, 3.710e-02, -2.734e-03, -4.113e-03, -4.476e-03, -3.980e-02, 1.792e-01, -5.059e-01, 4.834e-01, 2.061e-02, 1.111e-02, 1.884e-03, 6.519e-02, 1.851e-01) * s1_1_1;
  r0 += mat4x4<f32>(5.946e-03, -7.980e-02, 8.023e-03, -5.669e-02, -1.352e-04, -1.234e-03, 2.979e-05, -8.102e-04, 3.982e-04, 9.377e-02, -1.470e-03, 1.101e-01, 1.587e-03, 2.382e-03, 1.412e-02, 2.295e-02) * s1_1_2;
  r0 += mat4x4<f32>(9.474e-04, 2.385e-04, 5.123e-03, 2.388e-03, -2.845e-05, -3.780e-06, 3.829e-04, -4.331e-04, 4.010e-03, 9.158e-04, -5.717e-02, -4.495e-03, -1.511e-09, 3.279e-07, -7.790e-05, 1.333e-06) * s1_2_0;
  r0 += mat4x4<f32>(3.589e-03, 7.103e-03, -1.091e-01, -3.753e-02, -1.133e-06, -7.744e-05, 2.463e-04, 1.461e-04, -6.165e-03, 2.632e-03, -1.947e-02, -1.538e-01, 2.204e-05, 8.564e-06, -7.625e-04, 9.649e-05) * s1_2_1;
  r0 += mat4x4<f32>(7.097e-04, -4.438e-03, 6.621e-04, -3.779e-02, -5.328e-08, 1.141e-06, -7.899e-08, 3.284e-05, -1.033e-03, -1.219e-03, -8.548e-03, 5.265e-03, 6.527e-07, 5.636e-05, -1.795e-04, -3.353e-04) * s1_2_2;
  s0_0_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_1 = sample_conv3_vec4(pixel.xy, vec2i(0, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_2 = sample_conv3_vec4(pixel.xy, vec2i(1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_1_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_2_0 = sample_conv3_vec4(pixel.xy, vec2i(-1, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_1 = sample_conv3_vec4(pixel.xy, vec2i(0, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_2 = sample_conv3_vec4(pixel.xy, vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(9.892e-03, 3.307e-03, 4.081e-03, -2.847e-03, -1.413e-02, -1.166e-03, 9.904e-04, -8.748e-04, -7.642e-03, 2.281e-04, -1.446e-02, -8.679e-03, 4.054e-02, -3.649e-02, -1.417e-02, -4.728e-03) * s0_0_0;
  r0 += mat4x4<f32>(-1.361e-01, 1.022e-02, 2.567e-02, 3.283e-02, -7.628e-02, -6.897e-02, -3.096e-03, -1.908e-03, -3.357e-02, 3.973e-03, 3.743e-03, 6.577e-03, -1.645e-03, 3.705e-02, -5.532e-03, 4.438e-04) * s0_0_1;
  r0 += mat4x4<f32>(5.677e-03, -2.132e-02, 4.381e-03, 3.103e-02, 1.940e-04, 3.724e-03, -1.168e-04, -2.697e-03, -3.001e-02, -7.031e-02, 2.111e-02, 6.155e-03, -3.733e-04, -2.736e-03, -1.413e-05, -1.431e-03) * s0_0_2;
  r0 += mat4x4<f32>(-1.418e-02, 9.716e-03, -1.018e-03, 1.490e-02, -4.433e-02, 2.718e-03, -7.056e-02, -3.833e-03, -1.591e-03, -2.485e-04, -1.607e-02, -3.088e-03, -4.830e-01, 2.328e-01, 3.691e-01, 1.952e-02) * s0_1_0;
  r0 += mat4x4<f32>(1.057e+00, 4.298e-02, -6.448e-01, -1.343e-01, 2.542e-01, 2.214e-01, 2.370e-01, -2.799e-01, 2.331e-02, -2.824e-02, -5.553e-02, -1.174e-02, 2.186e-02, -1.685e-01, -1.702e-02, 1.440e-01) * s0_1_1;
  r0 += mat4x4<f32>(-1.265e-02, 3.654e-01, -3.506e-02, -1.267e-01, 1.053e-03, 1.061e-01, 5.046e-03, 1.213e-01, 1.606e-01, 1.877e-01, -1.028e-01, -1.076e-01, -7.882e-04, -2.580e-03, -4.474e-04, -1.439e-03) * s0_1_2;
  r0 += mat4x4<f32>(-1.542e-02, -4.031e-04, -6.525e-03, -2.250e-03, -3.230e-03, 1.566e-04, 3.961e-02, 4.338e-03, 7.764e-04, 5.295e-04, -7.335e-03, 8.814e-05, 2.546e-02, -2.311e-04, -4.908e-02, 5.959e-02) * s0_2_0;
  r0 += mat4x4<f32>(-1.965e-02, -1.732e-02, 2.570e-01, -2.352e-02, -3.292e-03, -2.902e-03, 8.418e-02, 9.922e-02, -6.708e-02, -1.138e-03, -3.354e-02, -2.647e-02, 2.370e-03, 6.271e-03, 4.345e-03, 6.721e-04) * s0_2_1;
  r0 += mat4x4<f32>(-1.872e-01, -2.730e-02, 4.286e-02, 8.333e-02, -2.086e-04, -8.880e-04, -8.076e-04, 2.815e-02, -1.657e-02, -1.066e-01, 1.353e-01, 8.888e-02, -3.005e-04, 2.559e-03, 4.856e-05, 6.482e-04) * s0_2_2;
  r0 += vec4f(1.718e-08, 2.879e-08, 5.555e-09, -1.238e-09);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

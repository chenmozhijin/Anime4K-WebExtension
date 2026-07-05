// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_LUMA: texture_2d<f32>;

fn sample_LUMA_f32(pos: vec2u, offset: vec2i) -> f32 {
  let size = vec2i(textureDimensions(tex_LUMA));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return luma709(textureLoad(tex_LUMA, coord, 0).rgb);
}

@group(0) @binding(1) var linearSampler: sampler;
@group(0) @binding(2) var out_tex: texture_storage_2d<rgba16float, write>;


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_LUMA);
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let outBase = vec2i(pixel.xy) * vec2i(4, 2);

  var s0_0_0: f32;
  var s0_0_1: f32;
  var s0_0_2: f32;
  var s0_1_0: f32;
  var s0_1_1: f32;
  var s0_1_2: f32;
  var s0_2_0: f32;
  var s0_2_1: f32;
  var s0_2_2: f32;
  var r0: vec4f;
  var r1: vec4f;
  var r2: vec4f;
  var r3: vec4f;
  var r4: vec4f;
  var r5: vec4f;
  var r6: vec4f;
  var r7: vec4f;
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  r2 = vec4f(0.0);
  r3 = vec4f(0.0);
  r4 = vec4f(0.0);
  r5 = vec4f(0.0);
  r6 = vec4f(0.0);
  r7 = vec4f(0.0);
  s0_0_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, -1));
  s0_0_1 = sample_LUMA_f32(pixel.xy, vec2i(0, -1));
  s0_0_2 = sample_LUMA_f32(pixel.xy, vec2i(1, -1));
  s0_1_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 0));
  s0_1_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 0));
  s0_1_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 0));
  s0_2_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 1));
  s0_2_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 1));
  s0_2_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 1));
  r0 += vec4f(-1.311e-02, 4.899e-02, -2.872e-02, 1.025e-01) * s0_0_0;
  r1 += vec4f(2.701e-02, 3.629e-01, -3.880e-02, -2.005e-02) * s0_0_0;
  r2 += vec4f(3.196e-01, 3.830e-02, 1.127e-01, 3.503e-01) * s0_0_0;
  r3 += vec4f(-3.970e-02, -1.344e-02, -1.051e-01, -6.514e-03) * s0_0_0;
  r4 += vec4f(3.514e-02, -1.539e-01, 7.631e-03, -1.041e-03) * s0_0_0;
  r5 += vec4f(2.877e-02, -2.035e-01, 6.299e-02, -1.314e-02) * s0_0_0;
  r6 += vec4f(1.066e-01, 4.276e-01, -8.902e-02, 5.562e-02) * s0_0_0;
  r7 += vec4f(-9.284e-02, 1.234e-01, 2.064e-02, -2.588e-02) * s0_0_0;
  r0 += vec4f(-5.205e-02, -5.876e-02, -1.668e-01, -2.779e-02) * s0_0_1;
  r1 += vec4f(-3.169e-02, 2.937e-01, 6.189e-02, -8.127e-02) * s0_0_1;
  r2 += vec4f(-1.976e-02, -1.256e-01, 1.487e-01, -8.018e-02) * s0_0_1;
  r3 += vec4f(-7.826e-02, -2.309e-01, -2.288e-01, -2.895e-02) * s0_0_1;
  r4 += vec4f(7.178e-02, -3.166e+00, -5.667e-04, 2.301e-02) * s0_0_1;
  r5 += vec4f(7.114e-02, 9.482e-03, 2.881e-01, 4.577e-02) * s0_0_1;
  r6 += vec4f(-4.636e-01, -8.728e-02, -3.290e-01, -4.385e-01) * s0_0_1;
  r7 += vec4f(-8.080e-02, 1.183e-02, -1.903e-02, 1.412e-02) * s0_0_1;
  r0 += vec4f(3.400e-03, 1.442e-02, -3.047e-03, -5.645e-02) * s0_0_2;
  r1 += vec4f(7.520e-03, 6.197e-02, -1.827e-02, -8.235e-03) * s0_0_2;
  r2 += vec4f(4.259e-02, 6.155e-02, 1.930e-01, -1.645e-01) * s0_0_2;
  r3 += vec4f(1.401e-01, 2.527e-01, -2.324e-02, 4.896e-02) * s0_0_2;
  r4 += vec4f(1.166e-01, 1.378e-01, 2.867e-04, -1.290e-02) * s0_0_2;
  r5 += vec4f(-1.096e-01, -1.947e-01, -4.852e-02, -2.233e-01) * s0_0_2;
  r6 += vec4f(8.799e-03, 2.598e-01, 3.955e-01, 1.404e-02) * s0_0_2;
  r7 += vec4f(6.848e-02, -1.458e-01, 3.201e-03, 7.879e-03) * s0_0_2;
  r0 += vec4f(-1.754e-03, -4.443e-01, -1.131e-01, -2.735e-01) * s0_1_0;
  r1 += vec4f(6.155e-01, 5.725e-02, 3.122e-01, 1.890e-01) * s0_1_0;
  r2 += vec4f(-4.855e-01, -7.839e-02, -2.881e-01, -3.311e-01) * s0_1_0;
  r3 += vec4f(1.489e-01, 3.008e-02, 8.362e-02, -6.421e-02) * s0_1_0;
  r4 += vec4f(5.873e-04, -6.100e+00, -3.928e-02, -4.491e-01) * s0_1_0;
  r5 += vec4f(-2.355e-02, 1.313e-01, -1.322e-01, 6.872e-03) * s0_1_0;
  r6 += vec4f(-2.858e-01, -2.758e-01, 4.186e-02, -1.646e-02) * s0_1_0;
  r7 += vec4f(3.469e-01, 4.341e-01, 2.115e-01, 3.955e-01) * s0_1_0;
  r0 += vec4f(4.981e-01, 1.059e-01, 5.022e-01, 3.701e-01) * s0_1_1;
  r1 += vec4f(-6.113e-01, -2.587e-01, -3.855e-01, -3.479e-02) * s0_1_1;
  r2 += vec4f(-2.776e-01, -4.527e-01, -2.572e-01, 7.447e-02) * s0_1_1;
  r3 += vec4f(2.868e-01, 3.388e-01, -5.180e-02, -2.787e-01) * s0_1_1;
  r4 += vec4f(-9.930e-02, -1.579e-01, -2.032e-01, -6.032e-02) * s0_1_1;
  r5 += vec4f(3.170e-01, 2.466e-01, 1.191e-01, 4.382e-01) * s0_1_1;
  r6 += vec4f(5.155e-01, -1.382e-01, 8.374e-02, 4.014e-01) * s0_1_1;
  r7 += vec4f(-8.946e-03, -5.291e-03, 8.718e-03, 6.194e-02) * s0_1_1;
  r0 += vec4f(1.422e-03, 1.082e-02, -2.357e-02, -5.543e-02) * s0_1_2;
  r1 += vec4f(2.613e-04, -5.480e-02, 4.938e-02, 7.806e-02) * s0_1_2;
  r2 += vec4f(1.022e-01, 5.603e-01, 1.047e-01, -1.882e-02) * s0_1_2;
  r3 += vec4f(-4.580e-01, -3.311e-01, -2.073e-01, -8.433e-02) * s0_1_2;
  r4 += vec4f(-1.748e+00, 4.061e-03, 2.981e-02, 2.658e-02) * s0_1_2;
  r5 += vec4f(-3.408e-01, 6.838e-03, 6.245e-02, -2.349e-01) * s0_1_2;
  r6 += vec4f(-2.124e-01, 1.348e-01, -1.583e-01, 7.039e-03) * s0_1_2;
  r7 += vec4f(-7.295e-02, -3.477e-01, 3.904e-04, -6.463e-02) * s0_1_2;
  r0 += vec4f(-5.886e-03, 6.473e-02, 6.422e-02, -4.443e-02) * s0_2_0;
  r1 += vec4f(2.388e-03, -1.804e-01, -4.565e-05, 1.225e-01) * s0_2_0;
  r2 += vec4f(1.091e-01, 3.454e-02, 2.239e-03, -1.126e-01) * s0_2_0;
  r3 += vec4f(3.234e-02, -5.372e-02, 3.677e-01, 2.546e-01) * s0_2_0;
  r4 += vec4f(1.517e-02, -1.255e-02, 1.243e-02, 4.385e-01) * s0_2_0;
  r5 += vec4f(2.014e-03, -2.234e-02, -6.009e-02, -1.743e-02) * s0_2_0;
  r6 += vec4f(-6.291e-02, -1.554e-01, -5.031e-02, -3.347e-02) * s0_2_0;
  r7 += vec4f(-6.615e-02, 1.622e-01, 1.330e-03, -7.278e-02) * s0_2_0;
  r0 += vec4f(-2.482e-02, 2.916e-01, -1.811e-01, -5.878e-02) * s0_2_1;
  r1 += vec4f(-4.135e-03, -2.450e-01, 2.278e-02, -8.250e-01) * s0_2_1;
  r2 += vec4f(1.677e-02, -5.504e-02, -1.802e-02, 6.121e-02) * s0_2_1;
  r3 += vec4f(-6.891e-02, -5.532e-05, 1.327e-01, 1.687e-01) * s0_2_1;
  r4 += vec4f(5.463e-02, -8.446e-01, 1.444e-02, 5.267e-02) * s0_2_1;
  r5 += vec4f(-3.956e-01, -6.058e-02, -2.846e-01, 1.185e-02) * s0_2_1;
  r6 += vec4f(1.323e-01, -3.036e-02, -1.803e-02, 2.108e-02) * s0_2_1;
  r7 += vec4f(-1.033e-01, -3.598e-02, -2.484e-02, -3.199e-01) * s0_2_1;
  r0 += vec4f(-1.005e-02, -2.621e-02, -2.399e-02, 3.808e-02) * s0_2_2;
  r1 += vec4f(-1.926e-03, -3.292e-02, -1.103e-02, 6.595e-02) * s0_2_2;
  r2 += vec4f(-1.594e-01, 2.194e-02, 4.655e-03, 2.628e-02) * s0_2_2;
  r3 += vec4f(5.178e-02, 1.229e-02, 3.522e-02, -1.085e-03) * s0_2_2;
  r4 += vec4f(7.840e-02, 7.496e-02, -3.830e-03, -1.805e-02) * s0_2_2;
  r5 += vec4f(4.449e-01, -9.260e-02, -8.821e-03, -7.016e-03) * s0_2_2;
  r6 += vec4f(-8.711e-02, 1.584e-01, 1.732e-02, -1.105e-02) * s0_2_2;
  r7 += vec4f(-8.754e-02, -1.910e-01, 1.290e-02, 8.062e-03) * s0_2_2;
  r0 += vec4f(-1.084e-02, 1.081e-02, 6.454e-03, 2.561e-02);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(5.666e-03, 3.852e-03, 3.239e-02, 2.603e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-7.807e-02, 1.229e-02, 4.926e-03, -6.119e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r2);
  r3 += vec4f(-7.613e-02, 5.927e-03, 7.831e-03, 1.507e-02);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r3);
  r4 += vec4f(4.433e-02, 6.881e-02, 7.382e-02, -9.239e-03);
  r4 = clamp(r4, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r4);
  r5 += vec4f(-7.517e-03, -8.460e-03, 1.385e-02, 1.164e-02);
  r5 = clamp(r5, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 0), r5);
  r6 += vec4f(-9.373e-09, -3.838e-01, -5.955e-03, 2.448e-02);
  r6 = clamp(r6, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 1), r6);
  r7 += vec4f(-4.654e-04, 4.624e-03, -1.333e-01, 1.224e-02);
  r7 = clamp(r7, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 1), r7);
}

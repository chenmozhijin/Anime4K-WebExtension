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

  let outBase = vec2i(pixel.xy) * vec2i(3, 2);

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
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  r2 = vec4f(0.0);
  r3 = vec4f(0.0);
  r4 = vec4f(0.0);
  r5 = vec4f(0.0);
  s0_0_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, -1));
  s0_0_1 = sample_LUMA_f32(pixel.xy, vec2i(0, -1));
  s0_0_2 = sample_LUMA_f32(pixel.xy, vec2i(1, -1));
  s0_1_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 0));
  s0_1_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 0));
  s0_1_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 0));
  s0_2_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 1));
  s0_2_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 1));
  s0_2_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 1));
  r0 += vec4f(1.800e-02, -9.556e-04, 4.619e-04, 3.781e-02) * s0_0_0;
  r1 += vec4f(-5.641e-02, -5.539e-02, -2.122e-02, -3.967e-01) * s0_0_0;
  r2 += vec4f(-9.497e-02, -4.838e-01, -4.203e-01, -5.976e-01) * s0_0_0;
  r3 += vec4f(5.872e-02, 1.057e-01, 4.177e-02, 1.080e-01) * s0_0_0;
  r4 += vec4f(-3.641e-04, 1.598e-02, 1.859e-02, -5.774e-02) * s0_0_0;
  r5 += vec4f(1.285e-03, -2.192e-03, -1.070e-02, 4.598e-02) * s0_0_0;
  r0 += vec4f(9.665e-03, 3.110e-03, -1.707e-02, -1.043e-02) * s0_0_1;
  r1 += vec4f(6.514e-02, 2.236e-01, 3.884e-01, 6.087e-01) * s0_0_1;
  r2 += vec4f(-1.181e-01, -2.069e-02, -4.929e-02, -3.162e-02) * s0_0_1;
  r3 += vec4f(6.519e-01, 6.777e-01, 4.144e-01, 7.045e-01) * s0_0_1;
  r4 += vec4f(-1.880e-01, -3.761e-02, -3.920e-02, 1.398e-02) * s0_0_1;
  r5 += vec4f(6.653e-03, -4.814e-03, -2.340e-02, -2.085e-02) * s0_0_1;
  r0 += vec4f(5.163e-02, -3.595e-03, 1.934e-02, -3.472e-02) * s0_0_2;
  r1 += vec4f(-1.657e-02, -1.473e-01, -4.358e-02, -2.085e-01) * s0_0_2;
  r2 += vec4f(-4.548e-02, 5.526e-02, 1.415e-03, -5.515e-03) * s0_0_2;
  r3 += vec4f(7.526e-02, 7.398e-02, 3.484e-02, 7.062e-02) * s0_0_2;
  r4 += vec4f(2.408e-02, 1.752e-02, 6.944e-03, 4.033e-02) * s0_0_2;
  r5 += vec4f(-4.888e-03, 8.054e-03, 3.470e-02, -6.227e-04) * s0_0_2;
  r0 += vec4f(2.400e-02, -1.832e-03, 1.201e-02, 3.403e-01) * s0_1_0;
  r1 += vec4f(6.092e-02, -1.685e-01, 1.263e-02, 3.409e-01) * s0_1_0;
  r2 += vec4f(-1.368e-01, -5.799e-02, -1.519e-01, -5.007e-03) * s0_1_0;
  r3 += vec4f(-5.839e-02, -7.105e-02, -2.902e-02, -5.847e-02) * s0_1_0;
  r4 += vec4f(-1.224e-02, -3.887e-02, -4.216e-02, -3.699e-01) * s0_1_0;
  r5 += vec4f(2.226e-02, 7.366e-01, 5.063e-01, 6.279e-01) * s0_1_0;
  r0 += vec4f(3.140e-02, -1.952e-02, -1.900e-01, -6.288e-02) * s0_1_1;
  r1 += vec4f(4.419e-01, 2.968e-01, 2.714e-01, -3.957e-01) * s0_1_1;
  r2 += vec4f(7.313e-01, 3.738e-01, 3.643e-01, 6.224e-01) * s0_1_1;
  r3 += vec4f(-6.511e-01, -2.398e-01, -4.209e-01, -2.303e-01) * s0_1_1;
  r4 += vec4f(-2.640e-01, -7.598e-01, -6.660e-01, -1.082e-01) * s0_1_1;
  r5 += vec4f(-2.582e-01, -7.207e-01, -5.371e-01, 8.053e-02) * s0_1_1;
  r0 += vec4f(7.761e-02, -6.399e-01, -2.528e-01, -4.345e-01) * s0_1_2;
  r1 += vec4f(-4.503e-01, -1.606e-01, -3.750e-01, 1.019e-01) * s0_1_2;
  r2 += vec4f(5.146e-02, 8.485e-02, -4.831e-02, 1.850e-02) * s0_1_2;
  r3 += vec4f(-6.894e-02, -5.580e-02, -5.642e-02, -6.322e-02) * s0_1_2;
  r4 += vec4f(4.269e-01, 7.967e-01, 7.380e-01, 5.333e-01) * s0_1_2;
  r5 += vec4f(2.952e-02, -2.101e-02, 4.166e-02, 1.130e-02) * s0_1_2;
  r0 += vec4f(3.282e-02, 2.965e-03, -9.623e-03, 1.610e-01) * s0_2_0;
  r1 += vec4f(-3.576e-02, -1.296e-01, 4.789e-03, -2.903e-02) * s0_2_0;
  r2 += vec4f(-1.863e-01, 1.980e-02, 3.746e-02, 1.466e-03) * s0_2_0;
  r3 += vec4f(3.162e-03, -2.554e-02, -6.777e-03, -4.885e-02) * s0_2_0;
  r4 += vec4f(2.804e-02, 7.517e-03, 1.873e-02, -1.501e-01) * s0_2_0;
  r5 += vec4f(-9.334e-03, 2.145e-02, -5.449e-01, 7.580e-02) * s0_2_0;
  r0 += vec4f(4.791e-02, 6.581e-01, 3.753e-01, 2.115e-01) * s0_2_1;
  r1 += vec4f(5.333e-02, 1.090e-01, -7.342e-02, 3.909e-02) * s0_2_1;
  r2 += vec4f(-9.893e-02, 7.774e-02, -9.740e-02, 9.212e-03) * s0_2_1;
  r3 += vec4f(-3.469e-05, -4.602e-01, 4.209e-03, -4.630e-01) * s0_2_1;
  r4 += vec4f(3.967e-02, -5.522e-02, -2.564e-02, -5.826e-02) * s0_2_1;
  r5 += vec4f(2.501e-02, -2.694e-02, 6.014e-01, -2.860e-02) * s0_2_1;
  r0 += vec4f(-4.004e+00, 4.233e-03, -1.208e-01, -2.084e-01) * s0_2_2;
  r1 += vec4f(-2.270e-02, 8.051e-03, -1.636e-01, -2.731e-02) * s0_2_2;
  r2 += vec4f(-9.351e-02, -5.327e-02, 3.702e-02, -1.113e-02) * s0_2_2;
  r3 += vec4f(-6.967e-03, -1.030e-02, 1.959e-02, -1.670e-02) * s0_2_2;
  r4 += vec4f(-2.470e-02, 5.183e-02, -4.114e-03, 1.549e-01) * s0_2_2;
  r5 += vec4f(-1.383e-02, 6.880e-03, -7.173e-02, 6.890e-03) * s0_2_2;
  r0 += vec4f(4.657e-02, 8.881e-05, -6.267e-03, 1.333e-02);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(1.722e-02, 2.403e-03, 3.720e-03, -3.403e-02);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(1.900e-02, -1.762e-02, 2.392e-03, 4.353e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
  r3 += vec4f(3.989e-03, -1.402e-02, 3.308e-02, 1.365e-02);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r3);
  r4 += vec4f(1.663e-02, -1.403e-02, 6.873e-03, 1.438e-02);
  r4 = clamp(r4, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r4);
  r5 += vec4f(1.111e-01, 2.506e-03, -4.079e-03, -6.913e-01);
  r5 = clamp(r5, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 1), r5);
}

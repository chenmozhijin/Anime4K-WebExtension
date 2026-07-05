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
  r0 += vec4f(-1.341e-01, -2.212e-02, 5.502e-03, -1.876e-02) * s0_0_0;
  r1 += vec4f(-1.082e-02, -3.419e-03, -5.775e-02, -4.400e-01) * s0_0_0;
  r2 += vec4f(2.803e-01, 1.593e-02, 6.870e-01, -8.431e-03) * s0_0_0;
  r3 += vec4f(-2.228e-02, 3.899e-03, -6.244e-02, -2.446e-02) * s0_0_0;
  r4 += vec4f(3.268e-02, 6.687e-01, 6.798e-02, 2.246e-01) * s0_0_0;
  r5 += vec4f(5.847e-02, -1.837e-02, -1.409e-01, -9.269e-03) * s0_0_0;
  r6 += vec4f(-4.369e-03, -2.871e-02, -4.038e-03, -2.685e-02) * s0_0_0;
  r7 += vec4f(-7.070e-05, -4.387e-02, 4.090e-02, -4.811e-02) * s0_0_0;
  r0 += vec4f(3.894e-02, 2.871e-03, -2.290e-02, 1.555e-02) * s0_0_1;
  r1 += vec4f(-6.621e-01, -2.270e-01, -4.089e-01, 1.513e-03) * s0_0_1;
  r2 += vec4f(-1.619e-01, 1.188e-02, -6.855e-01, -4.486e-02) * s0_0_1;
  r3 += vec4f(5.960e-03, -7.705e-03, 3.271e-01, -1.917e-02) * s0_0_1;
  r4 += vec4f(-4.795e-02, 1.848e-02, -8.355e-02, 8.536e-02) * s0_0_1;
  r5 += vec4f(6.052e-01, -4.397e-02, 2.982e-01, 3.315e-03) * s0_0_1;
  r6 += vec4f(-4.480e-02, 6.159e-03, -1.244e-02, -9.557e-02) * s0_0_1;
  r7 += vec4f(3.995e-04, -1.795e-01, 1.271e-02, 3.007e-02) * s0_0_1;
  r0 += vec4f(-5.955e-03, 3.323e-02, 2.842e-02, -2.115e-03) * s0_0_2;
  r1 += vec4f(-1.256e-02, -5.444e-02, -2.655e-02, 2.274e-03) * s0_0_2;
  r2 += vec4f(-1.343e-01, 2.430e-03, -4.977e-03, 3.986e-02) * s0_0_2;
  r3 += vec4f(-8.636e-02, 1.405e-03, -1.576e-01, -2.517e-02) * s0_0_2;
  r4 += vec4f(2.029e-01, -2.382e-02, 1.346e-04, -2.098e-02) * s0_0_2;
  r5 += vec4f(7.400e-02, 2.668e-01, 1.815e-02, 9.100e-01) * s0_0_2;
  r6 += vec4f(-1.817e-01, 7.790e-03, 1.536e-02, 1.278e-01) * s0_0_2;
  r7 += vec4f(-1.338e-03, -2.087e-02, 4.538e-02, 6.372e-02) * s0_0_2;
  r0 += vec4f(2.939e-01, -1.748e-02, 1.145e-01, 5.319e-01) * s0_1_0;
  r1 += vec4f(9.096e-03, -5.286e-02, -2.920e-03, -2.717e-03) * s0_1_0;
  r2 += vec4f(-1.494e-01, -1.720e-01, 1.024e-02, 1.656e-01) * s0_1_0;
  r3 += vec4f(-1.016e-01, -1.891e-02, -4.727e-02, -1.109e-02) * s0_1_0;
  r4 += vec4f(1.143e-01, 3.733e-02, 5.488e-01, 1.834e-01) * s0_1_0;
  r5 += vec4f(-7.206e-02, -5.411e-02, -6.375e-02, -7.585e-03) * s0_1_0;
  r6 += vec4f(5.104e-02, -4.189e-01, -1.323e-02, 1.146e-02) * s0_1_0;
  r7 += vec4f(5.484e-03, -2.202e-01, -7.666e-03, -1.690e-02) * s0_1_0;
  r0 += vec4f(-1.098e-01, 2.427e-01, 9.564e-02, -5.047e-01) * s0_1_1;
  r1 += vec4f(6.601e-01, 2.591e-01, 4.755e-01, 4.412e-01) * s0_1_1;
  r2 += vec4f(-2.124e-01, -3.383e-01, -1.259e-02, -3.271e-01) * s0_1_1;
  r3 += vec4f(4.092e-01, 4.930e-01, -1.246e-01, 6.263e-01) * s0_1_1;
  r4 += vec4f(-1.175e-01, -7.447e-02, -5.198e-01, -6.936e-02) * s0_1_1;
  r5 += vec4f(-5.453e-01, -4.919e-01, -4.593e-01, -9.868e-03) * s0_1_1;
  r6 += vec4f(4.031e-01, -8.208e-02, 1.666e-01, 9.313e-02) * s0_1_1;
  r7 += vec4f(-1.124e-02, 2.939e-01, -8.853e+00, 2.436e-01) * s0_1_1;
  r0 += vec4f(5.433e-02, -8.913e-02, -7.004e-02, -2.276e-02) * s0_1_2;
  r1 += vec4f(1.547e-02, 9.046e-02, 3.058e-02, -1.630e-03) * s0_1_2;
  r2 += vec4f(2.978e-01, 1.438e-01, 4.540e-03, -1.009e-02) * s0_1_2;
  r3 += vec4f(-1.200e-01, -1.680e-02, 7.441e-02, -1.050e-02) * s0_1_2;
  r4 += vec4f(-4.322e-01, -2.009e-02, -1.098e-02, -2.126e-01) * s0_1_2;
  r5 += vec4f(-7.940e-02, 4.189e-01, 2.939e-01, 8.211e-03) * s0_1_2;
  r6 += vec4f(-2.156e-01, -2.732e-02, -2.671e-02, -1.632e-01) * s0_1_2;
  r7 += vec4f(6.356e-03, 4.057e-02, 3.750e-02, -2.754e-01) * s0_1_2;
  r0 += vec4f(-2.558e-01, 3.890e-02, -3.524e-01, -7.172e-01) * s0_2_0;
  r1 += vec4f(2.247e-03, 6.047e-02, 2.219e-02, -7.110e-04) * s0_2_0;
  r2 += vec4f(-1.457e-01, 1.007e-01, -9.047e-04, 1.685e-01) * s0_2_0;
  r3 += vec4f(-7.423e-02, 6.121e-03, 1.108e-01, -1.391e-02) * s0_2_0;
  r4 += vec4f(1.992e-02, -1.294e-02, 3.080e-02, 6.894e-02) * s0_2_0;
  r5 += vec4f(1.011e-02, 2.439e-02, 2.239e-01, 4.159e-03) * s0_2_0;
  r6 += vec4f(-2.777e-01, 4.659e-01, 1.395e-02, -2.495e-02) * s0_2_0;
  r7 += vec4f(-7.801e-03, -7.840e-02, 4.048e-02, 1.812e-01) * s0_2_0;
  r0 += vec4f(8.287e-02, -5.057e-02, 1.362e-01, 4.208e-02) * s0_2_1;
  r1 += vec4f(3.211e-03, -9.007e-02, -2.222e-02, 1.759e-03) * s0_2_1;
  r2 += vec4f(3.471e-01, 1.570e-01, 1.814e-04, 2.449e-02) * s0_2_1;
  r3 += vec4f(2.801e-02, -4.712e-01, -1.846e-01, -1.580e-02) * s0_2_1;
  r4 += vec4f(-7.382e-03, -6.569e-03, -2.737e-02, -1.681e-01) * s0_2_1;
  r5 += vec4f(-5.005e-02, -1.494e-01, 3.908e-02, -6.590e-03) * s0_2_1;
  r6 += vec4f(-1.645e-01, 5.927e-02, -1.825e-02, -7.957e-03) * s0_2_1;
  r7 += vec4f(-6.504e-01, 3.999e-03, 3.625e-02, -4.504e-01) * s0_2_1;
  r0 += vec4f(-6.221e-02, -1.680e-01, 4.262e-02, -8.093e-03) * s0_2_2;
  r1 += vec4f(-5.363e-03, -2.075e-02, -4.909e-03, -1.096e-03) * s0_2_2;
  r2 += vec4f(-1.273e-01, -5.301e-03, -3.420e-04, -7.017e-03) * s0_2_2;
  r3 += vec4f(-4.017e-02, 1.351e-02, 3.218e-02, -2.622e-02) * s0_2_2;
  r4 += vec4f(-5.506e-02, 1.985e-02, -3.702e-03, -8.958e-02) * s0_2_2;
  r5 += vec4f(1.645e-03, 5.099e-02, -2.143e-01, -3.835e-03) * s0_2_2;
  r6 += vec4f(1.550e-03, 1.640e-02, 1.045e-02, 2.637e-02) * s0_2_2;
  r7 += vec4f(6.554e-01, 1.114e-02, 2.568e-02, 2.705e-01) * s0_2_2;
  r0 += vec4f(-5.369e-03, -1.332e-02, -1.140e-02, 1.724e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(5.821e-04, -1.295e-02, 1.377e-02, 4.321e-04);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-3.855e-03, -1.442e-02, 1.636e-04, -5.371e-02);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r2);
  r3 += vec4f(1.330e-04, 7.092e-03, -1.518e-02, -6.870e-01);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r3);
  r4 += vec4f(5.056e-03, -5.970e-01, 7.606e-03, 4.716e-03);
  r4 = clamp(r4, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r4);
  r5 += vec4f(3.433e-03, 7.249e-03, -5.267e-03, -8.769e-01);
  r5 = clamp(r5, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 0), r5);
  r6 += vec4f(-6.681e-03, 3.012e-03, -8.412e-02, 3.191e-02);
  r6 = clamp(r6, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 1), r6);
  r7 += vec4f(6.064e-04, -7.925e-04, 1.970e-02, -2.064e-02);
  r7 = clamp(r7, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 1), r7);
}

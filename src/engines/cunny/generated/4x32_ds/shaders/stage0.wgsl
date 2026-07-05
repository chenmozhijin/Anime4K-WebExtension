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
  r0 += vec4f(1.716e-02, 3.114e-02, 2.006e-03, 4.595e-01) * s0_0_0;
  r1 += vec4f(-1.695e-01, 4.963e-03, -8.582e-03, 1.909e-01) * s0_0_0;
  r2 += vec4f(1.020e-01, 7.901e-03, 3.106e-02, 7.357e-02) * s0_0_0;
  r3 += vec4f(4.919e-02, 4.054e-02, 1.271e-03, -2.155e-02) * s0_0_0;
  r4 += vec4f(5.812e-03, -1.207e-02, -4.118e-02, 2.046e-01) * s0_0_0;
  r5 += vec4f(-5.937e-02, 2.945e-02, 2.143e-01, 2.982e-01) * s0_0_0;
  r6 += vec4f(4.730e-02, -1.122e-01, -1.519e-01, -1.822e-04) * s0_0_0;
  r7 += vec4f(1.259e-02, -9.426e-02, 3.123e-02, -1.230e-02) * s0_0_0;
  r0 += vec4f(-2.795e-02, -6.221e-02, -1.413e-02, -2.611e-01) * s0_0_1;
  r1 += vec4f(5.723e-01, 3.803e-01, 4.248e-01, 2.494e-01) * s0_0_1;
  r2 += vec4f(-2.278e-02, 6.312e-01, 2.966e-01, 3.711e-01) * s0_0_1;
  r3 += vec4f(-5.671e-02, -2.242e-02, 4.807e-03, 5.848e-02) * s0_0_1;
  r4 += vec4f(3.501e-02, 4.060e-03, -3.975e-01, -2.744e-01) * s0_0_1;
  r5 += vec4f(1.101e-01, -4.041e-02, 4.569e-01, -8.934e-04) * s0_0_1;
  r6 += vec4f(-8.164e-02, -1.766e-01, 1.343e-01, 8.471e-04) * s0_0_1;
  r7 += vec4f(-4.120e-02, 1.241e-01, -1.698e-01, 3.284e-03) * s0_0_1;
  r0 += vec4f(-4.846e-02, 2.228e-02, 1.715e-02, -2.124e-01) * s0_0_2;
  r1 += vec4f(-3.944e-02, 1.004e-01, -1.122e-02, -2.536e-01) * s0_0_2;
  r2 += vec4f(3.800e-02, -2.592e-03, 1.649e-01, 9.030e-02) * s0_0_2;
  r3 += vec4f(2.333e-03, -1.118e-02, -8.854e-03, -7.420e-02) * s0_0_2;
  r4 += vec4f(-6.513e-02, 6.642e-03, 4.376e-01, 6.569e-02) * s0_0_2;
  r5 += vec4f(-4.640e-02, 1.298e-02, 2.625e-02, -6.132e-02) * s0_0_2;
  r6 += vec4f(4.358e-02, -2.165e-02, -3.500e-02, -1.753e-03) * s0_0_2;
  r7 += vec4f(2.870e-02, 5.053e-02, 1.002e-01, 8.230e-01) * s0_0_2;
  r0 += vec4f(-7.436e-02, 5.684e-01, 2.321e-01, -3.811e-01) * s0_1_0;
  r1 += vec4f(-1.051e-01, 1.839e-02, 1.323e-02, -1.233e-01) * s0_1_0;
  r2 += vec4f(-1.546e-01, -6.340e-01, -2.979e-01, 1.332e-03) * s0_1_0;
  r3 += vec4f(3.410e-01, 1.411e-01, 1.589e-03, 2.217e-01) * s0_1_0;
  r4 += vec4f(-8.839e-03, -5.350e-01, 2.360e-02, -3.542e-02) * s0_1_0;
  r5 += vec4f(1.337e-01, -6.803e-02, -2.114e-01, -4.069e-02) * s0_1_0;
  r6 += vec4f(-6.685e-02, -1.592e-01, -3.852e-02, 2.213e-05) * s0_1_0;
  r7 += vec4f(-3.992e-02, -2.378e-01, -6.008e-02, 3.774e-03) * s0_1_0;
  r0 += vec4f(5.629e-01, -4.984e-01, 1.160e-02, 3.410e-01) * s0_1_1;
  r1 += vec4f(-1.492e-01, 1.054e-01, 4.125e-02, -1.323e-01) * s0_1_1;
  r2 += vec4f(1.265e-01, -4.492e-03, 1.428e-02, 3.554e-02) * s0_1_1;
  r3 += vec4f(-2.519e-01, -6.911e-01, -2.532e-02, -3.416e-01) * s0_1_1;
  r4 += vec4f(-2.109e-02, 3.012e-03, -3.139e-01, -2.622e-01) * s0_1_1;
  r5 += vec4f(-3.143e-01, -4.829e-01, -4.446e-01, -4.836e-01) * s0_1_1;
  r6 += vec4f(-3.752e-01, -5.236e-02, -3.135e-01, -6.081e-01) * s0_1_1;
  r7 += vec4f(-5.645e-01, -1.540e-01, -4.984e-01, -2.441e-02) * s0_1_1;
  r0 += vec4f(2.529e-02, -2.620e-02, -2.914e-02, 8.133e-02) * s0_1_2;
  r1 += vec4f(-9.575e-02, -1.335e-01, -4.596e-01, 1.834e-02) * s0_1_2;
  r2 += vec4f(-3.365e-02, 5.157e-04, 2.141e-01, -1.065e-02) * s0_1_2;
  r3 += vec4f(-2.803e-01, 2.443e-02, -6.270e-01, -2.510e-01) * s0_1_2;
  r4 += vec4f(4.132e-01, 5.371e-01, 2.948e-01, 3.096e-01) * s0_1_2;
  r5 += vec4f(8.326e-02, -2.241e-02, -3.456e-02, 4.101e-02) * s0_1_2;
  r6 += vec4f(3.293e-02, 1.698e-02, 4.429e-02, 9.248e-03) * s0_1_2;
  r7 += vec4f(6.094e-01, 3.207e-01, 2.369e-01, 9.970e-03) * s0_1_2;
  r0 += vec4f(4.595e-02, 5.593e-03, -2.313e-02, -1.014e-01) * s0_2_0;
  r1 += vec4f(-2.007e-03, -2.151e-02, 1.764e-03, -9.357e-02) * s0_2_0;
  r2 += vec4f(-3.706e+00, 1.733e-03, -1.197e-01, -7.738e-02) * s0_2_0;
  r3 += vec4f(3.714e-01, 1.317e-01, -2.187e-03, 2.357e-01) * s0_2_0;
  r4 += vec4f(-5.179e-03, -2.104e-02, 9.146e-03, -1.751e-01) * s0_2_0;
  r5 += vec4f(-6.623e-02, 1.710e-02, 2.899e-03, -2.145e-01) * s0_2_0;
  r6 += vec4f(1.692e-02, -9.349e-03, -1.352e-02, 3.755e-04) * s0_2_0;
  r7 += vec4f(3.703e-02, 3.641e-01, 4.461e-02, 9.491e-04) * s0_2_0;
  r0 += vec4f(-5.098e-01, -3.918e-02, 1.220e-03, -3.820e-02) * s0_2_1;
  r1 += vec4f(-3.258e-03, -7.447e-02, -9.691e-03, -3.997e-02) * s0_2_1;
  r2 += vec4f(2.901e-02, -5.108e-03, -2.689e-01, -4.385e-01) * s0_2_1;
  r3 += vec4f(-6.423e-02, 1.111e-01, 2.720e-02, 1.287e-01) * s0_2_1;
  r4 += vec4f(-6.119e-02, 2.474e-02, -2.313e-02, 5.449e-01) * s0_2_1;
  r5 += vec4f(1.179e-01, 5.605e-01, -1.161e-02, 3.320e-01) * s0_2_1;
  r6 += vec4f(5.127e-02, 8.007e-02, 1.238e-01, -8.312e-03) * s0_2_1;
  r7 += vec4f(-4.132e-02, -3.076e-01, 1.605e-01, -3.267e-04) * s0_2_1;
  r0 += vec4f(9.292e-03, -3.040e-04, 1.363e-02, 1.100e-01) * s0_2_2;
  r1 += vec4f(-3.771e-03, -3.803e-01, 5.290e-03, 1.929e-01) * s0_2_2;
  r2 += vec4f(7.011e-02, 2.123e-03, -3.299e-02, -4.746e-02) * s0_2_2;
  r3 += vec4f(-1.085e-01, 1.976e-02, 6.303e-01, 4.763e-02) * s0_2_2;
  r4 += vec4f(-3.083e-01, -9.208e-03, 1.163e-02, -3.784e-01) * s0_2_2;
  r5 += vec4f(-5.616e-02, 8.636e-04, 4.686e-03, 1.305e-01) * s0_2_2;
  r6 += vec4f(3.304e-01, 4.370e-01, 2.512e-01, 6.106e-01) * s0_2_2;
  r7 += vec4f(7.945e-03, -6.946e-02, 1.204e-01, -1.154e-02) * s0_2_2;
  r0 += vec4f(7.267e-03, 1.350e-02, -1.227e-01, -3.158e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(1.212e-02, 8.083e-03, -9.242e-03, 6.418e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(3.675e-02, 2.454e-05, 8.853e-03, -7.821e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r2);
  r3 += vec4f(-2.968e-03, 2.373e-03, 4.447e-04, 9.035e-03);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r3);
  r4 += vec4f(-2.159e-02, 6.508e-05, 5.349e-03, -4.646e-03);
  r4 = clamp(r4, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r4);
  r5 += vec4f(1.074e-01, 1.351e-02, 1.094e-02, -1.068e-02);
  r5 = clamp(r5, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 0), r5);
  r6 += vec4f(2.702e-02, 1.939e-03, 5.153e-03, 1.159e-05);
  r6 = clamp(r6, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 1), r6);
  r7 += vec4f(1.770e-02, -1.734e-02, -1.911e-02, -7.740e-01);
  r7 = clamp(r7, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(3, 1), r7);
}

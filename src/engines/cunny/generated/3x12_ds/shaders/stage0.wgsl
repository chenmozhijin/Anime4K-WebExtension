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

  let outBase = vec2i(pixel.xy) * vec2i(3, 1);

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
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  r2 = vec4f(0.0);
  s0_0_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, -1));
  s0_0_1 = sample_LUMA_f32(pixel.xy, vec2i(0, -1));
  s0_0_2 = sample_LUMA_f32(pixel.xy, vec2i(1, -1));
  s0_1_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 0));
  s0_1_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 0));
  s0_1_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 0));
  s0_2_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 1));
  s0_2_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 1));
  s0_2_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 1));
  r0 += vec4f(1.678e-01, 1.604e-02, -1.335e-01, -1.412e-01) * s0_0_0;
  r1 += vec4f(3.048e-03, 2.490e-01, 7.037e-01, 1.393e-01) * s0_0_0;
  r2 += vec4f(-2.513e-02, 5.565e-02, -4.521e-01, -1.128e-01) * s0_0_0;
  r0 += vec4f(-2.459e-01, -1.631e-01, -7.604e-01, 1.907e-01) * s0_0_1;
  r1 += vec4f(9.485e-01, 1.525e-01, 6.440e-02, 4.822e-01) * s0_0_1;
  r2 += vec4f(2.451e-03, 9.345e-01, -2.703e-01, 1.168e-01) * s0_0_1;
  r0 += vec4f(4.524e-02, 1.343e-02, 5.090e-02, -3.698e-02) * s0_0_2;
  r1 += vec4f(1.596e-03, 2.291e-02, -1.665e-02, 2.847e-01) * s0_0_2;
  r2 += vec4f(-1.470e-02, 6.811e-02, 6.616e-03, -3.255e-02) * s0_0_2;
  r0 += vec4f(7.864e-01, 3.347e-01, 9.085e-01, 4.008e-02) * s0_1_0;
  r1 += vec4f(-2.224e-02, -8.055e-02, 1.450e-01, -1.462e-02) * s0_1_0;
  r2 += vec4f(1.284e-01, -3.005e-01, -2.764e-01, -8.187e-01) * s0_1_0;
  r0 += vec4f(-6.699e-01, -2.131e-01, -2.456e-02, -3.329e-01) * s0_1_1;
  r1 += vec4f(-9.199e-01, -9.877e-01, -8.485e-01, -9.486e-01) * s0_1_1;
  r2 += vec4f(3.352e-01, -5.996e-01, 9.794e-01, 8.613e-01) * s0_1_1;
  r0 += vec4f(-8.619e-02, -6.088e-03, -4.200e-02, 8.447e-02) * s0_1_2;
  r1 += vec4f(-1.112e-02, 1.299e-01, -4.221e-02, 1.054e-02) * s0_1_2;
  r2 += vec4f(-1.845e-01, -1.158e-01, 2.289e-02, 1.642e-02) * s0_1_2;
  r0 += vec4f(7.534e-02, -3.221e-02, -5.311e-02, -2.348e-03) * s0_2_0;
  r1 += vec4f(2.002e-02, 3.208e-02, -2.445e-02, 1.234e-01) * s0_2_0;
  r2 += vec4f(-5.716e-02, 1.075e-02, 3.455e-02, -7.073e-02) * s0_2_0;
  r0 += vec4f(-6.689e-02, 6.796e-02, 6.740e-02, 1.433e-02) * s0_2_1;
  r1 += vec4f(-2.959e-02, -3.576e-02, -4.847e-02, -1.231e-01) * s0_2_1;
  r2 += vec4f(-3.316e-02, -5.719e-02, 8.220e-03, 2.205e-02) * s0_2_1;
  r0 += vec4f(-9.039e-03, 6.588e-03, -1.251e-02, -1.546e-02) * s0_2_2;
  r1 += vec4f(1.093e-02, 1.360e-01, 6.161e-02, 1.319e-02) * s0_2_2;
  r2 += vec4f(-8.948e-02, 5.146e-03, -5.310e-02, 1.393e-02) * s0_2_2;
  r0 += vec4f(2.032e-02, 5.188e-02, -2.736e-04, 2.116e-01);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-1.868e-03, 2.315e-03, -2.456e-03, -1.397e-02);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(3.198e-03, 2.130e-02, -7.639e-03, 2.031e-02);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

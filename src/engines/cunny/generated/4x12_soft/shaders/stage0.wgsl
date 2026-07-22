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
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
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
  r0 += vec4f(2.322e-02, -1.334e-02, -3.813e-01, 7.910e-03) * s0_0_0;
  r1 += vec4f(5.275e-01, 4.515e-03, -1.155e-02, -1.005e-02) * s0_0_0;
  r2 += vec4f(6.457e-03, -2.327e-01, 1.199e-02, 8.356e-03) * s0_0_0;
  r0 += vec4f(-2.629e-02, 9.310e-03, 2.420e-01, 2.029e-02) * s0_0_1;
  r1 += vec4f(-5.410e-01, -2.006e-02, -2.862e-02, 1.862e-02) * s0_0_1;
  r2 += vec4f(9.178e-01, 4.564e-01, 9.718e-01, 5.527e-01) * s0_0_1;
  r0 += vec4f(-5.596e-03, -2.557e-03, 9.555e-02, -3.055e-02) * s0_0_2;
  r1 += vec4f(3.034e-02, 4.269e-03, 6.556e-02, -3.897e-02) * s0_0_2;
  r2 += vec4f(-9.238e-01, -1.487e-02, 2.676e-02, -1.692e-02) * s0_0_2;
  r0 += vec4f(-2.434e-02, -8.784e-01, 1.569e-01, -2.853e-02) * s0_1_0;
  r1 += vec4f(-5.235e-01, -3.186e-02, 2.751e-02, -1.664e-02) * s0_1_0;
  r2 += vec4f(-1.066e-02, -8.471e-02, -1.319e-02, -2.474e-03) * s0_1_0;
  r0 += vec4f(5.137e-01, 8.809e-01, -2.154e-01, 6.148e-01) * s0_1_1;
  r1 += vec4f(2.204e-01, -9.160e-01, -1.003e+00, -1.794e-01) * s0_1_1;
  r2 += vec4f(4.694e-02, -2.050e-02, -9.473e-01, -5.840e-01) * s0_1_1;
  r0 += vec4f(-7.205e-03, 2.723e-03, 6.471e-02, -2.853e-01) * s0_1_2;
  r1 += vec4f(2.836e-01, -2.596e-02, 4.541e-01, -3.645e-02) * s0_1_2;
  r2 += vec4f(-3.672e-02, -5.897e-02, -4.198e-02, -5.657e-02) * s0_1_2;
  r0 += vec4f(-3.135e-02, -9.858e-03, 1.565e-01, 4.558e-03) * s0_2_0;
  r1 += vec4f(1.898e-02, 2.736e-02, 4.620e-03, 2.843e-02) * s0_2_0;
  r2 += vec4f(4.234e-03, -4.465e-03, 2.688e-03, 4.187e-02) * s0_2_0;
  r0 += vec4f(-4.582e-01, 9.960e-03, -1.802e-01, -1.242e-01) * s0_2_1;
  r1 += vec4f(3.098e-01, 9.331e-01, 1.831e-01, 5.111e-01) * s0_2_1;
  r2 += vec4f(-1.963e-03, 5.862e-02, -2.674e-02, -2.304e-02) * s0_2_1;
  r0 += vec4f(-6.111e-02, -5.471e-05, 1.940e-02, -7.496e-02) * s0_2_2;
  r1 += vec4f(-3.271e-01, 2.240e-02, 1.412e-01, -3.351e-01) * s0_2_2;
  r2 += vec4f(-3.684e-03, -4.067e-02, 1.415e-02, -1.691e-02) * s0_2_2;
  r0 += vec4f(-2.169e-03, -2.010e-07, -2.248e-02, 8.771e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-5.858e-03, -4.679e-06, -1.530e-02, -3.276e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-1.539e-04, -7.213e-03, -1.678e-04, -1.016e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

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
  r0 += vec4f(1.399e-02, -8.613e-01, 4.510e-02, -6.198e-02) * s0_0_0;
  r1 += vec4f(3.144e-03, 3.465e-03, -1.064e-02, -3.830e-01) * s0_0_0;
  r2 += vec4f(1.107e-01, -1.557e-02, 5.595e-02, -4.578e-01) * s0_0_0;
  r0 += vec4f(6.443e-01, 8.875e-01, -8.281e-02, -2.051e-01) * s0_0_1;
  r1 += vec4f(-1.004e+00, 1.209e-02, 3.660e-02, 1.245e-01) * s0_0_1;
  r2 += vec4f(3.588e-01, 5.996e-01, -1.519e-01, 6.267e-01) * s0_0_1;
  r0 += vec4f(-6.438e-01, -9.581e-03, -3.701e-01, -2.779e-03) * s0_0_2;
  r1 += vec4f(-1.427e-02, -9.016e-03, -3.210e-02, 1.661e-02) * s0_0_2;
  r2 += vec4f(2.842e-02, 4.016e-01, 1.525e-01, -7.983e-02) * s0_0_2;
  r0 += vec4f(-3.874e-01, -9.402e-02, -4.577e-02, -1.556e-01) * s0_1_0;
  r1 += vec4f(-3.956e-03, 4.769e-02, 1.407e-02, -2.487e-01) * s0_1_0;
  r2 += vec4f(2.265e-01, -1.547e-02, -3.945e-04, 6.262e-01) * s0_1_0;
  r0 += vec4f(-3.448e-01, 7.295e-02, 8.072e-01, 8.032e-01) * s0_1_1;
  r1 += vec4f(1.008e+00, 1.200e-01, 8.973e-01, 6.333e-01) * s0_1_1;
  r2 += vec4f(-1.332e+00, -5.254e-01, -7.528e-01, -2.037e-01) * s0_1_1;
  r0 += vec4f(7.315e-01, 5.366e-03, -2.933e-01, -1.430e-01) * s0_1_2;
  r1 += vec4f(8.885e-03, 9.111e-02, -9.074e-01, -1.773e-02) * s0_1_2;
  r2 += vec4f(2.101e-01, -4.435e-01, 9.942e-02, -5.028e-01) * s0_1_2;
  r0 += vec4f(4.129e-01, -1.551e-02, -2.574e-01, 5.755e-03) * s0_2_0;
  r1 += vec4f(1.012e-03, -1.300e-02, -4.951e-03, -6.018e-02) * s0_2_0;
  r2 += vec4f(1.625e-02, 2.482e-02, -5.238e-02, -1.716e-01) * s0_2_0;
  r0 += vec4f(-3.211e-01, 1.562e-02, 1.657e-01, -9.189e-02) * s0_2_1;
  r1 += vec4f(-5.826e-04, -6.887e-01, 2.155e-02, 3.070e-01) * s0_2_1;
  r2 += vec4f(1.294e-01, -2.412e-02, 4.100e-01, -4.229e-01) * s0_2_1;
  r0 += vec4f(-9.839e-02, 2.218e-03, 3.019e-02, 1.475e-02) * s0_2_2;
  r1 += vec4f(-9.086e-04, 2.603e-01, -1.723e-02, -3.740e-01) * s0_2_2;
  r2 += vec4f(-2.375e-02, -3.243e-03, 2.389e-01, 5.905e-01) * s0_2_2;
  r0 += vec4f(-4.804e-03, -1.492e-04, -1.916e-03, 1.624e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-8.291e-05, -5.733e-04, 2.415e-06, 1.064e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-2.745e-03, -1.936e-04, -3.452e-03, -4.412e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

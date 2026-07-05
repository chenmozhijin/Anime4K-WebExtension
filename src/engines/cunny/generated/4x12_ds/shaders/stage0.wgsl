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
  r0 += vec4f(7.213e-02, 1.733e-02, -3.150e-02, 7.941e-02) * s0_0_0;
  r1 += vec4f(-8.719e-02, -5.164e-02, -9.595e-03, -7.228e-01) * s0_0_0;
  r2 += vec4f(-5.824e-02, 8.887e-01, -1.939e-01, 5.263e-01) * s0_0_0;
  r0 += vec4f(-1.067e-01, -7.984e-02, 7.952e-03, -5.510e-02) * s0_0_1;
  r1 += vec4f(-2.899e-01, -2.258e-01, -2.293e-02, -1.225e-01) * s0_0_1;
  r2 += vec4f(5.098e-01, 4.531e-02, -2.709e-01, 2.784e-01) * s0_0_1;
  r0 += vec4f(4.817e-03, 3.208e-02, 3.013e-02, -5.709e-03) * s0_0_2;
  r1 += vec4f(2.968e-02, -3.136e-03, 3.592e-03, -7.651e-03) * s0_0_2;
  r2 += vec4f(3.897e-02, 2.448e-02, -6.043e-02, 3.701e-02) * s0_0_2;
  r0 += vec4f(9.402e-01, -3.262e-02, 8.933e-02, 9.899e-01) * s0_1_0;
  r1 += vec4f(-8.804e-02, -7.544e-02, -2.538e-02, -3.894e-02) * s0_1_0;
  r2 += vec4f(-3.278e-02, -9.047e-01, -1.428e-01, -1.920e-02) * s0_1_0;
  r0 += vec4f(-8.417e-01, 3.517e-02, -5.337e-01, -9.473e-01) * s0_1_1;
  r1 += vec4f(-5.215e-01, -6.740e-01, 4.098e-01, 8.845e-01) * s0_1_1;
  r2 += vec4f(-4.230e-01, -1.704e-02, 7.559e-01, -7.090e-01) * s0_1_1;
  r0 += vec4f(-4.984e-02, -9.923e-02, 4.385e-01, -6.385e-02) * s0_1_2;
  r1 += vec4f(-1.509e-01, -1.208e-01, -1.174e-01, 5.624e-03) * s0_1_2;
  r2 += vec4f(-2.278e-02, -2.569e-02, -6.774e-03, -1.139e-01) * s0_1_2;
  r0 += vec4f(7.169e-02, 1.340e+00, -1.159e-01, 8.696e-02) * s0_2_0;
  r1 += vec4f(1.578e-01, 1.618e-01, 1.798e-02, 3.642e-03) * s0_2_0;
  r2 += vec4f(1.420e-02, 8.781e-03, -2.179e-02, -3.206e-02) * s0_2_0;
  r0 += vec4f(-1.150e-01, -7.690e-02, -4.444e-01, -1.325e-01) * s0_2_1;
  r1 += vec4f(8.634e-01, 8.553e-01, -1.158e-01, 1.544e-03) * s0_2_1;
  r2 += vec4f(-5.076e-03, -2.967e-02, 2.064e-02, -4.888e-02) * s0_2_1;
  r0 += vec4f(2.359e-02, 5.222e-02, 5.680e-01, 5.186e-02) * s0_2_2;
  r1 += vec4f(8.462e-02, 1.323e-01, 8.534e-02, -8.340e-04) * s0_2_2;
  r2 += vec4f(-1.776e-02, 7.646e-03, -1.835e-02, 8.228e-02) * s0_2_2;
  r0 += vec4f(1.752e-02, -1.156e+00, -2.883e-03, -2.400e-02);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(1.910e-02, -1.065e-02, 1.682e-02, 1.024e-02);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(3.166e-02, -4.865e-03, 1.062e-02, 1.609e-02);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

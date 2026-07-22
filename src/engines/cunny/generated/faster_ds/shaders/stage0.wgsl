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

  let outBase = vec2i(pixel.xy) * vec2i(2, 1);

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
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  s0_0_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, -1));
  s0_0_1 = sample_LUMA_f32(pixel.xy, vec2i(0, -1));
  s0_0_2 = sample_LUMA_f32(pixel.xy, vec2i(1, -1));
  s0_1_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 0));
  s0_1_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 0));
  s0_1_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 0));
  s0_2_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 1));
  s0_2_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 1));
  s0_2_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 1));
  r0 += vec4f(1.841e-01, 6.352e-01, -4.782e-02, -1.076e-02) * s0_0_0;
  r1 += vec4f(2.133e-02, -1.901e-02, 7.787e-02, -1.398e-02) * s0_0_0;
  r0 += vec4f(2.985e-02, 5.205e-01, 2.056e-02, -4.277e-02) * s0_0_1;
  r1 += vec4f(-6.660e-01, -5.970e-02, -3.772e-02, 3.924e-02) * s0_0_1;
  r0 += vec4f(2.027e-01, 4.142e-02, 2.695e-02, 4.800e-02) * s0_0_2;
  r1 += vec4f(1.636e-01, 4.947e-02, 2.570e-02, -1.516e-02) * s0_0_2;
  r0 += vec4f(3.898e-01, -1.082e+00, 1.200e+00, 1.102e+00) * s0_1_0;
  r1 += vec4f(-3.557e-02, -4.984e-02, -1.157e-01, 3.814e-03) * s0_1_0;
  r0 += vec4f(-1.053e+00, -4.080e-02, -1.137e+00, -1.012e+00) * s0_1_1;
  r1 += vec4f(-4.557e-01, 9.336e-01, -1.058e+00, 1.168e+00) * s0_1_1;
  r0 += vec4f(-3.388e-01, -4.637e-02, -7.155e-02, -7.784e-02) * s0_1_2;
  r1 += vec4f(1.004e+00, -5.106e-02, -3.184e-02, -1.943e-02) * s0_1_2;
  r0 += vec4f(2.685e-01, -6.809e-02, -4.436e-03, -6.277e-03) * s0_2_0;
  r1 += vec4f(-3.449e-02, -4.385e-03, 5.308e-02, 1.022e-02) * s0_2_0;
  r0 += vec4f(1.084e-01, 2.796e-02, -3.309e-02, 2.000e-02) * s0_2_1;
  r1 += vec4f(-7.496e-02, -1.793e-01, 9.452e-01, -1.191e+00) * s0_2_1;
  r0 += vec4f(9.098e-02, 1.648e-02, 4.042e-02, 2.891e-03) * s0_2_2;
  r1 += vec4f(8.861e-02, -4.284e-02, 1.191e-01, 1.793e-02) * s0_2_2;
  r0 += vec4f(-1.387e-02, -5.310e-05, -1.237e-02, 1.251e-02);
  r0 = max(r0, vec4f(0.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-1.363e-02, 3.391e-03, -8.025e-03, -1.858e-03);
  r1 = max(r1, vec4f(0.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
}

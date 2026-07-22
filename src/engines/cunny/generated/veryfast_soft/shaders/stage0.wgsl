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
  r0 += vec4f(-4.261e-02, -3.667e-02, -1.154e-02, -1.987e-01) * s0_0_0;
  r1 += vec4f(1.432e-02, -1.051e-02, 2.980e-03, 6.233e-02) * s0_0_0;
  r0 += vec4f(1.150e+00, 3.870e-02, -1.912e-02, -1.018e-01) * s0_0_1;
  r1 += vec4f(2.738e-02, 7.880e-02, -2.794e-02, 2.159e-01) * s0_0_1;
  r0 += vec4f(1.466e-02, 1.814e-02, 3.406e-02, 3.213e-01) * s0_0_2;
  r1 += vec4f(-4.349e-02, -5.303e-02, 2.717e-02, -8.656e-02) * s0_0_2;
  r0 += vec4f(-6.192e-03, 3.412e-01, 1.076e+00, 8.554e-01) * s0_1_0;
  r1 += vec4f(-3.558e-02, 5.132e-02, -1.138e-02, 3.005e-01) * s0_1_0;
  r0 += vec4f(-1.105e+00, 2.220e-01, -9.474e-01, -9.155e-01) * s0_1_1;
  r1 += vec4f(-1.059e+00, -1.333e-01, -1.073e+00, -1.152e+00) * s0_1_1;
  r0 += vec4f(-1.126e-02, 1.069e-02, -1.051e-01, 7.108e-03) * s0_1_2;
  r1 += vec4f(1.090e+00, 2.574e-01, -2.334e-02, 2.402e-01) * s0_1_2;
  r0 += vec4f(4.406e-02, 8.321e-02, -4.105e-02, 2.105e-01) * s0_2_0;
  r1 += vec4f(1.507e-02, -1.744e-02, 3.503e-05, -1.016e-01) * s0_2_0;
  r0 += vec4f(-4.078e-02, -7.062e-01, -6.218e-02, 4.684e-02) * s0_2_1;
  r1 += vec4f(-1.002e-02, -1.030e-01, 1.098e+00, 2.858e-01) * s0_2_1;
  r0 += vec4f(-5.676e-03, 1.173e-02, 7.469e-02, -2.327e-01) * s0_2_2;
  r1 += vec4f(-5.805e-03, -4.049e-02, 4.043e-03, 4.426e-02) * s0_2_2;
  r0 += vec4f(-1.137e-03, -3.262e-04, -2.050e-03, -2.276e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-5.205e-04, 1.480e-02, 2.195e-05, -1.857e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
}

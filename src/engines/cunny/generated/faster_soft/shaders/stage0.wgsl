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
  r0 += vec4f(-6.186e-02, 2.542e-02, -3.126e-02, 4.276e-01) * s0_0_0;
  r1 += vec4f(1.024e-01, 2.983e-01, 1.847e-02, 7.229e-03) * s0_0_0;
  r0 += vec4f(2.466e-01, -3.970e-02, -3.019e-01, -2.549e-01) * s0_0_1;
  r1 += vec4f(3.331e-01, -1.843e-01, 4.878e-03, -1.012e+00) * s0_0_1;
  r0 += vec4f(-1.487e-02, 1.207e-02, 1.938e-02, -1.742e-01) * s0_0_2;
  r1 += vec4f(2.189e-02, -1.410e-01, -1.995e-02, 3.394e-02) * s0_0_2;
  r0 += vec4f(-3.043e-02, -5.645e-02, -2.347e-01, 6.738e-01) * s0_1_0;
  r1 += vec4f(2.826e-01, -6.736e-01, -9.939e-01, -3.110e-03) * s0_1_0;
  r0 += vec4f(-1.997e-01, 7.020e-01, 1.021e+00, -6.116e-01) * s0_1_1;
  r1 += vec4f(-1.371e+00, 8.032e-01, 9.512e-01, 1.035e+00) * s0_1_1;
  r0 += vec4f(1.465e-01, -4.654e-03, -1.250e-01, -9.517e-02) * s0_1_2;
  r1 += vec4f(1.188e-01, -8.951e-02, 3.938e-02, -5.260e-02) * s0_1_2;
  r0 += vec4f(-3.857e-02, 3.157e-02, 2.097e-02, -1.312e-01) * s0_2_0;
  r1 += vec4f(2.049e-02, -3.059e-01, 4.589e-02, -8.052e-03) * s0_2_0;
  r0 += vec4f(9.864e-02, 9.063e-02, -3.894e-02, 3.186e-03) * s0_2_1;
  r1 += vec4f(3.989e-02, 3.252e-01, -3.164e-02, -2.699e-02) * s0_2_1;
  r0 += vec4f(-3.073e-02, -7.637e-01, -1.021e-01, 1.632e-01) * s0_2_2;
  r1 += vec4f(1.266e-01, -3.480e-02, -1.752e-02, 1.867e-02) * s0_2_2;
  r0 += vec4f(4.001e-03, 2.329e-06, 2.258e-04, 3.230e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(1.177e-03, 2.971e-03, -1.022e-04, 6.960e-04);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
}

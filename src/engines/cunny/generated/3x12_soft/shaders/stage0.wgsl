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
  r0 += vec4f(4.017e-03, 2.163e-02, -1.002e-02, -8.245e-02) * s0_0_0;
  r1 += vec4f(1.533e-02, -1.412e-02, -2.095e-02, -1.456e-02) * s0_0_0;
  r2 += vec4f(1.090e+00, 3.718e-01, 2.530e-02, -5.853e-02) * s0_0_0;
  r0 += vec4f(-3.021e-02, -7.030e-01, 1.833e-02, 8.436e-01) * s0_0_1;
  r1 += vec4f(-3.648e-03, -2.184e-02, -4.637e-01, -2.332e-02) * s0_0_1;
  r2 += vec4f(-1.048e+00, -3.455e-01, -5.261e-02, 4.802e-02) * s0_0_1;
  r0 += vec4f(2.722e-02, -1.899e-01, -5.562e-03, 2.338e-01) * s0_0_2;
  r1 += vec4f(-8.591e-02, 1.116e-02, -1.985e-01, -3.813e-03) * s0_0_2;
  r2 += vec4f(-4.699e-02, -2.802e-02, -1.862e-03, 1.403e-02) * s0_0_2;
  r0 += vec4f(-1.972e-02, 7.442e-02, 1.767e-02, -9.474e-02) * s0_1_0;
  r1 += vec4f(-2.740e-02, -9.590e-01, 7.886e-02, -6.213e-02) * s0_1_0;
  r2 += vec4f(8.192e-02, 3.845e-01, -2.209e-02, 4.713e-02) * s0_1_0;
  r0 += vec4f(-1.035e+00, 7.204e-01, 9.750e-01, -7.910e-01) * s0_1_1;
  r1 += vec4f(9.423e-01, -2.806e-02, 6.709e-01, 2.061e-01) * s0_1_1;
  r2 += vec4f(-8.376e-02, -3.271e-01, 5.770e-01, -8.823e-01) * s0_1_1;
  r0 += vec4f(1.048e+00, 7.322e-02, 2.703e-02, -1.008e-01) * s0_1_2;
  r1 += vec4f(-6.815e-01, 5.902e-05, 4.419e-02, -3.081e-02) * s0_1_2;
  r2 += vec4f(2.090e-03, -8.177e-02, -5.619e-01, 2.484e-01) * s0_1_2;
  r0 += vec4f(1.493e-02, -9.497e-02, -8.468e-03, 1.728e-01) * s0_2_0;
  r1 += vec4f(1.188e-02, 9.664e-01, -8.566e-02, 7.456e-02) * s0_2_0;
  r2 += vec4f(6.395e-03, -9.458e-02, -9.220e-04, 5.109e-02) * s0_2_0;
  r0 += vec4f(-2.741e-02, 4.229e-02, -9.902e-01, -9.435e-02) * s0_2_1;
  r1 += vec4f(-1.014e-01, 6.398e-02, -4.228e-02, -1.213e-01) * s0_2_1;
  r2 += vec4f(-1.364e-02, -4.071e-02, 1.941e-02, 4.013e-01) * s0_2_1;
  r0 += vec4f(1.677e-02, 5.994e-02, -2.648e-02, -8.944e-02) * s0_2_2;
  r1 += vec4f(-6.971e-02, -1.948e-02, -9.674e-03, -1.702e-02) * s0_2_2;
  r2 += vec4f(7.142e-03, 1.108e-01, -2.878e-02, -8.178e-03) * s0_2_2;
  r0 += vec4f(2.815e-03, 5.054e-03, 6.748e-05, -5.780e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(5.381e-03, 1.745e-03, -3.588e-03, 2.850e-02);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(6.194e-07, -5.462e-03, -3.649e-03, 3.135e-04);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

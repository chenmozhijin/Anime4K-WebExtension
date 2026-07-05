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

  let outBase = vec2i(pixel.xy) * vec2i(2, 2);

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
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  r2 = vec4f(0.0);
  r3 = vec4f(0.0);
  s0_0_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, -1));
  s0_0_1 = sample_LUMA_f32(pixel.xy, vec2i(0, -1));
  s0_0_2 = sample_LUMA_f32(pixel.xy, vec2i(1, -1));
  s0_1_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 0));
  s0_1_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 0));
  s0_1_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 0));
  s0_2_0 = sample_LUMA_f32(pixel.xy, vec2i(-1, 1));
  s0_2_1 = sample_LUMA_f32(pixel.xy, vec2i(0, 1));
  s0_2_2 = sample_LUMA_f32(pixel.xy, vec2i(1, 1));
  r0 += vec4f(2.654e-02, 3.835e-02, 1.188e-02, 2.228e-02) * s0_0_0;
  r1 += vec4f(-1.453e-02, -5.067e-02, 7.598e-03, 5.118e-03) * s0_0_0;
  r2 += vec4f(6.696e-02, 2.687e-02, 2.144e-03, -7.696e-03) * s0_0_0;
  r3 += vec4f(1.071e-03, 5.112e-03, 2.531e-04, -2.942e-02) * s0_0_0;
  r0 += vec4f(-4.418e-01, 7.103e-02, -1.092e-01, -5.347e-02) * s0_0_1;
  r1 += vec4f(6.013e-01, -5.944e-01, 1.265e-01, 7.840e-01) * s0_0_1;
  r2 += vec4f(7.124e-02, -4.348e-02, -6.166e-02, 8.081e-02) * s0_0_1;
  r3 += vec4f(4.932e-01, -1.583e-02, 7.581e-03, 5.969e-03) * s0_0_1;
  r0 += vec4f(4.120e-01, 1.271e-02, 3.320e-03, 1.533e-03) * s0_0_2;
  r1 += vec4f(3.381e-02, 6.566e-01, 6.571e-01, 2.425e-02) * s0_0_2;
  r2 += vec4f(-6.065e-02, 1.160e-02, 9.210e-02, -7.349e-02) * s0_0_2;
  r3 += vec4f(1.055e-02, 4.034e-03, -2.136e-03, 3.339e-01) * s0_0_2;
  r0 += vec4f(3.760e-01, -1.781e-02, -1.582e-01, -9.618e-02) * s0_1_0;
  r1 += vec4f(-2.779e-02, 7.359e-03, -4.329e-02, -8.507e-03) * s0_1_0;
  r2 += vec4f(-1.760e-02, 1.331e-02, 5.205e-02, 3.130e-03) * s0_1_0;
  r3 += vec4f(-4.970e-01, -2.882e-02, -5.579e-02, -1.592e-02) * s0_1_0;
  r0 += vec4f(9.735e-02, -2.711e-02, 4.424e-01, -5.954e-01) * s0_1_1;
  r1 += vec4f(-5.628e-01, -1.473e-01, -5.045e-02, -7.637e-01) * s0_1_1;
  r2 += vec4f(3.824e-01, -4.722e-02, 3.389e-01, 8.054e-01) * s0_1_1;
  r3 += vec4f(-1.008e-02, -7.480e-01, 5.429e-02, 4.472e-03) * s0_1_1;
  r0 += vec4f(-4.663e-01, 3.766e-02, -7.644e-03, -1.042e-01) * s0_1_2;
  r1 += vec4f(-3.302e-02, 1.321e-01, -6.490e-01, -4.503e-02) * s0_1_2;
  r2 += vec4f(-4.290e-01, 2.713e-02, -6.628e-01, -7.983e-01) * s0_1_2;
  r3 += vec4f(2.717e-03, -3.013e-02, -1.349e-02, -4.220e-01) * s0_1_2;
  r0 += vec4f(-4.204e-01, 1.003e-01, -7.213e-02, 5.886e-02) * s0_2_0;
  r1 += vec4f(1.188e-02, -1.846e-03, 3.172e-02, 4.740e-03) * s0_2_0;
  r2 += vec4f(-2.103e-03, 6.709e-01, -2.548e-02, -3.087e-03) * s0_2_0;
  r3 += vec4f(1.819e-03, 2.448e-02, -7.201e-01, -7.634e-03) * s0_2_0;
  r0 += vec4f(3.521e-01, -1.127e+01, -6.172e-02, 7.051e-01) * s0_2_1;
  r1 += vec4f(-2.649e-03, -2.423e-02, -3.870e-02, -1.803e-02) * s0_2_1;
  r2 += vec4f(-1.761e-02, 4.535e-02, 7.395e-02, 5.056e-02) * s0_2_1;
  r3 += vec4f(-1.076e-03, 7.630e-01, 7.166e-01, 6.411e-02) * s0_2_1;
  r0 += vec4f(5.987e-02, 2.239e-02, 8.580e-03, 6.222e-02) * s0_2_2;
  r1 += vec4f(-6.063e-03, 2.392e-02, -3.964e-02, 1.658e-02) * s0_2_2;
  r2 += vec4f(3.516e-03, -4.245e-02, 9.279e-02, -5.660e-02) * s0_2_2;
  r3 += vec4f(-4.877e-04, 2.786e-02, 1.555e-02, -3.797e-02) * s0_2_2;
  r0 += vec4f(-1.151e-03, 1.030e-02, 1.464e-03, 1.445e-02);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(1.254e-02, 4.626e-03, 2.368e-03, 6.124e-04);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-9.805e-03, -6.425e-01, -2.442e-03, 3.242e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r2);
  r3 += vec4f(-1.197e-03, -9.069e-04, 1.111e-04, -1.430e-02);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r3);
}

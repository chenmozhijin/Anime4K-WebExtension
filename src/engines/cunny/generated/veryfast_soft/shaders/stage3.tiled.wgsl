// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv2: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv2_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv2)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv2, sourceCoord * packedScale + lane, 0);
}

@group(0) @binding(2) var linearSampler: sampler;
@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;
var<workgroup> G: array<array<array<vec4f, 10>, 10>, 1>;

fn sample_original_luma(coord: vec2i) -> f32 {
  let outputSize = textureDimensions(out_tex);
  let uv = (vec2f(coord) + vec2f(0.5)) / vec2f(outputSize);
  return luma709(textureSampleLevel(tex_LUMA, linearSampler, uv, 0.0).rgb);
}


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let sourceSize = textureDimensions(tex_LUMA);

  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      G[0][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(0, 0), vec2i(1, 1));
    }
  }
  workgroupBarrier();

  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let outBase = vec2i(pixel.xy) * vec2i(2, 2);

  var s0_0_0: vec4f;
  var s0_0_1: vec4f;
  var s0_0_2: vec4f;
  var s0_1_0: vec4f;
  var s0_1_1: vec4f;
  var s0_1_2: vec4f;
  var s0_2_0: vec4f;
  var s0_2_1: vec4f;
  var s0_2_2: vec4f;
  var r0: vec4f;
  r0 = vec4f(0.0);
  s0_0_0 = G[0][localId.y + 0u][localId.x + 0u];
  s0_0_1 = G[0][localId.y + 0u][localId.x + 1u];
  s0_0_2 = G[0][localId.y + 0u][localId.x + 2u];
  s0_1_0 = G[0][localId.y + 1u][localId.x + 0u];
  s0_1_1 = G[0][localId.y + 1u][localId.x + 1u];
  s0_1_2 = G[0][localId.y + 1u][localId.x + 2u];
  s0_2_0 = G[0][localId.y + 2u][localId.x + 0u];
  s0_2_1 = G[0][localId.y + 2u][localId.x + 1u];
  s0_2_2 = G[0][localId.y + 2u][localId.x + 2u];
  r0 += mat4x4<f32>(1.255e-01, 5.798e-02, -1.163e-02, -8.770e-03, 3.371e-03, 2.788e-03, 1.468e-02, 4.457e-03, 2.673e-04, 8.711e-04, 3.817e-04, -1.424e-07, 8.862e-02, -1.069e-02, -1.059e-02, -1.579e-02) * s0_0_0;
  r0 += mat4x4<f32>(1.861e-01, 1.508e-01, 1.333e-03, -4.843e-03, 4.479e-02, 2.555e-02, 1.787e-01, 3.182e-02, -1.453e-03, 6.543e-03, -4.353e-04, -8.008e-07, -1.167e-01, 1.298e-01, -4.762e-02, 2.935e-03) * s0_0_1;
  r0 += mat4x4<f32>(-6.974e-03, 4.382e-02, -7.400e-04, -3.396e-03, -2.124e-01, -3.001e-01, 1.984e-02, 2.780e-01, 1.173e-03, -7.187e-03, -1.022e-03, -6.778e-04, -1.048e-02, 7.156e-02, -2.708e-03, -3.875e-02) * s0_0_2;
  r0 += mat4x4<f32>(-1.577e-01, 1.250e-02, -8.648e-02, -4.689e-02, -6.336e-03, -3.293e-03, 1.110e-03, 2.097e-03, 2.277e-03, -1.022e-02, -1.019e-03, -3.308e-03, 1.170e-01, -1.107e-02, 1.322e-01, 2.385e-03) * s0_1_0;
  r0 += mat4x4<f32>(-8.021e-02, -6.038e-01, 4.326e-01, -1.053e-01, 2.173e-01, -4.296e-02, 1.675e-01, 2.452e-02, -5.569e-01, -1.812e-01, -9.005e-02, 6.056e-02, -6.368e-02, 5.282e-01, -8.165e-01, 1.111e-01) * s0_1_1;
  r0 += mat4x4<f32>(-1.173e-02, 1.275e-01, 4.014e-03, 2.144e-01, 1.665e-01, -1.548e-01, -7.352e-02, -7.022e-01, 3.799e-01, -6.418e-02, -2.039e-02, -2.607e-01, -7.982e-02, 1.027e-01, -2.271e-02, 6.812e-02) * s0_1_2;
  r0 += mat4x4<f32>(2.949e-03, 2.134e-03, -8.520e-02, 8.288e-03, -6.587e-04, 1.055e-04, -1.581e-02, -6.011e-03, -1.238e-02, 9.397e-03, 3.083e-03, 2.538e-03, 1.998e-04, -1.396e-03, 6.518e-02, 4.520e-03) * s0_2_0;
  r0 += mat4x4<f32>(-9.190e-03, 1.922e-02, -6.755e-02, -1.704e-01, 5.656e-03, 9.584e-03, 1.098e-02, -2.932e-02, -1.432e-02, -3.629e-02, 1.106e-01, 1.470e-01, -4.086e-03, -2.335e-02, 1.047e-01, 1.373e-01) * s0_2_1;
  r0 += mat4x4<f32>(7.299e-03, 6.259e-03, -6.744e-03, 6.162e-03, 2.891e-03, -2.629e-03, 4.639e-02, 3.400e-02, 8.160e-03, 6.618e-02, 1.782e-01, 2.162e-01, -1.123e-02, -1.263e-02, -3.014e-02, 3.908e-02) * s0_2_2;
  r0 += vec4f(-2.727e-11, -1.608e-10, -1.877e-11, -2.711e-10);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

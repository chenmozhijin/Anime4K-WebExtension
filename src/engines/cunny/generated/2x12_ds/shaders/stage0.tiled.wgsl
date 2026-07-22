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
var<workgroup> G: array<array<array<f32, 10>, 10>, 1>;


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let sourceSize = textureDimensions(tex_LUMA);

  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      G[0][tileY][tileX] = sample_LUMA_f32(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1));
    }
  }
  workgroupBarrier();

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
  s0_0_0 = G[0][localId.y + 0u][localId.x + 0u];
  s0_0_1 = G[0][localId.y + 0u][localId.x + 1u];
  s0_0_2 = G[0][localId.y + 0u][localId.x + 2u];
  s0_1_0 = G[0][localId.y + 1u][localId.x + 0u];
  s0_1_1 = G[0][localId.y + 1u][localId.x + 1u];
  s0_1_2 = G[0][localId.y + 1u][localId.x + 2u];
  s0_2_0 = G[0][localId.y + 2u][localId.x + 0u];
  s0_2_1 = G[0][localId.y + 2u][localId.x + 1u];
  s0_2_2 = G[0][localId.y + 2u][localId.x + 2u];
  r0 += vec4f(-5.191e-02, 2.455e-02, 3.272e-01, 2.582e-02) * s0_0_0;
  r1 += vec4f(-4.211e-02, -7.496e-04, -2.097e-01, 1.265e-02) * s0_0_0;
  r2 += vec4f(-7.447e-02, 1.310e-02, -8.455e-02, 1.625e-02) * s0_0_0;
  r0 += vec4f(-2.028e-01, -5.257e-02, 1.477e-01, -5.079e-02) * s0_0_1;
  r1 += vec4f(4.814e-01, -8.497e-01, -2.609e-01, 2.017e-02) * s0_0_1;
  r2 += vec4f(-8.010e-02, -3.924e-02, -2.022e-02, -1.350e-01) * s0_0_1;
  r0 += vec4f(2.706e-01, 2.162e-02, -9.736e-03, 2.180e-02) * s0_0_2;
  r1 += vec4f(4.432e-01, 8.543e-01, 4.775e-01, -3.009e-02) * s0_0_2;
  r2 += vec4f(-3.725e-02, -6.188e-02, 4.952e-01, -9.321e-02) * s0_0_2;
  r0 += vec4f(5.377e-01, -8.473e-02, 6.348e-01, -1.252e-01) * s0_1_0;
  r1 += vec4f(-2.185e-03, 3.782e-03, -1.004e-01, -5.375e-02) * s0_1_0;
  r2 += vec4f(-2.385e-01, -1.786e-02, -1.480e-02, 2.699e-02) * s0_1_0;
  r0 += vec4f(-9.434e-01, -8.926e-01, -1.007e+00, -8.675e-01) * s0_1_1;
  r1 += vec4f(-9.980e-01, -5.412e-02, -4.424e-01, -1.035e+00) * s0_1_1;
  r2 += vec4f(1.031e+00, -7.735e-02, -2.289e-02, 6.952e-01) * s0_1_1;
  r0 += vec4f(4.494e-03, -1.101e-01, -1.018e-01, -1.142e-01) * s0_1_2;
  r1 += vec4f(1.165e-01, 7.109e-02, 6.309e-01, 1.087e+00) * s0_1_2;
  r2 += vec4f(-1.140e-01, -8.667e-02, -1.041e-01, -3.534e-01) * s0_1_2;
  r0 += vec4f(3.375e-01, 6.424e-02, 1.994e-02, 9.097e-02) * s0_2_0;
  r1 += vec4f(3.208e-02, 1.428e-03, 2.434e-02, 2.824e-02) * s0_2_0;
  r2 += vec4f(-5.633e-02, 5.896e-02, -5.889e-03, 3.063e-02) * s0_2_0;
  r0 += vec4f(2.049e-01, 9.394e-01, -1.221e-01, 9.395e-01) * s0_2_1;
  r1 += vec4f(-7.108e-03, -8.539e-03, -1.112e-01, -2.324e-02) * s0_2_1;
  r2 += vec4f(-2.983e-01, -1.784e-01, -4.995e-02, -5.822e-02) * s0_2_1;
  r0 += vec4f(-1.770e-01, 9.111e-02, 1.068e-01, 8.840e-02) * s0_2_2;
  r1 += vec4f(-2.290e-02, -1.237e-02, 7.306e-03, -3.704e-03) * s0_2_2;
  r2 += vec4f(-1.217e-01, 5.689e-01, -2.592e-02, -6.608e-03) * s0_2_2;
  r0 += vec4f(-4.064e-03, -7.491e-03, -4.980e-04, 1.221e-02);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(9.808e-04, 1.763e-02, 2.270e-03, -5.116e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(3.953e-03, 8.306e-03, 1.239e-02, 4.828e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

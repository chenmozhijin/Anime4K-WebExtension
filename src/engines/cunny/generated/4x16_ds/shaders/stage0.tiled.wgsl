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
  s0_0_0 = G[0][localId.y + 0u][localId.x + 0u];
  s0_0_1 = G[0][localId.y + 0u][localId.x + 1u];
  s0_0_2 = G[0][localId.y + 0u][localId.x + 2u];
  s0_1_0 = G[0][localId.y + 1u][localId.x + 0u];
  s0_1_1 = G[0][localId.y + 1u][localId.x + 1u];
  s0_1_2 = G[0][localId.y + 1u][localId.x + 2u];
  s0_2_0 = G[0][localId.y + 2u][localId.x + 0u];
  s0_2_1 = G[0][localId.y + 2u][localId.x + 1u];
  s0_2_2 = G[0][localId.y + 2u][localId.x + 2u];
  r0 += vec4f(1.788e-02, 9.228e-02, 1.276e-02, -1.347e-02) * s0_0_0;
  r1 += vec4f(1.482e-02, -2.908e-02, 7.169e-02, -4.113e-02) * s0_0_0;
  r2 += vec4f(1.425e-02, 9.581e-02, 7.619e-02, -3.136e-02) * s0_0_0;
  r3 += vec4f(-6.137e-01, -2.612e-02, -5.735e-02, -2.123e-02) * s0_0_0;
  r0 += vec4f(2.841e-01, 6.152e-01, 1.061e-01, 4.163e-02) * s0_0_1;
  r1 += vec4f(-2.933e-02, -7.730e-03, -8.994e-02, -1.130e-01) * s0_0_1;
  r2 += vec4f(6.252e-01, 2.783e-01, 1.036e-01, -7.267e-02) * s0_0_1;
  r3 += vec4f(4.932e-02, -1.178e-01, -7.147e-03, -6.465e-01) * s0_0_1;
  r0 += vec4f(6.771e-01, 4.364e-02, 1.024e-01, -2.629e-02) * s0_0_2;
  r1 += vec4f(6.176e-03, -2.737e-03, -3.966e-04, 1.380e-01) * s0_0_2;
  r2 += vec4f(-2.149e-02, 1.072e-01, 3.302e-03, 1.145e-01) * s0_0_2;
  r3 += vec4f(2.251e-02, 5.900e-03, -8.374e-02, 5.348e-03) * s0_0_2;
  r0 += vec4f(-2.682e-02, -4.554e-02, -5.527e-02, -1.278e-02) * s0_1_0;
  r1 += vec4f(1.062e+00, 5.409e-02, 3.330e-01, -3.386e-01) * s0_1_0;
  r2 += vec4f(-6.352e-01, -2.680e-02, -2.086e+00, -3.117e-01) * s0_1_0;
  r3 += vec4f(4.234e-02, -2.371e-01, 9.448e-02, 5.827e-02) * s0_1_0;
  r0 += vec4f(-2.582e-01, -5.810e-01, -9.931e-02, 6.215e-01) * s0_1_1;
  r1 += vec4f(1.461e-02, -1.327e-01, -4.055e-01, -4.580e-01) * s0_1_1;
  r2 += vec4f(8.506e-03, -7.773e-01, 8.033e-02, -4.596e-01) * s0_1_1;
  r3 += vec4f(5.438e-01, -2.400e-01, 6.334e-01, 6.297e-01) * s0_1_1;
  r0 += vec4f(-5.957e-01, -2.832e-02, -2.785e-01, -5.958e-01) * s0_1_2;
  r1 += vec4f(-1.624e-02, 3.387e-01, -6.068e-03, 8.204e-01) * s0_1_2;
  r2 += vec4f(9.166e-03, 1.604e-01, -2.713e-02, 7.559e-01) * s0_1_2;
  r3 += vec4f(-4.210e-02, -1.626e-01, -3.933e-01, -3.854e-02) * s0_1_2;
  r0 += vec4f(-1.214e-03, -3.737e-02, -3.454e-02, 2.390e-02) * s0_2_0;
  r1 += vec4f(-3.435e-03, 1.213e-02, 1.004e-01, 2.782e-03) * s0_2_0;
  r2 += vec4f(1.367e-02, -2.685e-02, 5.416e-02, -1.064e-03) * s0_2_0;
  r3 += vec4f(-1.073e-04, 6.851e-02, -3.380e-02, -4.146e-02) * s0_2_0;
  r0 += vec4f(2.554e-02, -3.787e-02, 1.072e-01, -3.989e-02) * s0_2_1;
  r1 += vec4f(-2.676e-02, -1.329e-02, 3.959e-03, -1.080e-01) * s0_2_1;
  r2 += vec4f(-1.568e-02, 7.774e-02, -4.529e-02, -8.814e-02) * s0_2_1;
  r3 += vec4f(-1.695e-02, 6.310e-01, -1.190e-02, 4.941e-02) * s0_2_1;
  r0 += vec4f(-1.136e-01, -2.241e-02, 1.603e-01, 5.764e-03) * s0_2_2;
  r1 += vec4f(6.791e-03, -7.158e-02, -1.655e-02, 9.945e-02) * s0_2_2;
  r2 += vec4f(2.137e-03, 3.491e-03, 8.381e-02, 9.264e-02) * s0_2_2;
  r3 += vec4f(1.743e-02, 9.058e-02, -1.358e-01, 9.263e-03) * s0_2_2;
  r0 += vec4f(1.632e-02, -1.462e-02, 4.336e-03, 1.858e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-1.004e+00, -1.225e-03, 2.959e-02, 1.617e-02);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(5.447e-06, 2.543e-03, 4.396e-02, -1.157e-02);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r2);
  r3 += vec4f(-1.267e-02, 1.800e-02, 2.404e-02, 5.023e-03);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r3);
}

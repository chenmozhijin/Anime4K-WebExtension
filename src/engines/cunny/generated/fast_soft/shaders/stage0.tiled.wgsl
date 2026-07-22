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
  r0 += vec4f(3.010e-02, 1.564e-02, -1.653e-02, -3.702e-03) * s0_0_0;
  r1 += vec4f(-1.406e-02, 1.070e-02, -3.109e-02, 2.731e-02) * s0_0_0;
  r2 += vec4f(-5.163e-02, 4.491e-02, 7.853e-01, 2.529e-01) * s0_0_0;
  r0 += vec4f(2.803e-02, -1.895e-02, 1.012e+00, 2.149e-02) * s0_0_1;
  r1 += vec4f(1.870e-01, -2.768e-02, -2.353e-01, 2.040e-01) * s0_0_1;
  r2 += vec4f(-5.183e-01, -3.464e-02, -7.988e-01, -4.419e-02) * s0_0_1;
  r0 += vec4f(-2.810e-02, -2.463e-03, 1.985e-02, -3.392e-02) * s0_0_2;
  r1 += vec4f(6.055e-01, 1.673e-02, -1.892e-01, 4.952e-02) * s0_0_2;
  r2 += vec4f(-1.032e-01, -7.236e-02, 3.918e-03, -2.431e-02) * s0_0_2;
  r0 += vec4f(3.346e-01, 8.850e-01, 2.140e-03, -9.192e-03) * s0_1_0;
  r1 += vec4f(-5.193e-02, -2.364e-02, 4.263e-02, 7.263e-02) * s0_1_0;
  r2 += vec4f(-4.015e-03, -5.815e-03, -7.910e-01, -5.395e-01) * s0_1_0;
  r0 += vec4f(-8.111e-01, -8.756e-01, -9.627e-01, -6.735e-02) * s0_1_1;
  r1 += vec4f(-7.967e-01, -9.668e-01, 3.975e-01, -8.028e-01) * s0_1_1;
  r2 += vec4f(7.652e-01, 9.664e-01, 7.637e-01, -1.460e-01) * s0_1_1;
  r0 += vec4f(7.927e-02, -5.525e-03, -4.855e-02, -9.200e-01) * s0_1_2;
  r1 += vec4f(2.806e-02, 9.875e-01, 8.642e-03, 2.861e-01) * s0_1_2;
  r2 += vec4f(-5.948e-02, -4.044e-01, 2.062e-02, 9.010e-02) * s0_1_2;
  r0 += vec4f(-1.899e-02, 2.585e-02, 1.148e-02, 1.157e-02) * s0_2_0;
  r1 += vec4f(7.441e-02, 6.822e-03, -3.548e-02, -4.318e-02) * s0_2_0;
  r2 += vec4f(1.059e-02, -6.225e-02, -6.352e-04, 1.452e-01) * s0_2_0;
  r0 += vec4f(2.635e-01, -1.487e-02, -4.457e-02, 5.068e-02) * s0_2_1;
  r1 += vec4f(-7.955e-03, 1.923e-02, 1.438e-02, -1.157e-02) * s0_2_1;
  r2 += vec4f(-1.213e-01, -4.688e-01, 4.193e-02, 3.039e-01) * s0_2_1;
  r0 += vec4f(2.899e-02, -1.022e-02, 2.218e-02, 9.512e-01) * s0_2_2;
  r1 += vec4f(-2.496e-02, -2.301e-02, -5.402e-03, 8.511e-02) * s0_2_2;
  r2 += vec4f(8.476e-02, 3.721e-02, -2.634e-02, -4.782e-02) * s0_2_2;
  r0 += vec4f(-1.865e-03, 9.461e-04, -2.628e-04, 2.123e-04);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-8.868e-03, 5.735e-04, -8.273e-03, -1.885e-03);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(1.006e-02, 3.972e-03, -2.517e-03, -8.864e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

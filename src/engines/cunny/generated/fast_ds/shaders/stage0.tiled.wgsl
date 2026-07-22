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
  r0 += vec4f(4.041e-02, 9.762e-02, 2.171e-02, 8.674e-02) * s0_0_0;
  r1 += vec4f(1.336e-02, -5.773e-02, -9.529e-02, 7.143e-02) * s0_0_0;
  r2 += vec4f(8.325e-02, 1.928e-02, -9.564e-02, -5.571e-01) * s0_0_0;
  r0 += vec4f(-6.575e-02, -1.562e-02, 1.012e+00, 3.738e-01) * s0_0_1;
  r1 += vec4f(-5.832e-02, 3.951e-01, -2.196e-01, -8.078e-02) * s0_0_1;
  r2 += vec4f(2.241e-01, 1.606e-01, 2.095e-01, -1.899e-01) * s0_0_1;
  r0 += vec4f(2.574e-02, -8.587e-02, 5.164e-02, -7.524e-02) * s0_0_2;
  r1 += vec4f(9.939e-01, 5.512e-01, 5.513e-03, 8.552e-04) * s0_0_2;
  r2 += vec4f(-3.983e-02, -2.604e-01, -1.028e-01, 1.299e-01) * s0_0_2;
  r0 += vec4f(9.906e-01, 3.528e-02, -6.959e-02, 2.416e-01) * s0_1_0;
  r1 += vec4f(-2.832e-02, 1.157e-01, -2.183e-01, -8.136e-02) * s0_1_0;
  r2 += vec4f(3.729e-01, -4.742e-03, -6.080e-02, 2.169e-01) * s0_1_0;
  r0 += vec4f(-9.435e-01, 8.926e-01, -8.849e-01, 4.545e-03) * s0_1_1;
  r1 += vec4f(-7.676e-01, -9.239e-01, 7.246e-01, -9.115e-01) * s0_1_1;
  r2 += vec4f(-1.050e-01, 7.291e-01, 7.910e-01, 8.643e-01) * s0_1_1;
  r0 += vec4f(-4.442e-02, -2.619e-02, -1.304e-01, -3.640e-01) * s0_1_2;
  r1 += vec4f(-1.055e-01, -6.269e-01, 1.415e-02, 3.846e-02) * s0_1_2;
  r2 += vec4f(4.092e-02, -6.295e-01, -1.182e-01, -1.678e-01) * s0_1_2;
  r0 += vec4f(-3.576e-02, -9.187e-01, 5.371e-02, -1.712e-01) * s0_2_0;
  r1 += vec4f(-1.685e-03, 5.898e-02, 5.844e-03, 8.580e-03) * s0_2_0;
  r2 += vec4f(1.522e-02, -5.661e-02, -2.173e-01, 1.233e-01) * s0_2_0;
  r0 += vec4f(2.638e-02, -9.028e-02, -1.191e-01, -5.175e-02) * s0_2_1;
  r1 += vec4f(-3.072e-02, 3.127e-01, -6.369e-02, 9.259e-02) * s0_2_1;
  r2 += vec4f(-5.195e-02, 7.929e-02, -2.329e-01, -7.104e-02) * s0_2_1;
  r0 += vec4f(9.126e-03, 1.058e-01, 6.688e-02, 2.216e-02) * s0_2_2;
  r1 += vec4f(1.929e-03, 1.770e-01, 2.155e-02, 8.600e-01) * s0_2_2;
  r2 += vec4f(2.261e-02, -2.613e-02, -1.607e-02, -3.508e-01) * s0_2_2;
  r0 += vec4f(-3.838e-03, -7.199e-04, -1.880e-03, 1.684e-02);
  r0 = max(r0, vec4f(0.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(3.019e-03, 1.704e-02, 1.492e-02, -4.056e-03);
  r1 = max(r1, vec4f(0.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(4.259e-04, 1.454e-02, 1.021e-02, -2.542e-03);
  r2 = max(r2, vec4f(0.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
}

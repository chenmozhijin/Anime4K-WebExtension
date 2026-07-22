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
var<workgroup> G: array<array<array<vec4f, 10>, 10>, 2>;

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
      G[0][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(0, 0), vec2i(2, 1));
      G[1][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(1, 0), vec2i(2, 1));
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
  var s1_0_0: vec4f;
  var s1_0_1: vec4f;
  var s1_0_2: vec4f;
  var s1_1_0: vec4f;
  var s1_1_1: vec4f;
  var s1_1_2: vec4f;
  var s1_2_0: vec4f;
  var s1_2_1: vec4f;
  var s1_2_2: vec4f;
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
  s1_0_0 = G[1][localId.y + 0u][localId.x + 0u];
  s1_0_1 = G[1][localId.y + 0u][localId.x + 1u];
  s1_0_2 = G[1][localId.y + 0u][localId.x + 2u];
  s1_1_0 = G[1][localId.y + 1u][localId.x + 0u];
  s1_1_1 = G[1][localId.y + 1u][localId.x + 1u];
  s1_1_2 = G[1][localId.y + 1u][localId.x + 2u];
  s1_2_0 = G[1][localId.y + 2u][localId.x + 0u];
  s1_2_1 = G[1][localId.y + 2u][localId.x + 1u];
  s1_2_2 = G[1][localId.y + 2u][localId.x + 2u];
  r0 += mat4x4<f32>(2.510e-01, -2.566e-02, 1.076e-01, 9.371e-03, -1.089e-07, 4.047e-07, -2.185e-07, -3.217e-07, -3.883e-03, -1.500e-03, 6.819e-04, -6.391e-04, 8.959e-03, -6.730e-03, -6.848e-03, -2.396e-03) * s0_0_0;
  r0 += mat4x4<f32>(-3.139e-01, 3.573e-01, -7.421e-02, -2.367e-01, -1.290e-07, 8.812e-08, -8.623e-07, 5.537e-07, 1.067e-02, 8.927e-03, -6.301e-04, -4.654e-03, 3.959e-03, 4.633e-02, 7.129e-03, 3.835e-03) * s0_0_1;
  r0 += mat4x4<f32>(-1.325e-02, -1.538e-01, -7.366e-03, 6.785e-04, 1.031e-07, -3.190e-07, 1.196e-06, -1.594e-07, 3.005e-03, 4.086e-03, 3.224e-03, -1.480e-02, 3.055e-04, 1.465e-03, -6.149e-04, -4.676e-03) * s0_0_2;
  r0 += mat4x4<f32>(-8.878e-03, -9.821e-04, 1.096e-01, -3.794e-03, 3.351e-07, -2.068e-03, 1.239e-06, -1.966e-04, 6.028e-02, 3.110e-04, 1.110e-01, 3.410e-03, 1.037e-01, 2.405e-02, 1.284e-01, 6.533e-04) * s0_1_0;
  r0 += mat4x4<f32>(1.207e-02, -1.241e-02, 1.945e-01, 3.271e-01, -1.295e-06, -9.311e-03, 1.318e-04, 1.581e-04, -4.893e-01, 9.114e-02, 1.602e-01, 5.961e-01, 2.548e-01, -6.932e-01, 2.209e-02, -4.812e-02) * s0_1_1;
  r0 += mat4x4<f32>(-4.439e-03, 8.852e-03, 1.795e-02, -2.674e-03, 1.064e-06, 1.140e-02, -1.323e-04, 3.804e-05, 8.667e-03, -2.150e-01, -2.854e-02, -6.806e-02, 1.164e-02, 1.255e-01, 4.803e-03, 1.019e-02) * s0_1_2;
  r0 += mat4x4<f32>(-2.768e-05, 1.131e-04, -3.375e-04, 2.552e-07, 4.732e-03, -3.805e-04, 1.789e-03, 1.529e-03, 1.551e-03, 6.016e-05, -3.849e-02, -6.007e-03, -3.805e-03, 2.920e-03, 3.716e-02, -2.673e-03) * s0_2_0;
  r0 += mat4x4<f32>(1.358e-04, -1.404e-04, -6.103e-03, -4.832e-04, -3.505e-01, 2.370e-02, -1.042e-01, -1.921e-02, 6.589e-03, 4.104e-03, -9.547e-02, -8.447e-02, -3.214e-03, 2.240e-02, -9.908e-02, -3.365e-01) * s0_2_1;
  r0 += mat4x4<f32>(-3.990e-06, -3.952e-06, 2.283e-03, -1.580e-03, 1.745e-02, -6.855e-01, 7.016e-02, 3.044e-01, 2.304e-03, -6.626e-04, 2.136e-02, -3.143e-02, 2.451e-03, -4.946e-03, -1.381e-02, 7.494e-03) * s0_2_2;
  r0 += mat4x4<f32>(2.101e-02, 8.086e-06, -1.418e-02, -1.513e-03, 2.097e-03, 1.218e-03, -8.258e-03, -7.411e-04, -6.468e-02, 2.912e-03, -3.844e-03, -2.964e-03, 4.454e-02, 2.831e-03, 2.538e-03, 2.714e-03) * s1_0_0;
  r0 += mat4x4<f32>(-4.562e-02, 5.503e-02, 2.661e-02, 1.529e-03, -6.190e-02, 2.581e-02, 1.711e-02, 1.976e-03, -1.064e-01, -2.280e-01, 2.075e-03, 1.422e-02, 2.725e-01, 1.950e-01, -1.562e-02, 4.893e-03) * s1_0_1;
  r0 += mat4x4<f32>(5.021e-03, -1.778e-02, -3.090e-04, -1.526e-02, -1.413e-02, 6.117e-03, -9.800e-03, -1.895e-02, -7.460e-03, -3.119e-02, -5.146e-03, 9.612e-03, -4.132e-03, 7.254e-02, 2.927e-03, 6.278e-03) * s1_0_2;
  r0 += mat4x4<f32>(3.689e-02, 1.056e-02, 4.516e-02, -1.052e-02, 8.769e-03, 1.687e-03, 7.560e-03, 6.384e-04, -7.053e-02, 5.967e-03, -9.399e-02, 1.409e-02, -4.725e-02, -2.427e-02, -1.140e-01, -1.150e-02) * s1_1_0;
  r0 += mat4x4<f32>(2.391e-01, 2.252e-01, -8.145e-01, -1.859e-02, -3.330e-01, -1.535e-02, -3.662e-01, 1.404e-03, 5.684e-01, 6.219e-02, 7.237e-02, -4.071e-01, -1.978e-01, -1.825e-01, 5.882e-01, -1.812e-01) * s1_1_1;
  r0 += mat4x4<f32>(-1.739e-02, -3.925e-02, 1.183e-02, -2.045e-01, 1.211e-02, 4.067e-01, 3.819e-02, 3.136e-01, -5.208e-03, 1.247e-01, 2.798e-02, 4.583e-02, 3.473e-03, 2.618e-02, -2.886e-02, 1.554e-01) * s1_1_2;
  r0 += mat4x4<f32>(6.890e-04, -5.187e-04, 2.202e-02, 1.943e-03, -3.007e-03, -1.668e-03, 5.449e-03, 9.238e-05, -5.150e-03, 2.220e-03, -3.884e-03, 4.636e-03, -8.638e-04, 9.015e-05, -2.889e-02, -5.227e-03) * s1_2_0;
  r0 += mat4x4<f32>(1.531e-03, 4.723e-03, 6.714e-02, 3.290e-02, 4.806e-03, 7.509e-03, -9.137e-02, 1.244e-02, -5.932e-03, -8.205e-03, 9.082e-02, 4.309e-02, 8.945e-04, -8.047e-03, -3.722e-02, -7.220e-03) * s1_2_1;
  r0 += mat4x4<f32>(-1.170e-03, 7.123e-03, -1.159e-02, -1.777e-02, -2.442e-04, -1.921e-02, -2.884e-02, 7.229e-02, 1.425e-03, -1.869e-03, -2.775e-03, 2.045e-02, -9.966e-04, -2.167e-03, -3.166e-03, 8.534e-03) * s1_2_2;
  r0 += vec4f(1.471e-09, -2.972e-10, -1.438e-08, -1.472e-08);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

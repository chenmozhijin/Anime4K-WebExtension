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

  let outBase = vec2i(pixel.xy) * vec2i(3, 2);

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
  var r4: vec4f;
  var r5: vec4f;
  r0 = vec4f(0.0);
  r1 = vec4f(0.0);
  r2 = vec4f(0.0);
  r3 = vec4f(0.0);
  r4 = vec4f(0.0);
  r5 = vec4f(0.0);
  s0_0_0 = G[0][localId.y + 0u][localId.x + 0u];
  s0_0_1 = G[0][localId.y + 0u][localId.x + 1u];
  s0_0_2 = G[0][localId.y + 0u][localId.x + 2u];
  s0_1_0 = G[0][localId.y + 1u][localId.x + 0u];
  s0_1_1 = G[0][localId.y + 1u][localId.x + 1u];
  s0_1_2 = G[0][localId.y + 1u][localId.x + 2u];
  s0_2_0 = G[0][localId.y + 2u][localId.x + 0u];
  s0_2_1 = G[0][localId.y + 2u][localId.x + 1u];
  s0_2_2 = G[0][localId.y + 2u][localId.x + 2u];
  r0 += vec4f(3.740e-01, 4.973e-02, 2.509e-01, -1.253e-01) * s0_0_0;
  r1 += vec4f(-1.306e-01, -1.102e-01, -2.294e-02, -2.572e-02) * s0_0_0;
  r2 += vec4f(4.476e-02, 1.074e-03, 7.434e-02, -4.985e-03) * s0_0_0;
  r3 += vec4f(6.482e-03, -3.101e-02, -1.087e-01, -1.751e-02) * s0_0_0;
  r4 += vec4f(1.883e-03, 4.751e-03, -4.526e-02, 1.453e-02) * s0_0_0;
  r5 += vec4f(1.111e-01, 5.530e-03, 1.424e-01, 4.305e-02) * s0_0_0;
  r0 += vec4f(-9.029e-03, 1.178e-01, 5.943e-01, 1.597e-02) * s0_0_1;
  r1 += vec4f(-1.587e-01, -6.901e-03, -1.875e-01, -2.035e-02) * s0_0_1;
  r2 += vec4f(-5.730e-02, -1.581e-02, 4.905e-01, -3.479e-02) * s0_0_1;
  r3 += vec4f(-2.860e-02, -2.355e-02, -3.947e-02, 1.724e-02) * s0_0_1;
  r4 += vec4f(-7.069e-03, -5.793e-04, 1.003e-01, -1.733e-01) * s0_0_1;
  r5 += vec4f(8.542e-03, -5.306e-02, 2.939e-01, -9.433e+00) * s0_0_1;
  r0 += vec4f(1.155e-03, 8.604e-02, 8.940e-02, 1.082e-01) * s0_0_2;
  r1 += vec4f(2.615e-02, -6.843e-02, 6.785e-02, -3.086e-02) * s0_0_2;
  r2 += vec4f(5.022e-03, 5.368e-03, -5.652e-01, 5.414e-03) * s0_0_2;
  r3 += vec4f(1.994e-02, -3.220e-02, 1.149e-02, -1.079e-02) * s0_0_2;
  r4 += vec4f(1.334e-03, -3.878e-03, -3.708e-02, 9.282e-03) * s0_0_2;
  r5 += vec4f(-1.216e-01, 3.491e-02, -2.242e-02, 4.398e-02) * s0_0_2;
  r0 += vec4f(-2.474e-03, -2.228e-02, -2.504e-01, -2.647e-01) * s0_1_0;
  r1 += vec4f(-4.285e-02, -6.169e-02, 2.592e-01, -1.301e-02) * s0_1_0;
  r2 += vec4f(2.183e-02, -2.030e-02, -7.102e-02, -1.626e-01) * s0_1_0;
  r3 += vec4f(1.428e-02, -3.065e-02, -2.979e-01, 7.601e-03) * s0_1_0;
  r4 += vec4f(7.687e-03, -5.972e-03, -3.790e-02, -2.581e-02) * s0_1_0;
  r5 += vec4f(2.153e-01, 1.562e-01, 6.313e-02, 1.196e-02) * s0_1_0;
  r0 += vec4f(-3.697e-01, -6.152e-01, -5.215e-01, -2.866e-01) * s0_1_1;
  r1 += vec4f(2.276e-01, 2.450e-01, 1.558e-01, 7.699e-01) * s0_1_1;
  r2 += vec4f(-5.215e-01, 1.354e-02, -4.747e-01, -6.168e-01) * s0_1_1;
  r3 += vec4f(-1.808e-03, -1.696e-02, 5.484e-01, 3.205e-01) * s0_1_1;
  r4 += vec4f(1.483e-02, 4.196e-01, 1.611e-02, 2.849e-01) * s0_1_1;
  r5 += vec4f(2.685e-01, -4.226e-01, -4.470e-01, 6.919e-02) * s0_1_1;
  r0 += vec4f(7.037e-03, 2.362e-01, -1.072e-01, 5.635e-01) * s0_1_2;
  r1 += vec4f(-3.094e-02, 9.830e-03, -8.536e-02, -1.035e-02) * s0_1_2;
  r2 += vec4f(1.816e-01, 4.901e-01, 5.488e-01, -9.348e-02) * s0_1_2;
  r3 += vec4f(-9.309e-03, -3.585e-02, -7.981e-02, -3.507e-01) * s0_1_2;
  r4 += vec4f(1.732e-03, 7.693e-03, 4.553e-02, -9.452e-02) * s0_1_2;
  r5 += vec4f(-4.815e-01, -5.849e-02, -2.105e-02, -1.148e-02) * s0_1_2;
  r0 += vec4f(-6.671e-04, 2.963e-02, -4.417e-03, -9.594e-02) * s0_2_0;
  r1 += vec4f(1.859e-02, -1.545e-01, -2.407e-01, -2.653e-02) * s0_2_0;
  r2 += vec4f(-5.316e-02, 5.674e-03, -5.156e-03, 1.656e-01) * s0_2_0;
  r3 += vec4f(5.548e-01, -1.705e-02, -1.379e-02, -2.229e-02) * s0_2_0;
  r4 += vec4f(-7.970e-03, 8.165e-03, 2.551e-01, -5.277e-03) * s0_2_0;
  r5 += vec4f(1.162e-01, 9.742e-02, -3.594e-02, 2.808e-03) * s0_2_0;
  r0 += vec4f(5.691e-03, -7.121e-03, -6.714e-02, -1.842e-01) * s0_2_1;
  r1 += vec4f(9.211e-02, -4.129e-04, 5.184e-02, -8.111e-03) * s0_2_1;
  r2 += vec4f(1.323e-01, -2.203e-02, -1.268e-02, 6.677e-01) * s0_2_1;
  r3 += vec4f(-5.410e-01, 9.288e-01, -1.927e-02, 5.135e-02) * s0_2_1;
  r4 += vec4f(-5.862e-01, -4.189e-01, -5.605e-01, -1.284e-02) * s0_2_1;
  r5 += vec4f(1.520e-01, 1.415e-01, -1.717e-02, 1.089e-02) * s0_2_1;
  r0 += vec4f(-6.056e-03, 4.550e-02, 1.638e-02, 2.715e-01) * s0_2_2;
  r1 += vec4f(3.547e-03, -3.784e-02, 2.234e-02, -2.946e-02) * s0_2_2;
  r2 += vec4f(2.403e-01, 1.203e-02, 1.849e-02, 7.598e-02) * s0_2_2;
  r3 += vec4f(-1.406e-02, -1.296e-02, 4.018e-03, 6.456e-03) * s0_2_2;
  r4 += vec4f(5.762e-01, -4.939e-03, 4.026e-02, -5.964e-03) * s0_2_2;
  r5 += vec4f(-2.652e-01, 5.085e-02, 3.051e-02, 2.065e-02) * s0_2_2;
  r0 += vec4f(1.760e-03, -7.020e-03, 5.201e-03, 5.904e-03);
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
  r1 += vec4f(-1.471e-02, -3.198e-03, -3.398e-02, -7.817e-01);
  r1 = clamp(r1, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), r1);
  r2 += vec4f(-8.038e-04, -4.526e-01, -1.524e-03, 5.932e-03);
  r2 = clamp(r2, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 0), r2);
  r3 += vec4f(3.682e-03, -9.459e-01, 2.800e-03, 7.637e-03);
  r3 = clamp(r3, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), r3);
  r4 += vec4f(8.970e-03, 4.212e-03, -7.919e-03, 3.061e-02);
  r4 = clamp(r4, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), r4);
  r5 += vec4f(3.218e-03, -2.311e-03, -1.346e-02, 1.622e-02);
  r5 = clamp(r5, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(2, 1), r5);
}

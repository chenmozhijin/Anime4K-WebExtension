// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv1: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv1_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv1)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv1, sourceCoord * packedScale + lane, 0);
}

@group(0) @binding(2) var linearSampler: sampler;
@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;
var<workgroup> G: array<array<array<vec4f, 10>, 10>, 2>;


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let sourceSize = textureDimensions(tex_LUMA);

  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      G[0][tileY][tileX] = sample_conv1_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(0, 0), vec2i(2, 1));
      G[1][tileY][tileX] = sample_conv1_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(1, 0), vec2i(2, 1));
    }
  }
  workgroupBarrier();

  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let outBase = vec2i(pixel.xy) * vec2i(1, 1);

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
  r0 += mat4x4<f32>(2.165e-02, 3.026e-02, 4.051e-02, 3.915e-02, -8.661e-02, -4.209e-02, -9.197e-02, -8.715e-02, -1.757e-02, 3.272e-02, 2.691e-02, 3.720e-02, -3.657e-02, -3.421e-02, 9.457e-02, -9.498e-02) * s0_0_0;
  r0 += mat4x4<f32>(-3.844e-03, 1.111e-01, -2.155e-01, 8.561e-02, 1.378e-01, -1.463e-02, -2.997e-01, -1.721e-01, -3.336e-02, 6.568e-03, -1.558e-01, -1.757e-01, 1.859e-01, -1.530e-01, 2.372e-01, -5.114e-02) * s0_0_1;
  r0 += mat4x4<f32>(-1.593e-01, 1.325e-02, -9.455e-02, 2.536e-02, -1.508e-01, -1.444e-02, 5.664e-02, 6.149e-02, -5.230e-02, 7.373e-03, 9.302e-02, 1.058e-01, -2.542e-02, -5.521e-02, 8.569e-02, -8.126e-02) * s0_0_2;
  r0 += mat4x4<f32>(7.059e-03, -2.256e-01, -3.135e-01, -6.569e-02, -4.626e-02, -6.717e-03, -2.683e-02, 3.845e-02, 5.796e-02, -3.883e-01, -2.855e-02, -7.155e-02, -5.518e-02, 1.636e-01, 1.162e-01, 4.832e-02) * s0_1_0;
  r0 += mat4x4<f32>(-3.423e-01, -3.567e-01, 1.446e-02, -4.825e-01, -3.835e-01, -3.271e-01, -1.225e-01, -3.975e-01, -1.139e-01, -6.856e-02, -3.757e-02, -3.596e-01, 1.564e-01, 1.209e-02, -2.389e-01, 9.043e-02) * s0_1_1;
  r0 += mat4x4<f32>(-7.499e-02, -1.461e-01, -1.823e-02, -2.821e-01, -1.620e-02, 1.028e-01, 6.275e-03, 7.592e-02, 1.056e-01, 9.988e-02, 2.519e-02, 1.703e-01, -1.373e-01, 2.056e-02, -1.912e-02, 1.412e-02) * s0_1_2;
  r0 += mat4x4<f32>(-1.091e-02, -1.138e-01, -3.009e-02, -1.811e-01, -4.826e-02, -1.227e-01, 2.871e-02, -5.174e-02, -1.070e-02, 1.071e-01, 3.567e-02, 4.503e-02, -6.667e-02, -2.303e-01, 3.178e-02, -8.346e-02) * s0_2_0;
  r0 += mat4x4<f32>(-1.034e-01, -4.693e-02, -3.141e-04, -5.685e-02, -1.026e-01, -7.886e-02, 4.021e-03, -8.618e-02, 4.561e-02, 2.164e-02, -3.332e-02, 1.561e-02, 3.133e-01, 4.816e-02, 8.110e-04, 1.741e-01) * s0_2_1;
  r0 += mat4x4<f32>(-7.156e-02, -3.047e-02, -1.382e-02, -6.068e-02, -3.332e-02, -1.972e-02, 3.408e-05, -5.339e-02, 5.886e-02, 7.158e-02, -6.510e-03, 6.955e-02, 6.617e-02, 4.597e-02, 1.283e-02, 2.872e-02) * s0_2_2;
  r0 += mat4x4<f32>(3.012e-02, -2.653e-02, 1.491e-02, 2.057e-02, 1.995e-02, -2.607e-02, 2.725e-01, 5.896e-02, 3.895e-03, 1.388e-02, 1.098e-02, 1.906e-02, 1.514e-02, -4.564e-02, -7.828e-02, -1.521e-02) * s1_0_0;
  r0 += mat4x4<f32>(-5.846e-03, -5.346e-03, -1.548e-01, -2.817e-02, -1.377e-01, -8.246e-02, 1.596e-01, -1.051e-01, 2.435e-02, -2.421e-02, -6.735e-02, -5.897e-02, -3.703e-02, 1.571e-02, -7.368e-02, 3.135e-02) * s1_0_1;
  r0 += mat4x4<f32>(-9.886e-03, -5.964e-03, -1.232e-03, -2.480e-02, 1.056e-01, 3.212e-02, -2.059e-01, -2.742e-02, -4.285e-02, -5.957e-03, -2.441e-02, -2.021e-02, 1.097e-03, -2.363e-02, 7.662e-03, -1.922e-02) * s1_0_2;
  r0 += mat4x4<f32>(2.475e-02, 1.587e-01, 4.623e-02, 2.221e-01, 9.528e-02, 6.513e-02, -1.196e-01, -1.614e-02, -1.004e-01, 3.769e-01, 2.771e-01, 2.510e-01, 1.271e-02, -2.648e-01, -4.736e-02, -8.565e-02) * s1_1_0;
  r0 += mat4x4<f32>(-4.147e-02, -9.884e-02, -4.189e-01, -3.886e-01, 7.715e-01, 4.817e-01, 3.018e-01, 8.706e-01, -2.961e-02, -5.356e-02, 3.162e-01, 7.178e-02, 7.615e-02, -2.710e-01, 3.433e-01, -3.467e-01) * s1_1_1;
  r0 += mat4x4<f32>(-5.225e-02, -1.094e-03, -4.061e-02, 2.662e-02, 1.853e-01, -1.053e-01, -9.647e-02, -1.398e-01, 5.732e-02, -5.526e-03, 3.870e-02, 1.720e-02, -6.596e-02, -3.064e-02, -2.771e-02, -7.296e-02) * s1_1_2;
  r0 += mat4x4<f32>(4.133e-02, 9.448e-03, -1.685e-02, 1.614e-02, 7.545e-02, 8.521e-02, -7.719e-02, 2.543e-02, 6.839e-02, 1.392e-01, -7.152e-02, 7.443e-02, 9.340e-03, 1.538e-02, -3.676e-02, -4.460e-02) * s1_2_0;
  r0 += mat4x4<f32>(-9.161e-02, -3.467e-01, 5.091e-02, -2.385e-01, -3.661e-02, 1.258e-01, 4.126e-04, 6.453e-02, -3.546e-02, 2.008e-01, 5.913e-03, 1.685e-01, 1.245e-01, 3.584e-01, -5.790e-02, 3.434e-01) * s1_2_1;
  r0 += mat4x4<f32>(-3.213e-02, -2.484e-02, -7.514e-03, -4.339e-02, -3.755e-02, -8.872e-02, 4.703e-03, -8.078e-02, 4.865e-03, 9.485e-03, 6.023e-03, 1.481e-02, -7.209e-03, -5.040e-02, -7.514e-03, 5.677e-02) * s1_2_2;
  r0 = clamp(r0, vec4f(0.0), vec4f(1.0));
  textureStore(out_tex, outBase + vec2i(0, 0), r0);
}

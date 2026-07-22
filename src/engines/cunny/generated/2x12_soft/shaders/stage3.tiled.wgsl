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
var<workgroup> G: array<array<array<vec4f, 10>, 10>, 3>;

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
      G[0][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(0, 0), vec2i(3, 1));
      G[1][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(1, 0), vec2i(3, 1));
      G[2][tileY][tileX] = sample_conv2_vec4(pixel.xy, vec2i(i32(tileX), i32(tileY)) - vec2i(localId.xy) - vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
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
  r0 += mat4x4<f32>(4.249e-01, -3.457e-01, 7.591e-02, -1.341e-01, 1.134e-02, -4.834e-03, -6.176e-03, -2.530e-04, -8.778e-02, 1.381e-02, -2.979e-04, 5.270e-04, 5.636e-04, -3.071e-04, -6.583e-04, -3.970e-04) * s0_0_0;
  r0 += mat4x4<f32>(-2.662e-03, 2.157e-02, -5.385e-04, 1.591e-02, 6.461e-02, 5.461e-02, -9.771e-03, -9.916e-03, 8.772e-02, -7.791e-02, 2.913e-04, 2.959e-02, 4.093e-03, 8.392e-03, 1.747e-03, 4.878e-04) * s0_0_1;
  r0 += mat4x4<f32>(-3.848e-06, -4.384e-06, 4.099e-07, -6.047e-06, -3.164e-03, 2.138e-02, 1.293e-03, -4.130e-03, -1.016e-03, 1.246e-02, -2.369e-04, -4.543e-03, -3.947e-05, -2.621e-03, 2.396e-05, -8.012e-05) * s0_0_2;
  r0 += mat4x4<f32>(1.246e-02, -4.553e-02, 2.425e-01, -1.907e-01, 3.525e-02, -5.991e-03, 2.490e-02, -1.336e-02, 1.292e-01, 8.481e-03, -6.671e-02, 2.906e-02, -4.638e-04, 1.900e-03, 1.423e-02, -6.533e-03) * s0_1_0;
  r0 += mat4x4<f32>(-3.462e-03, -1.148e-02, 1.663e-03, 1.890e-03, 9.805e-02, 1.723e-01, 1.937e-01, 2.608e-01, 1.248e-01, 1.714e-01, 5.971e-03, -5.566e-01, -7.629e-02, -1.304e-01, -1.516e-02, -3.602e-03) * s0_1_1;
  r0 += mat4x4<f32>(4.661e-06, -2.822e-05, -6.296e-07, 3.450e-06, -8.437e-03, 9.301e-03, -1.314e-02, 2.877e-02, 9.105e-03, 6.973e-02, -1.560e-04, 3.828e-02, -9.424e-03, 4.507e-02, 5.978e-03, -9.546e-03) * s0_1_2;
  r0 += mat4x4<f32>(-6.098e-04, -4.599e-05, 1.205e-02, -1.023e-02, -2.526e-03, 3.622e-03, 8.231e-03, 2.374e-03, -1.785e-03, -2.773e-03, 2.912e-02, -7.355e-04, 5.620e-03, 9.968e-04, 3.455e-02, 3.115e-03) * s0_2_0;
  r0 += mat4x4<f32>(-3.546e-05, -4.312e-04, -6.319e-05, -2.592e-03, -1.796e-02, -2.253e-02, -3.143e-02, -2.316e-02, 6.567e-03, 2.983e-04, 5.040e-02, 1.299e-02, -2.144e-02, 1.245e-02, -4.187e-01, 2.167e-02) * s0_2_1;
  r0 += mat4x4<f32>(-5.920e-07, 2.248e-07, -1.374e-07, -5.938e-07, 9.086e-04, -3.072e-03, -1.539e-03, 4.156e-03, 1.299e-03, -7.871e-04, 4.377e-04, 3.998e-02, 1.323e-02, -7.030e-02, -1.234e-02, -7.450e-02) * s0_2_2;
  r0 += mat4x4<f32>(2.481e-02, 1.660e-03, -2.832e-04, -2.047e-03, 2.554e-02, 5.075e-03, -5.785e-03, -6.690e-04, -3.446e-02, -6.909e-04, -1.838e-03, 1.554e-03, 6.578e-03, 7.055e-04, -3.060e-04, 3.240e-05) * s1_0_0;
  r0 += mat4x4<f32>(-4.244e-02, 1.219e-01, -4.918e-03, 1.674e-03, 8.569e-02, 1.189e-01, -1.377e-03, 1.437e-03, -6.777e-02, -1.724e-01, -2.668e-02, 7.020e-03, 5.608e-02, 1.250e-02, -3.215e-03, 3.796e-03) * s1_0_1;
  r0 += mat4x4<f32>(-1.082e-03, 5.718e-03, 2.147e-03, -1.112e-02, -9.906e-04, 2.704e-02, 2.456e-04, -7.119e-04, 9.025e-04, 3.168e-02, -1.690e-04, 7.354e-03, 6.277e-03, 2.999e-02, -3.101e-03, 9.560e-04) * s1_0_2;
  r0 += mat4x4<f32>(6.648e-02, 4.312e-03, 5.718e-02, 2.617e-03, -1.753e-01, -1.251e-03, -3.009e-02, -5.551e-03, -9.351e-02, -4.959e-03, -7.695e-02, 7.611e-04, -9.992e-03, -3.980e-03, 9.832e-04, 4.663e-03) * s1_1_0;
  r0 += mat4x4<f32>(-4.010e-01, -2.975e-02, -3.799e-01, 3.364e-01, 1.406e-02, -3.897e-01, 3.442e-01, 2.920e-01, 2.132e-01, 2.634e-02, 1.631e-01, -4.756e-01, -6.426e-01, -1.333e-02, 2.172e-01, 4.797e-02) * s1_1_1;
  r0 += mat4x4<f32>(4.236e-04, 1.509e-01, 3.787e-03, 1.165e-01, -2.784e-03, 9.932e-02, -1.619e-03, 9.244e-02, 1.189e-03, 1.031e-01, 2.305e-03, 1.337e-01, 9.335e-03, -2.074e-01, -2.405e-02, 8.515e-02) * s1_1_2;
  r0 += mat4x4<f32>(-3.805e-04, -1.806e-03, 7.601e-03, 3.036e-03, 2.002e-03, 2.594e-03, -5.504e-02, 1.433e-03, 5.855e-04, 1.177e-03, -1.248e-02, -4.754e-03, 1.528e-03, -1.541e-03, 6.347e-03, -2.104e-03) * s1_2_0;
  r0 += mat4x4<f32>(1.309e-03, 6.058e-05, -1.001e-01, -7.154e-02, -3.519e-03, 4.345e-03, -8.674e-02, -1.305e-01, 1.125e-03, -1.404e-03, 6.427e-02, 9.282e-02, 9.884e-03, 3.839e-03, 4.545e-04, 7.587e-02) * s1_2_1;
  r0 += mat4x4<f32>(1.088e-03, -2.846e-03, -5.854e-03, 1.935e-02, 1.838e-03, 1.435e-02, -4.744e-03, 7.629e-03, 7.239e-05, 8.069e-04, -9.010e-05, 4.534e-02, -1.518e-04, -9.850e-03, 6.338e-03, -4.554e-03) * s1_2_2;
  s0_0_0 = G[2][localId.y + 0u][localId.x + 0u];
  s0_0_1 = G[2][localId.y + 0u][localId.x + 1u];
  s0_0_2 = G[2][localId.y + 0u][localId.x + 2u];
  s0_1_0 = G[2][localId.y + 1u][localId.x + 0u];
  s0_1_1 = G[2][localId.y + 1u][localId.x + 1u];
  s0_1_2 = G[2][localId.y + 1u][localId.x + 2u];
  s0_2_0 = G[2][localId.y + 2u][localId.x + 0u];
  s0_2_1 = G[2][localId.y + 2u][localId.x + 1u];
  s0_2_2 = G[2][localId.y + 2u][localId.x + 2u];
  r0 += mat4x4<f32>(9.171e-02, 1.642e-02, -9.102e-03, 5.379e-04, 1.775e-02, 6.663e-04, 1.678e-02, 1.738e-03, 2.972e-02, -9.126e-03, 4.898e-03, -7.337e-04, 6.405e-04, -2.220e-03, 2.865e-03, -8.054e-04) * s0_0_0;
  r0 += mat4x4<f32>(2.374e-01, 2.488e-01, 6.940e-03, 4.773e-03, -1.492e-01, -5.192e-02, -3.106e-03, -5.454e-03, 5.211e-02, 5.310e-02, 1.811e-02, -1.628e-02, -3.235e-02, 6.131e-02, 1.821e-02, -6.660e-03) * s0_0_1;
  r0 += mat4x4<f32>(-7.334e-03, 4.469e-02, 1.575e-03, -4.722e-03, -4.113e-04, -4.259e-02, -5.982e-04, 2.925e-03, -4.922e-04, -1.287e-02, 1.674e-05, -3.481e-04, -8.257e-03, -5.065e-02, 1.732e-03, -3.609e-03) * s0_0_2;
  r0 += mat4x4<f32>(-1.411e-02, -5.164e-03, -9.227e-02, 1.208e-02, -1.164e-02, -5.501e-03, 5.257e-03, -4.676e-03, 3.047e-01, 1.672e-02, 2.768e-01, -3.095e-03, 1.004e-02, 1.037e-03, 3.971e-02, -8.777e-03) * s0_1_0;
  r0 += mat4x4<f32>(7.288e-03, -1.042e-02, -2.433e-01, -3.641e-01, 7.553e-02, 5.586e-01, -2.627e-01, 2.050e-01, -1.441e-01, -2.268e-01, -9.550e-02, 1.557e-01, 3.564e-01, -2.725e-01, -3.482e-01, 1.332e-01) * s0_1_1;
  r0 += mat4x4<f32>(1.286e-03, 1.689e-02, 3.874e-04, 1.676e-02, 3.601e-03, -3.588e-02, 1.211e-02, -1.018e-01, 2.605e-04, -7.088e-02, -8.821e-04, -8.037e-02, -1.077e-02, 1.284e-01, 2.640e-02, -1.526e-01) * s0_1_2;
  r0 += mat4x4<f32>(9.674e-04, -3.692e-04, -2.082e-04, -1.211e-03, 2.792e-03, 1.520e-03, 2.494e-03, -1.048e-03, -2.547e-03, -4.282e-03, 3.184e-02, 6.918e-03, -5.338e-03, 7.582e-04, 1.888e-02, -4.045e-03) * s0_2_0;
  r0 += mat4x4<f32>(1.709e-04, 1.016e-03, 3.579e-04, 3.842e-03, -4.962e-03, -8.560e-03, -1.517e-02, 7.340e-02, -1.869e-04, -1.293e-02, -4.600e-02, -1.850e-01, -3.618e-03, 1.018e-02, 2.329e-01, 1.202e-01) * s0_2_1;
  r0 += mat4x4<f32>(-1.519e-04, -2.562e-04, -2.240e-05, -9.021e-04, 4.172e-04, -1.682e-03, 2.635e-04, -3.317e-02, -6.340e-04, 6.472e-04, 1.322e-04, -3.302e-02, -1.102e-03, 8.252e-04, 1.285e-03, 3.800e-02) * s0_2_2;
  r0 += vec4f(-1.415e-09, 4.971e-09, -5.230e-12, 5.916e-11);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

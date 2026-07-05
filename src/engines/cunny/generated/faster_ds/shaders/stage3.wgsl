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

fn sample_original_luma(coord: vec2i) -> f32 {
  let outputSize = textureDimensions(out_tex);
  let uv = (vec2f(coord) + vec2f(0.5)) / vec2f(outputSize);
  return luma709(textureSampleLevel(tex_LUMA, linearSampler, uv, 0.0).rgb);
}


@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_LUMA);
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
  s0_0_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, -1), vec2i(0, 0), vec2i(2, 1));
  s0_0_1 = sample_conv2_vec4(pixel.xy, vec2i(0, -1), vec2i(0, 0), vec2i(2, 1));
  s0_0_2 = sample_conv2_vec4(pixel.xy, vec2i(1, -1), vec2i(0, 0), vec2i(2, 1));
  s0_1_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 0), vec2i(0, 0), vec2i(2, 1));
  s0_1_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 0), vec2i(0, 0), vec2i(2, 1));
  s0_1_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 0), vec2i(0, 0), vec2i(2, 1));
  s0_2_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 1), vec2i(0, 0), vec2i(2, 1));
  s0_2_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 1), vec2i(0, 0), vec2i(2, 1));
  s0_2_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 1), vec2i(0, 0), vec2i(2, 1));
  s1_0_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, -1), vec2i(1, 0), vec2i(2, 1));
  s1_0_1 = sample_conv2_vec4(pixel.xy, vec2i(0, -1), vec2i(1, 0), vec2i(2, 1));
  s1_0_2 = sample_conv2_vec4(pixel.xy, vec2i(1, -1), vec2i(1, 0), vec2i(2, 1));
  s1_1_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 0), vec2i(1, 0), vec2i(2, 1));
  s1_1_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 0), vec2i(1, 0), vec2i(2, 1));
  s1_1_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 0), vec2i(1, 0), vec2i(2, 1));
  s1_2_0 = sample_conv2_vec4(pixel.xy, vec2i(-1, 1), vec2i(1, 0), vec2i(2, 1));
  s1_2_1 = sample_conv2_vec4(pixel.xy, vec2i(0, 1), vec2i(1, 0), vec2i(2, 1));
  s1_2_2 = sample_conv2_vec4(pixel.xy, vec2i(1, 1), vec2i(1, 0), vec2i(2, 1));
  r0 += mat4x4<f32>(-3.405e-02, 1.866e-03, -4.929e-03, 2.498e-03, 1.344e-03, 1.597e-03, 1.249e-06, 1.194e-03, 4.480e-02, 1.199e-02, 2.597e-03, 3.033e-03, 1.905e-03, 2.746e-04, 5.966e-04, 1.858e-04) * s0_0_0;
  r0 += mat4x4<f32>(9.978e-03, -1.261e-01, 1.023e-02, 3.649e-02, 1.247e-02, 5.682e-04, 1.964e-03, -5.054e-03, 3.254e-02, 8.324e-02, -5.706e-04, -3.023e-03, -1.341e-03, 1.164e-03, -2.312e-03, -3.004e-04) * s0_0_1;
  r0 += mat4x4<f32>(-8.513e-03, 7.948e-03, -6.436e-03, 8.153e-03, 3.006e-02, 8.032e-02, 1.221e-02, -1.041e-02, 6.844e-04, 1.297e-02, -1.457e-04, -3.221e-03, 1.181e-03, 6.044e-06, 1.719e-03, 6.203e-04) * s0_0_2;
  r0 += mat4x4<f32>(-8.863e-02, -1.372e-02, -1.005e-01, -4.049e-03, -4.020e-03, -6.467e-04, 3.124e-03, 1.076e-03, -2.192e-01, -4.211e-02, 1.544e-02, -2.595e-02, 7.494e-02, 1.773e-02, 1.083e-02, 4.929e-05) * s0_1_0;
  r0 += mat4x4<f32>(3.623e-01, -2.477e-01, 3.233e-01, -4.131e-01, 2.759e-01, 2.544e-02, 1.938e-01, 8.423e-03, -6.395e-02, -5.025e-01, 2.066e-01, 2.500e-01, 2.303e-01, 2.158e-01, -5.981e-03, 2.667e-02) * s0_1_1;
  r0 += mat4x4<f32>(-3.041e-03, 1.372e-01, 8.653e-03, 9.107e-02, -5.238e-02, -3.584e-01, -4.477e-02, -2.582e-02, -1.886e-02, 2.521e-02, -2.874e-03, 1.971e-02, 5.468e-03, 8.579e-02, 1.047e-02, -5.278e-03) * s0_1_2;
  r0 += mat4x4<f32>(-7.336e-03, 1.523e-02, -5.704e-03, -3.667e-03, 7.526e-03, -9.237e-04, -1.955e-03, -2.011e-03, -5.918e-03, 1.658e-02, 2.581e-02, -1.182e-02, 1.295e-02, -1.108e-02, -1.313e-01, 2.127e-02) * s0_2_0;
  r0 += mat4x4<f32>(-2.815e-03, -1.436e-03, 6.285e-02, 1.012e-02, 3.665e-02, 2.656e-03, 1.262e-01, 2.306e-02, 1.212e-02, 1.305e-02, -2.299e-02, 6.118e-02, -4.455e-02, -5.602e-04, -1.577e-01, -3.545e-01) * s0_2_1;
  r0 += mat4x4<f32>(1.194e-03, -2.070e-03, -9.820e-03, 4.030e-02, -6.212e-03, -1.560e-02, -9.035e-03, -2.529e-01, 2.606e-03, 1.139e-02, 8.109e-03, -2.455e-02, 3.804e-03, -1.115e-02, 2.094e-03, 5.976e-02) * s0_2_2;
  r0 += mat4x4<f32>(-6.238e-02, -1.602e-02, -2.519e-04, -3.830e-03, 7.061e-02, -7.334e-03, 3.650e-02, -6.759e-03, 2.757e-03, -5.707e-03, -4.980e-03, -1.400e-03, 3.601e-02, 4.695e-03, 7.937e-03, -1.810e-03) * s1_0_0;
  r0 += mat4x4<f32>(-3.711e-02, -6.958e-02, 7.818e-03, 3.231e-03, -2.212e-01, 2.911e-02, -1.318e-02, -4.430e-02, 5.311e-02, -5.339e-04, -2.148e-02, 1.243e-03, -8.964e-02, 1.333e-01, -8.387e-03, -2.069e-02) * s1_0_1;
  r0 += mat4x4<f32>(-1.642e-02, -3.889e-02, -6.545e-04, 4.715e-03, -6.440e-03, -9.727e-03, -1.740e-03, 2.130e-02, 1.148e-02, -2.855e-02, -6.759e-03, 4.567e-03, 2.785e-03, -1.011e-02, 1.180e-02, 1.256e-03) * s1_0_2;
  r0 += mat4x4<f32>(1.704e-01, 1.137e-02, -2.527e-02, 3.733e-03, 1.131e-02, -1.142e-03, 6.042e-02, -1.138e-02, 7.124e-02, 5.341e-04, 1.970e-02, 9.909e-03, 7.183e-03, 3.415e-03, 7.070e-02, -3.441e-03) * s1_1_0;
  r0 += mat4x4<f32>(6.165e-02, 2.959e-01, -3.409e-01, -3.154e-01, 5.732e-02, 1.684e-01, -3.896e-01, 2.153e-01, -6.450e-01, 1.144e-01, 1.763e-01, 1.618e-01, -7.177e-02, 9.545e-02, -6.819e-01, 2.529e-01) * s1_1_1;
  r0 += mat4x4<f32>(1.359e-02, -6.142e-03, 2.887e-02, -4.918e-02, 2.955e-02, -8.662e-02, 5.206e-02, -7.300e-02, 1.543e-02, 1.431e-01, -4.787e-02, 1.971e-02, 7.697e-03, 4.190e-02, 6.247e-02, 4.181e-03) * s1_1_2;
  r0 += mat4x4<f32>(-3.428e-03, 8.373e-03, 5.969e-02, -5.721e-03, -3.539e-03, 1.404e-03, 1.474e-02, 7.659e-05, 1.503e-02, -1.505e-02, -3.628e-02, 7.339e-03, 5.869e-03, 2.350e-03, 2.973e-02, -2.493e-04) * s1_2_0;
  r0 += mat4x4<f32>(9.620e-03, -1.911e-02, 1.519e-01, 2.104e-01, -5.001e-03, -8.455e-03, 7.251e-02, 4.956e-02, -9.994e-03, -1.741e-02, 6.895e-03, -7.811e-02, -1.069e-02, 2.318e-02, 7.023e-03, 2.020e-02) * s1_2_1;
  r0 += mat4x4<f32>(-1.125e-03, 5.486e-03, -1.731e-03, 2.550e-04, 4.005e-04, 8.647e-03, 1.310e-03, -4.700e-02, 5.754e-03, -2.401e-02, -3.991e-02, 1.232e-01, -3.657e-03, -7.543e-03, 1.154e-02, -6.398e-03) * s1_2_2;
  r0 += vec4f(-1.400e-10, 3.503e-10, 7.918e-10, 1.349e-09);
  r0 = r0;
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

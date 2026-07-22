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
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
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
  r0 += mat4x4<f32>(-8.745e-02, 3.383e-02, 4.779e-03, 1.345e-02, -1.868e-03, 2.867e-03, -2.889e-04, 1.115e-03, 6.221e-02, 2.749e-03, -1.133e-02, -4.452e-03, -3.269e-02, -3.297e-04, 7.234e-03, -4.700e-03) * s0_0_0;
  r0 += mat4x4<f32>(4.776e-01, -2.351e-01, -4.595e-02, -1.193e-01, -2.361e-02, -2.980e-02, 9.339e-04, 3.573e-03, 4.443e-03, -5.262e-02, 2.593e-04, -4.259e-02, 2.009e-02, 3.289e-02, -1.821e-03, 1.233e-02) * s0_0_1;
  r0 += mat4x4<f32>(-6.475e-03, 9.050e-02, 1.046e-02, 8.310e-02, 1.110e-02, 1.366e-02, -7.064e-04, 6.121e-03, -1.315e-03, -1.964e-03, 8.686e-05, -1.607e-03, 6.700e-03, 2.105e-02, -1.192e-03, 2.453e-03) * s0_0_2;
  r0 += mat4x4<f32>(-2.723e-02, 1.998e-02, -4.554e-02, 2.205e-02, -4.439e-02, -4.404e-03, -2.104e-02, 8.697e-03, 2.229e-01, 1.297e-02, 3.286e-01, 9.755e-03, -2.192e-01, 4.147e-03, -1.890e-01, -1.323e-03) * s0_1_0;
  r0 += mat4x4<f32>(9.382e-03, 4.344e-02, 1.685e-01, 7.939e-02, -3.460e-01, -2.019e-01, 4.834e-01, 1.129e-01, -2.867e-02, -2.495e-01, -1.358e-02, 2.568e-01, 2.339e-01, -4.131e-01, 4.346e-01, 6.522e-03) * s0_1_1;
  r0 += mat4x4<f32>(2.435e-04, -3.573e-03, -3.126e-03, 1.075e-02, -3.135e-03, -6.763e-02, -5.822e-03, 1.431e-01, -1.461e-04, -5.105e-03, 2.164e-03, -2.817e-02, -7.371e-03, 1.032e-01, -1.119e-03, 1.146e-01) * s0_1_2;
  r0 += mat4x4<f32>(8.547e-04, 6.011e-04, 1.048e-05, 1.014e-02, -4.715e-04, -1.370e-03, -2.071e-02, -1.915e-03, -1.364e-02, -2.617e-03, 1.969e-02, -4.878e-03, 2.998e-03, 6.190e-03, -3.958e-02, 1.057e-02) * s0_2_0;
  r0 += mat4x4<f32>(7.958e-04, -5.562e-04, 5.722e-03, 1.152e-02, 1.077e-02, 2.148e-03, -1.172e-01, -6.975e-02, -4.030e-03, -9.735e-03, -6.964e-03, -7.798e-02, -7.563e-03, 1.614e-02, 1.546e-02, -1.085e-01) * s0_2_1;
  r0 += mat4x4<f32>(2.204e-04, 1.508e-04, 1.628e-05, 1.893e-03, -4.284e-04, 5.033e-03, -7.737e-03, -3.635e-02, 1.147e-04, -2.175e-03, 1.822e-03, 2.527e-04, 7.215e-04, 1.079e-02, -9.029e-04, 2.809e-02) * s0_2_2;
  r0 += mat4x4<f32>(2.697e-03, -1.313e-03, -1.015e-03, 4.832e-04, 1.273e-02, -1.454e-02, -1.164e-02, 1.968e-04, -1.176e-05, 3.554e-06, -1.848e-07, 6.425e-06, -6.480e-02, 8.408e-03, 5.938e-03, 1.289e-04) * s1_0_0;
  r0 += mat4x4<f32>(2.913e-02, 4.024e-02, -2.495e-03, 7.654e-03, 4.229e-03, -9.018e-02, -8.102e-03, -1.311e-02, -1.756e-03, -1.098e-03, 5.380e-06, -2.058e-05, -2.447e-01, -2.065e-01, 6.129e-03, 7.875e-03) * s1_0_1;
  r0 += mat4x4<f32>(-7.388e-04, -6.594e-03, -3.001e-04, -2.827e-03, 1.036e-03, 3.589e-03, -1.856e-03, -3.167e-03, 3.969e-04, -1.935e-06, -3.594e-06, 2.495e-07, 4.183e-03, -4.137e-02, 1.717e-03, 8.706e-03) * s1_0_2;
  r0 += mat4x4<f32>(4.236e-02, -7.043e-03, 2.397e-02, 6.630e-03, 7.486e-02, -2.240e-02, -6.752e-03, -4.068e-03, 4.342e-02, -4.620e-03, 8.827e-03, 3.317e-04, -8.227e-02, 1.475e-03, -7.788e-02, 6.877e-03) * s1_1_0;
  r0 += mat4x4<f32>(-5.452e-01, 3.314e-01, -9.257e-02, 1.323e-01, 3.059e-02, 7.693e-02, 3.600e-02, -6.459e-01, 2.915e-01, 3.681e-01, 2.526e-04, 1.969e-02, 4.150e-01, 3.682e-01, -2.828e-01, -2.700e-02) * s1_1_1;
  r0 += mat4x4<f32>(1.040e-02, -1.398e-01, -1.829e-03, -2.740e-02, 1.530e-03, 1.808e-02, 4.368e-05, 4.800e-02, -1.787e-02, 3.889e-02, 7.303e-04, -1.238e-02, -4.286e-03, 4.341e-02, 6.535e-03, -7.488e-02) * s1_1_2;
  r0 += mat4x4<f32>(4.696e-04, -2.962e-03, 8.343e-03, 1.359e-03, -8.558e-04, -3.073e-03, -1.854e-04, -1.114e-02, -4.766e-02, 2.779e-03, -1.173e-01, -4.016e-02, 8.598e-03, 3.102e-03, 9.206e-03, 6.121e-03) * s1_2_0;
  r0 += mat4x4<f32>(1.529e-02, -7.346e-03, -1.218e-01, 7.152e-02, 3.859e-03, 4.380e-03, 1.324e-02, 3.100e-02, -4.309e-02, -1.859e-02, -2.529e-01, 2.073e-01, -1.059e-02, 2.768e-03, 1.333e-01, 1.159e-01) * s1_2_1;
  r0 += mat4x4<f32>(-6.572e-04, -7.312e-03, -3.383e-03, -5.428e-02, -6.678e-04, 9.883e-04, -2.315e-03, 2.015e-03, 4.007e-04, -7.839e-03, -4.416e-03, -6.325e-02, -3.776e-05, -4.929e-03, 6.210e-03, 3.366e-02) * s1_2_2;
  r0 += vec4f(-1.011e-09, -5.997e-09, 3.794e-09, 4.918e-10);
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

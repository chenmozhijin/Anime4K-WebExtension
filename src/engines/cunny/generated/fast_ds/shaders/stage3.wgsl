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
  r0 += mat4x4<f32>(8.367e-04, 3.418e-04, 2.753e-03, 1.262e-03, 6.641e-02, 1.588e-02, 7.737e-03, 7.618e-03, 2.245e-03, 2.971e-03, 6.250e-03, 4.485e-03, -2.634e-02, -6.611e-03, 1.609e-03, -2.612e-03) * s0_0_0;
  r0 += mat4x4<f32>(-1.382e-01, -2.254e-02, -1.933e-03, -4.501e-03, 1.212e-01, 1.567e-01, -2.740e-03, 3.883e-03, -1.085e-02, -4.038e-03, -3.825e-03, 8.270e-03, -7.709e-02, -3.653e-02, 1.498e-03, 2.610e-03) * s0_0_1;
  r0 += mat4x4<f32>(-1.738e-01, -2.998e-01, -1.813e-02, -1.846e-02, -7.187e-04, 3.746e-02, -2.336e-03, 4.134e-04, 2.661e-03, -2.190e-03, -2.805e-02, -3.186e-02, 2.709e-03, -2.030e-02, 2.941e-03, 3.595e-03) * s0_0_2;
  r0 += mat4x4<f32>(9.860e-05, 6.208e-03, -7.769e-04, 3.451e-03, -1.828e-01, -1.513e-02, -1.421e-01, -2.109e-02, -6.373e-03, 1.224e-03, -6.534e-03, 2.165e-03, -2.646e-01, -2.946e-02, -1.950e-01, -2.545e-02) * s0_1_0;
  r0 += mat4x4<f32>(1.890e-02, -1.995e-02, 8.862e-02, 1.423e-02, 9.644e-02, -3.492e-01, 2.095e-01, 2.432e-03, 8.343e-03, -3.085e-02, 6.730e-03, -3.022e-02, -1.913e-02, 4.352e-01, -1.038e-01, 1.944e-01) * s0_1_1;
  r0 += mat4x4<f32>(-3.157e-03, 4.730e-02, 2.264e-01, 2.686e-01, 4.420e-03, 5.768e-02, 2.212e-04, 7.554e-02, 1.091e-01, 1.086e-01, 1.047e-01, 1.032e-01, -5.512e-03, -2.680e-02, -8.009e-04, -3.918e-02) * s0_1_2;
  r0 += mat4x4<f32>(1.805e-03, 6.204e-04, 5.042e-03, 2.847e-03, -5.171e-03, -1.513e-03, -4.456e-02, 2.166e-03, 3.317e-03, 3.381e-03, -1.679e-03, 1.177e-03, 3.585e-02, 7.146e-03, -1.126e-02, 6.312e-03) * s0_2_0;
  r0 += mat4x4<f32>(1.895e-03, 2.539e-03, -1.010e-02, 2.173e-04, 1.245e-02, -6.488e-03, -5.749e-02, -1.306e-01, -1.067e-02, -5.183e-04, -1.427e-02, -1.411e-02, -9.165e-03, 2.947e-02, 4.285e-02, 2.017e-01) * s0_2_1;
  r0 += mat4x4<f32>(-1.836e-03, -4.604e-04, 5.817e-03, -1.163e-03, -6.908e-05, 2.656e-02, 1.538e-04, 2.544e-02, -2.570e-02, -3.043e-02, 9.186e-03, 6.060e-03, 1.835e-03, -1.180e-02, -7.798e-04, -1.413e-02) * s0_2_2;
  r0 += mat4x4<f32>(3.858e-02, 1.159e-02, -1.714e-02, 1.321e-03, -4.651e-02, -6.978e-03, -6.425e-04, -5.179e-04, 1.593e-02, -4.188e-03, 7.966e-03, -2.096e-03, 2.021e-02, -2.831e-03, -6.218e-03, -1.591e-03) * s1_0_0;
  r0 += mat4x4<f32>(6.013e-02, 2.321e-02, -1.272e-02, 1.428e-03, -2.642e-02, -5.970e-02, 5.484e-04, -1.624e-02, -9.350e-03, 5.044e-02, 3.559e-02, 1.290e-02, 5.237e-02, 5.335e-02, -1.158e-02, -3.028e-03) * s1_0_1;
  r0 += mat4x4<f32>(-3.464e-03, -6.400e-03, -3.912e-03, 4.028e-03, -7.982e-04, 3.897e-03, 5.623e-04, -5.455e-03, -1.578e-02, -5.023e-03, 4.316e-03, 6.878e-03, 2.155e-02, 9.854e-05, -1.545e-03, -8.403e-03) * s1_0_2;
  r0 += mat4x4<f32>(6.274e-02, 9.949e-03, -1.482e-02, 1.966e-02, 1.823e-01, 3.239e-02, 1.672e-01, 2.803e-02, 3.854e-02, 2.798e-03, 5.290e-02, -1.323e-02, 8.033e-02, -4.927e-03, 5.214e-02, 6.217e-03) * s1_1_0;
  r0 += mat4x4<f32>(1.412e-01, 1.302e-01, 1.831e-01, -7.765e-01, 1.858e-01, -5.863e-01, 8.257e-02, 1.150e-01, 2.036e-01, 1.588e-01, -7.754e-01, 7.013e-02, -6.113e-01, 1.329e-01, 2.431e-01, 1.997e-01) * s1_1_1;
  r0 += mat4x4<f32>(4.956e-03, 2.910e-02, -1.130e-02, 3.894e-02, -6.194e-03, 4.187e-02, 1.297e-02, 1.890e-02, -9.858e-03, 3.552e-02, -1.203e-02, -4.467e-02, 7.554e-03, -1.228e-01, 1.355e-02, -3.137e-02) * s1_1_2;
  r0 += mat4x4<f32>(-9.285e-04, -3.891e-03, 1.489e-02, 1.933e-03, -2.277e-02, 2.816e-03, 1.509e-02, -1.466e-02, -1.913e-03, 6.877e-04, 2.422e-02, 2.455e-03, 4.516e-03, 3.046e-03, 3.825e-03, -8.076e-03) * s1_2_0;
  r0 += mat4x4<f32>(3.489e-03, -1.285e-02, 4.971e-02, 6.487e-02, 1.042e-02, -9.749e-03, -3.724e-02, -1.479e-01, -1.068e-02, 2.582e-03, 6.066e-02, 5.185e-02, -5.724e-03, 7.859e-03, -5.088e-02, 3.267e-02) * s1_2_1;
  r0 += mat4x4<f32>(-2.195e-03, -8.528e-03, -1.858e-03, 1.690e-02, -1.236e-03, 7.156e-03, -1.615e-03, 8.697e-03, -3.281e-03, -5.182e-03, 5.321e-03, 5.580e-03, 6.155e-03, -1.604e-02, -3.105e-03, -5.211e-02) * s1_2_2;
  r0 += vec4f(-7.733e-10, -6.961e-10, -2.278e-10, -5.781e-09);
  r0 = r0;
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

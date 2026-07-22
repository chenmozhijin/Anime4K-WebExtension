// SPDX-License-Identifier: LGPL-3.0-or-later
// Generated from CuNNy mpv GLSL. Do not edit manually.

const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_conv4: texture_2d<f32>;

@group(0) @binding(1) var tex_LUMA: texture_2d<f32>;

fn sample_conv4_vec4(pos: vec2u, offset: vec2i, lane: vec2i, packedScale: vec2i) -> vec4f {
  let logicalSize = vec2i(textureDimensions(tex_conv4)) / packedScale;
  let sourceCoord = clamp(vec2i(pos) + offset, vec2i(0, 0), logicalSize - vec2i(1, 1));
  return textureLoad(tex_conv4, sourceCoord * packedScale + lane, 0);
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
  s0_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(0, 0), vec2i(3, 1));
  s0_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(0, 0), vec2i(3, 1));
  s0_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(0, 0), vec2i(3, 1));
  s0_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(0, 0), vec2i(3, 1));
  s0_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(0, 0), vec2i(3, 1));
  s0_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(0, 0), vec2i(3, 1));
  s1_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(1, 0), vec2i(3, 1));
  s1_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(1, 0), vec2i(3, 1));
  s1_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(1, 0), vec2i(3, 1));
  s1_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(1, 0), vec2i(3, 1));
  s1_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(1, 0), vec2i(3, 1));
  s1_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(1, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(2.388e-02, -2.179e-02, -1.495e-02, -1.356e-02, 5.239e-03, -2.309e-03, 7.517e-04, 9.522e-04, -2.581e-02, -5.443e-03, 8.823e-03, -3.491e-03, 2.703e-02, -2.640e-03, -9.476e-03, 5.470e-03) * s0_0_0;
  r0 += mat4x4<f32>(-4.142e-02, 1.382e-01, -8.695e-03, 4.808e-02, 1.351e-03, 4.193e-03, -7.097e-03, -3.681e-03, -1.436e-02, -1.713e-02, 1.211e-02, 2.090e-02, 1.362e-01, 9.544e-02, 2.338e-02, -3.694e-03) * s0_0_1;
  r0 += mat4x4<f32>(-2.989e-03, -2.343e-02, -4.827e-04, -1.972e-02, -9.735e-03, -5.032e-03, -3.987e-03, -6.905e-03, 8.789e-03, 4.511e-03, 7.229e-03, 8.087e-03, -1.911e-02, 3.528e-02, -1.214e-02, 2.181e-03) * s0_0_2;
  r0 += mat4x4<f32>(1.270e-02, -1.064e-03, 6.812e-02, -1.000e-02, 1.484e-02, 1.731e-02, 6.290e-03, 3.235e-03, 6.860e-02, 9.856e-03, -1.395e-01, 3.042e-02, 2.633e-02, -2.918e-03, 7.205e-02, -9.850e-03) * s0_1_0;
  r0 += mat4x4<f32>(-1.438e-02, -5.431e-04, -3.300e-02, 7.007e-02, -3.142e-01, -2.705e-01, -2.310e-02, -9.285e-03, 1.468e-01, 2.173e-01, -5.744e-02, -3.330e-01, 1.171e-01, 8.227e-02, -5.113e-01, -1.525e-01) * s0_1_1;
  r0 += mat4x4<f32>(1.387e-03, -2.067e-03, -2.032e-03, -2.885e-03, 1.220e-02, -6.065e-02, -6.519e-03, -5.779e-03, 5.931e-03, 4.504e-02, -1.373e-03, 4.382e-02, -2.055e-02, -1.359e-02, 2.163e-02, -1.851e-01) * s0_1_2;
  r0 += mat4x4<f32>(-2.418e-03, -2.180e-03, -2.329e-03, 2.661e-03, -7.243e-03, -7.124e-03, 7.299e-02, 6.392e-03, 6.362e-03, 3.663e-03, 4.165e-02, 3.493e-03, -6.592e-03, 1.473e-03, 3.676e-03, 1.119e-03) * s0_2_0;
  r0 += mat4x4<f32>(-1.542e-03, -3.847e-04, -3.249e-04, -1.279e-03, 8.499e-02, 5.020e-02, 9.531e-02, 1.557e-01, -8.286e-04, 6.556e-03, 5.992e-02, 8.960e-02, -1.044e-02, -1.032e-02, 4.056e-02, 2.354e-02) * s0_2_1;
  r0 += mat4x4<f32>(-7.458e-04, 1.362e-04, 7.283e-05, 1.277e-03, -9.639e-03, -1.936e-03, 3.132e-02, 6.958e-02, 1.119e-03, -3.076e-03, 9.122e-04, 2.042e-02, -6.981e-03, -1.187e-02, -6.684e-03, -7.752e-03) * s0_2_2;
  r0 += mat4x4<f32>(2.814e-03, 3.148e-03, -1.132e-03, -6.398e-03, 1.439e-02, 2.829e-03, -2.626e-04, 5.178e-03, 8.911e-02, 6.704e-03, 3.282e-03, -7.610e-03, 4.977e-04, 4.986e-04, 2.492e-03, -4.189e-03) * s1_0_0;
  r0 += mat4x4<f32>(-2.823e-02, 3.015e-02, 2.882e-03, -1.051e-02, 4.334e-02, -8.423e-03, -4.752e-03, 7.005e-03, 2.837e-02, -2.014e-01, -1.233e-02, 9.915e-03, 1.724e-01, 1.304e-01, 5.953e-03, 1.205e-02) * s1_0_1;
  r0 += mat4x4<f32>(-2.935e-03, 1.517e-03, -6.146e-03, -4.596e-03, 5.094e-03, -1.761e-02, -4.354e-03, -5.804e-03, -3.110e-03, 1.074e-02, -3.243e-03, -4.863e-03, 3.929e-03, 5.750e-02, 7.298e-03, 1.157e-02) * s1_0_2;
  r0 += mat4x4<f32>(6.277e-02, 1.277e-02, 7.593e-02, 9.044e-03, -2.377e-02, -2.143e-02, 1.635e-02, -1.530e-03, 7.029e-02, 4.014e-03, 1.431e-01, 1.862e-02, -5.418e-02, 1.065e-02, -2.371e-02, 3.166e-02) * s1_1_0;
  r0 += mat4x4<f32>(1.483e-01, -5.953e-01, 1.826e-02, 3.266e-01, -5.438e-01, 2.192e-01, 1.694e-01, 1.648e-02, 4.286e-02, -1.889e-01, 7.104e-02, -4.457e-01, -1.159e-01, -1.840e-01, 2.338e-01, -3.845e-02) * s1_1_1;
  r0 += mat4x4<f32>(-3.541e-03, 4.060e-05, 1.047e-02, -1.971e-02, -3.058e-02, 6.355e-02, -1.071e-03, 5.601e-03, -2.668e-03, 2.787e-02, -7.114e-04, 3.528e-02, 7.299e-03, 7.689e-02, -5.682e-03, 1.274e-01) * s1_1_2;
  r0 += mat4x4<f32>(-1.342e-02, -7.935e-04, -3.368e-02, -5.183e-03, -3.825e-03, -2.990e-03, -5.412e-02, -5.920e-03, 5.003e-05, -5.121e-04, 7.959e-03, -3.997e-03, 5.189e-03, -1.387e-03, -1.053e-02, 1.819e-03) * s1_2_0;
  r0 += mat4x4<f32>(-2.544e-02, 3.770e-02, -5.524e-03, 9.469e-02, -2.353e-02, -4.780e-02, 1.780e-01, -6.772e-02, 1.365e-03, -1.446e-05, 1.205e-02, 4.146e-02, 1.905e-02, 6.786e-03, -7.593e-02, -5.630e-02) * s1_2_1;
  r0 += mat4x4<f32>(4.612e-03, 1.180e-02, -6.454e-03, -5.981e-03, 1.082e-03, -3.748e-02, -2.229e-02, -3.288e-02, -3.184e-03, 7.064e-04, -5.054e-03, 1.021e-02, 3.146e-04, 1.630e-02, 8.987e-03, 1.049e-02) * s1_2_2;
  s0_0_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_1 = sample_conv4_vec4(pixel.xy, vec2i(0, -1), vec2i(2, 0), vec2i(3, 1));
  s0_0_2 = sample_conv4_vec4(pixel.xy, vec2i(1, -1), vec2i(2, 0), vec2i(3, 1));
  s0_1_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 0), vec2i(2, 0), vec2i(3, 1));
  s0_1_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 0), vec2i(2, 0), vec2i(3, 1));
  s0_2_0 = sample_conv4_vec4(pixel.xy, vec2i(-1, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_1 = sample_conv4_vec4(pixel.xy, vec2i(0, 1), vec2i(2, 0), vec2i(3, 1));
  s0_2_2 = sample_conv4_vec4(pixel.xy, vec2i(1, 1), vec2i(2, 0), vec2i(3, 1));
  r0 += mat4x4<f32>(-2.370e-04, -8.572e-04, -2.001e-03, 7.761e-04, 2.123e-02, 1.536e-02, 1.274e-02, -7.336e-03, 2.614e-03, -1.381e-03, -4.164e-03, -4.223e-03, 1.770e-02, 4.606e-04, 3.006e-03, 2.284e-03) * s0_0_0;
  r0 += mat4x4<f32>(-3.455e-02, -6.941e-03, -1.279e-02, -4.495e-03, -6.119e-03, -2.816e-03, 4.406e-02, 4.285e-02, -1.856e-01, -9.240e-03, 2.836e-02, -2.436e-02, 3.072e-02, 3.407e-02, 1.014e-02, -6.580e-03) * s0_0_1;
  r0 += mat4x4<f32>(-2.424e-02, -8.274e-03, 1.670e-02, -1.367e-03, 1.744e-02, 1.847e-02, -4.058e-03, 1.788e-02, 4.189e-04, 7.005e-02, -6.018e-04, -8.652e-03, 6.124e-04, -8.224e-03, 1.516e-04, 2.652e-03) * s0_0_2;
  r0 += mat4x4<f32>(-5.683e-03, -9.489e-03, 3.950e-04, -6.793e-03, 8.911e-03, 5.503e-02, 1.017e-02, 5.414e-02, 7.029e-03, 2.001e-03, 3.845e-03, -5.365e-03, 8.470e-02, -3.136e-03, 6.568e-02, -2.159e-04) * s0_1_0;
  r0 += mat4x4<f32>(-1.289e-01, 2.727e-02, -6.540e-02, -2.783e-03, -1.609e-01, -1.479e-01, -1.606e-01, -1.509e-01, -1.125e-01, 2.898e-02, -4.326e-01, 6.509e-02, -2.135e-01, 2.303e-01, -9.698e-02, 1.964e-01) * s0_1_1;
  r0 += mat4x4<f32>(2.749e-01, -1.897e-01, 6.079e-02, -6.428e-02, 3.901e-02, -1.324e-02, 3.964e-02, -1.455e-02, 2.624e-03, 1.321e-01, 2.834e-03, 1.880e-01, 1.176e-02, -6.067e-02, 6.097e-03, -4.895e-02) * s0_1_2;
  r0 += mat4x4<f32>(-2.229e-03, -4.046e-04, -4.468e-03, -4.846e-03, 8.917e-03, -1.339e-02, 1.825e-02, 1.288e-02, 6.357e-03, -1.097e-03, 8.546e-03, 1.583e-03, 8.010e-03, 4.861e-03, 4.602e-02, 3.677e-03) * s0_2_0;
  r0 += mat4x4<f32>(-1.234e-02, -1.343e-02, -1.067e-01, -3.090e-03, 4.602e-02, 4.333e-02, -3.324e-03, -3.199e-03, -7.482e-03, -2.385e-03, 5.757e-02, -9.232e-03, 3.198e-02, 1.649e-02, -6.421e-02, 9.351e-02) * s0_2_1;
  r0 += mat4x4<f32>(2.706e-02, 6.566e-02, 1.387e-01, -3.276e-02, -5.716e-03, 1.415e-02, 1.209e-02, 1.568e-02, -2.524e-03, -5.214e-03, -1.433e-03, 1.958e-02, 2.355e-03, -1.244e-02, 1.034e-02, -3.471e-02) * s0_2_2;
  r0 += vec4f(-2.068e-10, -4.688e-10, -2.061e-10, -2.685e-10);
  r0 = r0;
  textureStore(out_tex, outBase + vec2i(0, 0), vec4f(r0.x + sample_original_luma(outBase + vec2i(0, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 0), vec4f(r0.y + sample_original_luma(outBase + vec2i(1, 0)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(0, 1), vec4f(r0.z + sample_original_luma(outBase + vec2i(0, 1)), 0.0, 0.0, 1.0));
  textureStore(out_tex, outBase + vec2i(1, 1), vec4f(r0.w + sample_original_luma(outBase + vec2i(1, 1)), 0.0, 0.0, 1.0));
}

// Layer: Anime4K-v3.2-Upscale-CNN-x2-(L)-Conv-4x3x3x3
// Inputs: ["MAIN"]
// Output: conv2d_tf
@group(0) @binding(0) var MAIN_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf_tex: texture_storage_2d<rgba16float, write>;
@group(0) @binding(2) var anime4kLinearSampler: sampler;

fn anime4kTextureLoadClamped(texture: texture_2d<f32>, pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  let dim = vec2f(textureDimensions(texture));
  let uv = (vec2f(pos) + vec2f(0.5, 0.5) + vec2f(f32(x_off), f32(y_off))) / dim;
  return textureSampleLevel(texture, anime4kLinearSampler, uv, 0.0);
}

fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn go_0(pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  return anime4kTextureLoadClamped(MAIN_tex, pos, x_off, y_off);
}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dim_out: vec2u = textureDimensions(conv2d_tf_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  var result: vec4f = mat4x4<f32>(-0.01802505, -0.06508559, 0.0017542128, -0.25521114, -0.024155967, 0.07601142, 0.07508073, -0.69212615, 0.06438325, 0.07916419, -0.07266247, -0.17089996, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, -1);
  result += mat4x4<f32>(-0.18881685, 0.063188724, 0.08637344, -0.20066689, -0.22774473, -0.10913083, -0.048009537, -0.27475306, -0.15950447, -0.027433012, 0.030303264, 0.018863251, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 0);
  result += mat4x4<f32>(0.19171959, 0.028070524, -0.09780952, 0.057611514, 0.26147488, 0.07180017, 0.09667393, 0.008605127, 0.011190245, 0.040944707, -0.025871381, -0.011468774, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 1);
  result += mat4x4<f32>(-0.08601777, 0.2180965, -0.052060187, -0.08091977, 0.3995336, 0.21213862, 0.105202965, 0.010929526, -0.080743685, -0.040439352, -0.07998862, 0.08096829, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, -1);
  result += mat4x4<f32>(-0.08608087, -0.10902571, 0.5245411, 0.53331816, -0.5507893, 0.6141555, 0.9744618, 0.89056116, 0.081408836, 0.28096125, 0.13647869, 0.026274862, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 0);
  result += mat4x4<f32>(0.13985278, -0.29691598, -0.26792645, -0.042485088, 0.27941233, -0.65306807, -0.360506, 0.03810829, 0.09663724, -0.26655033, 0.04372338, 0.063264176, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 1);
  result += mat4x4<f32>(0.18246013, -0.070464276, 0.04686214, 0.059332885, 0.16861221, 0.022623831, -0.09161491, 0.07130491, 0.15691474, 0.095743366, 0.059467375, -0.009469478, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, -1);
  result += mat4x4<f32>(-0.07830576, 0.17082681, -0.013175545, -0.035535168, 0.1573564, -0.16532823, -0.49614525, -0.050994795, 0.027053844, -0.20359018, 0.08111269, 0.018715343, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 0);
  result += mat4x4<f32>(-0.060515754, 0.13169582, -0.15245132, -0.045724656, -0.50778043, -0.11690067, -0.08320143, 0.01093529, -0.1954136, 0.07388989, -0.1360143, -0.023233788, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 1);
  result += vec4f(-0.0054077627, -0.15644358, 0.06612042, 0.014728144);
  textureStore(conv2d_tf_tex, pixel.xy, result);
}

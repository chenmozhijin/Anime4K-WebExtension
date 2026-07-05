// Layer: Anime4K-v3.2-Upscale-CNN-x2-(L)-Conv-4x3x3x3
// Inputs: ["MAIN"]
// Output: conv2d_tf1
@group(0) @binding(0) var MAIN_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf1_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_tf1_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  var result: vec4f = mat4x4<f32>(0.12039797, 0.04008252, 0.073074624, -0.11763173, 0.091902, -0.040129073, 0.009170759, -0.10760076, -0.032387916, 0.07807673, -6.477932e-05, 0.040181372, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, -1);
  result += mat4x4<f32>(0.11585734, -0.0078019407, 0.063107856, 0.09835168, -0.029397847, 0.12520139, 0.078661725, -0.12675259, 0.05563671, -0.058422342, 0.01478436, -0.08239175, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 0);
  result += mat4x4<f32>(-0.14991632, -0.0134848505, -0.38663143, -0.10859369, -0.012961176, -0.09099144, -0.19593886, -0.08396245, -0.02676463, -0.0066295485, 0.026225863, -0.014788537, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 1);
  result += mat4x4<f32>(0.20830092, -0.07655779, 0.04518565, 0.16015635, 0.5536684, 0.09759215, -0.101477005, -0.5042874, 0.35608026, -0.15335238, 0.0796228, -0.05107349, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, -1);
  result += mat4x4<f32>(-0.3968312, 0.091579735, -0.085623756, -0.16367513, -0.48967922, -0.08557767, 0.34444988, 1.0766053, -0.2158915, 0.22244956, -0.033804208, 0.25898156, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 0);
  result += mat4x4<f32>(0.026278365, 0.1678205, -0.38981274, 0.16932413, -0.0146527905, 0.65131354, -0.08886725, 0.07017853, 0.012986331, 0.029087646, -0.034898676, 0.040925268, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 1);
  result += mat4x4<f32>(0.07614263, 0.015624113, -0.054716587, -0.04951801, 0.016731577, -0.08749623, 0.07815944, -0.015630174, -0.08723511, 0.077201165, -0.12674089, -0.08418575, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, -1);
  result += mat4x4<f32>(-0.07938198, -0.4056014, 0.26949093, 0.067213245, -0.47538033, -0.7786735, -0.25821188, 0.029314762, -0.1799233, -0.31132734, 0.17210929, -0.018579468, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 0);
  result += mat4x4<f32>(0.06732179, 0.18373649, -0.00039802346, 0.006567155, 0.36993378, 0.20254396, 0.12314272, -0.07356931, 0.12402926, 0.122744165, -0.07482636, 0.011531308, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 1);
  result += vec4f(-0.001029383, 0.0058537456, 0.38202196, -0.028818231);
  textureStore(conv2d_tf1_tex, pixel.xy, result);
}

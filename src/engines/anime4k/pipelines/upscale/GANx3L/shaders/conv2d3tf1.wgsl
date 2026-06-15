// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x40
// Name: conv2d3tf1
// Inputs: ['conv2d_tf', 'conv2d_tf1', 'conv2d_tf2', 'conv2d_2_tf', 'conv2d_1_tf']
// Output: conv2d_3_tf1
@group(0) @binding(0) var conv2d_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_2_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_3_tf1_tex: texture_storage_2d<rgba16float, write>;
fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn g_0(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_tf_tex, pos, 0), 0.0);
}

fn g_1(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_tf1_tex, pos, 0), 0.0);
}

fn g_2(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_tf2_tex, pos, 0), 0.0);
}

fn g_3(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_tf_tex, pos, 0), 0.0);
}

fn g_4(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_tf1_tex, pos, 0), 0.0);
}

fn g_5(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_tf2_tex, pos, 0), 0.0);
}

fn g_6(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_7(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_8(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_9(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}


@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_out: vec2u = textureDimensions(conv2d_3_tf1_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(0.029635962, 0.08045753, 0.03622311, 0.06677362, 0.14780864, -0.087087184, 0.22309896, -0.1772139, -0.08716722, 0.1075154, 0.044472143, 0.021324798, 0.10346262, -0.24718447, -0.2489118, 0.4517737) * g_0(pixel.xy);
  result += mat4x4<f32>(0.20637918, -0.11695054, 0.27656725, 0.009858572, -0.62555677, 0.12796827, -0.057749186, -0.02636826, 0.11764726, -0.034879886, -0.062285252, -0.048256125, 0.37146622, -0.17392562, 0.24782267, 0.3184173) * g_1(pixel.xy);
  result += mat4x4<f32>(0.2624149, 0.007052751, 0.1595428, 0.26269603, -0.33775207, -0.66331345, 0.18036188, -0.25012106, -0.15003558, 0.12337829, -0.3230818, 0.06187628, 0.096601635, 0.24300486, -0.13784438, 0.27110842) * g_2(pixel.xy);
  result += mat4x4<f32>(-0.180413, 0.039972585, 0.48966697, -0.4130023, -0.03654654, -0.27514896, -0.025462124, 0.06652415, 0.28900522, 0.035381883, 0.20655172, 0.0073647103, -0.5028713, -0.0061578755, -0.09185675, -0.52771837) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.3205473, -0.23172325, -0.20749244, 0.058195353, 0.20280065, -0.106998004, 0.08968707, 0.10981961, -0.13291806, 0.0028465164, 0.11793527, 0.11942547, 0.100123264, -0.14852245, -0.032194547, -0.118260525) * g_4(pixel.xy);
  result += mat4x4<f32>(0.004620961, -0.13271236, 0.110130526, -0.075169735, 0.35998157, -0.046072174, 0.02044828, -0.1019322, -0.038753018, -0.12328749, -0.28227237, 0.18373057, -0.23704045, 0.20384738, 0.097455874, -0.23102747) * g_5(pixel.xy);
  result += mat4x4<f32>(0.30397, -0.007688397, -0.2519374, -0.14401323, -0.031671453, 0.10171321, -0.18295656, -0.029794114, 0.19171898, 0.23662621, 0.09319509, -0.3479054, 0.036986895, 0.13572362, 0.1142681, -0.17851138) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.19525734, 0.36855492, 0.05751295, -0.12524441, 0.06309533, 0.20228319, -0.07533531, 0.26733333, -0.21407285, -0.2900094, -0.28743416, 0.18039729, -0.27968687, -0.23786859, -0.21049118, -0.006130187) * g_7(pixel.xy);
  result += mat4x4<f32>(0.34406897, -0.14967814, 0.56049985, -0.18166065, -0.061995413, 0.117799215, 0.3054206, 0.4034068, -0.2116504, -0.6017806, 0.004660423, 0.051566444, 0.4380975, -0.3172436, -0.09930328, -0.16182126) * g_8(pixel.xy);
  result += mat4x4<f32>(-0.09316841, 0.036305115, -0.30209473, 0.098138526, -0.012532953, -0.050068337, -0.22571203, -0.30636647, -0.124337815, 0.07323685, -0.15504828, 0.19263308, -0.017216058, 0.34484297, -0.1460544, -0.24951003) * g_9(pixel.xy);
  result += vec4f(0.10388342, 0.00828351, 0.14884935, 0.034392886);
  textureStore(conv2d_3_tf1_tex, pixel.xy, result);
}

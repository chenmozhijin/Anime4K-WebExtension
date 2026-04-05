// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x48
// Name: conv2d6tf2
// Inputs: ['conv2d_3_tf', 'conv2d_3_tf1', 'conv2d_3_tf2', 'conv2d_5_tf', 'conv2d_1_tf', 'conv2d_4_tf']
// Output: conv2d_6_tf2
@group(0) @binding(0) var conv2d_3_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_3_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_3_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_5_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_6_tf2_tex: texture_storage_2d<rgba16float, write>;
fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn g_0(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_1(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf1_tex, pos, 0), 0.0);
}

fn g_2(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf2_tex, pos, 0), 0.0);
}

fn g_3(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_4(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf1_tex, pos, 0), 0.0);
}

fn g_5(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf2_tex, pos, 0), 0.0);
}

fn g_6(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_7(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_8(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_9(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_10(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}

fn g_11(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}


@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_out: vec2u = textureDimensions(conv2d_6_tf2_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.21563801, -0.12204513, 0.31932783, 0.28290224, -0.17011476, -0.06448831, 0.004365267, -0.07169507, 0.21165244, -0.07712424, 0.14979824, 0.2240992, 0.48357385, -0.015724417, -0.3836641, 0.07599027) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.20743755, -0.119118474, 0.1009234, -0.2842955, -0.24531132, 0.062108602, 0.11733637, 0.06687575, -0.065953426, 0.15715389, 0.21475503, -0.1019138, 0.08085453, -0.24522887, -0.108375534, 0.29179853) * g_1(pixel.xy);
  result += mat4x4<f32>(0.16713834, 0.030504826, -0.2423963, -0.41885766, -0.20249867, -0.061683156, -0.14999944, 0.54505223, 0.16486095, -0.023248592, -0.17566164, 0.089543514, -0.1884646, 0.15263423, 0.14438081, -0.21730141) * g_2(pixel.xy);
  result += mat4x4<f32>(0.37399703, 0.2731133, 0.11279373, 0.004775496, -0.19443156, -0.071899086, 0.17512012, -0.11265631, 0.01926881, -0.31321192, -0.32160205, -0.23714963, 0.097321026, 0.13937393, -0.28038052, -0.046872586) * g_3(pixel.xy);
  result += mat4x4<f32>(0.124041334, 0.083966166, 0.13945055, 0.087915726, 0.11154068, -0.09223973, -0.012948238, 0.16114026, 0.13717382, 0.11968761, 0.076536775, -0.15866219, -0.19017774, -0.11172013, 0.024816172, 0.096302085) * g_4(pixel.xy);
  result += mat4x4<f32>(0.081017025, -0.1537902, 0.193927, 0.22226687, 0.441012, 0.18478638, 0.30040395, 0.032401927, -0.13839063, 0.017778423, -0.42750338, -0.19760555, -0.21953818, -0.2148397, -0.084683254, 0.20916465) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.3921892, 0.2123992, 0.14027761, 0.10175143, -0.11134986, -0.16432697, -0.1097465, -0.21807413, -0.09732297, -0.11108596, -0.39636138, -0.06654249, 0.18766358, -0.0061503067, 0.1286225, 0.2418667) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.0039234986, 0.17088562, 0.12906016, -0.13476452, -0.09124947, 0.3098052, 0.09895542, 0.18631962, -0.06776231, 0.19485205, 0.14722902, 0.32147923, -0.1811334, 0.15313488, 0.0796922, 0.0012897709) * g_7(pixel.xy);
  result += mat4x4<f32>(0.032229863, 0.025498863, 0.06695979, 0.019412167, -0.16543043, -0.12314033, 0.112201385, 0.16554663, 0.13644108, 0.3098045, 0.081390016, -0.006008416, -0.016406069, 0.22883923, 0.22282913, -0.13947442) * g_8(pixel.xy);
  result += mat4x4<f32>(0.010251363, 0.08210024, -0.33465254, -0.012109372, 0.027115503, 0.1481351, -0.081793204, -0.20716506, 0.0056828605, -0.30995828, 0.11498873, 0.15678942, -0.061227474, -0.14681229, 0.1498136, 0.11219651) * g_9(pixel.xy);
  result += mat4x4<f32>(0.21796124, -0.12195326, 0.44734144, -0.124715045, -0.05986958, -0.25252253, -0.13802508, 0.16756216, 0.28327593, 0.38355786, -0.27178785, -0.19969118, -0.26010805, -0.074593216, 0.10679648, 0.15610766) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.07648412, -0.18866923, -0.2592641, 0.32486007, -0.6200149, 0.09312683, 0.42827863, -0.2703639, 0.08144911, -0.054994784, -0.24911343, 0.41974616, 0.036914464, -0.32325324, 0.012920313, -0.48379797) * g_11(pixel.xy);
  result += vec4f(-0.013587518, 0.049618572, -0.065549955, -0.007242324);
  textureStore(conv2d_6_tf2_tex, pixel.xy, result);
}

// Layer: Anime4K-v4.0-Restore-CNN-Soft-(M)-Conv-3x1x1x56
// Name: output
// Inputs: ['MAIN', 'conv2d_tf', 'conv2d_1_tf', 'conv2d_2_tf', 'conv2d_3_tf', 'conv2d_4_tf', 'conv2d_5_tf', 'conv2d_6_tf']
// Output: output
@group(0) @binding(0) var conv2d_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_2_tf_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_3_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_5_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_6_tf_tex: texture_2d<f32>;
@group(0) @binding(7) var output_tex: texture_storage_2d<rgba16float, write>;
fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn g_0(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_tf_tex, pos, 0), 0.0);
}

fn g_1(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_tf_tex, pos, 0), 0.0);
}

fn g_2(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_3(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_4(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_5(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_6(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_7(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_8(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}

fn g_9(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}

fn g_10(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_11(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_12(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}

fn g_13(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}


@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_out: vec2u = textureDimensions(output_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.030150581, -0.002168429, 0.014918388, 0.0, 0.020940892, 0.04591048, 0.049137186, 0.0, 0.111167125, 0.05311203, 0.0625381, 0.0, 0.020043287, 0.04785493, 0.040921766, 0.0) * g_0(pixel.xy);
  result += mat4x4<f32>(0.04158565, -0.008488135, 0.0020472286, 0.0, 0.049123142, -0.055042226, -0.06489915, 0.0, 0.09238876, 0.10387972, 0.09576964, 0.0, -0.054776173, -0.098954335, -0.09018853, 0.0) * g_1(pixel.xy);
  result += mat4x4<f32>(0.2081418, 0.08273068, 0.040325668, 0.0, -0.09937802, -0.13162258, -0.13989717, 0.0, -0.13983749, 0.01309777, 0.0023888077, 0.0, -0.18937743, -0.07021057, -0.047152344, 0.0) * g_2(pixel.xy);
  result += mat4x4<f32>(-0.09646629, 0.080605574, 0.10463501, 0.0, 0.22579835, 0.24077554, 0.22600271, 0.0, 0.049726978, 0.015292378, -0.0047161994, 0.0, 0.16281025, 0.048491795, 0.038338162, 0.0) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.09772107, -0.043998875, -0.054745924, 0.0, -0.1257736, -0.13175423, -0.10889618, 0.0, -0.015900036, 0.07074481, 0.08210496, 0.0, -0.11321135, -0.12526917, -0.105605066, 0.0) * g_4(pixel.xy);
  result += mat4x4<f32>(0.14187162, 0.14032297, 0.13016908, 0.0, 0.018954534, 0.016011704, 0.010169183, 0.0, 0.04762765, -0.044460997, -0.06499567, 0.0, 0.11133751, 0.09464176, 0.08865274, 0.0) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.16567162, -0.1744712, -0.1637222, 0.0, -0.02412003, 0.0074480795, 0.007903436, 0.0, -0.06161098, -0.046788957, -0.03971239, 0.0, 0.030736001, 0.036460854, 0.03660504, 0.0) * g_6(pixel.xy);
  result += mat4x4<f32>(0.084027, 0.10024112, 0.08152756, 0.0, 0.005087354, -0.026047802, -0.027264625, 0.0, 0.10519243, 0.08977278, 0.077558964, 0.0, -0.052826345, -0.06602686, -0.055083472, 0.0) * g_7(pixel.xy);
  result += mat4x4<f32>(0.007862721, 0.009936555, 0.012004831, 0.0, -0.042322706, -0.061728776, -0.05359773, 0.0, 0.030532641, 0.045623366, 0.04214089, 0.0, 0.030569768, 0.011892851, 0.0074041556, 0.0) * g_8(pixel.xy);
  result += mat4x4<f32>(0.03948997, 0.043119986, 0.039943404, 0.0, 0.0526772, 0.06820589, 0.058139592, 0.0, -0.062081397, -0.06755701, -0.054816127, 0.0, -0.004076369, 0.0061744447, 0.016273081, 0.0) * g_9(pixel.xy);
  result += mat4x4<f32>(0.0071622543, 0.004829105, -0.002032197, 0.0, -0.048541367, -0.059043564, -0.05662218, 0.0, 0.0015553127, 0.009178359, 0.009577062, 0.0, 0.114169896, 0.1349016, 0.11432262, 0.0) * g_10(pixel.xy);
  result += mat4x4<f32>(0.019324556, 0.028323999, 0.027396113, 0.0, 0.016746879, 0.01608199, 0.026891617, 0.0, 0.12068619, 0.13617857, 0.113496214, 0.0, -0.013930715, -0.014250072, -0.00824306, 0.0) * g_11(pixel.xy);
  result += mat4x4<f32>(-0.0024534757, -0.0064973077, -0.007905654, 0.0, -0.019158727, -0.024820521, -0.020509848, 0.0, -0.09608131, -0.11177871, -0.10503465, 0.0, -0.011210447, -0.010875943, -0.015295865, 0.0) * g_12(pixel.xy);
  result += mat4x4<f32>(0.09681486, 0.113604136, 0.10416855, 0.0, -0.08199983, -0.09013433, -0.08562243, 0.0, 0.041304465, 0.048315883, 0.042945288, 0.0, -0.09863276, -0.117853515, -0.09870226, 0.0) * g_13(pixel.xy);
  result += vec4f(-0.0039074384, -0.0085585555, -0.0132283475, 0.0);
  textureStore(output_tex, pixel.xy, result);
}

// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x40
// Name: conv2d3tf2
// Inputs: ['conv2d_tf', 'conv2d_tf1', 'conv2d_tf2', 'conv2d_2_tf', 'conv2d_1_tf']
// Output: conv2d_3_tf2
@group(0) @binding(0) var conv2d_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_2_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_3_tf2_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_3_tf2_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.15275823, 0.31693572, 0.03429309, -0.06982273, 0.08535909, 0.019838037, -0.03189405, 0.3190016, 0.16633914, 0.48730284, -0.27923077, 0.31791112, 0.43154097, 0.005003616, -0.26277873, -0.009333685) * g_0(pixel.xy);
  result += mat4x4<f32>(0.23504019, -0.12419379, 0.07217815, -0.090434305, -0.0380588, -0.14686479, -0.33812302, -0.20242776, -0.20776805, 0.24741934, -0.16489775, 0.07052134, -0.08030772, 0.23784883, -0.28709608, -0.17689173) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.05109775, -0.40860242, -0.003464472, -0.19893257, 0.23186824, -0.12760048, -0.22718583, 0.02299852, 0.27083093, 0.073904194, -0.056870755, -0.35324985, -0.023004858, -0.29591596, -0.020298446, -0.05753052) * g_2(pixel.xy);
  result += mat4x4<f32>(0.0035456547, -0.37682405, 0.047876693, 0.1168026, 0.015805494, -0.04388269, 0.12970346, 0.2497829, -0.009891778, 0.116980106, 0.13058232, 0.22570355, 0.13866597, 0.036246244, 0.10916998, -0.040503114) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.25300103, -0.065156855, 0.063345924, 0.11406543, -0.1902478, 0.16440767, 0.043949526, 0.43318078, -0.03932035, -0.08510957, 0.19621156, -0.045045726, -0.08339006, -0.04335483, 0.37129655, -0.22328225) * g_4(pixel.xy);
  result += mat4x4<f32>(0.16169593, 0.2758587, 0.38249364, 0.12606645, 0.4582731, 0.09374545, -0.10988087, -0.21678255, -0.004099455, -0.09436347, 0.33964127, 0.20880581, -0.06742301, -0.025149476, 0.12146305, 0.5012377) * g_5(pixel.xy);
  result += mat4x4<f32>(0.11523535, 0.31662583, -0.0709322, -0.066175185, 0.08868106, -0.042457394, 0.32469732, -0.1987238, 0.41399983, 0.015568244, 0.14037918, 0.2879998, -0.32157704, 0.22491854, -0.07769691, 0.2052648) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.299831, -0.247278, -0.2011737, -0.3759366, -0.14935663, -0.095033385, 0.06259881, -0.23891686, -0.4340098, 0.07340212, -0.0012697511, -0.16527005, 0.0814454, -0.43962866, -0.3040046, 0.06242604) * g_7(pixel.xy);
  result += mat4x4<f32>(0.11802704, 0.2323739, 0.13466287, -0.25053164, -0.08020803, 0.1628004, -0.030645542, -0.40872335, -0.24624921, 0.15931502, 0.40752286, -0.07906199, 0.4286516, -0.1651973, -0.07021073, 0.0867332) * g_8(pixel.xy);
  result += mat4x4<f32>(-0.23617363, 0.053548977, -0.14130518, -0.37744048, -0.11805406, -0.13757266, -0.026939899, 0.028020354, 0.24626125, -0.06998214, -0.02793638, 0.10509643, 0.06577935, -0.17211749, -0.12747282, -0.16999653) * g_9(pixel.xy);
  result += vec4f(-0.022106458, -0.012578552, 0.016203664, 0.026009269);
  textureStore(conv2d_3_tf2_tex, pixel.xy, result);
}

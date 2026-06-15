// Layer: Anime4K-v4.0-Restore-CNN-(M)-Conv-3x1x1x56
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
  result += mat4x4<f32>(-0.08837163, -0.065234736, -0.034704313, 0.0, 0.021405501, 0.013663729, 0.019249594, 0.0, 0.05328863, 0.03580334, 0.046457592, 0.0, -0.12216048, 0.022547891, 0.016400825, 0.0) * g_0(pixel.xy);
  result += mat4x4<f32>(0.061996464, 0.05631466, 0.06808407, 0.0, -0.005013109, -0.0044589997, -0.032367796, 0.0, 0.016481603, 0.13721058, 0.14924648, 0.0, 0.020035887, -0.07250003, -0.08034037, 0.0) * g_1(pixel.xy);
  result += mat4x4<f32>(0.24078514, 0.081361525, 0.053420708, 0.0, -0.009353794, -0.051077116, -0.058007747, 0.0, -0.14071098, 0.01035966, 0.005308949, 0.0, -0.1489842, -0.06711817, -0.05552926, 0.0) * g_2(pixel.xy);
  result += mat4x4<f32>(-0.13002375, 0.012733757, 0.017821986, 0.0, 0.17767483, 0.20204604, 0.1751779, 0.0, 0.12804912, 0.07381453, 0.05655911, 0.0, 0.17044514, 0.07301451, 0.06523978, 0.0) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.1170986, -0.05130371, -0.027939914, 0.0, -0.16645707, -0.121526904, -0.09471366, 0.0, -0.04143118, 0.026693767, 0.034615446, 0.0, -0.084318705, -0.064990036, -0.054324172, 0.0) * g_4(pixel.xy);
  result += mat4x4<f32>(0.12094524, 0.09518409, 0.07387219, 0.0, 0.062216382, 0.053228356, 0.031372335, 0.0, 0.072797105, 0.026258165, 0.009804673, 0.0, 0.120719045, 0.073281154, 0.056623302, 0.0) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.11141495, -0.11566289, -0.10398725, 0.0, -0.0651895, -0.06820691, -0.054204144, 0.0, -0.032746475, -0.008849683, -0.007610222, 0.0, -0.024655705, -0.048778858, -0.041144755, 0.0) * g_6(pixel.xy);
  result += mat4x4<f32>(0.058090195, 0.07538767, 0.059722915, 0.0, 0.044788487, 0.04212742, 0.027502589, 0.0, 0.04892866, 0.015416752, 0.008312418, 0.0, -0.011864114, -0.0074752793, -0.0060824654, 0.0) * g_7(pixel.xy);
  result += mat4x4<f32>(0.043446552, 0.061971307, 0.05758086, 0.0, -0.06379154, -0.053758245, -0.047204215, 0.0, 0.016307736, 0.03423424, 0.030179083, 0.0, 0.041445345, 0.03843772, 0.033059113, 0.0) * g_8(pixel.xy);
  result += mat4x4<f32>(-0.003803544, 0.0008906116, -0.00059585314, 0.0, 0.102071285, 0.11485224, 0.10007254, 0.0, -0.074306004, -0.08803551, -0.07972321, 0.0, -0.030704215, -0.021514274, -0.009049376, 0.0) * g_9(pixel.xy);
  result += mat4x4<f32>(0.0066058086, 0.0011408008, 0.0016199006, 0.0, -0.03916473, -0.042929266, -0.04018418, 0.0, -0.03153446, -0.039413508, -0.034767237, 0.0, 0.113516055, 0.12577052, 0.113335624, 0.0) * g_10(pixel.xy);
  result += mat4x4<f32>(0.02655948, 0.041905303, 0.03861737, 0.0, 0.048471425, 0.049788587, 0.050447535, 0.0, 0.12092813, 0.13564217, 0.12613249, 0.0, -0.0023508538, 0.0012828974, 0.0028730957, 0.0) * g_11(pixel.xy);
  result += mat4x4<f32>(0.0084758485, 0.008800083, 0.008206044, 0.0, -0.056123603, -0.06610845, -0.060320783, 0.0, -0.081793964, -0.101638645, -0.096699014, 0.0, -0.04402356, -0.04177539, -0.03829645, 0.0) * g_12(pixel.xy);
  result += mat4x4<f32>(0.10676299, 0.118409514, 0.10618478, 0.0, -0.05880252, -0.06488367, -0.06432695, 0.0, 0.019221924, 0.017602798, 0.017413978, 0.0, -0.07512528, -0.080483615, -0.066218294, 0.0) * g_13(pixel.xy);
  result += vec4f(-0.010478934, -0.008364784, -0.010246552, 0.0);
  textureStore(output_tex, pixel.xy, result);
}

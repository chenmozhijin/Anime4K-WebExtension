// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x48
// Name: conv2d6tf1
// Inputs: ['conv2d_3_tf', 'conv2d_3_tf1', 'conv2d_3_tf2', 'conv2d_5_tf', 'conv2d_1_tf', 'conv2d_4_tf']
// Output: conv2d_6_tf1
@group(0) @binding(0) var conv2d_3_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_3_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_3_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_5_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_6_tf1_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_6_tf1_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.12407633, -0.027812717, 0.23094666, 0.060302667, -0.16624144, -0.0007371851, -0.28186718, 0.22369424, 0.022404855, 0.09096415, 0.0017822908, 0.336001, -0.09130467, 0.034111694, 0.19113103, -0.14513424) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.014768806, -0.31290373, 0.015769936, -0.13507901, -0.010203078, 0.4945444, -0.01088852, -0.1582938, -0.14903755, -0.1840089, -0.009966903, -0.19425109, -0.21303283, 0.26285252, -0.046254523, -0.15465552) * g_1(pixel.xy);
  result += mat4x4<f32>(0.07533467, 0.26080438, 0.024856985, 0.34277654, -0.3129344, 0.30575162, 0.06931557, -0.044698272, 0.18042412, 0.45999247, -0.5192437, 0.022618707, -0.020097036, -0.27706465, -0.0050434433, -0.12770803) * g_2(pixel.xy);
  result += mat4x4<f32>(0.098648146, -0.21701503, 0.10266521, -0.085537605, 0.02402345, -0.28643832, 0.19378376, -0.12658586, 0.115897186, 0.01580828, 0.11827048, 0.29019687, -0.19341177, 0.09564265, 0.03476779, 0.11699004) * g_3(pixel.xy);
  result += mat4x4<f32>(0.058346223, 0.25530934, -0.026972264, 0.3190419, 0.12263199, 0.124316074, 0.04734691, 0.011293402, -0.17419139, -0.15893947, 0.093723476, 0.23282392, 0.19400646, -0.0533148, 0.026266033, 0.19663234) * g_4(pixel.xy);
  result += mat4x4<f32>(-0.06663804, 0.20435949, 0.044924624, -0.24982749, 0.20327586, 0.12442739, -0.3155765, -0.18541007, 0.18991531, -0.19276267, 0.21697456, 0.03178544, -0.3381796, -0.15325621, -0.25820518, -0.07297032) * g_5(pixel.xy);
  result += mat4x4<f32>(0.098007046, -0.17018083, 0.3390076, -0.2280134, 0.12989196, -0.044336785, -0.10702673, -0.37464848, 0.028437488, 0.24224928, -0.107826136, 0.0031239046, -0.34256136, -0.17936559, 0.091159485, -0.054418396) * g_6(pixel.xy);
  result += mat4x4<f32>(0.053965975, -0.17428857, -0.43524495, -0.15119378, -0.25487635, 0.16371927, 0.1467712, -0.08216164, -0.5624722, -0.11886804, -0.058240388, 0.17669299, -0.15173754, 0.13094892, 0.39045286, -0.017048221) * g_7(pixel.xy);
  result += mat4x4<f32>(-0.15798661, -0.36355045, 0.1957264, -0.05392931, 0.098283805, 0.14677107, 0.16887192, -0.11125151, -0.113571666, 0.15960959, -0.09331763, -0.032195523, 0.17286941, 0.33965907, 0.09051416, -0.25542957) * g_8(pixel.xy);
  result += mat4x4<f32>(0.16866244, 0.05636189, -0.100324616, 0.20495924, -0.102705345, -0.08387417, -0.09328024, 0.21541446, 0.1430065, 0.0308464, -0.0793588, -0.029477509, -0.28854427, -0.29555637, 0.33754608, -0.18144317) * g_9(pixel.xy);
  result += mat4x4<f32>(-0.11338383, 0.019528843, -0.24414338, -0.36290777, 0.54908705, -0.083018646, 0.007534378, -0.1406417, 0.37853354, 0.09911941, -0.047861155, -0.3186758, 0.2125856, -0.114667036, -0.07411896, 0.050717812) * g_10(pixel.xy);
  result += mat4x4<f32>(0.2961511, 0.28937215, -0.36593223, -0.16141813, -0.087650776, -0.47516292, 0.0052091824, 0.033959586, -0.06072628, -0.0012637508, -0.037578013, -0.35235298, 0.11726439, 0.6064031, 0.34058803, 0.45300734) * g_11(pixel.xy);
  result += vec4f(-0.0038817346, -0.052502215, 0.008882693, -0.017785465);
  textureStore(conv2d_6_tf1_tex, pixel.xy, result);
}

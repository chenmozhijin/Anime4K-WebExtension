// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x56
// Name: conv2d9tf1
// Inputs: ['conv2d_6_tf', 'conv2d_6_tf1', 'conv2d_6_tf2', 'conv2d_8_tf', 'conv2d_1_tf', 'conv2d_4_tf', 'conv2d_7_tf']
// Output: conv2d_9_tf1
@group(0) @binding(0) var conv2d_6_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_6_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_6_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_8_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_7_tf_tex: texture_2d<f32>;
@group(0) @binding(7) var conv2d_9_tf1_tex: texture_storage_2d<rgba16float, write>;
fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn g_0(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}

fn g_1(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf1_tex, pos, 0), 0.0);
}

fn g_2(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf2_tex, pos, 0), 0.0);
}

fn g_3(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}

fn g_4(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf1_tex, pos, 0), 0.0);
}

fn g_5(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf2_tex, pos, 0), 0.0);
}

fn g_6(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_8_tf_tex, pos, 0), 0.0);
}

fn g_7(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_8_tf_tex, pos, 0), 0.0);
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

fn g_12(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_7_tf_tex, pos, 0), 0.0);
}

fn g_13(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_7_tf_tex, pos, 0), 0.0);
}


@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_out: vec2u = textureDimensions(conv2d_9_tf1_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(0.06760422, 0.16268754, -0.14517367, -0.023386402, -0.23272006, 0.48739922, 0.06399116, -0.032946702, -0.17306012, 0.334446, 0.17779559, -0.2660973, -0.3468709, 0.51220256, -0.010311926, -0.040047005) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.0538168, -0.048309397, 0.064760834, 0.09675621, 0.20269404, -0.2615111, -0.27282992, -0.12584937, 0.10904846, -0.15973651, -0.076846495, -0.09462694, 0.12722874, 0.21629119, -0.35314724, -0.086036965) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.049174394, -0.05765949, 0.21250841, 0.17151582, 0.15764381, 0.040890984, 0.05118504, -0.14658877, 0.05469671, 0.13701054, 0.20377803, -0.39008877, -0.0016028697, 0.13317284, -0.11653242, 0.12591232) * g_2(pixel.xy);
  result += mat4x4<f32>(0.21234287, -0.3048995, -0.12653783, -0.109162085, -0.050768167, -0.17156011, 0.05592974, 0.27197394, -0.19419932, -0.046344608, -0.05445905, -0.13253787, 0.05778321, 0.16979085, -0.04466505, -0.06867837) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.18974759, 0.22814974, -0.007522141, -0.10096491, -0.26759568, 0.32048568, 0.2660603, 0.112091035, 0.41875598, -0.1051111, 0.06525224, 0.27191457, 0.017352497, -0.31743342, 0.29108858, 0.26573792) * g_4(pixel.xy);
  result += mat4x4<f32>(0.031855166, -0.122523904, -0.28207538, 0.12833035, -0.025733596, 0.008542537, -0.1891138, 0.16361842, 0.058317598, -0.007289248, 0.03349703, -0.038986582, 0.18147361, -0.3912238, 0.024964351, 0.14339498) * g_5(pixel.xy);
  result += mat4x4<f32>(0.37369347, -0.012460246, -0.037854888, 0.067713045, -0.06288331, 0.26436228, -0.058873445, 0.04463945, -0.04286497, -0.04824939, 0.17835206, -0.036378298, 0.33058742, -0.14685723, 0.1025378, 0.051385757) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.131484, -0.040644694, -0.14443769, 0.1950223, 0.09507341, 0.48859578, -0.26267928, 0.24538381, -0.063596986, -0.18749404, -0.031884808, -0.07132067, -0.04606875, 0.03708701, -0.26145473, 0.2371378) * g_7(pixel.xy);
  result += mat4x4<f32>(0.094301306, -0.08795415, -0.035933804, 0.21765485, -0.29858732, 0.11440603, 0.14095801, 0.18262209, -0.08135902, -0.45404965, 0.20399955, -0.06393024, 0.023793167, 0.16001467, -0.11817577, -0.16322103) * g_8(pixel.xy);
  result += mat4x4<f32>(0.07168084, 0.0879652, -0.083207026, -0.045181375, 0.07845201, -0.15828066, 0.05710845, 0.05699917, -0.061211787, 0.039662443, 0.036026876, 0.14224064, -0.23701179, 0.01259322, -0.091701694, 0.42408752) * g_9(pixel.xy);
  result += mat4x4<f32>(0.017442457, -0.1311232, -0.22520894, -0.049517628, -0.20945188, -0.035541452, -0.13055338, -0.04001523, -0.09402065, -0.19641486, -0.10066238, 0.115912616, -0.10684873, 0.02787531, 0.28450257, 0.02690632) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.2659566, 0.43625832, -0.0695883, -0.2624756, -0.2827253, -0.22893822, 0.26025924, 0.24121284, 0.2272709, 0.2178127, -0.15199527, 0.32607552, 0.005909836, 0.056527212, 0.19446251, -0.010751997) * g_11(pixel.xy);
  result += mat4x4<f32>(0.1273358, -0.28996274, -0.19322409, 0.018734567, 0.48555133, -0.17389202, 0.13595583, 0.46163267, -0.08973322, -0.30239192, 0.49897516, 0.021815563, -0.2589829, 0.0039008032, 0.056682784, 0.048075546) * g_12(pixel.xy);
  result += mat4x4<f32>(0.415353, 0.112207405, 0.20997275, 0.033321556, -0.1327579, 0.12338585, 0.61820966, -0.3411527, 0.018252999, 0.05708125, -0.24571265, 0.11019793, 0.24145919, 0.20340635, -0.0693869, 0.16271423) * g_13(pixel.xy);
  result += vec4f(-0.07107039, 0.0061239223, 0.0013546069, 0.02994767);
  textureStore(conv2d_9_tf1_tex, pixel.xy, result);
}

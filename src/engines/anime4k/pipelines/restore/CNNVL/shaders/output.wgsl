// Layer: Anime4K-v4.0-Restore-CNN-(VL)-Conv-3x1x1x112
// Name: output
// Inputs: ['MAIN', 'conv2d_1_tf', 'conv2d_1_tf1', 'conv2d_2_tf', 'conv2d_2_tf1', 'conv2d_3_tf', 'conv2d_3_tf1', 'conv2d_4_tf', 'conv2d_4_tf1', 'conv2d_5_tf', 'conv2d_5_tf1', 'conv2d_6_tf', 'conv2d_6_tf1', 'conv2d_7_tf', 'conv2d_7_tf1']
// Output: output
@group(0) @binding(0) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_1_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_2_tf_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_2_tf1_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_3_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_3_tf1_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(7) var conv2d_4_tf1_tex: texture_2d<f32>;
@group(0) @binding(8) var conv2d_5_tf_tex: texture_2d<f32>;
@group(0) @binding(9) var conv2d_5_tf1_tex: texture_2d<f32>;
@group(0) @binding(10) var conv2d_6_tf_tex: texture_2d<f32>;
@group(0) @binding(11) var conv2d_6_tf1_tex: texture_2d<f32>;
@group(0) @binding(12) var conv2d_7_tf_tex: texture_2d<f32>;
@group(0) @binding(13) var conv2d_7_tf1_tex: texture_2d<f32>;
@group(0) @binding(14) var output_tex: texture_storage_2d<rgba16float, write>;
fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn g_0(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_1(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_1_tf1_tex, pos, 0), 0.0);
}

fn g_2(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_1_tf_tex, pos, 0), 0.0);
}

fn g_3(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_1_tf1_tex, pos, 0), 0.0);
}

fn g_4(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_5(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_2_tf1_tex, pos, 0), 0.0);
}

fn g_6(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_2_tf_tex, pos, 0), 0.0);
}

fn g_7(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_2_tf1_tex, pos, 0), 0.0);
}

fn g_8(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_9(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_3_tf1_tex, pos, 0), 0.0);
}

fn g_10(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf_tex, pos, 0), 0.0);
}

fn g_11(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_3_tf1_tex, pos, 0), 0.0);
}

fn g_12(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}

fn g_13(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_4_tf1_tex, pos, 0), 0.0);
}

fn g_14(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_4_tf_tex, pos, 0), 0.0);
}

fn g_15(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_4_tf1_tex, pos, 0), 0.0);
}

fn g_16(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_17(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_5_tf1_tex, pos, 0), 0.0);
}

fn g_18(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_5_tf_tex, pos, 0), 0.0);
}

fn g_19(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_5_tf1_tex, pos, 0), 0.0);
}

fn g_20(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}

fn g_21(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_6_tf1_tex, pos, 0), 0.0);
}

fn g_22(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf_tex, pos, 0), 0.0);
}

fn g_23(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_6_tf1_tex, pos, 0), 0.0);
}

fn g_24(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_7_tf_tex, pos, 0), 0.0);
}

fn g_25(pos: vec2u) -> vec4f {
  return max4(textureLoad(conv2d_7_tf1_tex, pos, 0), 0.0);
}

fn g_26(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_7_tf_tex, pos, 0), 0.0);
}

fn g_27(pos: vec2u) -> vec4f {
  return max4(-textureLoad(conv2d_7_tf1_tex, pos, 0), 0.0);
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
  result += mat4x4<f32>(0.09689336, 0.06046458, 0.072598994, 0.0, 0.11994565, 0.104477674, 0.09302802, 0.0, -0.05718302, 0.050438102, 0.08814741, 0.0, 0.0308889, 0.0033925986, -0.01715605, 0.0) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.028314235, 0.06597744, 0.0966897, 0.0, 0.035656154, 0.07770106, 0.075551905, 0.0, 0.0001793458, -0.000479495, -0.00297406, 0.0, -0.053916585, -0.016807461, -0.0057141334, 0.0) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.047189303, -0.0207, -0.020910334, 0.0, -0.07933196, -0.06961211, -0.086069845, 0.0, 0.0943727, 0.008463375, 0.010755166, 0.0, 0.062410597, 0.022625161, 0.04068433, 0.0) * g_2(pixel.xy);
  result += mat4x4<f32>(0.10270994, -0.019080428, 0.0050091282, 0.0, -0.004672948, -0.013966742, -0.0063746064, 0.0, -2.5856789e-05, 0.03151499, -0.0023983798, 0.0, 0.113539025, 0.12381699, 0.100360274, 0.0) * g_3(pixel.xy);
  result += mat4x4<f32>(0.07868885, -0.030913834, -0.009213676, 0.0, 0.04870991, 0.021467991, 0.038739506, 0.0, -0.042969644, -0.07122453, -0.08798675, 0.0, -0.09784122, 0.021434791, 0.02510374, 0.0) * g_4(pixel.xy);
  result += mat4x4<f32>(0.050420716, 0.0729716, 0.076532185, 0.0, -0.019112485, -0.01037939, -0.026948035, 0.0, -0.02591423, 0.008927897, -0.00042541025, 0.0, 0.1043701, -0.0071186824, -0.041817162, 0.0) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.16143242, -0.0009298223, -0.01228508, 0.0, 0.07744052, -0.018313263, -0.0488145, 0.0, 0.09241393, 0.07128674, 0.055164956, 0.0, 0.054884013, -0.04834418, -0.06281626, 0.0) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.049036566, -0.05979936, -0.05594288, 0.0, -0.014564307, 0.031926468, 0.037857566, 0.0, 0.015474487, -0.11385003, -0.11527764, 0.0, -0.07076006, 0.057038613, 0.095983796, 0.0) * g_7(pixel.xy);
  result += mat4x4<f32>(0.03094887, -0.008734403, 0.00042712069, 0.0, 0.053891554, 0.05837673, 0.06200635, 0.0, 0.09071558, -0.04202184, -0.046172567, 0.0, -0.0425916, 0.04905093, 0.020835675, 0.0) * g_8(pixel.xy);
  result += mat4x4<f32>(0.096628904, -0.037792254, -0.043241944, 0.0, -0.011923947, -0.025950424, -0.031381752, 0.0, -0.060941868, -0.07859433, -0.07535451, 0.0, -0.026777223, 0.08604982, 0.07829908, 0.0) * g_9(pixel.xy);
  result += mat4x4<f32>(-0.06435972, 0.0036599538, 0.00786578, 0.0, -0.061972067, -0.05681472, -0.06667608, 0.0, -0.106890626, 0.007406496, 0.029977169, 0.0, -0.20519382, -0.044860814, 0.0021225857, 0.0) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.16876474, 0.012789643, 0.026692612, 0.0, 0.017817136, 0.026935097, 0.02227043, 0.0, 0.01690181, 0.07716103, 0.086527, 0.0, 0.07923805, -0.10443151, -0.10859543, 0.0) * g_11(pixel.xy);
  result += mat4x4<f32>(0.003730466, -0.024648283, -0.022169832, 0.0, -0.0062762927, 0.022062732, 0.032966793, 0.0, 0.016349113, 0.017197203, 0.020952817, 0.0, -0.1763789, 0.035497356, 0.053835396, 0.0) * g_12(pixel.xy);
  result += mat4x4<f32>(0.020886675, -0.07054202, -0.079142675, 0.0, 0.06664387, 0.044960167, 0.042230908, 0.0, -0.095019594, 0.012421141, 0.0142890485, 0.0, 0.056814816, -0.012751135, -0.014684506, 0.0) * g_13(pixel.xy);
  result += mat4x4<f32>(0.011765893, 0.0008920681, -0.0018258415, 0.0, -0.010473814, -0.023085753, -0.028783914, 0.0, -0.023034256, -0.0024786016, -0.0052162083, 0.0, 0.1643386, -0.06132718, -0.09289065, 0.0) * g_14(pixel.xy);
  result += mat4x4<f32>(0.016597198, 0.09389637, 0.10833379, 0.0, -0.043163072, -0.04714812, -0.035274632, 0.0, 0.09634976, -0.009292612, -0.022424143, 0.0, -0.08765172, 0.0051558353, 0.010900356, 0.0) * g_15(pixel.xy);
  result += mat4x4<f32>(0.030815786, 0.021069322, 0.01812191, 0.0, 0.084839165, -0.0080813095, -0.029270556, 0.0, -0.10456346, 0.062386703, 0.0665605, 0.0, 0.11926609, -0.1104228, -0.13291118, 0.0) * g_16(pixel.xy);
  result += mat4x4<f32>(-0.07159541, -0.007267032, -0.010134558, 0.0, 0.008234213, 0.045609634, 0.040295456, 0.0, 0.018416971, 0.01308482, 0.014649557, 0.0, 0.035107512, -0.02140815, -0.030279048, 0.0) * g_17(pixel.xy);
  result += mat4x4<f32>(0.01918586, 0.03875863, 0.03229402, 0.0, -0.07917104, 0.041135103, 0.057182517, 0.0, 0.08609541, 0.0079662455, 0.004327576, 0.0, -0.14332893, 0.03120354, 0.056732506, 0.0) * g_18(pixel.xy);
  result += mat4x4<f32>(0.03200192, -0.0035752193, -0.0031064528, 0.0, -0.010902813, 0.014607456, 0.019431474, 0.0, -0.016461229, -0.004938204, -0.004655488, 0.0, -0.033470232, 0.0026075812, 0.005896968, 0.0) * g_19(pixel.xy);
  result += mat4x4<f32>(0.037410006, 0.048742272, 0.04348088, 0.0, 0.037719514, 0.030768529, 0.03127472, 0.0, 0.056426726, 0.03066893, 0.016440205, 0.0, -0.010599352, 0.022832409, 0.023211194, 0.0) * g_20(pixel.xy);
  result += mat4x4<f32>(-0.005733291, 0.06365659, 0.06663611, 0.0, -0.041917093, -0.016493445, -0.020438088, 0.0, -0.0014357592, -0.0022506563, -0.0045095007, 0.0, 0.029893145, -0.009129354, -0.015173116, 0.0) * g_21(pixel.xy);
  result += mat4x4<f32>(0.013052085, 0.005108175, 0.0025906067, 0.0, -0.021950055, -0.036447693, -0.036141638, 0.0, -0.036296472, 0.0068928464, 0.013102313, 0.0, 0.0060471976, -0.024798103, -0.023548538, 0.0) * g_22(pixel.xy);
  result += mat4x4<f32>(0.0067743887, -0.06191211, -0.062355213, 0.0, 0.0016080744, -0.020445071, -0.016840393, 0.0, 0.028264903, 0.01852915, 0.015891539, 0.0, -0.023877412, -0.013271666, -0.008158679, 0.0) * g_23(pixel.xy);
  result += mat4x4<f32>(-0.04317466, -0.018953001, -0.020452993, 0.0, -0.009322576, -0.03022352, -0.030970376, 0.0, 0.05653658, 0.05430553, 0.046692245, 0.0, 0.05615359, 0.059338935, 0.056018773, 0.0) * g_24(pixel.xy);
  result += mat4x4<f32>(0.022878079, 0.03392234, 0.033057988, 0.0, -0.017554542, -0.0141542535, -0.014122613, 0.0, -0.048634093, -0.05316463, -0.047988772, 0.0, -0.058002178, -0.040221967, -0.034025013, 0.0) * g_25(pixel.xy);
  result += mat4x4<f32>(-0.018253656, -0.04197674, -0.040467236, 0.0, -0.04358929, -0.028309818, -0.025425073, 0.0, -0.008488672, -0.001727991, 0.00035808363, 0.0, -0.0011709273, 0.0052514165, 0.0059479307, 0.0) * g_26(pixel.xy);
  result += mat4x4<f32>(-0.08333935, -0.09818201, -0.09476284, 0.0, -0.033692095, -0.046259012, -0.045797516, 0.0, -0.007577072, 0.0022402718, 0.0016200038, 0.0, 0.0029786075, -0.020728534, -0.018938033, 0.0) * g_27(pixel.xy);
  result += vec4f(0.047567394, -0.02504617, -0.028163986, 0.0);
  textureStore(output_tex, pixel.xy, result);
}

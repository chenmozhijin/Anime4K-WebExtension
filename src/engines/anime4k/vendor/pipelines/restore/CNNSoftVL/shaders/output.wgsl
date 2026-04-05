// Layer: Anime4K-v4.0-Restore-CNN-Soft-(VL)-Conv-3x1x1x112
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
  result += mat4x4<f32>(0.121882804, 0.055417646, 0.037575886, 0.0, 0.040015355, 0.10440659, 0.120197006, 0.0, 0.008896276, 0.07269119, 0.09253319, 0.0, 0.009000448, -0.033739295, -0.059260685, 0.0) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.048027042, 0.09210703, 0.123745404, 0.0, -0.007914943, 0.05483587, 0.054822505, 0.0, -0.005998682, 0.005822986, 0.009868176, 0.0, -0.05866792, -0.04236153, -0.022935968, 0.0) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.091270015, -0.033997003, -0.012321896, 0.0, -0.037983265, -0.078790314, -0.085029654, 0.0, 0.10656225, 0.0008334142, -0.0041227583, 0.0, 0.077364065, 0.033960085, 0.029391684, 0.0) * g_2(pixel.xy);
  result += mat4x4<f32>(0.15057671, -0.037442014, -0.037083894, 0.0, 0.015493511, -0.016119987, -0.027061606, 0.0, -0.012329675, 0.0060544596, -0.019787522, 0.0, 0.12182345, 0.11346318, 0.08640806, 0.0) * g_3(pixel.xy);
  result += mat4x4<f32>(0.19254518, 0.009179287, 0.023821035, 0.0, 0.020269603, 0.025629226, 0.040180814, 0.0, -0.025135614, -0.07785793, -0.099851295, 0.0, -0.122886, 0.03322616, 0.0509256, 0.0) * g_4(pixel.xy);
  result += mat4x4<f32>(0.060054794, 0.053996198, 0.047226787, 0.0, 0.038959846, -0.025839888, -0.030583512, 0.0, -0.034999896, 0.011966571, -0.011057454, 0.0, 0.05765179, -0.041760337, -0.0694113, 0.0) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.20393562, -0.0055942894, -0.02089636, 0.0, 0.14781304, -0.01954523, -0.0746086, 0.0, 0.071556985, 0.07512172, 0.067927115, 0.0, 0.084076844, -0.0561336, -0.06856403, 0.0) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.039552618, -0.04448951, -0.04170605, 0.0, -0.00886809, 0.06708884, 0.07120977, 0.0, 0.04834384, -0.10599933, -0.11024835, 0.0, -0.015948117, 0.084044695, 0.10778199, 0.0) * g_7(pixel.xy);
  result += mat4x4<f32>(0.050153337, 0.012563414, 0.014994658, 0.0, 0.10498867, 0.07151875, 0.06761489, 0.0, 0.061650798, -0.035183728, -0.050987806, 0.0, 0.0017240314, 0.041055307, 0.020366805, 0.0) * g_8(pixel.xy);
  result += mat4x4<f32>(0.110105395, -0.044468552, -0.072567016, 0.0, -0.049364448, -0.015713394, -0.021540897, 0.0, -0.01636263, -0.084110685, -0.08281401, 0.0, -0.08940374, 0.047863875, 0.051104594, 0.0) * g_9(pixel.xy);
  result += mat4x4<f32>(-0.081597924, 0.002422661, 0.01143175, 0.0, -0.07504751, -0.09938017, -0.1063178, 0.0, -0.10390281, 0.0262197, 0.060155805, 0.0, -0.24289346, -0.0054961476, 0.045964316, 0.0) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.1829316, 0.047622137, 0.07963877, 0.0, 0.048703995, -0.0026299425, -0.003712008, 0.0, 0.029338706, 0.096882835, 0.102083966, 0.0, 0.078538164, -0.07247937, -0.06820231, 0.0) * g_11(pixel.xy);
  result += mat4x4<f32>(-0.02302231, -0.035528302, -0.030674051, 0.0, 0.029780716, 0.031591274, 0.045867007, 0.0, 0.01335752, 0.037001595, 0.04351411, 0.0, -0.11126892, 0.038589563, 0.06444906, 0.0) * g_12(pixel.xy);
  result += mat4x4<f32>(0.0047764573, -0.063372664, -0.065609895, 0.0, 0.0478139, 0.025694113, 0.025097322, 0.0, -0.1019169, 0.029989049, 0.050038517, 0.0, 0.07504127, -0.017047737, -0.026222635, 0.0) * g_13(pixel.xy);
  result += mat4x4<f32>(0.0024485083, 0.00640911, 0.008171829, 0.0, -0.014622121, -0.06078096, -0.0800138, 0.0, -0.0062360805, -0.014344496, -0.021332184, 0.0, 0.117842786, -0.103745885, -0.13756834, 0.0) * g_14(pixel.xy);
  result += mat4x4<f32>(-0.01942775, 0.08720701, 0.104858086, 0.0, -0.05545872, -0.041375194, -0.035368554, 0.0, 0.080331706, -0.021207837, -0.043905254, 0.0, -0.12515299, 3.445463e-05, 0.018742712, 0.0) * g_15(pixel.xy);
  result += mat4x4<f32>(0.013106969, 0.010379314, 0.012753471, 0.0, 0.07086715, -0.020893, -0.03968904, 0.0, -0.06114372, 0.029510446, 0.035070244, 0.0, 0.11180839, -0.087067656, -0.124039896, 0.0) * g_16(pixel.xy);
  result += mat4x4<f32>(-0.056521703, -0.001166792, -2.3704073e-05, 0.0, 0.011961608, 0.01848977, 0.019861937, 0.0, 0.012167056, 0.018613879, 0.020505793, 0.0, 0.009734187, -0.0308419, -0.035206888, 0.0) * g_17(pixel.xy);
  result += mat4x4<f32>(0.0048758825, 0.018046578, 0.014597015, 0.0, -0.061724614, 0.040989272, 0.05644141, 0.0, 0.070315465, 0.008318584, 0.0028647361, 0.0, -0.11316492, 0.043919202, 0.07653594, 0.0) * g_18(pixel.xy);
  result += mat4x4<f32>(0.031487904, -0.010548384, -0.009984509, 0.0, -0.0022647562, 0.0043304027, 0.0029451603, 0.0, -0.0063251094, -0.013420807, -0.011919729, 0.0, -0.022760967, 0.019141173, 0.01782793, 0.0) * g_19(pixel.xy);
  result += mat4x4<f32>(0.023055293, 0.028219413, 0.024810018, 0.0, 0.031653803, 0.050207954, 0.04504577, 0.0, 0.03877294, 0.0280465, 0.025589157, 0.0, 0.0019387804, 0.023891818, 0.016049948, 0.0) * g_20(pixel.xy);
  result += mat4x4<f32>(0.006562233, 0.03880659, 0.037682824, 0.0, -0.021441424, -0.011277022, -0.012471097, 0.0, -0.030526241, -0.013880651, -0.014213582, 0.0, 0.0075785257, -0.0017350517, -0.0024610942, 0.0) * g_21(pixel.xy);
  result += mat4x4<f32>(0.015097556, 0.020325955, 0.015611413, 0.0, -0.014755199, -0.034323387, -0.032325987, 0.0, -0.008603291, 0.010346807, 0.011044969, 0.0, -0.004739154, -0.026397636, -0.01995132, 0.0) * g_22(pixel.xy);
  result += mat4x4<f32>(0.0097906375, -0.015094543, -0.016887931, 0.0, -0.0007786067, -0.0069163437, -0.008449091, 0.0, 0.025534432, 0.018064791, 0.017047096, 0.0, 0.00055667467, 0.001493328, 0.003636564, 0.0) * g_23(pixel.xy);
  result += mat4x4<f32>(-0.042251963, -0.042396102, -0.040224236, 0.0, -0.004492444, -0.0069470624, -0.0065821502, 0.0, 0.062203273, 0.06213223, 0.053592753, 0.0, 0.06424337, 0.07964681, 0.07316769, 0.0) * g_24(pixel.xy);
  result += mat4x4<f32>(0.026366957, 0.02789826, 0.027239393, 0.0, -0.006712127, -0.0035723334, -0.0032348586, 0.0, -0.04960562, -0.062758155, -0.058574595, 0.0, -0.02896146, -0.020999067, -0.021301663, 0.0) * g_25(pixel.xy);
  result += mat4x4<f32>(-0.013106142, -0.017057793, -0.014653614, 0.0, -0.04254173, -0.043040022, -0.041918345, 0.0, -0.011146975, -0.0043820064, -0.003768677, 0.0, -0.0027743059, -0.0114479, -0.0082087545, 0.0) * g_26(pixel.xy);
  result += mat4x4<f32>(-0.10087762, -0.10447133, -0.1005168, 0.0, -0.04165659, -0.04558967, -0.040086865, 0.0, 0.0016493691, 0.0055392827, 0.0070476984, 0.0, -0.018665023, -0.035552308, -0.03375731, 0.0) * g_27(pixel.xy);
  result += vec4f(0.018580848, -0.022256816, -0.0266178, 0.0);
  textureStore(output_tex, pixel.xy, result);
}

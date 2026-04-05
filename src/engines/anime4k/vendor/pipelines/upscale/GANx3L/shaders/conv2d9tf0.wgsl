// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x56
// Name: conv2d9tf
// Inputs: ['conv2d_6_tf', 'conv2d_6_tf1', 'conv2d_6_tf2', 'conv2d_8_tf', 'conv2d_1_tf', 'conv2d_4_tf', 'conv2d_7_tf']
// Output: conv2d_9_tf
@group(0) @binding(0) var conv2d_6_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_6_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_6_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_8_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_7_tf_tex: texture_2d<f32>;
@group(0) @binding(7) var conv2d_9_tf_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_9_tf_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.20878315, 0.073090814, 0.34913197, 0.04554434, -0.3036766, 0.04255219, 0.060676616, 0.24025755, -0.019680336, -0.15252031, -0.03416314, -0.072506554, 0.013241457, -0.10496547, 0.050562985, -0.033250205) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.18049034, 0.09664636, 0.41482204, 0.23575203, -0.05704124, -0.044852983, 0.1783455, -0.017561441, -0.06852369, 0.014129533, -0.21115111, -0.22699773, 0.38242704, 0.01165174, 0.04190493, -0.2141891) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.011946614, -0.16289592, 0.041371312, 0.40975794, 0.0041022287, -0.23657559, 0.10817027, -0.26924378, -0.12006245, 0.26678962, 0.072988346, -0.2085322, 0.0048250603, 0.12894252, 0.07966851, 0.24471562) * g_2(pixel.xy);
  result += mat4x4<f32>(0.18590502, 0.0845459, -0.12875262, 0.26096, 0.029233042, 0.36381075, 0.117661506, 0.006412487, 0.20946807, 0.07426911, 0.029169528, 0.0654646, 0.16450708, 0.12593012, -0.109644994, 0.14572893) * g_3(pixel.xy);
  result += mat4x4<f32>(0.1973355, -0.2275125, -0.28223652, 0.31719315, 0.3813502, 0.2693579, -0.037815563, -0.16148391, 0.12829015, -0.0030689894, 0.022164742, 0.035949815, -0.3378249, -0.13235879, 0.15883659, -0.17731927) * g_4(pixel.xy);
  result += mat4x4<f32>(-0.2885664, 0.14904943, -0.19845994, 0.23251331, -0.30293494, 0.02003626, 0.20378608, 0.27291408, -0.16427508, -0.1587996, -0.22501752, -0.04937006, -0.115756296, 0.09290222, -0.26140857, -0.014537909) * g_5(pixel.xy);
  result += mat4x4<f32>(-0.1513065, -0.31879196, -0.2727547, -0.4583672, 0.3103975, -0.09158548, 0.009788355, -0.09834531, 0.011489709, 0.042706747, 0.37254226, 0.15954055, 0.2172001, 0.09373807, 0.29088458, -0.35286763) * g_6(pixel.xy);
  result += mat4x4<f32>(0.23374696, 0.33407655, 0.23616461, -0.09521148, -0.14927168, 0.11939751, 0.42869845, -0.16612507, -0.2706815, 0.16172597, -0.5814591, -0.11577833, 0.065650895, -0.3334003, -0.41168052, 0.32357255) * g_7(pixel.xy);
  result += mat4x4<f32>(0.3248823, -0.27207342, -0.048840526, -0.217887, -0.018053366, -0.24292938, 0.1603505, 0.06505262, -0.010766065, 0.07076721, 0.22251016, -0.041497335, -0.09878612, 0.2061045, 0.080330074, -0.029014835) * g_8(pixel.xy);
  result += mat4x4<f32>(-0.26376098, -0.04971863, -0.03045489, 0.009807002, 0.11108562, 0.0693266, 0.15279642, -0.1372833, 0.18326105, -0.059612468, -0.005589879, 0.021735538, -0.027800532, -0.14984077, -0.116767704, -0.06531209) * g_9(pixel.xy);
  result += mat4x4<f32>(0.19206688, 0.21824414, 0.03791829, 0.22117318, 0.01257811, -0.044042267, 0.25616458, 0.082941554, -0.1181948, -0.17940602, -0.20808466, -0.06987383, 0.0019713745, -0.1609917, 0.153718, -0.32214788) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.19472712, -0.007020553, -0.36049378, -0.24589752, -0.011828978, 0.38882232, -0.3257698, 0.08382738, -0.09556564, -0.20949766, -0.32732338, 0.08303877, -0.107999764, 0.2836336, -0.0661124, 0.24043255) * g_11(pixel.xy);
  result += mat4x4<f32>(-0.1972939, 0.12734106, -0.09953153, -0.45152718, -0.15855458, 0.08746372, 0.11452114, 0.030538268, 0.11946308, 0.17044471, -0.24375156, -0.10093911, 0.19120134, -0.14312318, -0.14860255, -0.1223525) * g_12(pixel.xy);
  result += mat4x4<f32>(0.14979935, -0.3136038, -0.25878516, 0.12995318, -0.075706124, -0.104598634, 0.1455947, -0.6167443, 0.06843719, -0.16347055, 0.04413483, 0.08870554, -0.29839858, 0.07214889, 0.049274225, -0.15555117) * g_13(pixel.xy);
  result += vec4f(-0.004266169, -0.020547107, -0.0031655694, 0.0643683);
  textureStore(conv2d_9_tf_tex, pixel.xy, result);
}

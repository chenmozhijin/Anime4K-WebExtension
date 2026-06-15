// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x56
// Name: conv2d9tf2
// Inputs: ['conv2d_6_tf', 'conv2d_6_tf1', 'conv2d_6_tf2', 'conv2d_8_tf', 'conv2d_1_tf', 'conv2d_4_tf', 'conv2d_7_tf']
// Output: conv2d_9_tf2
@group(0) @binding(0) var conv2d_6_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_6_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_6_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_8_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_7_tf_tex: texture_2d<f32>;
@group(0) @binding(7) var conv2d_9_tf2_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_9_tf2_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(0.0014731521, -0.15165007, 0.04889816, -0.23228844, 0.11362322, 0.07071926, -0.23770805, -0.04347728, -0.16787082, -0.008313435, -0.42370048, 0.08681679, 0.10611205, -0.012660734, 0.10022364, 0.027629996) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.35393402, 0.018436229, 0.10629333, 0.029471794, -0.21129252, -0.301571, 0.0045201713, -0.15636055, 0.298371, 0.11426107, 0.018450111, -0.13657977, 0.22216578, 0.009629214, 0.5373198, 0.30699998) * g_1(pixel.xy);
  result += mat4x4<f32>(-0.1504586, -0.16447587, -0.2739809, -0.14074785, 0.39510623, -0.08384201, 0.14561974, -0.43195033, -0.055713434, 0.12800978, 0.2829296, -0.23494978, 0.14326042, -0.09509476, -0.3169162, 0.124649614) * g_2(pixel.xy);
  result += mat4x4<f32>(-0.23705968, 0.15959233, 0.11467344, 0.15141489, -0.096755706, 0.023953263, 0.13856179, 0.024189185, 0.13272291, 0.46271062, 0.55494446, -0.14286532, 0.1501738, 0.28827608, 0.058801714, 0.029045105) * g_3(pixel.xy);
  result += mat4x4<f32>(-0.002308931, 0.07281086, -0.5197955, 0.079986535, 0.38919175, 0.3164044, 0.35857818, 0.09364757, 0.17373051, -0.1447216, -0.05244769, 0.15533692, 0.046295535, -0.19459103, -0.33215967, -0.15369573) * g_4(pixel.xy);
  result += mat4x4<f32>(0.11478203, -0.29375935, -0.19501545, -0.081721894, -0.103483915, 0.041965716, 0.056954723, 0.19596405, -0.13819647, 0.010641367, -0.11124998, -0.08675409, 0.036859434, 0.23720297, 0.14129876, -0.044769786) * g_5(pixel.xy);
  result += mat4x4<f32>(0.08397742, -0.12651941, 0.17676216, -0.084249385, 0.36716628, 0.039452277, -0.27606088, -0.36796048, 0.31680533, 0.14186403, 0.4466997, 0.13315229, 0.011085958, -0.17513317, 0.13940759, 0.27495402) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.1870658, 0.18817395, 0.010469263, -0.39973256, -0.57167524, -0.38714117, -0.26255277, 0.14361858, 0.018649995, 0.15935089, -0.21745402, -0.0056655053, -0.15408997, -0.03154883, -0.29631105, 0.27472818) * g_7(pixel.xy);
  result += mat4x4<f32>(-0.07735958, 0.042861674, 0.36729267, -0.2362879, -0.15516327, -0.009109079, 0.063800156, -0.253287, 0.4471074, 0.0944695, -0.26948866, -0.07759066, 0.045151226, -0.13749917, 0.14566323, -0.13593693) * g_8(pixel.xy);
  result += mat4x4<f32>(0.28955856, 0.09293573, 0.07423561, 0.1616493, 0.22285056, 0.01639275, 0.026332684, -0.14958683, -0.32087958, -0.3138252, -0.17335242, -0.38171476, -0.25562596, -0.022701526, 0.17425084, -0.042576227) * g_9(pixel.xy);
  result += mat4x4<f32>(0.24964347, -0.07078707, 0.18416835, -0.054758202, -0.061644293, -0.0964391, 0.14583856, -0.34874785, -0.3402768, 0.14743538, 0.36047265, 0.04471611, 0.015971184, 0.25227246, -0.011749087, -0.18359871) * g_10(pixel.xy);
  result += mat4x4<f32>(-0.059328917, -0.07904788, -0.23883855, -0.06956805, -0.040810965, 0.09536262, 0.0018617791, -0.1898438, 0.1794419, 0.11382087, -0.16192305, 0.22020166, 0.03995484, -0.19086155, -0.2970539, 0.14597812) * g_11(pixel.xy);
  result += mat4x4<f32>(-0.034995254, 0.060782332, -0.0519364, 0.41303346, -0.06989344, 0.21384521, 0.31474474, 0.12592849, 0.17633408, -0.2764535, 0.36884397, -0.015302021, 0.02951528, 0.094452016, 0.13392285, 0.14435606) * g_12(pixel.xy);
  result += mat4x4<f32>(0.13522784, 0.101011604, 0.04657966, -0.043399148, 0.008192044, 0.0027336285, 0.011269824, 0.09976881, -0.026473437, -0.124423906, -0.19602631, -0.09871594, -0.10603456, 0.057509303, -0.09007557, -0.14438893) * g_13(pixel.xy);
  result += vec4f(-0.07283617, -0.09245546, -0.006695486, -0.013076421);
  textureStore(conv2d_9_tf2_tex, pixel.xy, result);
}

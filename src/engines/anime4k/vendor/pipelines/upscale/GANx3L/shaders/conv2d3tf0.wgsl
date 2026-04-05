// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x40
// Name: conv2d3tf
// Inputs: ['conv2d_tf', 'conv2d_tf1', 'conv2d_tf2', 'conv2d_2_tf', 'conv2d_1_tf']
// Output: conv2d_3_tf
@group(0) @binding(0) var conv2d_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_2_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_3_tf_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_3_tf_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(-0.02357968, 0.13800439, 0.054744735, -0.32328397, -0.2263118, -0.3222542, -0.15286992, -0.3053175, -0.20046607, 0.025345843, 0.032755207, 0.40165102, 0.03166696, 0.29110438, 0.28861988, 0.05585125) * g_0(pixel.xy);
  result += mat4x4<f32>(0.11055126, -0.33034575, 0.039494887, -0.17843343, 0.35742196, 0.00032650787, 0.21049741, 0.18823248, -0.1741954, 0.27586365, -0.043366615, 0.02092058, -0.082515135, -0.15504313, 0.13261497, 0.14650741) * g_1(pixel.xy);
  result += mat4x4<f32>(0.39276633, -0.031067554, -0.08830738, -0.23975314, -0.20294978, 0.030291535, 0.4623106, 0.06494191, 0.042467684, -0.28105733, -0.053258326, -0.17269841, 0.09479501, 0.11930515, 0.1258843, 0.11058792) * g_2(pixel.xy);
  result += mat4x4<f32>(-0.18343425, -0.4381688, -0.08248827, -0.42846557, -0.08277779, 0.45192116, 0.21961756, 0.23076119, -0.2093829, -0.29050866, 0.26212537, -0.25469857, -0.4832557, -0.45126852, -0.35072148, -0.18368497) * g_3(pixel.xy);
  result += mat4x4<f32>(0.10529696, 0.5964488, 0.13258573, -0.07494986, -0.3341919, 0.19418421, -0.18307082, 0.34982273, -0.0430461, 0.21097268, 0.03212202, -0.015623122, 0.43791813, 0.16207397, 0.123477034, -0.087993294) * g_4(pixel.xy);
  result += mat4x4<f32>(-0.01878982, 0.007308694, 0.25769314, 0.18407181, 0.00095180905, -0.2600526, -0.31043288, -0.24622385, 0.07832029, 0.05502411, 0.37793204, -0.07329948, -0.28405467, -0.15038961, 0.19259417, 0.105486296) * g_5(pixel.xy);
  result += mat4x4<f32>(0.047820415, 0.3303589, 0.035807017, -0.41168606, -0.2118325, -0.045765184, -0.15234827, 0.28021428, -0.2084036, -0.40200952, -0.3261011, -0.13480914, -0.06876906, -0.19167677, -0.20444186, -0.44851676) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.24726203, -0.0097923195, -0.23193192, 0.31947026, 0.4274281, -0.36929542, 0.10095328, -0.19663717, 0.3244895, 0.49458218, 0.24745567, 0.15722558, 0.43052208, 0.377559, 0.22543637, 0.13009055) * g_7(pixel.xy);
  result += mat4x4<f32>(0.01817998, 0.111477636, -0.12727399, 0.27395004, 0.19770023, -0.1636959, 0.25407487, -0.24871433, -0.08552937, 0.3223687, 0.30668882, 0.40221208, -0.20192504, 0.14656074, 0.5100356, -0.0948956) * g_8(pixel.xy);
  result += mat4x4<f32>(0.40383592, -0.043663148, 0.4813348, 0.10317451, -0.049076255, -0.022925228, 0.0872564, 0.21741754, 0.23656987, -0.22309794, -0.2260013, 0.20823886, -0.055542476, 0.016604664, -0.1964831, 0.11962174) * g_9(pixel.xy);
  result += vec4f(-0.049604952, -0.039514415, -0.06137416, -0.0015509313);
  textureStore(conv2d_3_tf_tex, pixel.xy, result);
}

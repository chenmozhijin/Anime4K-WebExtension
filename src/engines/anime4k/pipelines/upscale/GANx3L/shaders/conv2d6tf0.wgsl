// Layer: Anime4K-v4.1-Upscale-GAN-x3-(L)-Conv-4x1x1x48
// Name: conv2d6tf
// Inputs: ['conv2d_3_tf', 'conv2d_3_tf1', 'conv2d_3_tf2', 'conv2d_5_tf', 'conv2d_1_tf', 'conv2d_4_tf']
// Output: conv2d_6_tf
@group(0) @binding(0) var conv2d_3_tf_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_3_tf1_tex: texture_2d<f32>;
@group(0) @binding(2) var conv2d_3_tf2_tex: texture_2d<f32>;
@group(0) @binding(3) var conv2d_5_tf_tex: texture_2d<f32>;
@group(0) @binding(4) var conv2d_1_tf_tex: texture_2d<f32>;
@group(0) @binding(5) var conv2d_4_tf_tex: texture_2d<f32>;
@group(0) @binding(6) var conv2d_6_tf_tex: texture_storage_2d<rgba16float, write>;
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
  let dim_out: vec2u = textureDimensions(conv2d_6_tf_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  
  var result: vec4f = vec4f(0.0);
  result += mat4x4<f32>(0.15610647, -0.15150696, -0.076018915, 0.030773202, -0.13935511, 0.17644633, 0.028819937, 0.30125114, 0.38625193, 0.35517895, 0.0975343, 0.114022225, 0.25494647, -0.23291643, 0.29096943, 0.15063812) * g_0(pixel.xy);
  result += mat4x4<f32>(-0.22949804, -0.1368772, -0.07729264, 0.08470473, -0.06426131, -0.0064847367, 0.08241476, -0.1476949, -0.13712044, -0.36110023, -0.081719294, 0.19409889, 0.05562042, 0.26609465, 0.020447321, 0.2567414) * g_1(pixel.xy);
  result += mat4x4<f32>(0.03337578, 0.2905731, 0.21772428, -0.074480034, 0.071880735, 0.27764675, -0.17273173, -0.0037474795, -0.1842544, 0.21896398, -0.30134472, 0.1711769, 0.23913746, -0.0435854, -0.12745531, -0.050227556) * g_2(pixel.xy);
  result += mat4x4<f32>(0.34923258, -0.5455803, -0.2904644, -0.5446842, -0.040965725, -0.055288248, -0.50672686, -0.10309429, 0.045286313, -0.04284262, -0.19785875, -0.16594213, -0.10000842, 0.47245356, -0.32767087, 0.32854807) * g_3(pixel.xy);
  result += mat4x4<f32>(0.05952625, -0.062991776, 0.3438396, -0.08141334, -0.2488028, -0.04746144, 0.06563561, 0.45020792, -0.19996788, 0.015523991, -0.19214569, -0.24849077, -0.022107737, 0.28190804, 0.13384444, -0.12800638) * g_4(pixel.xy);
  result += mat4x4<f32>(-0.37812218, 0.09970516, 0.015231938, 0.07226164, -0.33720142, -0.05899804, -0.0025790115, -0.17770731, 0.111127384, 0.008749534, -0.09077738, -0.060420215, -0.10196339, 0.09641038, 0.25222716, 0.12781976) * g_5(pixel.xy);
  result += mat4x4<f32>(0.24168618, 0.18625724, -0.012904225, -0.011732107, 0.085045695, -0.4754185, 0.10896487, 0.09179793, -0.31662637, -0.117563, 0.5133052, -0.09457646, -0.15872721, -0.09779008, 0.56810176, 0.3339073) * g_6(pixel.xy);
  result += mat4x4<f32>(-0.09105348, -0.17617023, -0.21897802, -0.14157395, 0.16165406, -0.46579927, 0.24905841, 0.11579037, 0.09073764, 0.36771873, -0.29340085, -0.04271419, -0.11684365, -0.17138094, 0.12188604, -0.14749436) * g_7(pixel.xy);
  result += mat4x4<f32>(0.10943254, -0.17193961, -0.07027378, -0.26047203, 0.04288517, 0.21311204, 0.03997142, -0.17006959, 0.16181368, 0.28361118, 0.26655135, -0.097007245, -0.15998597, -0.09568138, -0.27558687, -0.11706871) * g_8(pixel.xy);
  result += mat4x4<f32>(0.365517, 0.5422966, -0.0013869518, 0.3447622, -0.25885904, -0.098901175, -0.048043057, 0.15867509, -0.12303401, -0.15362008, 0.270228, -0.2756776, -0.44207478, -0.0419657, 0.09387863, -0.07240854) * g_9(pixel.xy);
  result += mat4x4<f32>(0.15073416, -0.032387026, -0.039117433, -0.50999755, 0.073477276, -0.14495571, 0.15120687, -0.3443857, -0.29039595, -0.16189122, 0.14190345, -0.10934344, -0.21965231, -0.45768484, 0.11907852, 0.5091087) * g_10(pixel.xy);
  result += mat4x4<f32>(0.23260471, 0.16441877, 0.16760987, 0.10740154, -0.21663232, -0.10124566, -0.20843595, 0.066555224, 0.24608357, 0.16345865, -0.11965141, 0.18451719, 0.41683537, -0.044497896, 0.39102596, -0.11944608) * g_11(pixel.xy);
  result += vec4f(-0.02423156, 0.015124756, -0.02608139, 0.030428935);
  textureStore(conv2d_6_tf_tex, pixel.xy, result);
}

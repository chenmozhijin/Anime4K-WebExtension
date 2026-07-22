// Layer: Anime4K-v4.0-Restore-CNN-(L)-Conv-4x3x3x3
// Inputs: ["MAIN"]
// Output: conv2d_tf
@group(0) @binding(0) var MAIN_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf_tex: texture_storage_2d<rgba16float, write>;

fn anime4kTextureLoadClamped(texture: texture_2d<f32>, pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  let size = vec2i(textureDimensions(texture));
  let coord = clamp(vec2i(pos) + vec2i(x_off, y_off), vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(texture, coord, 0);
}

fn max4(vector: vec4f, value: f32) -> vec4f {
  return max(vector, vec4f(value));
}

fn go_0(pos: vec2u, x_off: i32, y_off: i32) -> vec4f {
  return anime4kTextureLoadClamped(MAIN_tex, pos, x_off, y_off);
}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let dim_out: vec2u = textureDimensions(conv2d_tf_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  var result: vec4f = mat4x4<f32>(-0.27899465, -0.14974926, 0.6271667, -0.04888494, 0.2164516, -0.47826648, 0.09537477, 0.16404815, -0.009546488, -0.24541017, -0.20505093, -0.11507772, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, -1);
  result += mat4x4<f32>(-0.22372562, 0.046120282, 0.44437107, 0.54215515, -0.10638798, -0.010795577, 0.19478157, 0.5756847, 0.24542068, 0.11135218, -0.27672207, 0.09624475, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 0);
  result += mat4x4<f32>(0.1703517, -0.17810228, -0.34460765, -0.40586865, 0.2102622, 0.08207581, 0.17641851, 0.23701222, -0.32159516, -0.017147528, 0.41743183, 0.19025058, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 1);
  result += mat4x4<f32>(0.4708481, -0.1587934, -0.15760423, -0.11388875, -0.36032093, -0.044305246, 0.19414884, 0.31109568, -0.09320259, -0.23072109, 0.0242641, 0.040976923, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, -1);
  result += mat4x4<f32>(0.00951417, 0.2746557, -0.49743456, 0.14564055, 0.15047263, 0.08832856, -0.24360974, -0.3517844, -0.12219134, 0.12957081, 0.2876983, 0.13303527, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 0);
  result += mat4x4<f32>(-0.12760738, 0.16703783, 0.04391735, 0.34657615, -0.26698044, -0.096000046, -0.46030682, -0.38363042, 0.3510441, 0.2620507, -0.30533043, -0.32785, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 1);
  result += mat4x4<f32>(0.63138646, -0.12703805, 0.38107973, -0.09134196, -0.04012397, -0.1390924, 0.07578805, -0.09274019, -0.045394078, 0.18203364, 0.16900069, 0.13399005, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, -1);
  result += mat4x4<f32>(-0.13648264, -0.13971807, -0.32322997, -0.08377875, 0.40967095, 0.19853555, -0.26386982, -0.50860924, -0.00555831, 0.06922444, 0.034828495, -0.08413197, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 0);
  result += mat4x4<f32>(0.21196735, 0.24934316, -0.27111465, -0.19941513, -0.30186844, 0.44828892, 0.35906994, -0.35723612, -0.074009515, -0.34400147, -0.22145566, -0.15622428, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 1);
  result += vec4f(-0.44569078, -0.084358215, -0.014156722, -0.0353374);
  textureStore(conv2d_tf_tex, pixel.xy, result);
}

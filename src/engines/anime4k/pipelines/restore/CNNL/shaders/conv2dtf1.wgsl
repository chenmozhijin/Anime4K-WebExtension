// Layer: Anime4K-v4.0-Restore-CNN-(L)-Conv-4x3x3x3
// Inputs: ["MAIN"]
// Output: conv2d_tf1
@group(0) @binding(0) var MAIN_tex: texture_2d<f32>;
@group(0) @binding(1) var conv2d_tf1_tex: texture_storage_2d<rgba16float, write>;

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
  let dim_out: vec2u = textureDimensions(conv2d_tf1_tex);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  var result: vec4f = mat4x4<f32>(0.1953752, -0.09707663, 0.43315637, 0.3862221, 0.2346731, 0.085327715, 0.36244828, 0.06630519, -0.05342483, 0.112148136, 0.07938104, 0.14795923, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, -1);
  result += mat4x4<f32>(0.25197014, 0.032906674, 0.3392793, 0.18099307, -0.36539522, 0.10986396, 0.5440999, 0.41803896, -0.4117931, 0.46616048, 0.0827279, 0.040264074, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 0);
  result += mat4x4<f32>(-0.060543116, 0.34531194, -0.3202978, 0.32803985, -0.08720925, 0.63656414, -0.052656054, -0.076137036, 0.15297869, -0.11485237, -0.21027736, -0.24086118, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, -1, 1);
  result += mat4x4<f32>(-0.2044052, 0.111065395, -0.36082193, -0.39179638, 0.19812255, -0.3797384, 0.03176089, -0.35085422, 0.31697252, -0.31267545, -0.068170965, -0.06266394, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, -1);
  result += mat4x4<f32>(0.0055682547, 0.24352197, 0.08972456, -0.4340704, -0.25253078, -0.4218859, 0.08408476, -0.5052765, 0.005511427, -0.36491954, 0.3825727, 0.01774532, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 0);
  result += mat4x4<f32>(0.13323675, -0.6641518, -0.38277033, 0.67553586, -0.5879293, -0.1286407, 0.1355451, 0.19463064, -0.09206729, 0.41892347, 0.16736335, -0.017109495, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 0, 1);
  result += mat4x4<f32>(0.0627963, 0.29361042, 0.23339616, -0.42217752, 0.21872504, -0.21531922, -0.5016595, 0.20158494, 0.2814043, -0.1474019, 0.08778552, 0.28085083, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, -1);
  result += mat4x4<f32>(-0.009900911, -0.42754972, 0.02737237, -0.17740859, 0.541632, -0.28397697, -0.36375052, -0.172693, 0.1506882, 0.15196925, -0.30358136, -0.29542333, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 0);
  result += mat4x4<f32>(-0.3690586, 0.19382606, -0.040331036, -0.14121497, 0.121049926, 0.54470515, -0.23628974, 0.20663929, -0.34591553, -0.14778244, -0.23809184, 0.12616424, 0.0, 0.0, 0.0, 0.0) * go_0(pixel.xy, 1, 1);
  result += vec4f(-0.009787335, 0.051148742, -0.007458707, -0.016416457);
  textureStore(conv2d_tf1_tex, pixel.xy, result);
}

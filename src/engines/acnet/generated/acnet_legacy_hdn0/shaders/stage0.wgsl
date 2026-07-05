const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_LUMA: texture_2d<f32>;

fn sample_LUMA(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_LUMA));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  let color = textureLoad(tex_LUMA, coord, 0);
  return vec4f(luma709(color.rgb), 0.0, 0.0, color.a);
}

@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.75769705, -0.020978633, 0.029168185, -0.0188724);
      result += vec4f(0.060916748, 0.008870892, -0.19374, 0.026361894) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.10268694, 0.15398064, 0.7258638, -0.9421819) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.044656154, -0.8588956, 0.011868592, 0.12578909) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.14226541, 0.044758577, -0.8265947, -0.054290023) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.71963114, 0.86591, 0.41470954, 0.12815204) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.18030833, -0.24202932, 0.008753498, 0.7101893) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.084153794, -0.036423013, -0.045293033, -0.010597835) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.06962451, 0.058463693, -0.04514171, 0.03859186) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.008150022, 0.0124604255, -0.018197935, -0.014054487) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

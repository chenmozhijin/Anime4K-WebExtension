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

  var result: vec4f = vec4f(-0.7604295, -0.0059438823, 0.017396742, 0.004520172);
      result += vec4f(0.044161607, 0.0052909567, -0.19152719, 0.031133022) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.08616722, 0.15492399, 0.7269663, -0.9430303) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.06749972, -0.8575752, 0.011305518, 0.13086984) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.14332297, 0.037113868, -0.84166706, -0.05649923) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.7180264, 0.8681992, 0.4150768, 0.13070372) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.17174453, -0.24100713, 0.010963769, 0.71135265) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.07941442, -0.038818832, -0.036321957, -0.008321253) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.067135096, 0.056471046, -0.058478814, 0.0330729) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.0014139495, 0.009907993, -0.010297978, -0.014142729) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

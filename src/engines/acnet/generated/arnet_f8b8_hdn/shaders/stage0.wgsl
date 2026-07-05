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

  var result: vec4f = vec4f(-0.105040506, -0.37178555, -0.6758617, -0.73047924);
      result += vec4f(-0.0631249, -0.024949858, -0.062396538, -0.2885574) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.3674888, -0.7624243, 0.021319997, -1.7105587) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.07288085, -0.8256859, -0.1654668, -0.2681926) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.062815376, 0.06474114, 0.08661237, -0.55113345) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(2.3151944, 7.3184524, 2.0620563, 6.9700685) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.58783674, -1.6263762, -0.09560001, -1.0504514) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.269491, -0.12661019, -0.053956755, -0.22483426) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.37168017, -1.7732943, -0.08284252, -0.8205347) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.010580854, -1.0488057, -0.32862133, -0.38923088) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

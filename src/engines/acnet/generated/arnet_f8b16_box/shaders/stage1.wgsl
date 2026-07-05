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

  var result: vec4f = vec4f(0.066693656, -0.05594309, 1.0627273, -0.53832006);
      result += vec4f(-0.21356018, -0.3606661, -0.037226815, -0.66178477) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.7377616, 0.0004598452, 0.43539968, -0.802467) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.037201732, 0.0779517, 0.17878476, 0.044258304) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.76961315, -0.6488743, 0.35272172, -2.438797) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.3455708, 1.0115751, -4.9238367, 5.9269075) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.20528492, 0.49096644, 0.92574954, 0.26706523) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.23771892, -0.619655, 0.14298204, -0.6444276) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.04268834, -0.041590016, 0.75579435, -0.99380064) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.27523288, 0.051220812, 0.18574941, 0.04617542) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

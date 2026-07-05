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

  var result: vec4f = vec4f(1.709073, 0.25194097, 0.041318227, -0.33228493);
      result += vec4f(0.18833996, 0.08127281, -0.23336545, -0.25695112) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(1.2498063, -0.3263982, -2.0523973, -0.70353854) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.36346397, -0.12667961, -0.4193895, -0.13904545) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.645029, -0.08012512, -0.3314896, -0.47551358) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-8.157924, 1.6064371, 3.0926151, 3.0315893) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(1.0364797, -0.6963227, -0.5856325, -0.1760626) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.22534299, -0.039520934, 0.21620576, -0.14568609) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.79370546, -0.5913354, 0.1365081, -0.1611852) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.36780867, -0.2658319, 0.119021975, -0.08019524) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

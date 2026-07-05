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

  var result: vec4f = vec4f(-0.21458076, -1.3411951, 0.1979225, -0.0038848184);
      result += vec4f(-0.15199742, -0.7743253, -0.18282413, -0.034448367) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.9744788, -1.8069692, -0.06492042, -0.2075491) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.24908268, -0.19821057, 0.18366349, -0.061168622) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.378397, -2.2787821, -0.59979355, -0.27197778) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(2.189482, 9.984648, 0.2992254, 1.6245346) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.44034827, -0.60132414, 0.36351332, -0.37425154) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.06872529, -0.72894883, -0.25749388, -0.20360018) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.10341813, -0.9619604, -0.028314054, -0.5162642) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.025673946, -0.21645321, 0.06361493, -0.12453979) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

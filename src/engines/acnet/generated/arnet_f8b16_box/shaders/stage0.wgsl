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

  var result: vec4f = vec4f(-0.20916396, -0.114979796, -0.121293485, 0.41740054);
      result += vec4f(-0.120361745, 0.08987524, -0.4597662, 0.13814682) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.2910056, 0.024256192, -0.44898665, 0.07797567) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.16758847, -0.019366413, 0.10649319, 0.33153138) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.005368458, 0.044417135, -1.7684394, 0.63217366) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-1.4088356, -0.10547898, 2.6798656, -6.45352) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.82074875, -0.14186917, 0.5237104, 1.5226384) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.08123946, 0.15130381, -0.18896474, 0.5227847) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.55711573, -0.09750062, -0.5099458, 1.6984713) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.17520297, -0.08829159, 0.09215468, 0.47318792) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

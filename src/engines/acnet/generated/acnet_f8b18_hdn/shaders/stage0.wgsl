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

  var result: vec4f = vec4f(-0.3136146, 5.7620425, 0.06724245, -0.089983284);
      result += vec4f(-0.043338295, 1.534949, -0.054556187, -0.3897453) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.44223285, 1.0257725, -0.6434495, 1.7350936) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.29362598, 1.1372288, 0.8292416, -0.38697928) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.622624, 0.7626491, 0.33408922, 0.36351743) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(5.7978196, -19.47884, -4.2955813, 5.541236) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.7644521, 0.56204975, 0.9966599, 0.6036974) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.08529966, 1.4322598, 0.69405437, -0.024063785) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-6.2084312, 1.1837571, 1.3216803, -7.4372563) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.17855231, 1.3653498, 0.79186225, -0.052047834) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.25283092, 1.0275543, 1.7423258, -0.6188597) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.17922601, 0.07659215, 3.167064, -2.669166);
      result += vec4f(0.2820395, 0.26163378, 1.4773068, -0.70833796) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.45496038, 1.4001225, -0.5454532, -0.4732345) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-2.7072306, 0.44661877, 1.2457404, -0.69371855) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.549171, 1.7919246, 0.32010388, -0.5390293) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-0.66536677, -11.796198, -11.642864, 8.262481) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.5393669, 1.5799712, -1.3296499, -1.1527569) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-1.2419696, 0.33850837, 1.0422593, -0.8762881) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.71970713, 1.5284525, -0.510905, -0.4668954) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.1151464, 0.062176067, 1.0418855, -0.43935466) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.33292875, 0.010052932, 0.9581052, -0.053414416) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

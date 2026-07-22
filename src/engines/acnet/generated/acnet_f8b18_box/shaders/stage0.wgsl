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
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.23615615, 5.8309393, -0.1860364, -0.07352639);
      result += vec4f(0.022865755, 0.60263544, -0.20150466, -0.07474669) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.24271622, 1.0747224, 0.48023456, 0.4601699) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.10634776, 0.85678935, -0.07611138, 0.055917565) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.39276585, 0.35327628, 0.33735842, 0.2825116) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(6.9185815, -17.666967, -5.585014, 8.503052) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.41055152, 0.26785275, 0.66653574, 0.19342168) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.14677471, 0.707301, -0.10192377, -0.22277805) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-6.7399445, 0.551047, 4.6494117, -9.087683) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.33893415, 0.61388904, -0.35396338, -0.19941783) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.11909424, 1.0130122, 1.9290066, -0.5367691) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

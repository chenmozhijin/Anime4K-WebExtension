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

  var result: vec4f = vec4f(0.02339131, -0.053690657, 0.013868082, -0.107966915);
      result += vec4f(-0.8324125, 0.97923094, 0.4390296, -1.609712) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.5540275, -0.11278517, 1.1788406, -0.42266038) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.44798127, 0.6924998, -0.07455559, -0.5101584) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.7986842, 2.3852844, 0.7812117, -3.6084046) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-6.9535637, -4.0648613, -4.307677, 5.880962) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(3.356355, -1.0906544, 0.89468765, 0.44545737) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.099523425, 0.113329075, 0.18288681, -0.16065188) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(2.938326, 0.7060379, 0.8609803, -0.1983859) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.40172628, 0.30901924, 0.5376545, 0.0903868) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.528495, -0.6519189, 0.74122864, -0.33652022) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

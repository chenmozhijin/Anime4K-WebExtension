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

  var result: vec4f = vec4f(-0.08493366, -0.2786129, -0.58670616, -0.51802194);
      result += vec4f(0.077919364, -0.04769914, -0.010180572, -0.274473) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.25197005, -0.47258818, -0.124250084, -1.3711518) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.058012925, -0.30048227, -0.12747297, -0.021991564) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.0790147, -0.047865253, -0.0006321799, -0.77488947) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(2.102238, 5.6661806, 1.481504, 6.1054325) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-1.1490909, -1.564071, 0.269017, -0.95578444) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.1553921, -0.09371717, -0.016118424, -0.07445497) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.5012672, -1.4881132, -0.050368603, -0.8994223) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.078897454, -0.7724702, -0.29424444, -0.48471436) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

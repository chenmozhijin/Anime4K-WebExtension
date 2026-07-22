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

  var result: vec4f = vec4f(-0.9520906, 0.013774246, -0.4940886, 0.13375327);
      result += vec4f(-0.0014878281, -0.7632004, 0.19272894, 0.46537745) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-1.3460438, 0.18894365, -0.0490235, -0.9890594) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.32281575, 1.4070463, 0.37536892, -0.37987557) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.65934813, 3.253703, -0.10119856, -1.7713721) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(5.563184, -5.9529715, -2.4931717, 7.4821305) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-2.1096349, 0.7543952, -0.3000822, -2.676932) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.11039619, -0.27639085, 0.14380127, -0.094028816) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-1.2408149, 1.8090338, 0.122120835, -1.6043427) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.53610414, -0.3941251, 0.46432167, -0.23128629) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.25083545, -0.85913664, 0.38589597, 0.73232096) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

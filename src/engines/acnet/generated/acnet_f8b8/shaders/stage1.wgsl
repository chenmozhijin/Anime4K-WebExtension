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

  var result: vec4f = vec4f(-0.42101532, 0.11790651, 3.447722, -2.627864);
      result += vec4f(0.21621396, -0.044754006, 1.1840594, 0.02162446) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.022212164, 1.561308, 0.14661855, -1.6041354) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-2.4093924, 0.49497297, 1.5170786, -0.3289562) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.7547148, 1.1307895, 0.68737507, -0.92217743) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-1.0857999, -9.989466, -12.069179, 8.053226) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.13323481, 1.2238587, -0.6690112, -1.1373993) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-1.0158925, 0.99110115, 1.2131628, -0.2545955) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(1.314239, 0.6567321, 0.21274994, -0.44225144) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.3511378, 0.03912955, 0.5568054, -0.4044556) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.35850996, 0.040749874, 0.9799285, -0.074893005) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

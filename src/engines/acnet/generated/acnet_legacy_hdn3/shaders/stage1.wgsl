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

  var result: vec4f = vec4f(0.2293561, -0.25948596, -0.23700292, -0.0498955);
      result += vec4f(-0.12458046, -0.08166234, -0.0082794465, -0.08334999) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.015544854, 0.22471838, 0.20448554, 0.07015573) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.40754262, 0.04718101, 0.10563168, 0.023447273) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.11559548, 0.03940544, -0.2238755, 0.36160892) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.59294224, 0.10847132, 0.2823044, 0.37885955) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.14491335, 0.14349294, -0.19260868, -0.18402907) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.10802329, -0.047987018, 0.25813594, 0.012832781) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.017055104, -0.013497529, 0.13620697, 0.13470872) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.051592335, -0.06060062, -0.19140281, -0.018682102) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

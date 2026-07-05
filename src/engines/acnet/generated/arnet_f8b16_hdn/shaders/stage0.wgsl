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

  var result: vec4f = vec4f(-0.40474063, -0.07174562, -0.147614, 0.09051207);
      result += vec4f(0.03360732, 0.055383857, -0.69251186, 0.35907382) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.6247874, 0.46075433, -1.190883, 0.5141197) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.36582428, -0.008755694, 0.14798853, 0.72058165) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.31575537, 0.027697705, -2.7910457, 1.0737635) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-2.249256, 0.7169892, 4.554565, -9.012131) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.92633986, -0.3609356, 0.7916489, 1.80375) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.25534815, 0.029100308, -0.41222313, 0.95443815) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.6380171, -0.6929372, -0.5732948, 2.107451) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.112585954, -0.348778, 0.16444196, 0.91958535) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

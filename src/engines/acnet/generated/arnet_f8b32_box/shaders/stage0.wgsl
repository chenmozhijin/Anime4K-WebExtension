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

  var result: vec4f = vec4f(2.4323022, -0.22828117, -0.20080844, 0.044999436);
      result += vec4f(0.21620196, 0.33899835, -0.056130085, 0.119907245) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(1.6208134, 0.37953773, -0.07702198, 1.2824847) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.2933088, -0.86281914, 0.1799169, 0.22152382) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(1.2412217, 0.82699364, -0.38867325, 0.9043083) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-11.995076, -0.063639976, 0.44857165, -4.838835) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(1.583796, -0.6429665, 0.37960654, 1.1577513) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.29652214, -0.112540536, 0.10172261, 0.17884535) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(1.1588112, 0.34161076, -0.1665404, 0.78065425) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.37276858, -0.013808406, 0.09336872, 0.25953647) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.25468552, -1.8220541, 0.1224549, -0.061341956);
      result += vec4f(-0.113926314, -0.9885413, -0.31704837, 0.010605677) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-1.2453108, -1.4618844, -0.19939004, 0.03430353) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.43819913, -0.2068211, 0.22581033, -0.06793481) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.35519043, -2.2948873, -0.8806911, -0.18223676) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(2.9696484, 10.717995, 0.89160013, 1.8091561) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.6579424, -0.15940052, 0.5000054, -0.48716503) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.089129224, -1.0069337, -0.39730665, -0.2911508) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.17440543, -0.9192161, -0.09059268, -0.7011048) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.052031334, -0.40339017, 0.13731581, -0.27628085) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

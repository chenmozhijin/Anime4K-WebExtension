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

  var result: vec4f = vec4f(2.6430902, -0.17723602, -0.2191435, 0.16245425);
      result += vec4f(0.4550083, 0.47122118, -0.1064218, 0.23819526) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(2.0064356, -0.05286569, -0.558778, 1.3708235) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.6476818, -1.0847726, -0.10072228, 0.4018587) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(1.6448395, 0.97864604, -0.949026, 1.2099131) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-14.661193, 0.18830281, 3.0603378, -6.3074856) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(1.7987776, -0.8060996, -0.22304106, 1.3807234) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.5367798, 0.23953316, -0.0024314073, 0.4619609) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(1.5401462, 0.3897031, -0.6989619, 1.1183732) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.46186206, -0.20462188, 0.060072005, 0.25578487) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

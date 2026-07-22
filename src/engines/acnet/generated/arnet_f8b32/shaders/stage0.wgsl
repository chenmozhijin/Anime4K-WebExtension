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

  var result: vec4f = vec4f(2.3931289, -0.2419472, -0.23745963, 0.027176194);
      result += vec4f(0.32757992, 0.31895435, -0.024737809, 0.15199375) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(2.3479156, 0.24484101, 0.022282282, 1.597659) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.4303529, -0.89018714, 0.035001338, 0.23289886) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(1.7783369, 0.7354799, -0.5069207, 1.1371855) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-14.585708, 0.19067635, 1.4493552, -5.58865) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(2.0392795, -0.679876, -0.010152761, 1.2355633) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.52154434, 0.062086467, 0.02109674, 0.2632722) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(1.5764238, 0.21725823, -0.47271413, 1.0100732) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.3604063, -0.026721517, 0.08156278, 0.13267797) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

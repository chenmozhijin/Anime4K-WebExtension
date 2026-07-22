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

  var result: vec4f = vec4f(-1.8226194, -0.18304786, -0.11006379, -5.4665446);
      result += vec4f(1.8967302, 0.4068176, -0.15961757, 0.629601) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.43019655, -1.1231238, -1.2882037, -1.2283385) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.43150303, 0.6431824, 1.6665094, 0.4594167) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.40467802, -0.23824231, -1.8056979, -1.7672147) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.2845016, -7.348465, -1.0739578, 8.952271) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.3360462, -0.8275929, -1.5199665, -0.98189056) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-1.9610755, 0.05825573, 0.9561907, 0.8279638) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.28404436, 8.214533, -0.63554144, -1.3857102) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(1.0856783, 0.14681761, 1.3565657, 0.86741835) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.31795388, -0.6472097, 0.34090975, 0.15820411) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

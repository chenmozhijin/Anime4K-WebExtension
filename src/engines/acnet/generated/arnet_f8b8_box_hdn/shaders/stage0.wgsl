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

  var result: vec4f = vec4f(-0.1308818, -0.5894596, -0.5726054, -0.9234302);
      result += vec4f(0.4776677, -0.24809746, 0.14274669, -0.14049466) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.31116533, -0.575233, 0.06841963, -2.026552) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.0779066, -0.9701354, -0.04709945, -0.5983946) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.14361788, 0.44581804, 0.12843797, -1.286525) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.6642284, 6.3018203, 0.55355054, 9.501169) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.5249475, -1.4277556, -0.07683453, -1.0472189) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.28118804, -0.0726434, 0.048533753, -0.589429) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.45711908, -0.99036324, 0.18973114, -1.038648) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.13039853, -0.8620632, -0.027902897, -0.5995117) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

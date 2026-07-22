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

  var result: vec4f = vec4f(-1.3817835, -0.11243686, -2.711542, -5.05187);
      result += vec4f(0.85619694, 0.014065241, 0.5650665, 0.3603563) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-1.3266423, -0.21520127, -0.8162335, -0.7604627) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(1.9337507, 0.10299092, 2.5689094, 0.23503247) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.4646314, -0.10452116, -0.72777545, -0.20558739) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-0.12025979, -9.385449, 0.8313174, 7.3714113) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-2.3635364, -0.15976419, -0.87068045, -0.611805) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-1.0171509, 0.19568579, 0.45639578, 0.11700249) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.9045163, 9.559798, -0.65684444, -0.63186836) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.49621585, -0.14339185, 0.912713, 0.31356454) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.3309977, -0.4931741, 0.19681782, 0.13029887) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

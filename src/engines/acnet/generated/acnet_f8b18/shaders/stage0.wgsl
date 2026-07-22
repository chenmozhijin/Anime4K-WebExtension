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

  var result: vec4f = vec4f(-0.32191616, 5.3028965, 0.04837258, -0.0720083);
      result += vec4f(0.4851954, 1.2688932, 0.44713223, -0.1298429) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.0520662, 1.2246435, 0.30095866, 0.09583094) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.24238102, 1.304448, 1.4011562, 0.10185474) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.91541344, 0.6347347, 0.2866581, -0.24015978) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(6.0795803, -19.129179, -7.02034, 7.9173036) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.09941017, 1.3707882, 1.1703601, -0.3477068) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.01891674, 0.57223684, 0.11666077, 0.308608) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-5.9547696, 2.3949144, 2.4081972, -7.993023) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.31613737, 0.8127513, 0.7634171, 0.2676375) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.19065897, 1.0447218, 1.3857305, -0.6915713) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

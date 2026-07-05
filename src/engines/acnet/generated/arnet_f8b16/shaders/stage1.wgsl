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

  var result: vec4f = vec4f(0.12863807, -0.08361923, 0.73069316, -0.29207167);
      result += vec4f(-0.10207736, -0.3571098, 0.12221278, -1.0146286) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-1.2617569, -0.27257594, 0.7539576, -1.0588313) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.104920365, -0.040117465, 0.43960094, 0.10618094) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.8820428, -0.46632877, 0.51157063, -2.9404857) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.136855, 1.5556183, -5.758464, 6.6279225) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.33843294, 0.32030326, 1.0537988, 0.64119315) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.10296737, -0.8627554, 0.36857775, -0.99191564) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.38212913, 0.00030439833, 0.8053627, -1.0630047) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.37968943, 0.10600485, 0.34075654, -0.07808754) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

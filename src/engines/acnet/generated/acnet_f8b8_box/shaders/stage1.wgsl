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

  var result: vec4f = vec4f(-0.27927524, 0.038226366, 3.6820662, -3.2044444);
      result += vec4f(0.106212996, -0.15064196, 0.78944147, 0.017546773) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.4172255, 2.121417, 0.75201416, -0.20778105) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-2.4468246, 0.41974404, 0.7876719, -0.12863237) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.43852943, 1.3832036, 1.0293695, -0.44270885) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.017875083, -10.364959, -12.850952, 5.1183333) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.30375662, 1.2705932, -0.18014407, -0.55194116) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.44586673, 0.48217747, 0.5351928, 0.07215761) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.45507145, 0.8288927, 0.48496163, -0.06510307) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.0006561586, 0.08609024, 0.7706708, -0.1879712) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.36523545, 0.027748123, 0.9972102, -0.038536575) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

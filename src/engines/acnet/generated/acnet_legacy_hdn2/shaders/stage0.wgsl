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

  var result: vec4f = vec4f(-0.09096397, 0.2113586, -0.0120110605, -4.565676e-38);
      result += vec4f(-0.020676212, 0.08470576, -0.53869176, -4.204857e-38) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.0067641074, -0.29454887, 0.07293408, -4.197148e-38) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.28287417, -0.05583051, -0.001766192, -4.1487885e-38) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.25575832, -0.08463457, -0.031402405, -4.2854936e-38) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.19765267, -0.096834816, 0.31700346, -4.287099e-38) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.24700022, 0.31208223, 0.14964607, -4.2362906e-38) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.35056126, 0.17690438, 0.038568918, -4.1861437e-38) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.29305857, 0.027624428, 0.005502537, -4.1974393e-38) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.22245024, 0.05195446, -0.006655462, -4.1677385e-38) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

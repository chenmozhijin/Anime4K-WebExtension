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

  var result: vec4f = vec4f(-0.14442891, 0.18967623, -0.029027192, 0.1619869);
      result += vec4f(0.18451032, 0.05966895, 0.101019464, -0.30140042) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.05458439, -0.03916836, 0.0634665, -0.42348373) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.14494365, 0.21674164, 0.15225378, -0.58263254) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.13432784, -0.29132113, 0.21692212, 0.231401) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.1007308, 0.0030285006, 0.19860075, -0.26842955) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.26370606, 0.12625162, -0.07045596, -0.110691026) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.06126085, -0.043414947, -0.0016405607, -0.09148418) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.22115815, 0.18662775, -0.27833992, 0.011485789) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.20074493, -0.16554105, -0.35448664, 0.056395672) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

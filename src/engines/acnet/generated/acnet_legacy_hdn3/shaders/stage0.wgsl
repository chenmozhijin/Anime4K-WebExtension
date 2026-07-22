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

  var result: vec4f = vec4f(-0.13294265, -0.04314599, -0.0031026239, -0.012948182);
      result += vec4f(-0.04605319, -0.05197, -0.0016930394, 0.2665958) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.12741782, -0.5039056, -0.0017573548, 0.16871749) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.2976153, -0.3304785, -0.0017151905, 0.23025009) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.03928537, -0.0115114255, -0.0017366993, -0.19008632) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-0.1250755, 0.045582134, -0.0018000369, 0.3824937) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.25267214, 0.43697152, -0.0017563803, 0.3024489) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.07914003, 0.060110252, -0.0016833674, 0.1811211) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.059990093, 0.07803234, -0.0017469153, 0.058072984) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.030273713, 0.31057927, -0.0017052131, 0.20795333) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

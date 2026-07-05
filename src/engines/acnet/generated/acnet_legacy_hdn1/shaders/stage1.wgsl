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

  var result: vec4f = vec4f(-0.032691695, -0.0053375834, -0.7776655, 0.023226019);
      result += vec4f(0.01191564, -0.05273716, 0.1569073, -0.034319036) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.20412867, 0.43151182, 0.4733164, -0.7637252) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.018920409, 0.17027341, 0.002665145, -0.09702218) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.060857512, 0.26647383, 0.017996596, -0.14159738) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.8354775, 0.55240065, 0.41367108, 0.2956665) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.1405976, 0.0034744565, 0.013238853, 0.6621997) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.9182746, 0.053495042, 0.04693245, 7.3507785e-05) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.24551472, -0.047059435, 0.10278042, 0.1268263) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.046117917, -0.02659325, 0.010698959, -0.06344204) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

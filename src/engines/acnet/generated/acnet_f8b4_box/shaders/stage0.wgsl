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

  var result: vec4f = vec4f(-0.02296435, 0.023671567, -0.07634503, 0.107763305);
      result += vec4f(-0.48973072, -0.80593777, 0.2587103, -0.08823088) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-4.709795, 1.0907546, -0.124107696, -0.7935343) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-1.2120236, -0.03665492, 0.1752936, 0.1227181) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(1.8589612, 2.4966013, 0.009606998, -0.51372904) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(5.252568, -7.7796865, -2.0184288, 9.700816) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.080768816, 3.264038, -0.39279547, -5.0853634) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.9037288, 0.12216292, 0.08964709, 0.15443683) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.055446234, 2.111968, -0.02266025, -2.4223566) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.22213419, -0.4644997, 0.24784315, -0.79181415) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.559764, -0.79051983, 0.5048311, 0.63295287) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.0010380931, -1.1788054, 0.024233848, -0.00079728756);
      result += vec4f(0.033546112, 0.10980652, 0.097957306, 0.21237579) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.21189734, -0.12089546, 0.68326527, -4.2253747) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.19883607, 1.0329657, -0.09688856, 0.25435346) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.15327626, -0.18092306, 0.74079853, -0.17313564) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(5.7319126, -1.1648409, -5.8184586, 4.171934) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-5.6207337, 0.9392109, 0.99913746, -0.19774051) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.024911148, 0.10242643, 0.35410124, -0.060014643) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.14164221, 0.13694477, 1.27163, 0.06270146) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.18961844, -0.19659716, 0.44041228, -0.043810427) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.91579723, 0.5282313, 0.3303117, -0.9281135) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

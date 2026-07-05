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

  var result: vec4f = vec4f(-0.0436365, 0.056210577, 3.021989, -2.9694762);
      result += vec4f(-0.13493043, -0.1966653, 1.2285681, 0.10217771) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.96810734, 2.4982018, 0.41408718, -0.42534795) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-1.6002465, 0.2239687, 0.23666382, 0.103307486) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.04307448, 1.4711927, 0.43538904, -0.60707176) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.7391681, -11.043868, -12.007745, 4.635531) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-1.1452447, 1.0722167, -0.23561971, -0.3456138) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.024730891, 0.40472025, 0.7628108, 0.122418724) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.17576364, 1.272926, 0.21833096, -0.41361603) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.5021179, 0.0020607968, 1.0572705, 0.055249073) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(0.3276348, -0.021614257, 0.96951044, -0.043437235) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.13415533, 0.5957967, 0.18573186, -0.22107354);
      result += vec4f(-0.19706872, 0.13773434, -0.13379705, -0.14510259) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.21416408, 0.12765284, -0.25377017, -0.25750276) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.15520647, -0.27552927, -0.22261587, 0.23089972) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.16986519, 0.030886747, 0.0144063085, -1.0926592) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.3433146, -1.2873248, 0.29551548, 1.7660391) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.25528362, 0.65383357, 0.17788033, 1.057005) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.18115292, 0.14145151, 0.18909556, -0.06874397) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.24306163, -0.035464212, 0.13354263, -0.6081392) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.18827598, -0.5570947, -0.31886894, -0.29289347) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.0405628, 0.6630622, 0.18771015, -0.36084938);
      result += vec4f(-0.39351067, 0.16793106, -0.110391356, -0.3798772) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.6798279, 0.41518748, -0.4020509, -0.050056413) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.33937326, -0.4168177, -0.23510462, 0.42652926) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.35541362, 0.44375327, 0.08913679, -1.3297155) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.3558502, -1.1614158, 0.28278214, 1.7813346) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.080448546, 0.049287762, -0.09262317, 1.7724081) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.4633562, 0.14104171, 0.4034955, -0.42121467) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.35197482, -0.046875026, 0.16980822, -0.90886885) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.37999597, -0.72608364, -0.30596268, -0.13958338) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

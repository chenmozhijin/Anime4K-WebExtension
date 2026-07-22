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

  var result: vec4f = vec4f(-0.009154066, -1.039782, 0.07893965, -0.0064686593);
      result += vec4f(-0.056329858, -0.013738108, 0.5655572, -0.0696923) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.31327206, -0.42445022, 0.22491252, -4.2451563) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.13844505, 1.1953727, 0.27652943, -0.13557576) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.25594977, -0.6461535, -0.7988287, 0.19066685) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(4.6649423, 0.0507302, -5.290037, 3.9755867) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-5.146957, 0.5173108, 1.0807666, 0.21823066) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.10243103, 0.2500768, 0.68329096, -0.116089635) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.31072846, -0.40007186, 0.9574798, 0.28871822) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.10721373, -0.25367194, 0.81117064, -0.11024403) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.7837886, 0.43316808, 0.17751233, -0.7012072) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

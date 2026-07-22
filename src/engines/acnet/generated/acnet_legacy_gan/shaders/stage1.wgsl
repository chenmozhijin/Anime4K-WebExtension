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

  var result: vec4f = vec4f(0.027740039, 0.004209226, 0.010177463, -0.0007635845);
      result += vec4f(0.20605397, 0.042960368, -0.025444472, 0.0052847886) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.04192662, -0.29512995, 0.053816862, -0.90876) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.15014108, -0.17356527, -0.013704738, 0.02191212) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.3052118, 0.31809103, -0.020824034, 0.03270793) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.5812289, -0.29979798, 1.0746503, 0.89949995) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.26151183, -0.22240783, -0.13063146, -0.04513497) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.1711326, 0.28737754, 0.02783358, -0.017282758) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.16485837, 0.3037313, -0.30974755, 0.013021884) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.016462307, 0.05447338, -0.6277237, 0.0028771409) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.03474459, -0.0070720874, -0.10013279, -0.118082635);
      result += vec4f(0.18782651, 0.5652151, 0.6771285, -1.5165958) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.25280973, -3.9883099, 0.58445805, -1.166839) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.25640592, 3.6623607, -0.09468086, -0.6348317) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.12811042, 1.9890102, 2.8167398, -1.4086549) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-4.2978525, -0.052715927, -4.3371353, 4.2058096) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(3.9640062, -3.1365125, 0.030465677, 0.5032456) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.008730273, -0.8037422, 0.3636137, -0.7821526) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.26167747, 1.4492971, -0.036388632, 0.45704973) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.24339637, 0.23728843, -0.101272486, 0.23622961) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.20965439, -0.49924847, 0.11036147, -0.5661883) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

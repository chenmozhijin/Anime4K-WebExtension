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

  var result: vec4f = vec4f(-0.022474332, -0.04031908, -0.4158596, -0.12032401);
      result += vec4f(0.48467752, 1.3462241, 0.24947017, 0.17509644) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.07103987, -3.4081705, 1.7699698, -1.6160386) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.26703182, 3.557975, -0.683565, -0.3743574) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.5526703, 0.2237493, 1.6111275, -4.2640214) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-6.2188444, 1.0127466, -4.278872, 6.782645) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(2.4247656, -4.2557445, 1.1046124, 0.07664678) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.774701, 0.092686586, -0.57995135, 0.026409462) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(3.1735241, 0.044326767, 1.2517438, -0.38507527) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.14134878, 1.2684245, 0.27005672, -0.5399449) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.31989717, -0.43375728, 1.0458002, -0.19648786) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

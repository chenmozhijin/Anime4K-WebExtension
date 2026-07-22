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

  var result: vec4f = vec4f(-0.15548003, -1.2117563, 0.16974583, 0.07362262);
      result += vec4f(-0.12439125, -0.6656371, -0.167925, -0.13347107) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.80804497, -1.2217002, -0.039011087, -0.18566582) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.16395536, -0.15109828, 0.09526718, -0.02434743) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.29666695, -1.6768528, -0.45279092, -0.3564805) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.6182445, 7.7032385, 0.20520492, 1.30084) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.27674186, -0.3084677, 0.3114159, -0.17619619) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.04094812, -0.5211399, -0.1863517, -0.15991245) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.07902685, -0.70783436, 0.022913294, -0.33325148) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.010898411, -0.23390462, 0.059962202, -0.08825335) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

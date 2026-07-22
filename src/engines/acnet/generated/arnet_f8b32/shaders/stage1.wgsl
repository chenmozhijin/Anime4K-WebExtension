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

  var result: vec4f = vec4f(0.0002345005, -0.17612538, 1.283451, -0.05674848);
      result += vec4f(-0.054392952, -0.263558, 0.33644766, 0.20244288) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.099365756, -1.5605663, 3.247705, 1.3717663) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.11750756, 0.17752263, 0.6527089, 0.03805931) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.71650106, 0.01591552, 1.958903, 0.93504906) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(0.43225488, 2.632522, -13.186448, -2.411101) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(0.37081853, -0.61308837, 2.1869256, -0.25166446) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.18172812, -0.2977309, 0.41367823, -0.24242795) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.36407864, 0.41787726, 1.3847754, -0.0981407) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.15709925, -0.38883445, 0.35897738, 0.007410966) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}

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
var<workgroup> tile_LUMA: array<array<vec4f, 10>, 10>;

@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);

  let groupOrigin = pixel.xy - localId.xy;
  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      tile_LUMA[tileY][tileX] = sample_LUMA(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.019117504, 0.016439393, -0.056224704, -0.028287381);
      result += vec4f(0.0070730527, -0.5860508, 0.39738065, -0.18207029) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-1.7070692, 1.919717, -0.3416047, 0.34748343) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-2.3198478, -0.16834992, 0.2608378, -0.5092186) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.49081817, 2.1772783, -0.26706007, -0.21766064) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(4.10187, -7.6547394, -2.2346961, 6.9182715) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.2504337, 2.7552006, -0.5384465, -2.5550156) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.5846671, 0.008839007, 0.21411818, -0.026295288) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.1308197, 2.032555, 0.20430213, -1.4288373) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.10937453, -0.48138437, 0.1849107, -0.8480284) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(-0.64275664, -0.9624484, 0.5522177, 0.87019974) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

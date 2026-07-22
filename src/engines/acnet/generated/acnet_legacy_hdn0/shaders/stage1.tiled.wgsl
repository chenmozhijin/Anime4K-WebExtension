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

  var result: vec4f = vec4f(0.022259412, 0.033957068, 0.015033918, -0.004427886);
      result += vec4f(0.20543455, 0.05584802, -0.03197904, -0.0039509404) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.03929093, -0.28871828, 0.058393784, -0.9121528) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.14942667, -0.16663766, -0.019341178, 0.018137803) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.3106026, 0.31227425, -0.013532211, 0.03651123) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(0.57216865, -0.30970073, 1.0649008, 0.8946607) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.2640297, -0.2281357, -0.12455744, -0.04195298) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.17080982, 0.28796, 0.028265117, -0.019909695) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.16403982, 0.3001047, -0.3030245, 0.021723656) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(-0.021239942, 0.052614987, -0.63775283, 0.0060133804) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

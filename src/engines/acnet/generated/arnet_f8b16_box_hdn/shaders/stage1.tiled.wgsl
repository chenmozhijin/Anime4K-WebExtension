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

  var result: vec4f = vec4f(0.027954437, -0.019852057, 1.1335084, -0.60845494);
      result += vec4f(-0.37518975, -0.5985854, 0.01014708, -0.8887006) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.608406, -0.14657182, 0.5113595, -0.7404944) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.10606584, 0.24540104, 0.24303916, 0.14408068) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.7796253, -0.7417535, 0.4389279, -2.8510132) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(1.5356971, 0.53706026, -5.8772, 6.588399) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.06567552, 0.92838633, 1.0108384, 0.59554595) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.0038063994, -0.91321784, 0.1379434, -0.72539485) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.18460913, 0.51183707, 0.9425896, -1.080004) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.51277095, 0.0221194, 0.38271686, -0.18846613) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(1.3806447, 0.30389702, 0.13670442, -0.34698144);
      result += vec4f(0.18678226, 0.020074807, -0.23402289, -0.19466245) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(1.2186962, -0.37308416, -1.646005, -0.93698156) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.30138123, -0.11394566, -0.32386273, -0.19877216) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.7322277, -0.16338614, -0.5329469, -0.5218243) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-6.7310038, 1.4848659, 2.894306, 3.519154) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.9261256, -0.6313374, -0.4410314, -0.4290179) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.08088353, -0.022364622, 0.0942498, -0.034395516) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.7033586, -0.59638053, -0.0051182657, -0.27024364) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.11868737, -0.08229401, 0.014033407, -0.04415704) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

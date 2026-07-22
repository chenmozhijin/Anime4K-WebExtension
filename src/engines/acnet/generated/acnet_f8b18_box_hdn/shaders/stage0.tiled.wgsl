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

  var result: vec4f = vec4f(-0.30775982, 5.8763285, -0.5138627, -0.04217948);
      result += vec4f(-0.17235014, 0.80620867, 0.029089957, -0.15505074) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.17855339, 1.041914, 0.36870718, 0.8038139) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.19012618, 1.4119081, -0.11001858, -0.028020771) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.57258713, 0.6388708, -0.13644806, 0.91066784) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(6.3399324, -17.54031, -4.696528, 8.180942) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.19683008, -0.6304941, 0.55041355, 0.5125526) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.48239475, 1.3634863, -0.084770516, -0.53845) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-6.500105, 0.36837375, 4.1392746, -9.322691) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(-0.54402846, 0.61081463, 0.06214561, -0.42021626) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(-0.17743547, 1.0187329, 1.7504321, -0.48532808) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

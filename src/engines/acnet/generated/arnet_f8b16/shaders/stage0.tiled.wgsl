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

  var result: vec4f = vec4f(-0.29452887, -0.049118385, -0.17182972, 0.11143626);
      result += vec4f(-0.09773339, -0.067372546, -0.62318873, 0.3716493) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.5077909, 0.09508149, -0.7389432, 0.56982875) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.3369331, -0.012112849, 0.068288475, 0.5088349) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.00968829, -0.15150186, -1.765783, 1.1687982) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-1.5484484, 0.6211626, 3.5698614, -8.258947) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.9074852, -0.20820332, 0.47185424, 1.6625113) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.18624856, -0.03209025, -0.61851925, 0.7219089) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.5689382, -0.3785833, -0.5270955, 2.0204177) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.10372899, -0.10339122, 0.071639806, 0.77598625) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

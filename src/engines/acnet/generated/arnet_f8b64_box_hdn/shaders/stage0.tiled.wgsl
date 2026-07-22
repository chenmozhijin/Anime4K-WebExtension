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

  var result: vec4f = vec4f(-0.19771305, -1.597174, 0.09886879, 0.049166612);
      result += vec4f(-0.063521154, -0.99946123, -0.3364046, -0.08713193) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.8971205, -1.2148262, -0.18988968, 0.090503626) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.18552306, -0.23001324, 0.09891289, 0.006092748) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.16239157, -1.8378472, -0.74432564, -0.38807598) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(1.5994463, 9.838648, 0.72213745, 1.7633054) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.36995897, -0.14425512, 0.47418898, -0.31187037) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.08669638, -0.9274728, -0.3516066, -0.288454) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.063603245, -0.79665965, 0.011321228, -0.6209653) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.034692552, -0.5245632, 0.22141686, -0.27541232) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

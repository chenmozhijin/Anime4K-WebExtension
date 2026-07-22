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

  var result: vec4f = vec4f(0.053561945, 0.6055156, 0.3490864, -0.43418613);
      result += vec4f(-0.40561053, 0.30451736, -0.38416237, -0.72206295) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.26821506, 0.3327443, -0.57786983, 0.3177613) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.32824084, -0.43213567, -0.43613958, 0.65478104) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.5102963, 0.74547166, -0.16920412, -2.1667192) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(0.5625796, -1.7396206, 0.886749, 1.261106) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.25937605, -0.25688243, -0.027861848, 2.3802097) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.20132224, 0.26358095, 0.3071098, -0.30141607) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.101281255, 0.1504355, 0.10350503, -0.6395119) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(-0.17788564, -0.43211913, -0.19598256, 0.12564114) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

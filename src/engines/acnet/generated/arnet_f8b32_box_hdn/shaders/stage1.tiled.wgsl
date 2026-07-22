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

  var result: vec4f = vec4f(0.04036558, -0.09772256, 1.0676079, -0.09928858);
      result += vec4f(-0.004357377, -0.3516729, 0.37861434, 0.094155066) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.1357368, -1.0256568, 2.3690662, 1.3183702) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.09340151, 0.30928734, 0.7213583, 0.18213262) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.4635207, 0.4274813, 1.0688015, 1.2165076) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(0.06311562, 0.55208665, -10.365845, -2.2128544) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.40451813, -0.26983187, 2.0777316, -0.51695526) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.13190055, -0.15160814, 0.48786157, -0.28240442) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.15726544, 0.9122116, 0.47022977, -0.016980253) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.10046952, -0.37745127, 0.66231024, -0.018784612) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

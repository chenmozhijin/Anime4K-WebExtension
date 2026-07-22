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

  var result: vec4f = vec4f(2.5041401e-05, 0.049430102, -0.0757139, -0.0006753281);
      result += vec4f(-0.01750845, 0.20829982, 0.07517716, -0.1388998) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.10931793, 1.2598708, -0.25234008, -8.791554) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.13551117, 0.60036063, -0.10073337, 0.072945416) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.077230886, -0.17796135, 0.41265845, 0.29977226) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(8.641723, -3.8223362, -7.173074, 8.820807) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-8.522976, 0.9583158, 4.906339, -0.1583849) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.08372082, 0.20870823, -0.24312992, -0.14779171) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.35937583, -0.042075627, 1.3917837, -0.008179367) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.2257561, -0.4555202, 0.7088947, 0.05051881) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(-0.88596326, 0.5202477, 0.2554725, -1.0100371) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(2.4631464, -0.1512156, -0.19945192, -0.039180584);
      result += vec4f(0.3063214, 0.27273303, 0.023459982, 0.14759284) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(1.7732626, 0.43125707, -0.09722172, 1.2240523) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.55322415, -1.0425823, 0.05052686, 0.4592476) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(1.7324077, 1.0462998, -0.6057863, 1.2601806) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-14.105693, -0.48315144, 1.1312957, -5.963642) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(1.9890764, -0.6362129, 0.20562412, 1.425379) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.46208113, -0.10311411, 0.10195345, 0.34256607) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(1.5283223, 0.50094724, -0.412377, 1.0821706) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.48208854, 0.030891875, 0.08147516, 0.30295995) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

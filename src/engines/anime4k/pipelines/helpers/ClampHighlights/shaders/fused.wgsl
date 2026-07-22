const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const TILE_SIZE: u32 = 12u;

@group(0) @binding(0) var tex_in: texture_2d<f32>;
@group(0) @binding(1) var tex_out: texture_storage_2d<rgba16float, write>;

// 8x8 outputs plus a two-pixel halo on every side for the 5x5 maximum filter.
var<workgroup> lumaTile: array<array<f32, 12>, 12>;

fn getLuma(color: vec4f) -> f32 {
  return dot(color, vec4f(0.299, 0.587, 0.114, 0.0));
}

fn quantizeF16(value: f32) -> f32 {
  return unpack2x16float(pack2x16float(vec2f(value, 0.0))).x;
}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let groupOrigin = vec2i(pixel.xy) - vec2i(localId.xy);
  for (var tileY = localId.y; tileY < TILE_SIZE; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < TILE_SIZE; tileX += WG_X) {
      let sourceCoord = groupOrigin + vec2i(i32(tileX), i32(tileY)) - vec2i(2, 2);
      lumaTile[tileY][tileX] = getLuma(textureLoad(tex_in, sourceCoord, 0));
    }
  }
  // Every invocation must reach the barrier. Moving the bounds return above it can
  // deadlock or invalidate partially covered workgroups at texture edges.
  workgroupBarrier();

  let outputSize = textureDimensions(tex_out);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var verticalMax = 0.0;
  for (var y = 0u; y < 5u; y += 1u) {
    var horizontalMax = 0.0;
    for (var x = 0u; x < 5u; x += 1u) {
      horizontalMax = max(horizontalMax, lumaTile[localId.y + y][localId.x + x]);
    }
    // The old horizontal pass stored rgba16float. Preserve that rounding before the
    // vertical maximum instead of silently carrying f32 through the fused pass.
    verticalMax = max(verticalMax, quantizeF16(horizontalMax));
  }
  // The old vertical pass also stored rgba16float before the final clamp pass.
  verticalMax = quantizeF16(verticalMax);

  let color = textureLoad(tex_in, vec2i(pixel.xy), 0);
  let luma = getLuma(color);
  let lumaDifference = luma - min(luma, verticalMax);
  textureStore(tex_out, pixel.xy, color - vec4f(lumaDifference, lumaDifference, lumaDifference, 0.0));
}

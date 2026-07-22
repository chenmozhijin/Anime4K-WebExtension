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

  var result: vec4f = vec4f(0.14374012, -0.19421141, 0.78406787, -0.4121586);
      result += vec4f(-0.17008063, -0.61251485, 0.24138168, -1.3129126) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-2.1486478, 0.07910521, 0.91319686, -0.8752486) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.4292483, 0.16904484, 0.63663864, 0.36659288) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.8175345, -1.0683235, 0.7895445, -3.8698168) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(1.949731, 2.2414258, -7.1707883, 7.089782) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.032173257, 0.7319808, 1.1082517, 1.4250348) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.23164566, -1.1413795, 0.560371, -1.3346894) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.98305684, -0.064006194, 0.96386695, -0.9494896) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.7245699, -0.09686165, 0.40421328, -0.010351539) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

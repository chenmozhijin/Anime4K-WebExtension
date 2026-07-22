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

  var result: vec4f = vec4f(-0.064415894, -0.10044994, 1.3609532, -0.082128674);
      result += vec4f(0.028665077, -0.3441329, 0.17317882, 0.04223825) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.14185467, -1.0310557, 2.349525, 0.9410531) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.06522253, 0.40238264, 0.71799, 0.22595602) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.35851598, -0.042929385, 1.0749406, 0.6412093) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-0.03831905, 1.1441044, -10.5549965, -1.6529373) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.3679276, -0.18809687, 1.9939964, -0.23134418) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.08987402, 0.0055206562, 0.27275175, -0.21281476) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.26604146, 0.42125064, 0.76595896, 0.0021445863) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.14890507, -0.28678253, 0.46482286, -0.09367876) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

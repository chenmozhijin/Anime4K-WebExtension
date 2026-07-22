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

  var result: vec4f = vec4f(-0.2565709, -0.12390594, -0.06984413, 0.5099516);
      result += vec4f(-0.07394383, 0.43032774, -0.47846407, 0.16730374) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.37750873, -0.35879466, -0.46378922, -0.038450103) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.16958568, 0.0047675003, 0.112779, 0.47185874) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.17826012, 0.025324, -1.8978077, 0.55690104) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-1.8237495, 0.43063137, 2.9159837, -7.278643) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(0.7403125, -0.4087259, 0.4997512, 1.4985062) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.11667362, 0.2648966, -0.08071481, 0.40656984) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.5612681, -0.14426933, -0.66467595, 1.9587482) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.34773418, -0.2955225, 0.11390518, 0.93474525) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

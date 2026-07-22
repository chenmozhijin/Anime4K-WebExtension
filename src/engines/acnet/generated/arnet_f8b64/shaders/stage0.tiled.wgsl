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

  var result: vec4f = vec4f(-0.21458076, -1.3411951, 0.1979225, -0.0038848184);
      result += vec4f(-0.15199742, -0.7743253, -0.18282413, -0.034448367) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.9744788, -1.8069692, -0.06492042, -0.2075491) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.24908268, -0.19821057, 0.18366349, -0.061168622) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.378397, -2.2787821, -0.59979355, -0.27197778) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(2.189482, 9.984648, 0.2992254, 1.6245346) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.44034827, -0.60132414, 0.36351332, -0.37425154) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.06872529, -0.72894883, -0.25749388, -0.20360018) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(-0.10341813, -0.9619604, -0.028314054, -0.5162642) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.025673946, -0.21645321, 0.06361493, -0.12453979) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
  textureStore(out_tex, pixel.xy, result);
}

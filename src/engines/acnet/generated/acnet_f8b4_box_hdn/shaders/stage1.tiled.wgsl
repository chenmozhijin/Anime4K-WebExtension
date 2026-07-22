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

  var result: vec4f = vec4f(-0.00017995387, 0.07146585, -0.04053683, -0.00012303889);
      result += vec4f(-0.26174378, 0.20855927, 0.11915015, -0.14608495) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.6367523, 1.0271081, -0.08911097, -5.6632886) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.40994748, 0.46176693, 0.45201576, -0.091531575) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(0.39324787, -0.29848456, 0.18881902, 0.123422384) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(6.4203486, -3.5953643, -6.134201, 5.4678793) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-6.7359157, 0.5140024, 3.101447, 0.24888086) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(0.010680014, 0.12702996, 0.32656217, -0.079708196) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.15242882, -0.21721889, 1.6723503, 0.21824926) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(-0.20567572, 0.21532308, 0.23721887, -0.07780123) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(-0.77515215, 0.68788326, 0.077566564, -1.0873845) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

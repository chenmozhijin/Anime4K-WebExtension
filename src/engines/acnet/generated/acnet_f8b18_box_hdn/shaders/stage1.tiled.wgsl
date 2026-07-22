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

  var result: vec4f = vec4f(-0.82432836, -0.22872761, -3.0731204, -4.7879453);
      result += vec4f(0.8555729, 0.23097394, 0.019826218, -0.014290921) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-1.5599259, -0.5987939, -0.2222822, -0.3335467) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(2.2587178, 0.18637231, 2.3965201, 0.0048499107) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.44170833, -0.8322408, -0.2668063, -0.3546644) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-0.18400131, -9.2548485, 0.6259482, 7.0122914) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-2.2428083, -0.55477023, -0.83140594, -0.37473625) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.87931556, 0.33728448, 1.0403144, 0.21590444) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.94557804, 10.005256, -0.75571525, -0.8702347) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.19138134, 0.27575016, 0.79587054, 0.33239776) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(0.4128489, -0.39878866, 0.18776785, 0.027443258) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

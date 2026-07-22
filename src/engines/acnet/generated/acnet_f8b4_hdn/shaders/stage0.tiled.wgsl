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

  var result: vec4f = vec4f(-1.0801387, 0.010736534, -0.09996092, 0.17188877);
      result += vec4f(-0.10510232, -0.6233211, 0.18224616, 0.18920027) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(-0.8711202, 2.1895814, -0.30829662, -0.41484356) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(-0.40961394, -0.30645505, 0.2638376, -0.9180099) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.3390162, 2.70994, -0.40125102, -0.8186109) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(3.9631553, -7.9951277, -1.8325032, 5.798825) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.75852615, 2.7020936, -0.54321253, -1.486686) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-0.21920748, -0.3788346, 0.27245826, -0.31408373) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.08710727, 2.224693, -0.2127486, -1.3382735) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(-0.22543146, -0.51307786, 0.34813306, -0.5522911) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(0.14206024, -1.0139476, 0.36949465, 0.8508606) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

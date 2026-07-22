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

  var result: vec4f = vec4f(-1.8263676, -0.17046389, -1.7433875, -5.063071);
      result += vec4f(1.2357554, -0.08719417, 0.35244483, 0.6596365) * tile_LUMA[localId.y + 0u][localId.x + 0u].x;
      result += vec4f(0.23452638, 0.18737924, -1.0458206, -1.0255984) * tile_LUMA[localId.y + 0u][localId.x + 1u].x;
      result += vec4f(0.053701144, 0.108582966, 1.7041646, 0.56469995) * tile_LUMA[localId.y + 0u][localId.x + 2u].x;
      result += vec4f(-0.08349756, 0.5621448, -2.239158, -1.4554149) * tile_LUMA[localId.y + 1u][localId.x + 0u].x;
      result += vec4f(-0.27457225, -9.746034, 0.6337528, 9.056275) * tile_LUMA[localId.y + 1u][localId.x + 1u].x;
      result += vec4f(-0.33780164, 0.4468791, -1.7812151, -1.0735617) * tile_LUMA[localId.y + 1u][localId.x + 2u].x;
      result += vec4f(-2.1125653, -0.2742373, 0.5528937, 0.39493346) * tile_LUMA[localId.y + 2u][localId.x + 0u].x;
      result += vec4f(0.97213054, 9.351824, -0.29173273, -1.774338) * tile_LUMA[localId.y + 2u][localId.x + 1u].x;
      result += vec4f(0.82333666, -0.5888503, 2.126132, 0.89343166) * tile_LUMA[localId.y + 2u][localId.x + 2u].x;
      result = max(result, vec4f(0.0)) + vec4f(0.31975967, -0.5446572, 0.262607, 0.17629634) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}

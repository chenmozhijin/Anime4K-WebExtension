const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP1_TEX_0: texture_2d<f32>;

fn sample_TMP1_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP1_TEX_1: texture_2d<f32>;

fn sample_TMP1_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_1, coord, 0);
}

@group(0) @binding(2) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_1: array<array<vec4f, 10>, 10>;

@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

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
      tile_TMP1_TEX_0[tileY][tileX] = sample_TMP1_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP1_TEX_1[tileY][tileX] = sample_TMP1_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP2_TEX_1[tileY][tileX] = sample_TMP2_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.07806616, 0.34594676, -0.34843528, 0.12947987);
      result += mat4x4<f32>(0.07375903, -0.21341345, 0.033945702, 0.37403092, 0.036751565, -0.019071363, 0.015082477, 0.16833867, 0.024942344, 0.17573869, -0.12762684, -0.11570137, -0.08657452, 0.16770335, 0.014323833, 0.0025288307) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.05369176, -0.586116, 0.2213458, -0.0015556022, -0.08668443, -0.26513183, 0.26561305, 0.16523872, 0.09066646, 0.24798192, -0.16749081, 0.23519614, 0.05681576, 0.013520268, 0.19512072, -0.122655585) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12870471, 0.17726777, 0.04929855, 0.2938987, 0.004177072, 0.028756259, -0.085981734, 0.057575308, -0.12310362, -0.075066335, -0.013139844, 0.209914, -0.08430697, -0.08384662, 0.06779744, -0.08819206) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.089935064, 0.058282755, 0.03646494, -0.01893387, 0.12173862, -0.07964589, 0.037098303, 0.4236724, 0.022458978, 0.197705, 0.11029929, -0.30764326, -0.05214255, 0.101240814, 0.14538138, -0.1571671) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12787214, -0.103095226, -0.30425522, 0.30074283, -0.10307827, -0.07583439, -0.35228464, -0.43073106, -0.012811271, -0.33440146, 0.7424279, 0.16614844, -0.07820304, -0.15914999, 0.25953838, -0.74639803) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0140525615, 0.25948885, -0.1322746, 0.38640094, -0.19416147, -0.13854606, -0.30125725, 0.16386193, -0.14741787, 0.04645007, 0.11257096, 0.19166204, -0.24264148, -0.38282982, -0.15406094, -0.22388591) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12696916, 0.12278851, -0.09227026, -0.088781156, 0.045506537, -0.02489308, 0.03015254, -0.16099903, 0.023398293, 0.11423445, -0.015057948, -0.00014878348, 0.0028451718, -0.049898982, 0.04749076, -0.12513001) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.23962606, 0.0116487015, -0.025441714, 0.38564143, -0.38109413, 0.030012652, 0.08387752, -0.26088867, -0.05702168, -0.221374, 0.06994239, -0.27967954, -0.08110039, -0.08739953, 0.09535503, -0.32876068) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06557094, -0.024771376, -0.14514808, -0.23363984, -0.011902662, -0.18552606, 0.26638594, -0.010416523, -0.015708208, -0.15874247, 0.1947241, -0.21708626, -0.051427886, -0.004565376, 0.28358784, -0.18289983) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.16272557, 0.06265593, -0.038221616, 0.06506561, -0.080876276, -0.44776157, 0.20294741, -0.13924278, 0.005784028, 0.23446399, -0.015466934, -0.21515577, 0.009798324, 0.016690511, 0.037406147, -0.14951092) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07119155, -0.06893386, 0.2062623, 0.17952952, -0.001981543, -0.045871716, 0.009855724, 0.37407812, -0.11755177, 0.15758489, -0.30174586, 0.2860451, 0.042276345, 0.33726844, -0.045071747, -0.23377287) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08847261, -0.04887891, 0.3117045, -0.13008828, 0.13032928, -0.03881723, 0.21523015, 0.10232371, -0.05388142, -0.12669334, 0.11463893, -0.09468786, 0.061517484, -0.143803, 0.13316116, 0.036981292) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.032533836, -0.06052597, 0.20887984, 0.4693504, 0.093873836, -0.16737306, -0.37140954, -0.22199093, -0.16084379, -0.36342648, -0.13364378, -0.5104086, 0.08070809, -0.14959152, 0.13984993, 0.030968038) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12378471, 0.13393705, -0.027061284, -0.40232065, 0.19921654, -0.2583405, -0.10765035, 0.1270577, -0.038070776, 0.10885555, 0.43248072, 0.3157395, 0.50489366, -0.1761108, -0.19621076, -0.70293766) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.054066874, -0.26990137, 0.03684485, -0.0360786, 0.19651045, -0.22053522, -0.027097765, -0.50316083, 0.13769192, -0.09049166, 0.03578416, 0.017326966, -0.052525472, -0.1544091, -0.2249308, -0.095649414) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.039058894, -0.1797681, -0.022874856, 0.17920119, -0.07899944, 0.11720725, -0.13688049, 0.05416885, 0.16574852, 0.018767605, 0.1250681, 0.032305114, 0.15613501, -0.11249501, 0.12064467, 0.08520725) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21669029, -0.060832612, -0.20371409, 0.11134122, -0.04895438, 0.08241158, 0.0037396243, 0.19484589, 0.41565782, -0.23609583, 0.02573449, -0.13266887, -0.09648919, -0.43318793, 0.012846323, -0.17896125) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.029362673, 0.09545121, 0.08299184, 0.11424714, -0.0039964505, -0.1663846, -0.029381754, -0.21284346, -0.031230623, 0.14721744, -0.026054714, 0.2221396, -0.30543706, 0.26449415, 0.12006327, -0.052336175) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

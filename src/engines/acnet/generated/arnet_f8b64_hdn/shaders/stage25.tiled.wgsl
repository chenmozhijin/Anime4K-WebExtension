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

  var result: vec4f = vec4f(-0.37508315, 0.0025710715, -0.13335529, -0.112880796);
      result += mat4x4<f32>(0.0061990405, 0.06912524, 0.28789967, 0.061444983, 0.19288698, -0.35874256, 0.10313204, 0.16939655, 0.16926798, 0.119278684, 0.43171138, 0.32244596, -0.0016839475, -0.008051351, 0.20050032, -0.04309179) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.011101214, -0.22107427, 0.053235203, -0.11959501, 0.06150488, 0.24235901, 0.1784359, 0.5647079, 0.06776603, 0.19281627, 0.52253544, 0.2993092, 0.054540396, -0.07977225, 0.039529763, -0.25090867) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.098204665, -0.14108828, 0.15299447, 0.1488444, -0.124545164, -0.009200395, 0.21889277, -0.36180195, 0.014990717, 0.024932243, -0.085999444, 0.1566871, 0.040401023, 0.2043826, 0.3530877, -0.20571813) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20004861, -0.13191545, 0.14635612, -0.58013123, 0.3037037, 0.46586922, -0.36167893, 0.4343067, 0.20650852, -0.66185266, -0.1393272, 0.24059153, -0.17092513, -0.13338386, 0.011356897, -0.067035325) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16905071, 0.38074702, -1.8778446, -0.6787161, -0.3980782, 0.22852601, 0.16720253, 1.7253878, 0.07775361, 0.05389275, 0.03699088, -0.1209886, 0.23410778, 0.14875829, -0.047461867, 0.3122764) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19927713, -0.3432583, -0.04018732, -0.039978407, -0.04687316, 0.4750678, -0.16670056, -0.0028236806, -0.06685667, 0.41114342, 0.14701864, -0.4152905, 0.11668389, -0.31116948, -0.23058616, 0.2734675) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.019532831, -0.30793175, -0.14681906, -0.16532245, -0.11970041, -0.22266966, -0.10650008, -0.097916216, -0.17234117, -0.34261256, -0.26704752, -0.029110378, -0.023821589, 0.03065218, 0.09772843, -0.02731882) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.3113628, -0.36025336, -0.52357316, 0.2031327, -0.019934006, 0.30170697, -0.09761527, -0.11254082, -0.19181962, -0.1682004, -0.37351322, -0.5545617, 0.11026967, 0.29790622, 0.31691602, -0.035660196) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09127784, 0.056517117, 0.04991662, -0.1586194, -0.057077732, 0.12266458, 0.06791043, -0.15782334, -0.28410357, -0.09235182, -0.20928025, 0.011895314, 0.13629997, 0.20201422, 0.15490064, 0.078719154) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.17450058, -0.47176707, 0.29081264, 0.34407213, -0.017063478, -0.044999618, 0.16814524, -0.2808363, -0.04839073, -0.19144283, -0.1943827, -0.07659227, 0.021295391, 0.12023306, 0.18043958, -0.17123984) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3102087, 0.20116714, 0.66566646, 0.38962984, 0.4380051, 0.2180989, 0.16029331, 0.91767263, -0.10323757, 0.0071454765, 0.2129218, -0.06190649, 0.27076778, 0.14042471, 0.077681765, 0.10298616) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17862079, -0.016928859, 0.33503538, 0.06717067, -0.66093296, 0.14087301, 0.10697822, 0.045129582, -0.014962274, -0.08770585, -0.12300102, -0.121725865, -0.08747178, 0.10998776, -0.07229523, -0.15076506) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15170614, -0.547327, -0.29405627, 0.33939904, 0.3174975, 0.35136256, -0.050927974, -0.535933, -0.08167458, -0.43833035, -0.13896811, 0.16433106, 0.0738954, -0.5986505, 0.13728088, 0.11096299) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(1.2214525, 0.27126634, -0.30329072, -0.5365767, 0.18217207, 1.0597064, -1.0720615, 0.82717174, 0.018746622, -0.37911573, 1.174544, 0.27049, -0.100228086, 0.9648404, -0.16694386, 0.99294144) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.20815219, 0.33741665, -0.14263171, -0.2232979, -0.28593186, 0.82788444, 0.026220897, 0.49344826, -0.11478864, 0.043561906, -0.081414856, 0.052196324, -0.2411726, 0.18163195, 0.063692115, 0.121380515) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.041515477, -0.3934857, -0.20954457, 0.060761966, -0.2841356, -0.14671339, 0.24976525, 0.5172251, 0.17390504, 0.043766502, -0.020597963, 0.003439103, -0.06690205, -0.06972333, -0.41953298, 0.052597284) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.32303283, -0.09803054, -0.38203603, 0.025325887, 0.2239001, -0.046919554, 0.027643256, -0.1524634, 0.2509532, 0.2166313, 0.36019874, -0.24781577, -0.08569749, 0.45812225, 0.1154024, 0.5411161) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.35804352, 0.1899422, -0.15142784, -0.0743724, -0.16763915, 0.13848689, 0.13473555, 0.5787667, 0.08740255, 0.133007, 0.03715438, 0.16464393, 0.06777233, 0.08234969, 0.11732194, -0.14391966) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.4647102, 0.025511887, -0.18545729, 0.13466245);
      result += mat4x4<f32>(-0.021595374, -0.030431196, -0.17324056, 0.018013462, -0.014977953, 0.10639165, 0.16103895, 0.082461394, -0.04545375, 0.36596125, 0.0055699875, -0.22793408, 0.18415849, -0.37868285, -0.26030976, 0.23119701) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07570228, -0.5846004, 0.24611779, 0.09104808, 0.061540827, -0.19094633, 0.06518976, -0.045815267, -0.10945362, 0.032915607, -0.025671128, -0.114309356, -0.14663956, 0.15529236, -0.29066205, -0.02480545) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12648447, -0.1528201, 0.17002833, -0.11691635, 0.05199434, 0.01853551, 0.2270636, 0.023619832, -0.09956359, 0.1589252, 0.09013765, -0.16129528, -0.32223552, 0.35090092, -0.16116005, -0.059206165) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.023663674, -0.055061974, -0.096304074, 0.020933721, -0.044213694, -0.39439854, 0.06618879, 0.045529243, -0.1156425, 0.25092992, -0.103265546, -0.06773122, 0.24647304, -0.3127038, -0.07703826, 0.2561463) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.042526394, 0.18843792, 0.013656089, -0.05261724, 0.38286522, 0.076421686, 0.051365867, 0.027184214, -0.4908339, -0.2995607, -0.1072858, -0.4017849, 0.28812984, -0.2909293, 0.08159071, 0.11883941) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.16633573, 0.12796752, -0.08468013, -0.14364812, -0.09489391, -0.2132656, 0.07140793, 0.0022536926, -0.115511455, -0.012978373, 0.03898613, -0.22182024, -0.24286142, 0.23104085, 0.13770947, -0.17257442) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24823467, 0.05924564, -0.34497875, 0.01482724, 0.04930769, 0.16832797, 0.07685233, 0.013270253, -0.06423098, 0.18110369, 0.09439151, -0.1327035, 0.21937937, -0.28245613, 0.19749837, 0.0154214855) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.04763953, -0.081915446, 0.1831957, -0.11288063, 0.065610334, -0.30662277, 0.1763558, 0.08595631, -0.056319203, -0.012760728, 0.0019061128, -0.123804204, 0.05727481, -0.0030551031, 0.2712089, -0.112981334) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0072255475, -0.032019146, -0.1769336, 0.050322592, 0.21492888, 0.028018212, 0.15149012, 0.021228576, -0.06694453, 0.19216867, 0.057525754, -0.06388435, -0.25654423, 0.39364043, 0.15174665, -0.27474684) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07478691, 0.028865922, 0.018789139, -0.024905145, -0.09107926, 0.112774886, 0.14287779, -0.14242108, 0.11767206, -0.010653794, 0.074926734, 0.11950338, 0.28216222, -0.16251442, 0.14703766, 0.1485947) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09550737, -0.17407201, 0.045013092, -0.00068972947, -0.0048279376, -0.06064837, 0.15888564, -0.01399757, 0.2030659, -0.098059714, -0.037527867, 0.1595915, 0.3087538, -0.3158804, 0.076209135, 0.15659103) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10844819, -0.04392716, 0.07319923, -0.025287306, -0.09053341, 0.14736077, 0.047117606, -0.09855733, 0.12372103, -0.038233276, -0.045793306, 0.10667474, 0.17545131, -0.29264304, -0.1662712, 0.16580234) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.047069404, -0.21856824, 0.12781462, 0.08597287, -0.36971653, -0.73933023, -0.027761016, -0.09862559, 0.2941722, 0.2112662, 0.02263545, 0.19671884, -0.012546512, 0.07748392, 0.21431078, -0.14627779) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07576761, -0.35614678, 0.3909086, -0.3960963, 0.28725865, -0.15283906, 0.048320808, 0.5526545, 0.54818517, 0.25054842, -0.11817394, 0.79025996, -0.04884256, -0.30315155, -0.1127628, 0.042704843) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.18829952, -0.27918646, 0.40289032, 0.0023190803, -0.07195272, -0.035015974, -0.05320036, 0.049012862, 0.20806915, 0.09280957, -0.10462287, 0.26375306, 0.1429406, -0.07983279, -0.17656836, 0.13777283) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.043705337, -0.15793754, 0.2478738, -0.0060048937, -0.21447565, -0.34684935, -0.02511178, -0.0961689, 0.13203482, 0.18584701, 0.013972769, 0.062333383, -0.19505864, 0.24876402, 0.0666949, -0.13306598) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11252092, -0.22685596, 0.25859112, -0.33112636, -0.2561494, -0.6565418, 0.06568629, -0.3158715, 0.29179856, 0.14754534, 0.014782302, 0.22689791, -0.15429576, 0.5033957, 0.24764475, -0.17990525) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.083347745, -0.0786655, 0.42646188, -0.105169654, -0.19517004, 0.08356404, 0.09349021, -0.24899808, 0.026158642, -0.06251043, -0.18570372, 0.085744426, -0.38471648, 0.39561057, -0.40416774, -0.071203105) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

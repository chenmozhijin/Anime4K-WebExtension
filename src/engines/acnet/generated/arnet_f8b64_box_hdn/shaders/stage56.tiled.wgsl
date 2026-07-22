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

@group(0) @binding(2) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_0: array<array<vec4f, 10>, 10>;

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
      tile_TMP2_TEX_0[tileY][tileX] = sample_TMP2_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(0.28251815, -0.017550774, 0.1280893, 0.3859947);
      result += mat4x4<f32>(-0.27518132, -0.25275514, -0.17484534, 0.22103596, 0.24737723, -0.13347133, -0.0098814815, 0.26703504, 0.024256026, 0.12917432, -0.054785747, 0.08338619, 0.13576595, -0.0822785, -0.15153353, 0.064866476) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.2668652, 0.16580196, -0.2958946, 0.51727057, 0.4390407, 0.057469007, -0.24622546, -0.11420957, 0.015026114, 0.1537705, -0.026558036, -0.064956844, 0.36982647, 0.031576194, -0.032901507, 0.042375572) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.28469986, 0.13656805, -0.15965356, 0.23383985, -0.21442464, -0.16195378, 0.14600976, -0.40964922, -0.04138139, 0.039468914, -0.020765215, 0.037664838, 0.053817466, 0.048634868, 0.1864935, -0.2779316) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06004114, -0.27502793, 0.2583634, 0.33484173, -0.10844582, -0.24385227, -0.24376972, -0.034654815, 0.20990993, 0.046553705, 0.19346935, 0.06500034, -0.21894579, -0.3251689, -0.27097797, 0.26788184) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.090573594, 0.2537666, 0.28995234, 0.29675293, 0.07823348, -0.05104815, -0.50790644, 0.17040329, 0.3737977, 0.0030337304, 0.006831125, -0.18645695, 0.11285288, -0.43056777, -0.03713409, -0.28008774) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13032101, 0.14255655, 0.04806915, 0.23680924, -0.56729096, -0.060344834, 0.18655849, 0.5881529, 0.0312476, -0.040155075, 0.11684067, -0.14008047, 0.17368153, -0.13969997, -0.10051861, -0.21123141) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14218834, -0.06384637, -0.16457997, 0.1766805, 0.112024404, -0.081060655, -0.01892758, -0.050533462, -0.091477916, -0.05988635, 0.41470078, -0.11531297, -0.091651596, -0.05068532, -0.038770106, 0.036052924) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.034862146, 0.1183104, -0.0034192412, -0.21471, 0.25936532, -0.050881036, -0.12841001, -0.17568587, 0.4103916, 0.036479104, 0.18685427, -0.31426546, 0.049421564, 0.2083669, 0.1088261, -0.022878537) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.3001902, -0.08114724, -0.050080802, -0.045805227, 0.33084545, -0.20729807, -0.015365921, 0.12028474, -0.21504799, 0.11773363, 0.1915866, -0.031630922, -0.013425701, 0.0021537796, 0.1437219, -0.0072300304) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.1663147, 0.03772937, -0.05367299, -0.09977748, 0.21678036, -0.10481126, -0.42740765, 0.28952134, -0.23573688, 0.22319514, 0.3333664, -0.44032606, -0.02183116, -0.05341151, 0.11049921, 0.024980417) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21417318, -0.097858936, -0.17055798, -0.13465555, 0.06614605, -0.02377386, 0.22470911, -0.070079885, 0.192107, 0.0076137437, 0.24453065, -0.18498562, -0.014191475, 0.04472822, 0.25088134, -0.05440929) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.054952707, -0.123206995, -0.05134636, -0.2262414, -0.10817317, -0.031575844, 0.041179046, -0.10881316, 0.039201505, 0.04782599, 0.090821184, -0.14888479, 0.2648299, -0.050926544, 0.22931178, -0.037138417) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.046041228, -0.012971875, -0.09911465, -0.1098905, 0.22486347, 0.1633021, -0.3334357, 0.098201536, 0.1908371, 0.23092976, 0.25156942, -0.12996872, -0.19731042, -0.2258794, 0.3363335, 0.034254756) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.11975202, -0.10215467, -0.32120973, 0.13488679, -0.69301295, -0.20353128, 0.14074837, 0.07093409, 0.010351477, 0.0954973, 0.26952243, -0.22675471, -0.252098, 0.12263645, 0.6963873, -0.34099346) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.3689948, -0.18418501, -0.015753856, -0.22986248, -0.02696446, -0.3827351, -0.5436959, -0.28003433, -0.1518729, 0.14781241, 0.17583622, 0.018573765, 0.18954425, -0.029056625, 0.011882589, -0.20470276) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11436478, -0.10459986, 0.066403516, -0.100793034, 0.32111776, 0.22698238, -0.019366851, -0.1328363, -0.034410115, -0.09321083, -0.05917573, 0.044441592, -0.43107766, 0.0996185, 0.16262552, -0.14272653) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.029967748, -0.06746616, -0.13660963, -0.13449018, -0.09275739, -0.1299511, -0.17619215, -0.022248406, -0.49114072, 0.11833866, -0.19894283, 0.036486033, -0.14762792, 0.30726668, 0.37705314, -0.17369144) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16911922, -0.04994984, 0.10848987, -0.18422838, 0.043745242, -0.038632233, 0.15554568, -0.044173438, -0.3603565, 0.27669886, 0.06651415, 0.008294003, 0.23671614, 0.07873415, -0.23926432, 0.13544635) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.14533849, -0.010549215, 0.289052, -0.6653924);
      result += mat4x4<f32>(-0.16971172, -0.037982732, 0.012107517, 0.031622402, 0.015641715, -0.14541562, 0.057344403, 0.45607215, -0.19211987, -0.1495433, 0.010922882, 0.28178486, 0.048988562, -0.26675647, 0.16038713, 0.19456907) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09720843, 0.14303039, -0.09705908, 0.011519725, -0.017864648, -0.07703705, 0.078238964, 0.1901169, -0.11152878, 0.0138583565, -0.019210698, 0.036796052, -0.07887531, -0.10809909, 0.2164392, 0.49526826) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.19937474, -0.040596444, 0.06966769, -0.17961974, -0.022359908, -0.12981766, -0.09948739, 0.11562884, -0.020340161, -0.047993664, 0.011303657, 0.102322996, -0.09272206, -0.13712195, 0.161358, 0.3932902) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0294834, 0.15023161, -0.07784715, 0.1339304, 0.1514963, -0.6614533, 0.38092688, 0.0024823376, -0.30121478, -0.33622277, -0.11627623, 0.43986616, 0.12201191, 0.06555563, 0.10842995, -0.09881615) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12490337, 0.20251474, -0.023220228, 0.48090488, -0.043519158, -0.17877802, -0.06660637, -0.26763746, -0.34966913, -0.11405585, -0.4259322, 0.2919497, -0.06598822, -0.08689773, 0.3957462, -0.22452565) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18313794, 0.10954275, -0.15409702, 0.02695667, -0.30837584, 0.16721402, -0.06435482, 0.045388114, -0.15907156, -0.04467468, -0.11271312, 0.2544508, 0.06450544, -0.007514646, -0.21471858, -0.2603601) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16842692, 0.08698377, 0.019863097, 0.17910106, -0.08791917, -0.4845751, 0.11028038, 0.109597504, -0.19297443, -0.036492705, -0.117264435, 0.4560836, 0.34366494, 0.19115, 0.04024055, -0.5124493) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3131629, 0.04534393, -0.28489915, -0.15601118, 0.13886702, 0.051038228, -0.4822281, -0.14517677, -0.32316032, -0.1921729, -0.007427033, 0.3970721, 0.019316694, -0.5573163, -0.20007603, 0.25761878) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.23482801, -0.062171996, -0.067102455, 0.10612283, 0.08002129, -0.03365507, -0.29270118, 0.100419044, -0.13156946, -0.14693159, -0.07043048, 0.11707479, -0.23521198, -0.4348165, 0.026544051, 0.2718669) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.020676386, 0.14626212, -0.14937767, -0.2911234, 0.117629826, 0.09763084, -0.3264328, -0.34187645, 0.14604867, -0.11436099, 0.14009959, -0.065875486, -0.1618686, 0.1533647, 0.11860239, 0.20038183) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.018107349, 0.18224429, -0.013124793, -0.22120246, -0.33331066, 0.030958802, -0.13084109, 0.39401603, -0.020697776, 0.0200305, -0.17029165, 0.28434813, -0.034374144, 0.08011982, 0.07259314, 0.46938396) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.034570552, -0.06953974, -0.039614722, -0.0451375, -0.12637012, 0.043262262, 0.10554123, 0.0037070524, -0.043518025, -0.19074717, 0.23184365, 0.28537008, 0.04764019, 0.018503727, 0.07075201, 0.18083584) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.023460252, 0.68791634, -0.4254225, -0.23168957, -0.13477291, 0.07832028, 0.21141678, 0.41769826, -0.23547283, -0.13316622, -0.22728974, 0.07104433, 0.06982447, -0.2516504, 0.19058669, -0.034210447) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.11870836, -0.10178895, 0.27265182, 0.19214079, -0.27082095, 0.03273192, 0.021122606, 0.19449906, -0.51748013, -0.2884528, -0.10218497, 0.48305082, 0.230673, -0.20581114, -0.039256636, 0.62149984) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15016347, -0.21796158, 0.12975287, 0.27740967, -0.17906919, 0.24944082, -0.014547711, -0.2529903, 0.101535425, -0.118476346, 0.6402414, -0.28761914, 0.18212079, 0.083764076, -0.08433438, -0.37429762) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.019390529, 0.33710206, -0.24121448, 0.1468981, -0.10574021, -0.15979418, 0.028114662, 0.043655448, -0.00014829365, 0.20431274, 0.18673788, -0.18523331, 0.073656514, -0.28241438, -0.29210618, 0.19959368) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19717273, -0.40967667, 0.4508212, 0.2825753, 0.022117453, 0.10455527, -0.06476416, -0.0010397867, -0.030718515, -0.069998585, -0.23640023, 0.14725193, 0.08173575, -0.07349153, -0.66971636, 0.5442188) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.049097113, -0.13114113, 0.18824916, 0.06846367, -0.03955683, 0.14502081, 0.066236936, -0.1513598, -0.16408451, -0.09638854, 0.020853106, 0.19628781, 0.10481193, 0.02189229, -0.13408771, -0.22813249) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

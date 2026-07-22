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

  var result: vec4f = vec4f(-0.12962133, -0.05123738, 0.08446193, 0.09265008);
      result += mat4x4<f32>(0.23231992, -0.07392093, 0.135592, -0.019598162, 0.049652386, -0.000522764, 0.07793938, 0.012002618, 0.13220093, -0.10328056, 0.12912236, 0.07431063, 0.0021284288, -0.021035545, 0.06992985, 0.030958865) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.075204775, -0.24582122, -0.05780619, 0.08213023, 0.2563387, -0.036258753, -0.1508885, 0.20620756, 0.56996137, 0.18028192, 0.054274354, -0.14636615, 0.18715847, 0.009122881, 0.3502294, -0.16711637) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.053270496, -0.023056842, -0.06589916, -0.020635668, 0.35618037, 0.0039551803, -0.09067172, -0.09536052, 0.17227778, -0.056960978, -0.006018264, -0.15224536, 0.18389565, -0.12129765, 0.22570767, 0.0025240346) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.26811624, -0.28064933, 0.13957705, -0.016932277, 0.27328917, 0.019920764, -0.16727135, 0.16384302, -0.14808024, 0.16479273, -0.018681202, -0.064321555, -0.01694455, 0.043210134, 0.14117353, -0.016877366) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.67612, -0.15477794, -0.02494848, -0.05258346, 0.4782167, 0.24269338, 0.20300081, -0.11327723, 0.25947195, 0.547557, -0.69490045, -0.046841476, -0.41843432, 0.07927676, 0.16134697, -0.040251993) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.3295725, 0.004695297, 0.35822845, -0.33117232, 0.24407771, 0.21983324, 0.020781936, -0.23769891, 0.48771542, -0.05802793, 0.06813323, -0.21336323, 0.09393447, -0.060430527, 0.19417758, -0.0020158715) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16567059, -0.035382003, -0.13700555, -0.0040082713, 0.024562364, 0.092340745, 0.10174386, -0.018839758, 0.3804839, 0.016157256, -0.14577737, 0.026154008, -0.046955317, 0.10685513, 0.14982687, -0.038861096) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.7743493, -0.082988, 0.75986993, -0.06412758, 0.057284504, 0.08953959, 0.10690505, 0.022960944, 0.5410199, -0.08624716, -0.15052035, 0.014160384, -0.0058785495, 0.080081835, -0.10439765, 0.1025219) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.24317354, -0.0933996, 0.0153463185, 0.09032625, -0.15323465, 0.13057482, 0.1775008, -0.031790953, 0.017816853, -0.2033224, -0.53444856, 0.30660048, 0.04241668, 0.06383561, -0.010569965, 0.017048607) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05314639, -0.055475857, 0.16037059, -0.029365536, -0.03051002, 0.10439703, -0.16319421, -0.024210053, 0.02548671, 0.082115375, -0.04550206, -0.03820194, 0.021152325, 0.081485935, -0.10955127, -0.027321763) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.14928415, -0.13182504, 0.21357793, -0.044038154, -0.08391868, -0.011923137, -0.071837716, 0.098204084, -0.020849407, -0.025436534, 0.15513878, 0.028797159, 0.2727505, 0.047316957, 0.2167796, -0.13674521) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.045280855, -0.12405923, 0.006539804, 0.059390295, 0.16250704, -0.35186636, 0.06550862, 0.1496993, -0.28069797, 0.16973217, 0.110344864, -0.05441812, -0.08430829, 0.047994502, -0.016982358, 0.045964036) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06165359, 0.00073422084, -0.04752656, -0.051147204, 0.34725937, -0.06498177, -0.37557346, 0.21114804, -0.08793243, 0.009736005, 0.5387428, -0.20573168, 0.0052779038, 0.06760937, 0.12481407, -0.12634282) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.33551967, -0.26174816, -0.24829626, 0.1786886, -0.0058207675, -0.19905086, 0.7644835, -0.21816035, -0.3545281, -0.12005762, -0.46905056, 0.49315113, -0.26266897, -0.35579535, -0.34429446, 0.21909595) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.41011938, -0.55708045, -0.01881239, 0.36488768, -0.57479614, -0.011003913, -0.17672636, -0.049441606, 0.07599376, -0.15082762, 0.33739674, -0.014106324, -0.20801392, 0.034018002, -0.2864886, 0.036206763) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07716312, 0.0037298552, 0.036196552, -0.011885784, 0.039125938, 0.076328, -0.035859443, 0.018036941, -0.026396345, -0.033435125, 0.015310547, -0.036965035, -0.1911691, 0.16655745, 0.48347554, -0.3748997) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.04511949, -0.014531043, 0.4320157, -0.109364815, 0.06988099, 0.08051643, -0.2481849, -0.021521624, -0.046460245, -0.079626895, -0.332042, 0.14167546, 0.09631288, 0.06952208, 0.022496952, 0.1674503) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.50524247, 0.13311276, 0.1267962, 0.0818928, 0.42272455, -0.02889256, -0.34914067, -0.14847188, -0.3154579, -0.11388814, 0.101016946, 0.1519091, 0.2702921, -0.096844554, -0.07440684, -0.00769596) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

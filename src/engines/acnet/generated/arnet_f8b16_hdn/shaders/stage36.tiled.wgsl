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

  var result: vec4f = vec4f(0.728852, -0.05051624, -0.2666937, -0.3306582);
      result += mat4x4<f32>(-0.05817392, 0.035981324, 0.19166403, -0.024439262, 0.16525699, 0.07586422, 0.02426138, 2.7596889e-05, -0.011432367, 0.2801443, -0.42955685, 0.28298342, 0.091140255, 0.1352958, 0.2906518, 0.0149574) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.023822807, -0.7012284, 0.20302407, -0.2600558, -0.30351818, -0.151677, 0.09141845, -0.25068733, 0.16527724, 0.18741603, -0.028410409, 0.044346612, -0.051460844, 0.22260225, -0.29938716, 0.08136399) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15058318, 0.032800227, -0.076050654, 0.0011291578, -0.07394038, -0.29559124, 0.08806591, 0.1643551, -0.20217519, 0.14914373, 0.026409378, -0.0071680197, -0.32607546, 0.049121033, 0.23592238, -0.08037764) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2720482, -0.0690218, -0.15264188, 0.034220528, 0.23586915, 0.14567593, 0.11878096, -0.021666128, -0.49086764, -0.51602745, 0.011933053, -0.4052058, 0.29190597, -0.25723997, 0.28703263, -0.161539) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07593831, -0.58278996, -0.029718947, -0.0052470206, 0.71809477, -0.53761524, -0.45213363, 0.028855575, -0.619264, 0.10270029, -0.41379005, 0.259483, -0.4465893, -0.2557581, -0.32419118, 0.1371604) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.011411826, -0.23121873, -0.40367275, 0.15043777, 0.2727231, 0.094873674, -0.566814, 0.26605737, 0.59117484, -0.33360094, 0.018618872, 0.16651547, 0.19389394, -0.20710638, 0.44563106, -0.34076887) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.32933518, -0.13800614, -0.031142352, 0.10257485, 0.024891445, -0.4426211, -0.022384215, -0.19172767, 0.2297791, -0.7055827, 0.09380238, -0.18647797, -0.06418143, 0.17277859, 0.34852564, -0.029509652) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1439704, -0.22126162, 0.014775703, -0.27180368, -0.1674413, -0.19893754, -0.164667, 0.07269721, -0.022290783, 0.1524334, -0.1554652, -0.16393018, -0.38313943, 0.2815526, -0.121848755, 0.078521855) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.4734181, -0.17490447, 0.14958043, -0.14309436, -0.036862105, -0.26266542, 0.35558245, -0.3514133, -0.102275215, 0.1442676, 0.044796508, 0.03880955, 0.1521028, 0.25220636, -0.16562814, 0.0416196) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.18914334, 0.19362234, 0.038249806, 0.0024076551, 0.20689262, -0.4078789, 0.19382994, 0.007212268, -0.18171497, -0.035042115, -0.023750905, -0.016114058, -0.45743752, 0.021125652, -0.06430871, 0.21322955) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.18562269, 0.1620788, 0.19098124, -0.24111506, 0.03449744, -0.03995001, -0.0091093285, -0.11040495, -0.27460584, -0.23235801, -0.18389146, -0.08260626, -0.33067784, -0.3057865, -0.13583457, 0.40736178) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2591629, -0.24197082, -0.054954667, -0.03834017, 0.4232038, 0.045948636, 0.17817032, -0.15802366, -0.17322762, 0.01623225, -0.1294157, -0.00074936583, -0.12104166, -0.2964878, -0.0024181195, 0.10818759) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3236507, -0.33609748, -0.36792737, 0.10080632, -0.22995017, 0.40652883, -0.30437145, 0.096962646, -0.096385784, 0.0032429167, -0.0124005405, -0.08545666, -0.3940536, -0.29371613, -0.118858874, 0.3361791) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5353522, 0.13373728, 0.25287068, 0.05086132, -1.1578425, -0.05571083, -0.29025692, 0.5545229, 0.18470345, -0.29827425, 0.28433847, -0.14918058, -0.24074, -0.7207084, -0.1836787, 0.48340786) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.41726482, 0.4560093, 0.32724693, 0.1484235, 0.032035235, 0.3525154, -0.16575567, -0.24129663, -0.24809453, -0.021808699, -0.06744669, 0.031760357, -0.07799142, -0.517955, 0.023052564, 0.44819382) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0713519, 0.08307502, 0.04361414, -0.019414218, 0.59762233, -0.2660774, 0.26281217, -0.28991044, -0.24116293, 0.2843053, -0.119720966, 0.03801535, -0.2906102, -0.13868916, -0.08062747, 0.22394082) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1744312, -0.071146935, 0.13217881, -0.028300589, 0.03956242, 0.34524164, 0.0019424459, -0.16612425, -0.25634167, -0.25584456, -0.024945028, -0.11670329, -0.15214038, -0.5485668, -0.12742311, 0.38388282) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2194978, 0.46389902, -0.21881634, 0.38172796, 0.30155706, 0.26146135, 0.46253932, -0.47111574, -0.17258903, -0.14609744, -0.042077787, 0.07688708, 0.36632103, -0.27587092, -0.26394233, 0.13997744) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

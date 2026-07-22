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

  var result: vec4f = vec4f(0.06848854, 0.09889069, 0.28174624, 0.119954474);
      result += mat4x4<f32>(-0.05368751, 0.09783439, -0.0023207166, -0.07319495, -0.025805682, -0.097787835, -0.055126164, -0.13450974, 0.18000437, -0.07049772, 0.07731095, 0.15151834, 0.021021519, 0.009433556, 0.18564111, -0.20031384) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.34914547, -0.023906266, 0.0033021872, 0.347026, 0.18739271, -0.10533957, -0.24541177, -0.4454622, -0.31290957, 0.3012576, 0.07030294, -0.31701308, 0.20038785, 0.084978126, -0.05414139, 0.061393935) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.26110262, -0.044032276, -0.038709667, -0.24665283, -0.14560124, 0.11440252, 0.07707664, 0.012267519, 0.06585118, 0.036587823, -0.18868224, 0.06222455, -0.014308961, 0.2020477, 0.1706748, -0.02646908) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.4923588, -0.37649536, -0.09381044, 0.47647282, 0.18048422, -0.08260889, 0.14438951, -0.24112873, -0.021274783, 0.04648116, 0.13174374, 0.2134578, 0.7092198, 0.061301205, 0.28969696, 0.3922645) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.49372268, 0.011579937, -0.07854226, -0.21807022, 0.37435725, -0.29989484, -0.33702546, 0.06000558, -0.110279, 0.52961403, -0.11297554, -0.51309496, 0.018246774, -0.44121453, 0.30905217, -0.20894912) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.5740314, -0.10375419, -0.48481196, -0.6069967, -0.05579365, 0.085981034, 0.25224674, -0.040528826, -0.37862536, 0.6589529, 0.10981503, 0.13966416, 0.12786338, -0.020283949, -0.3989832, -0.232354) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.5031011, 0.14461736, 0.17227925, -0.33009714, 0.0041556456, 0.0067712185, 0.16147554, 0.035958417, 0.18478411, -0.027227098, 0.064619854, -0.000106484054, 0.5916837, -0.26971394, -0.0404998, -0.08405953) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.5717733, 0.03234892, -0.2775055, -0.085139126, -0.09213288, 0.066542596, -0.16549876, -0.22276749, 0.37289673, 0.13946493, 0.30917603, -0.38001677, -0.0028992586, 0.009966908, -0.011019691, -0.64594007) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.50175714, 0.17306468, 0.40031123, -0.018349625, 0.05259407, 0.09219956, 0.04128508, 0.005905472, -0.162217, 0.0564998, 0.12500995, -0.0688149, -0.14739619, -0.085547164, 0.07851124, 0.022667611) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.019440856, 0.107066, -0.11935887, -0.096643545, 0.054727674, -0.016883668, 0.19903313, 0.0025506064, 0.13736914, 0.1698213, -0.029719118, -0.022514777, -0.14683162, 0.15838788, -0.32752803, -0.036551) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12689404, 0.038187962, -0.06867436, -0.20357813, 0.17366956, 0.0491541, 0.07705705, -0.039639663, 0.034855135, 0.06577135, 0.24282216, -0.030411715, -0.29113302, 0.13015941, -0.3237759, -0.42297146) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.13659112, -0.012827092, -0.01935301, 0.048153985, 0.15780708, 0.008714028, 0.13728696, -0.13408853, 0.20777711, 0.061625645, 0.012664316, 0.06240461, -0.27489656, 0.045908697, -0.105491035, -0.15777601) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.27320844, 0.3915156, -0.08207123, -0.13916692, 0.2700718, -0.064669885, -0.060555384, 0.032645233, 0.24285194, 0.079999305, -0.19421151, 0.26227146, -0.07855703, -0.23041566, -0.14957806, 0.044273257) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2299048, -0.22236674, 0.101072505, 0.7869852, 0.26605722, 0.24516544, 0.13197945, -0.6450926, -0.6639711, 0.10873473, -0.3696389, -0.6054781, 0.37813967, -0.106618226, -0.5906332, 0.6441932) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11101943, -0.18012533, -0.3198847, -0.09008111, -0.29301667, 0.048907947, -0.41539177, -0.35814404, 0.044341557, -0.030341502, -0.3115832, 0.026057962, -0.2868846, 0.07656541, -0.24974829, 0.023487275) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.037717957, 0.17873378, -0.13297288, 0.111517586, 0.29613954, 0.14494908, -0.11145509, -0.0063116914, 0.029871248, -0.17920847, 0.17861886, -0.0042977366, 0.29688504, 0.27888268, -0.113483556, -0.15307638) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.021126593, -0.14860399, -0.2056812, 0.19419532, -0.43394187, -0.042695582, -0.53899056, -0.32567838, -0.5240296, 0.080490485, -0.4297864, -0.06398746, 0.531523, 0.079480745, -0.39439034, -0.06788895) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13287178, 0.12583524, -0.15163802, -0.044310823, 0.011069545, 0.11811695, 0.07600959, -0.43484768, 0.05000317, -0.018874196, -0.20815307, -0.08219698, -0.028286941, -0.03634811, -0.69848555, -0.17461225) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

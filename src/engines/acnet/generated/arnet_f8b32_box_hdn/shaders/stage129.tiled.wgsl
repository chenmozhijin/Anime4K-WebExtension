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

  var result: vec4f = vec4f(0.10868812, 0.25185737, -0.20967282, 0.069125146);
      result += mat4x4<f32>(0.06497826, 0.027911963, 0.01879438, 0.04089842, 0.06790588, 0.022696085, 0.006992027, 0.0044273627, 0.08127144, 0.04842761, -0.16307072, 0.21322368, -0.03342811, 0.03967194, 0.029076818, -0.014324298) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.23391424, -0.13277014, 0.03438359, 0.057304252, 0.19297504, -0.1539099, 0.051796347, 0.07583513, -0.34713304, -0.17453708, -0.31345105, 0.28085983, -0.17842764, 0.0046831015, -0.11073759, -0.03288016) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.50945956, -0.03460831, 0.1124942, -0.27768672, 0.057574756, 0.047575727, -0.08863103, 0.06770762, -0.38256577, -0.01576442, -0.00426804, -0.063060746, 0.087336585, -0.022501897, -0.1142459, 0.061951894) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14318296, 0.031030923, 0.020996157, -0.008726882, 0.07243841, 0.0443864, 0.03093131, 0.0019302143, 0.47039554, 0.18533175, -0.24616246, 0.20281744, -0.43609548, -0.03818487, -0.018018749, 0.10896638) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.02859921, -0.26309735, 0.2417983, -0.22325079, 0.6834121, -0.389961, 0.39078736, 0.18781449, -0.4377304, 0.0044964813, 0.21110496, 0.40932494, -0.13932791, 0.053697117, -0.14126223, -0.62166446) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(1.5227146, -0.10135115, 0.022639593, -0.4791983, -0.004938147, -0.00090595125, 0.06415292, -0.0046425327, 0.003902351, -0.007337143, 0.0138759585, -0.123449154, 0.67377853, 0.29434648, 0.49291524, -0.40629044) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06934426, 0.008623197, -0.00095137494, 0.00681648, 0.18515584, -0.0818343, -0.0012679382, 0.0001598509, 0.105756424, 0.0570002, -0.054812137, 0.04941632, -0.13024555, -0.019391077, 0.0033646384, -0.07861415) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.051811587, 0.04616534, -0.10742124, 0.0014230493, -0.3690535, -0.5230796, 0.34192106, -0.18531328, -0.08583978, 0.022502126, -0.10350219, 0.049899485, 0.14788088, -0.14106078, 0.24453758, -0.13269024) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.094268344, 0.019988587, -0.0071479008, -0.009915181, 0.07271511, -0.07223048, 0.05102485, 0.03695785, -0.08797958, -0.013385638, -0.011364765, -0.045021955, 0.25823042, -0.037877504, 0.09151048, 0.0014714927) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07537068, 0.114625745, 0.102936424, -0.08586049, 0.008225596, -0.022645926, -0.005497282, -0.0034748563, 0.20639464, -0.19515634, -0.0017705634, 0.0017011395, 0.32733145, -0.0057557425, 0.024200194, 0.026230723) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.037092824, 0.09192871, 0.16038583, -0.10669054, -0.114665695, -0.15300648, -0.14723738, 0.092801236, 0.19514605, -0.16338517, -0.030891148, 0.18965137, -0.31392258, -0.0929428, 0.06906774, -0.111485) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3133529, 0.11096722, -0.13061994, 0.1977249, -0.12945351, -0.08266276, -0.14731415, -0.009449881, 0.12868026, -0.0312344, 0.09084801, -0.002493087, 0.014648907, -0.08708975, 0.087515384, -0.07279576) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.077626586, -0.06792166, 0.21263339, -0.27307072, 0.41499224, 0.17759126, -0.09316955, 0.20834486, -1.1919091, 0.04988432, 0.31729472, -0.66265535, 0.18435979, -0.01804646, 0.05867903, 0.03214038) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13571745, 0.1827749, -0.38121003, 0.3812504, -0.15926805, 0.13794085, 0.152389, 0.54451376, -0.31738827, 0.3211114, 0.3630748, -0.32280907, 1.0216545, 0.2675458, 0.03565263, -0.15617567) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.67774194, 0.026621614, -0.07820281, 0.3120514, -0.19462784, -0.10806154, -0.041418847, -0.0023965535, -0.06822173, -0.0729745, -0.11222775, 0.08381706, 0.57273144, -0.08927145, -0.008320369, -0.05184923) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1254091, 0.11905831, -0.04099366, 0.051134035, 0.07548195, 0.029542394, -0.023110967, 0.024966743, 0.11596397, -0.19491667, 0.039758418, -0.016571121, -0.10091347, -0.15198866, 0.0063690054, -0.07015621) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2163995, 0.05668999, 0.036902856, 0.048201203, -0.061486002, -0.042783104, -0.0055507612, -0.006693376, 0.087071694, -0.13987026, -0.07352496, 0.038077578, 0.47775936, 0.30518514, -0.16065784, 0.14667302) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.042098787, 0.057841044, 0.006713972, 0.00807094, 0.18860938, 0.020832343, -0.033036392, 0.006174455, 0.18411615, 0.08088358, 0.019883635, 0.03410408, 0.021617249, 0.0047326093, -0.034319926, -0.0091388775) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

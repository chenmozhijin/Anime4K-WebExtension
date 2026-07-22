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

  var result: vec4f = vec4f(-0.06008449, 0.017964132, 0.30993906, -0.05177464);
      result += mat4x4<f32>(0.08971859, 0.035822753, 0.057844747, -0.073472485, -0.08836102, 0.03746374, 0.07577396, 0.0853185, -0.02838974, -0.01797835, 0.0037776264, 0.14071578, -0.018964944, 0.042668525, 0.13859487, -0.15752669) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.18629354, -0.10473272, -0.19551937, -0.038897395, -0.06835067, 0.0149996765, 0.21475151, 0.13542789, -0.15849784, -0.19439381, -0.0047857547, 0.025408141, -0.10331207, 0.07483792, -0.12715457, -0.025957026) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.059973963, 0.003330399, -0.10197035, -0.10685916, -0.04645311, 0.18948558, 0.1266009, 0.006253531, 0.1384607, -0.05376202, 0.06187082, -0.03835237, 0.17788488, 0.10638666, 0.0005851033, 0.17997108) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11002267, 0.05310491, 0.21485439, -0.16672237, -0.12263875, 0.0268448, 0.18525061, 0.11642531, -0.08376329, -0.19226256, 0.0079339035, -0.025714524, 0.160124, 0.059528805, 0.06695698, -0.0010130353) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16235547, 0.13847794, -0.62838745, -0.2022581, 0.11000246, -0.029058604, 0.01574843, 0.66459894, -0.5651785, 0.28431064, -0.8143902, -0.07017864, 0.058395095, 0.77710557, 0.2019572, 0.08718608) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.026871657, -0.23516658, -0.14604867, -0.04118592, -0.19919837, -0.15308237, -0.17300302, -0.31037074, -0.13148731, -0.1621188, -0.049110837, 0.10116823, -0.28710467, -0.08332232, 0.0734212, 0.21137778) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07660914, 0.066069596, 0.046985414, 0.05297615, 0.030941341, -0.08583186, 0.06750293, 0.028913576, 0.01686035, -0.16913846, 0.0003322551, 0.039853256, 0.029531972, 0.08606162, 0.022316542, -0.03136159) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10031967, -0.05819311, -0.06758531, 0.34170747, -0.038372308, -0.20543633, -0.050632697, 0.25197133, 0.038647674, 0.22318584, -0.013020547, -0.27125296, 0.052665494, 0.03523378, -0.012511693, -0.03356905) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.013568492, -0.025199462, 0.025604753, 0.03501222, 0.0008256337, 0.08406708, -0.011127669, -0.1457533, -0.103554726, 0.07103133, 0.16370429, -0.07514663, -0.009933495, -0.034785617, 0.045640897, 0.03189175) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.016297523, -0.02035152, 0.088909365, 0.121874265, -0.017966105, 0.23051807, 0.26201507, -0.13591252, 0.12422132, -0.07140828, -0.07050194, -0.15043147, 0.442544, -0.20265086, 0.16978139, 0.46826696) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11835831, 0.020442685, 0.014065929, -0.09389795, -0.29318556, 0.08699888, 0.24829574, 0.354278, 0.28534755, 0.40026414, 0.133486, 0.13810186, 0.0038095661, 0.08861372, 0.4830822, -0.0981848) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.018344237, 0.050210338, 0.08412641, -0.037387233, -0.36173797, -0.10157547, -0.3125295, 0.13748631, -0.082114436, -0.023307811, 0.029033419, -0.069269456, 0.056539644, 0.23528747, 0.19932657, 0.04511249) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.16780396, -0.17695968, -0.0055240947, 0.13446261, -0.124949396, -0.17335846, -0.14868118, 0.20199837, -0.040988933, 0.31664446, 0.18896152, -0.19756429, -0.43034476, -0.027169826, 0.017597567, 0.29141766) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15868053, 0.32060328, 0.69365615, -0.014259218, -0.7109839, -0.110251814, 0.091583565, 0.018241953, -0.3526733, -0.33974534, -0.6361691, -0.48802453, 0.32736698, 0.16355877, -0.07396524, -0.28135428) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.084479444, 0.09321135, 0.08066036, 0.13164292, -0.006585119, 0.19595706, 0.19961125, 0.015786547, 0.11652975, -0.010811725, 0.25751203, -0.043682545, 0.0068383208, 0.19264048, -0.04482422, -0.081033394) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0721355, 0.09386756, 0.17931901, 0.22666901, -0.1899176, -0.23399758, -0.19040033, 0.27083653, -0.015005084, 0.024528362, -0.0915385, -0.079072736, -0.08198241, -0.023846777, 0.036534492, 0.030555438) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.097980745, -0.114607364, -0.15849353, 0.14331117, -0.07300456, -0.07691635, -0.11466646, -0.018923977, 0.22354686, -0.2995341, -0.028889561, 0.033842817, 0.10686634, -0.19308074, -0.053914018, 0.10219415) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.050766766, 0.07824504, 0.13875818, -0.066337556, -0.15924025, 0.0037592358, -0.05886437, 0.09154994, -0.023323404, 0.025877396, -0.009475654, 0.1320996, 0.058380775, 0.13704135, 0.1478499, -0.025308225) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

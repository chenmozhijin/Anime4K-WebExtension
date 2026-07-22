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

  var result: vec4f = vec4f(-0.16147813, -0.15462388, -0.1132081, 0.12812404);
      result += mat4x4<f32>(-0.00015096412, 0.069528386, -0.06325406, -0.065004736, -0.061228786, 0.1359585, 0.052326858, -0.00390443, 0.02464374, -0.039187126, 0.035522137, 0.050038587, -0.032116137, 0.026425648, -0.031470932, 0.018188039) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.02034155, 0.095356956, -0.04782462, 0.00016155536, 0.06318213, -0.15061124, 0.082392596, 0.09052832, -0.025563657, 0.0735066, 0.10075126, 0.06884159, -0.09274939, -0.11674239, -0.0012880168, 0.14037028) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.075421736, 0.036303893, -0.007848976, 0.020990076, -0.025904076, 0.21315295, -0.049387496, -0.1340025, 0.1417267, -0.040117323, -0.0149182435, 0.060796835, 0.13809867, -0.111885436, -0.036078446, 0.080541216) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.019817369, 0.09510606, -0.04385021, -0.112775415, -0.009970447, -0.008495136, 0.06980276, 0.08050643, 0.018843103, -0.0026475012, 0.016698187, 0.041456304, -0.29675537, 0.10401504, -0.2629339, 0.03156079) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0077212714, 0.21191761, 0.10314839, -0.1488617, -0.21929432, 1.0110972, -0.3295787, -0.22316714, -0.25099736, 0.10732931, -0.17806774, 0.15262567, -0.2501168, -0.122947745, -0.2644829, 0.93002504) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.29068717, 0.14320488, 0.06168752, -0.027129339, -0.15823725, -0.07489186, 0.021260241, -0.21618327, 0.036330424, 0.17209673, 0.039527692, -0.21813291, 0.008556176, -0.19531827, -0.066915244, 0.3185511) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.034793425, -0.061378207, -0.0026695286, -0.025248783, 0.10083241, -0.07165447, -0.01440048, -0.07616679, 0.06899053, -0.03846414, 0.018367754, 0.09898875, -0.003884904, -0.031793624, -0.018456854, 0.03375269) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24090868, -0.11259369, 0.1244771, -0.15557915, -0.19954897, -0.18127777, 0.082311854, -0.015946139, 0.01582984, 0.16942969, 0.07973882, 0.21989387, 0.027640827, -0.10938731, -0.14046963, 0.033498187) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.5908386, 0.067701474, -0.19487688, 0.077198386, -0.0413998, 0.07754444, -0.047220264, -0.132061, 0.15270923, 0.07871862, 0.067633465, 0.100111686, 0.05221048, -0.04211819, 0.0046037436, 0.07303031) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.10804206, 0.12492646, -0.15585597, -0.14775746, 0.016505718, -0.16180333, 0.04569257, 0.08011426, 0.022784049, 0.048921075, -0.04541512, -0.078036845, 0.08679323, -0.031946797, -0.06603802, -0.013795567) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.42347258, 0.10504401, -0.18357587, 0.18554693, 0.027016606, 0.21060465, -0.12282375, -0.12699816, -0.029828347, 0.068565406, 0.12938897, 0.042664554, -0.19879061, -0.0137529345, 0.07110281, -0.0929485) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.12150984, -0.047964152, 0.14320558, 0.05729984, 0.08920568, -0.031231655, -0.043585427, 0.033995163, -0.058466814, 0.11685628, 0.019511372, -0.009898415, 0.04346596, -0.07569762, 0.026900634, 0.092184834) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.03672981, -0.034434948, -0.020278908, -0.0346412, -0.025915725, -0.13495032, 0.16024753, 0.049989644, 0.05669223, -0.15185808, -0.050679073, -0.1270551, 0.028230878, 0.023222737, -0.07179763, -0.13912602) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.09803509, 0.022827962, 0.21351126, -0.36714163, 0.2677687, 0.07155607, 0.39585817, -0.7697741, -0.10917068, -0.07184206, -0.31903514, 0.39342594, -0.7089031, -0.0058508925, -0.6662396, 0.63635385) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07720959, 0.34523243, -0.13143648, -0.094602324, 0.13839293, 0.011712308, -0.015994899, 0.04146101, -0.10846406, -0.00047668852, -0.08507916, -0.17445987, -0.047283065, -0.035589643, -0.03603154, -0.007917922) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0069116033, 0.018542431, -0.006350863, -0.03450274, 0.008209285, 0.037663653, -0.058548287, -0.054433748, -0.096806146, 0.06136737, -0.009823128, -0.10192551, -0.019890849, 0.047555733, -0.0037413544, 0.07734452) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.057106033, 0.23197903, 0.03413823, -0.051789872, -0.00075420685, 0.08579166, 0.0784484, 0.023567975, -0.041753646, -0.06597277, 0.07030642, 0.016212676, -0.08321292, 0.050695937, 0.030577773, 0.09029999) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.026379481, -0.061483826, -0.009663931, 0.006269553, -0.021418745, -0.045621004, 0.007901911, 0.020709889, -0.055890556, 0.02865263, -0.011454044, -0.056040246, -0.06009653, -0.18390466, 0.06552864, 0.017165927) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

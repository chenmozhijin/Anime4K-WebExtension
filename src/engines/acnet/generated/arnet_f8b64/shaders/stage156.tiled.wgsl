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

  var result: vec4f = vec4f(0.060034294, -0.042071167, 0.09551389, -0.09076627);
      result += mat4x4<f32>(0.042602938, 0.052938636, -0.16304663, -0.03978654, 0.11009032, -0.2161029, -0.13932213, 0.06177874, -0.054549407, 0.1974989, 0.12222628, 0.023742562, -0.035370406, -0.071094304, -0.058928438, -0.07698644) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.32125992, 0.08067034, -0.100924954, 0.51548773, 0.12050043, -0.39215514, -0.19068055, 0.044951167, -0.103890784, 0.30528867, 0.15439844, -0.01411939, -0.022864887, -0.26263586, -0.13987601, -0.0047770436) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11441868, -0.0012941522, -0.038712602, -0.46875018, 0.10003962, -0.23836848, -0.08560327, -0.0050567794, -0.0572961, 0.10166748, 0.007875927, 0.0030417044, 0.025254633, -0.20306313, -0.10430426, -0.037113227) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.016692376, 0.33818397, 0.048454944, -0.3235433, 0.09155654, -0.23174343, -0.1390627, 0.06423003, -0.072126456, 0.22158805, 0.09545815, -0.034882642, 0.031584337, -0.24076617, -0.12082661, 0.091068685) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28569034, 0.19816175, 0.37142065, -0.5934928, 0.12608853, -0.42562932, -0.16090065, 0.065105006, -0.11277127, 0.30749652, 0.02329769, -0.07282917, 0.14567646, -0.3091041, -0.050150987, -0.0248981) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0064930483, 0.17250347, 0.06819834, -0.17486542, 0.13604979, -0.31673568, -0.11390158, 0.068110995, -0.08858697, 0.14219798, 0.029567664, 0.0018122402, 0.1037827, -0.27971232, -0.052924223, 0.0497) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06378867, 0.030102862, -0.046209678, -0.061605085, 0.048948675, -0.100699276, -0.035699833, 0.011342874, -0.037045687, 0.14005186, 0.04239331, -0.047048897, 0.012993103, -0.111151375, -0.07777824, 0.042688157) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07196753, -0.034726497, -0.103925966, -0.111184314, 0.1014224, -0.24589068, -0.11637005, 0.08286381, -0.103870034, 0.16264859, -0.027608272, -0.05520478, 0.056383803, -0.2662141, -0.11638681, -0.083195634) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.016374007, 0.20258525, 0.012021426, -0.13093758, 0.08279865, -0.14827476, 0.0040549096, 0.044453166, -0.04773924, 0.05980859, -0.035155717, -0.029609624, 0.13977486, -0.23040357, -0.053597864, 0.07350533) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.15642917, 0.003246689, 0.40026328, 0.026216326, 0.03236541, -0.10170605, -0.078244574, 0.10297077, -0.030538626, 0.15347701, 0.08345164, 0.040960792, 0.3544354, -0.11278319, -0.33167621, -0.07286688) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.010997694, -0.12144077, -0.22746137, 0.036543496, 0.039688148, -0.059674688, -0.0045936033, -0.24601324, -0.10210636, 0.24583131, 0.01946486, -0.02922517, 0.4597866, -0.11493621, -0.12715845, 0.6322275) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3022742, -0.16605233, -0.72099245, -0.019413844, -0.023098314, -0.08014429, -0.008166621, 0.095727384, -0.07178925, 0.17353053, 0.0725278, 0.0060951454, 0.17548896, 0.072199635, 0.015863156, 0.112069294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.02559985, 0.15232559, 0.064889126, 0.02196607, 0.011476365, 0.06557574, -0.0093967635, -0.032385074, -0.071379475, 0.23656274, 0.13250883, 0.06763261, 0.6918453, -0.3547413, -0.5876885, 0.15828551) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30150637, -0.10194514, -0.55107677, -0.102794565, 0.49169266, 0.016236737, -0.45426247, 0.46339986, -0.1023946, 0.45481783, 0.12815255, 0.065348715, 0.21727869, 0.09228159, 0.1470067, -0.20595062) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.083472066, -0.09672092, -0.3096545, -0.14055172, 0.019345485, -0.070794515, 0.024654714, 0.40085894, -0.13652894, 0.2595957, 0.03128755, 0.026571164, -0.1505341, 0.07476431, -0.105135895, -0.49039996) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.21145783, 0.14238314, 0.65855676, 0.18223244, -0.07508753, 0.07007193, 0.16251193, 0.011852631, -0.03507291, 0.13536733, 0.08239065, 0.01731437, 0.3308082, 0.09837279, 0.087623045, -0.23766124) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.044452857, 0.18601234, -0.038557522, -0.021303639, -0.12331649, 0.03908467, 0.0057182466, 0.12714252, -0.05796504, 0.24303873, 0.1416819, 0.098865725, -0.08466044, 0.12489947, 0.2698257, -0.2512289) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13199022, 0.004864259, 0.31047451, 0.05944669, -0.11980454, 0.05261201, 0.2155476, 0.08108292, -0.069996044, 0.12895532, -0.043741167, -0.012961524, 0.10358413, 0.04151075, 0.05225323, 0.31537023) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

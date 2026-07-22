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

  var result: vec4f = vec4f(0.22047856, 0.20804234, 0.25615537, 0.44206756);
      result += mat4x4<f32>(0.10321505, 0.1549008, 0.090762965, -0.04497403, -0.100672156, 0.043832883, -0.024224345, -0.11408175, 0.15712231, 0.2971801, 0.24853139, 0.04347742, -0.07619431, -0.18251318, 0.008095732, -0.2275336) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.12076726, 0.30316225, -0.04295621, -0.15382445, -0.087787054, -0.14741948, 0.35013992, 0.158592, -0.10629931, 0.1693287, -0.0035942975, 0.13283584, -0.059930712, -0.40203598, 0.39464173, -0.07654248) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.035039846, 0.02164642, -0.023456566, 0.07736301, -0.12569937, -0.23742342, 0.101106815, -0.23893589, -0.13409412, -0.009341927, 0.16013826, -0.13071632, 0.092321195, 0.3501045, -0.41506943, -0.056992825) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07662994, -0.4629776, -0.05734491, 0.08115204, 0.054661777, 0.16845092, 0.36665452, -0.025088241, 0.13464195, 0.18816228, 0.009436111, -0.1364213, -0.18332107, -0.34775278, -0.16452716, -0.32329968) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.121089906, 0.1531831, -0.3495448, 0.0019833155, 0.07299113, 0.42868552, -0.04408765, 0.12212445, 0.18076175, -0.2596781, 0.75149083, -0.015658936, -0.108885095, 0.31378227, -0.051447853, -0.38008398) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.03366738, -0.068754196, -0.027134843, 0.04093837, -0.12640925, -0.11080016, 0.05690528, -0.31785122, -0.09389612, 0.024668045, 0.20494261, -0.43200138, -0.11370949, 0.26725852, -0.082746506, 0.32489306) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07201067, 0.23730677, 0.0454598, -0.021773357, 0.07194418, 0.11343591, 0.11587135, -0.012549077, 0.026500309, 0.4608638, 0.0930647, -0.24480847, -0.11095929, -0.24823338, -0.10298773, 0.0050347825) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.121299915, 0.2512782, 0.02931887, 0.08677821, -0.06556702, -0.04265194, 0.21990404, -0.115863085, 0.18276967, 0.41498783, 0.38024804, -0.04055662, -0.07990873, -0.071402274, -0.3068805, 0.20571996) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.024792142, 0.07476749, -0.0058876253, 0.16189907, 0.018160874, -0.039727245, -0.1165463, 0.001328554, 0.31541958, 0.323755, 0.14868836, -0.19725057, -0.023521287, 0.15317114, 0.07454916, 0.16100204) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0712266, 0.30502436, 0.003584024, -0.22447942, 0.051435865, 0.012345863, 0.40284887, 0.01820195, 0.00727653, -0.080495924, -0.15847911, 0.20013443, 0.04036382, 0.11372816, -0.037581813, 0.052690182) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2129743, 0.14664574, -0.8308639, 0.09639331, -0.1942918, -0.16115287, -0.17943038, -0.3681018, 0.20313607, 0.2428026, -0.39029026, 0.17260724, -0.041090053, -0.18265249, -0.041262206, 0.19628479) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06553052, 0.20093022, 0.017936356, -0.060521014, 0.07087727, 0.08264611, -0.22737576, 0.26512805, -0.0008043628, -0.23002705, 0.09400758, -0.08497732, -0.058223307, -0.1110247, -0.048087426, 0.17941225) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.16406834, 0.19309051, -0.5756261, -0.04299132, 0.11700266, -0.47736493, -0.12334256, 0.35080823, -0.055016395, -0.050289083, -0.015713433, 0.12710817, 0.09411302, 0.10136816, 0.07325355, -0.08583932) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14866342, -0.05908903, -0.6944214, 0.2576167, -0.1815572, -0.7889077, -0.16799916, -0.22202009, -0.097924285, 0.9755189, -0.21301906, -0.5357366, -0.10213867, -0.15100251, -0.25360784, 0.10351993) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18763478, -0.06500202, 0.2289789, -0.37573388, 0.09575136, 0.05069866, -0.29542774, 0.31242883, -0.18569127, 0.23899448, 0.027303688, -0.46798727, -0.011521493, 0.04266619, 0.24162956, 0.26199654) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11969349, 0.06731074, -0.022182435, 0.028791774, -0.03401182, -0.17533277, 0.27601746, -0.052116763, 0.058904387, -0.07132677, 0.20097403, 0.14978205, 0.08308942, -0.2105263, 0.005864518, 0.058322597) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09138603, 0.08525912, 0.19863044, -0.0833074, -0.11890324, -0.29568323, -0.3021644, 0.13113594, -0.05168347, 0.13835639, 0.19005498, -0.09763734, 0.069131866, -0.40226737, -0.20667705, 0.03868185) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03521091, 0.17193706, 0.061475564, -0.11557248, 0.005564225, 0.04084706, -0.26350114, -0.048500326, -0.06569363, -0.086054906, -0.15533629, -0.11404522, -0.12648225, -0.48626375, -0.105267584, 0.00069674256) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.25666046, -0.035238303, 0.0075589633, 0.16231982);
      result += mat4x4<f32>(-0.032926228, 0.04297183, 0.07254102, -0.24818285, -0.07279661, 0.23396903, -0.24103631, 0.19647983, 0.042152304, -0.5221824, 0.25184023, 0.06104309, 0.050371394, 0.12407923, -0.13713758, 0.043122202) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08185134, 0.15057784, 0.09288807, 0.050924934, -0.1314385, 0.18647076, 0.013951448, -0.23660293, -0.1355688, -0.06793155, -0.03082028, -0.09004121, -0.049777217, 0.12176029, -0.25583977, -0.05757051) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.029275011, 0.08780093, 0.10923368, -0.057484236, 0.05164064, 0.07879072, -0.30891407, 0.17701285, -0.05008707, -0.016630521, -0.0040906295, 0.095390275, 0.03361527, 0.24311426, -0.11296818, -0.032713603) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.012375044, 0.011604391, 0.16031459, -0.12252789, -0.102031596, 0.16813566, -0.27453658, 0.47658372, 0.13751896, -0.37059042, 0.008657076, -0.16324738, -0.024359666, -0.14672904, -0.11379778, -0.093278304) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20135161, 0.6170948, -0.15258488, 0.07492823, -0.39626652, -0.17693855, 0.84921587, -0.50851864, -0.044806916, -0.77073115, 0.24693885, -0.3070422, 0.508733, -0.14298889, -0.13886072, 0.16246559) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09507938, 0.18051621, -0.16688903, -0.02215103, 0.16439582, 0.2709604, -0.23940518, 0.057544675, 0.028968172, -0.12261256, 0.03963687, -0.044261664, 0.18362841, 0.3359676, -0.12919176, -0.41167465) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.011891524, -0.08542868, 0.16791773, -0.108438954, 0.039850775, 0.057909187, -0.021004146, 0.22549102, 0.13097057, 0.2665251, 0.17792119, -0.019001048, 0.019380149, 0.00933521, -0.060195625, -0.18007466) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.035684243, 0.012682784, 0.04576836, -0.16102391, -0.22075956, -0.16943368, -0.111350685, -0.3586081, 0.005377024, -0.059390765, -0.093108006, 0.00043665487, 0.14469528, 0.09090045, 0.33114636, 0.07398804) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.02482423, 0.061398994, -0.0935414, 0.24745056, 0.044793785, 0.055136528, 0.05372894, -0.18023296, 0.0026933027, 0.029106313, 0.000934407, -0.060747206, 0.15325254, 0.23034735, -0.28136542, 0.24864598) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.022731328, 0.11286155, -0.061386574, 0.16769615, -0.21674006, 0.084631376, -0.18664433, -0.11267496, -0.020259751, -0.33082375, 0.19027935, -0.15591349, 0.006985214, -0.04783472, 0.026051562, -0.051639155) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19411802, 0.4965928, -0.1959881, -0.32196528, -0.13213247, 0.21331193, 0.054792825, -0.19451071, 0.0922418, -0.4778003, 0.29162973, -0.13411216, 0.1489245, 0.08452076, -0.287752, 0.020732027) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.109428786, 0.42320544, -0.2035664, -0.2165924, 0.2791532, -0.08324241, 0.18405966, -0.28894708, -0.0501123, -0.14457808, 0.100986496, -0.106534146, 0.07013725, -0.18846297, -0.023430716, -0.045948774) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06341942, 0.066032685, 0.4133196, -0.12531054, -0.048272338, 0.30096018, -0.16576844, 0.51954806, -0.060126003, -0.6478942, 0.18685697, -0.22547323, 0.06983552, 0.072520286, -0.23663142, -0.15247706) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.39489478, 0.76497865, -0.0656844, -0.4785934, -0.0869216, -0.13056658, 0.27768886, 0.20117514, -0.05272255, -0.8762813, 0.23686329, -0.09098748, -0.3299929, -0.48385164, -0.51507086, 0.13620622) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.028100044, -0.10564184, 0.32725805, -0.24868268, 0.35634017, -0.28946263, -0.054991856, 0.17986439, -0.07965249, -0.30143943, 0.33744985, -0.3826037, -0.26044944, -0.21729751, 0.13129964, -0.26311836) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12131284, -0.10265744, -0.02594863, -0.084202535, 0.112113774, -0.0041759154, -0.23373112, 0.08676994, 0.020978943, -0.25609675, -0.082809664, 0.01669272, -0.16019493, -0.12593056, -0.1024549, 0.13035259) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09434942, 0.20924816, -0.08306994, -0.13497242, -0.17644067, 0.22134367, -0.009263751, -0.20625283, -0.013184178, -0.42419955, -0.3296478, -0.07818981, 0.027328953, -0.27209258, 0.04264449, -0.009892862) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12111977, -0.2600733, -0.00852462, -0.08463672, 0.008439176, -0.27511734, 0.11329679, 0.07645184, -0.088310346, -0.051313505, -0.037787925, -0.13159454, -0.13131526, 0.047562756, 0.005938813, -0.13420664) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

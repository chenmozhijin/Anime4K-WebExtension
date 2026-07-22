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

  var result: vec4f = vec4f(0.2129283, 0.13525948, -0.20840523, -0.096916825);
      result += mat4x4<f32>(-0.1546469, -0.2016145, -0.08581707, 0.06971786, -0.09028949, -0.13381946, -0.09176395, -0.06467837, 0.02805809, 0.0066023944, -0.023213297, 0.0180084, 0.0072199227, 0.032044224, -0.016668357, -0.03740373) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.25951633, -0.12540257, 0.27208045, -0.089465395, 0.12587109, -0.21271895, -0.041363362, -0.09643618, 0.38489255, 0.21064015, 0.11444158, 0.027313951, -0.12828057, 0.116414465, -0.016742822, 0.15390201) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.25450817, -0.06846337, -0.21192382, -0.099798895, 0.0514714, -0.090180285, 0.044811483, -0.034103245, -0.091776915, 0.01302275, -0.020410627, 0.07183283, 0.04307893, 0.0784635, -0.0056145047, 0.009996375) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.113026634, -0.29630908, -0.23506773, 0.7794876, -0.33850056, 0.027927035, -0.07464755, 0.025765061, -0.09187201, -0.07753346, -0.043162115, -0.046136517, 0.11169592, 0.06125627, 0.049620096, 0.033493225) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5129958, -0.22424437, 0.2092428, 0.014026682, 0.031864017, -0.63735807, -0.13365743, 0.03952985, 0.0040108818, -0.30214664, 0.59673107, -0.06309656, -0.69462025, -0.4504565, -0.012995973, 0.5471054) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0018955073, 0.1392436, -0.091155976, -0.21096386, -0.12211467, -0.079243325, -0.004948256, -0.14417681, -0.11845532, 0.12224736, 0.10759755, -0.049312625, 0.077089526, -0.17613533, -0.06856897, 0.3145622) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.05932283, 0.05602422, -0.34904948, -0.16952415, 0.059091393, -0.081740916, -0.0025223992, -0.007739575, -0.09684448, -0.039883286, -0.04393426, -0.012110678, 0.06332803, -0.025107762, 0.0049619447, -0.03765088) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.4170396, 0.059564903, -0.08079942, -0.07895022, 0.1461385, -0.17640932, -0.032806806, -0.118552625, 0.050108396, -0.08447848, 0.01721255, -0.036099855, -0.072959855, -0.09877323, 0.22500157, 0.0060955826) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11099157, -0.060371924, -0.25366688, -0.2076171, -0.031242179, -0.03342911, -0.025077363, -0.01122168, -0.084961325, -0.011958822, -0.024132136, 0.017591888, 0.016208861, 0.043038655, -0.0034752465, -0.023568759) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.11631247, 0.123591825, 0.036245514, 0.0062018326, 0.13296163, -0.008446052, -0.0048413756, -0.026322365, -0.0045165527, -0.07752441, 0.05231563, -0.011621216, 0.19121335, -0.10449782, 0.06974705, 0.023848893) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10210893, 0.24902533, 0.10389837, -0.13040301, -0.24783544, 0.0010902431, -0.08094453, -0.04231167, 0.14631186, -0.061520346, 0.07621053, -0.022580229, -0.26259124, 0.05221462, -0.27478963, -0.097412795) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0074571725, 0.056806974, 0.016941763, 0.03994154, 0.116459586, 0.023092471, 0.08298993, 0.06781446, -0.04407516, 0.191998, 0.088003576, 0.0126172695, 0.09180277, 0.018146358, 0.007601052, -0.15351208) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.20238882, -0.068956904, 0.14649937, 0.009357411, -0.7067956, -0.04336868, 0.01147166, -0.13496163, 0.01538192, 0.0631794, 0.009642735, 0.017244406, 0.07835159, -0.09196195, 0.064282574, -0.09063491) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.49197802, 0.15791133, 0.2796216, -0.4246935, 0.27023572, -0.15205653, -0.19913583, 0.5100272, 0.06881039, 0.14509578, -0.038376573, -0.03867075, 0.5999258, -0.6211633, -0.28331715, -0.5447054) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18009318, 0.017024558, -0.06840623, -0.06438333, -0.20289375, -0.087572865, 0.03335596, 0.08726433, -0.24781337, 0.6098109, 0.1658139, -0.15949008, 0.32963443, -0.40573716, -0.12981488, -0.27997717) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.008734154, 0.018086066, -0.07364892, -0.029001957, 0.1931817, 0.09940115, 0.049805827, 0.027603986, 0.05991742, -0.04947043, 0.07600401, 0.0011050736, 0.058062866, 0.0073683956, 0.06452017, 0.023989651) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0019261339, 0.124084644, -0.0032771807, -0.024803242, 0.12839521, 0.043006532, -0.010682778, -0.0057637584, 0.034923486, 0.14214694, 0.06367003, 0.082821645, 0.058126964, -0.07872505, 0.05477733, -0.0077349404) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10381012, 0.00063006824, 0.028131433, -0.035819657, 0.005463332, -0.08950433, -0.0018645686, -0.051940635, 0.026236104, 0.19863297, 0.14561586, 0.041456472, 0.051825643, -0.016223304, 0.024549846, 0.00011014211) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

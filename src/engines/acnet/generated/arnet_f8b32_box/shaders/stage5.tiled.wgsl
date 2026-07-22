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

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_1[tileY][tileX] = sample_FEAT_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.28503975, 0.18948704, 0.123460814, 0.23753487);
      result += mat4x4<f32>(-0.103044294, -0.33031258, 0.24474369, 0.06706562, -0.052010186, -0.2483848, -0.012354053, -0.06202347, -0.42228723, -0.41018677, -0.2711813, -0.05283388, 0.46211872, 0.15288234, -0.20020375, -0.0014186527) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10053307, 0.2058394, -0.3720963, -0.4474942, 0.3037519, -0.17796417, -0.35123664, 0.005120522, 0.22499776, -0.31079224, 0.278456, 0.03572661, 0.27940515, -0.10998645, -0.40208724, -0.13658679) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.32148558, -0.003745397, 0.22574434, 0.042508457, 0.18690595, -0.07107319, -0.10481849, -0.07162394, -0.29458064, 0.037384894, -0.1550819, -0.17735606, 0.3440847, -0.11653067, 0.08700269, -0.16623572) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.23385914, -0.052584536, -0.28770977, -0.5604968, -0.43399373, -0.25895095, -0.015103022, -0.37071165, 0.38152096, 0.11374288, -0.11172751, 0.412593, -0.4330374, -0.22223958, 0.13276103, -0.37127635) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15777807, 0.07220193, 0.2783284, 0.584937, -0.21518965, 0.08081662, -0.22214808, -0.21794495, 0.0613146, 0.90744776, 0.15209526, -0.17899387, -0.08637386, -0.49434304, -0.19964787, -0.3904346) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.3403006, -0.039988413, -0.2925716, 0.20196572, -0.2906779, -0.017319584, -0.080807775, 0.08366375, 0.46265948, -0.24511172, 0.15918444, -0.15042457, 0.46391517, -0.099813096, 0.1583292, -0.39582482) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.26395717, -0.0139673855, 0.046387132, -0.12668696, 0.06634305, 0.14771454, 0.22968765, 0.034106415, -0.052897993, 0.03734965, -0.12218032, 0.15193576, 0.007055986, -0.17125042, -0.042117644, -0.08941543) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.28799668, 0.053426437, 0.060348723, 0.2597606, 0.34421286, 0.15926397, 0.010806424, -0.10822087, -0.014552966, 0.04626795, -0.044378318, -0.07291166, 0.21569231, -0.036926698, -0.105617896, 0.058354303) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.22200638, -0.09385224, -0.025121834, 0.057240646, 0.24594794, -0.095749386, -0.048013482, -0.10949034, -0.26344323, -0.06320871, 0.108433634, 0.1351655, 0.017838566, -0.15212068, -0.019094491, -0.10335005) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06479652, 0.035153743, -0.1125289, 0.122188024, 0.09930798, 0.30378515, -0.381419, -0.34991202, -0.39091513, -0.31705886, 0.076570354, -0.15006703, -0.08201982, -0.32274553, -0.16897504, -0.19719633) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.89115274, -0.7069444, 0.95498854, 0.16211085, -0.13676138, -0.09651249, -0.005422019, 0.09691444, 0.15099911, 0.06962351, 0.41009894, -0.08334454, -0.17748086, -0.47887352, 0.7682936, 0.11178289) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.01824642, 0.29416546, -0.34103703, -0.07834713, -0.35721123, 0.16370311, -0.3579985, 0.109479144, 0.02395988, -0.33139607, -0.044369828, 0.1928851, 0.059477523, -0.048317757, 0.23816334, 0.008481605) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3129306, -0.09749149, -0.36202163, 0.10794117, -0.32831994, -0.16558695, -0.34784892, -0.11335888, -0.12007039, 0.21020772, -0.025518702, 0.5124242, -0.5426517, -0.13311574, 0.08747292, -0.37862575) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42958876, -0.75667316, 0.2108167, 0.09513006, 0.14814149, -0.17486039, -0.04669189, -0.28221914, 0.10511722, 0.036398802, 0.24336475, -0.7220203, -0.4399071, -0.33436865, 0.055661056, -0.075267) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.36125445, 0.24705482, -0.10620059, 0.052918114, 0.041755535, -0.26532692, -0.21301974, 0.32530203, -0.15151395, 0.118728586, -0.1621027, 0.3197349, 0.19904557, 0.016192142, -0.12934676, -0.14864536) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.087715186, -0.10172604, -0.031766888, 0.031797867, -0.19586445, -0.070670165, 0.058771722, -0.024079379, -0.15566579, 0.078884915, 0.04199167, -0.422848, 0.13618714, -0.09232397, 0.092594445, -0.12119548) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18994355, -0.23022437, 0.043203857, 0.11834146, -0.0811106, -0.3861648, 0.028194837, 0.02843575, -0.13053697, 0.07664714, -0.01761856, -0.36176297, 0.10713713, -0.07617711, 0.15040274, -0.17697191) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19804007, -0.0003062356, -0.06027336, -0.21409023, -0.14935681, -0.35724407, -0.0070192474, -0.15396294, -0.07009251, -0.15301375, 0.110766806, -0.28850862, 0.009810162, 0.09858461, 0.0037262684, 0.07955448) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

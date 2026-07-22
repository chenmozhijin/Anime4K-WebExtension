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

  var result: vec4f = vec4f(0.34791347, 0.5974985, 0.24972059, -0.19389063);
      result += mat4x4<f32>(-0.11213102, -0.29296115, -0.008951239, 0.13174391, -0.17550236, -0.3476923, 0.085576095, -0.039038356, -0.09199944, -0.115060516, 0.1446727, 0.16767046, 0.3751859, 0.015233273, 0.084924445, -0.7804529) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.04097551, 0.30596444, 0.1601077, 0.4264727, -0.037291285, -0.2283027, -0.009157334, 0.26191163, -0.09624442, -0.104826555, 0.22484393, 0.19519772, 0.066402376, 0.24590915, -0.23684254, -0.21041425) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15046369, -0.050281588, 0.020064209, 0.17193274, -0.04805618, 0.21065886, -0.22976837, 0.15301497, -0.14419809, -0.08596421, 0.18836085, 0.23281403, 0.19879498, 0.67932105, -0.30802506, -0.22050358) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17893882, -0.09231043, 0.24756046, 0.4981236, -0.0060188323, -0.26190966, -0.09224514, -0.08192106, -0.1486561, -0.16659783, 0.22041985, 0.23259501, 0.24070106, -0.30327305, -0.075214446, -0.09961022) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2032746, -2.1250477, -0.3898437, -0.9228337, -0.10537155, -0.10548218, 0.15698321, 0.23818855, -0.21520816, -0.18819824, 0.21783136, 0.3381138, 0.15172121, -0.21875635, -0.023546813, -0.7785441) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24220923, -0.067362875, 0.18346502, 0.30291745, -0.11331814, 0.12644322, -0.10343719, -0.027086265, -0.15185389, -0.20164715, 0.25452098, 0.31719208, 0.06893792, 0.48966753, -0.055051945, 0.20407242) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13958709, -0.08262339, -0.23178641, 0.06241776, -0.109995455, -0.3930398, -0.24241161, -0.2707905, -0.13006878, -0.14784496, 0.13565283, 0.13579148, -0.17490901, -0.71713984, 0.33268625, 0.4530372) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.39896592, 0.64054936, 0.29819864, 0.6009268, -0.07849458, 0.040421035, 0.1854364, 0.35902473, -0.14479578, -0.15771587, 0.18608561, 0.22420184, -0.40413243, -0.03612808, 0.22746135, 0.4432599) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.031168418, -0.11041705, -0.08639167, 0.010984663, 0.034158185, -0.027481383, -0.21936014, 0.20235825, -0.10903544, -0.16324838, 0.1077435, 0.19955072, -0.2630292, 0.03131231, -0.039385695, 0.813485) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08894731, -0.5724105, 0.15409264, 0.26945338, 0.13840213, 0.03989667, 0.10017429, -0.09531703, -0.04194373, 0.15672627, -0.038192954, 0.36755544, 0.035626166, 0.0017618153, 0.13641867, 0.13499083) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.058705974, -0.29597497, 0.23681056, 0.0985164, 0.08904668, -0.2020975, -0.4553653, -0.09837487, 0.13702963, -0.2805715, 0.09655173, 0.09573644, -0.06503906, -0.66752934, -0.08903458, -0.22344312) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14404775, -0.2824866, -0.023308061, -0.7025126, 0.019822529, 0.076808795, 0.03744327, -0.12685949, -0.09828152, -0.2447139, -0.08874849, 0.30901232, 0.09852054, -0.07536011, 0.10654688, 0.049294587) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.26139688, -0.3225144, 0.28364602, 0.47634792, 0.24218354, -0.25283375, -0.3764541, 0.30431053, 0.14479029, 0.90525687, 0.29199076, 0.6689206, 0.19815823, -0.0045325602, -0.35426334, -0.15673406) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.28855538, 0.7316935, -0.5247367, -0.4014882, -0.10759793, 1.2651169, 0.7853912, 0.031056978, -0.21189576, -0.9704295, -0.3711338, -0.120926164, 0.08193863, 0.5331669, -0.86451745, 0.014894546) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.2360347, 0.12041226, -0.05860945, -0.35014468, 0.07358301, -0.013396315, 0.051456306, -0.23854017, -0.023830399, 0.007846539, 0.07996622, 0.36605445, 0.033441983, -0.22035056, 0.022261001, 0.061868377) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24200143, 0.11432026, -0.09713528, 0.7779458, -0.07081391, 0.076621026, -0.101427756, -0.11126518, 0.16480756, 0.17830992, -0.26756907, 0.1597035, 0.07337049, 0.20134947, 0.079461046, 0.0020566827) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.040917914, 0.34668782, -0.14743245, 0.35541034, 0.17665659, 0.21059203, 0.32333392, 0.25048178, 0.28580028, 0.52241135, -0.14394923, -0.18787573, -0.44973898, -0.40847385, 0.5738967, 0.10194942) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12582459, 0.6773659, -0.19797608, -0.19417813, 0.008216965, -0.073368825, 0.03936478, -0.08337175, 0.004504965, -0.042650234, -0.07829564, -0.02901888, 0.100456305, 0.09926929, -0.32527745, -0.007872351) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.08450709, 0.3417919, 0.3122741, 0.3971833);
      result += mat4x4<f32>(0.062891565, -0.035154574, -0.040213324, -0.036077518, 0.016834188, -0.01845271, -0.043002132, 0.34576896, -0.0015686882, 0.08934518, -0.016510436, -0.013127028, -0.021937588, -0.016041014, -0.29217875, 0.28063616) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.056673035, 0.045354523, -0.18842229, 0.2455589, -0.22329737, -0.0761457, 0.28257105, 0.14839636, -0.27655238, -0.16440482, 0.11090663, -0.26721334, -0.10092968, -0.08991119, -0.09417921, 0.16936964) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.16815192, -0.29636037, 0.1215821, -0.12306359, -0.1655155, -0.104985945, -0.16651098, 0.24960281, 0.20243064, 0.22264299, -0.08532174, 0.099276505, -0.03071181, -0.57932884, 0.33524895, -0.057235166) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3384143, 0.8776829, 0.4762622, -0.42281052, 0.035581607, -0.009589359, -0.05784603, 0.0062016807, 0.31476793, -0.1640355, -0.7873604, 0.34448195, -0.3283507, -0.32102704, 0.15391329, 0.31573743) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18901695, -0.0049410267, -0.239557, 0.6596491, -0.11344989, -0.19617312, 0.43702382, 0.019357692, -0.034709197, 0.31815597, 0.12220514, 0.21163973, -0.09233493, 0.60326076, 0.18076032, 0.7010819) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.4359386, -0.61240995, -0.18184097, -0.19406267, 0.104466595, -0.19213536, -0.18283318, 0.10812311, -0.15461408, -0.3978264, 0.4253245, -0.21442303, 0.09089133, 0.018227264, -0.09510122, -0.78908956) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.064943776, -0.16263793, -0.03591315, -0.13449049, 0.15123469, 0.35534957, 0.19736227, -0.36910093, 0.0605926, 0.09164676, -0.14757787, -0.24066356, -0.22705126, -0.17215645, -0.308361, 0.21624272) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.16813599, -0.29391026, -0.06881435, -0.14523211, 0.1747842, 0.10580392, -0.034143962, -0.3373186, -0.08127833, -0.32645637, 0.083572775, -0.17002627, -0.096185155, 0.08687204, 0.0024753541, 0.03594326) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09886558, 0.4332147, 0.102760024, -0.035073582, -0.13013996, -0.03394756, 0.14239174, -0.30951068, -0.054772485, 0.05909286, 0.20394099, 0.11242447, 0.10302326, 0.13656776, -0.13620329, 0.07311933) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08545751, 0.13521644, 0.22236744, 0.0058391076, 0.073373534, -0.03811485, -0.13563739, 0.060848624, 0.021496948, -0.15487245, 0.14567435, 0.14794919, -0.024399575, 0.16809247, 0.07909519, -0.122870564) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.03646983, -0.1543484, 0.04787635, 0.22451827, -0.029086504, -0.36816213, 0.21020214, -0.020723747, -0.033062775, -0.31643558, 0.33667496, 0.13933189, 0.03311722, 0.2557527, -0.16762662, -0.29351184) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0014179768, 0.09896938, -0.14467688, 0.29896295, 0.10478594, 0.09447065, -0.3321101, 0.20189567, 0.06778294, -0.335077, 0.065176845, 0.11818364, 0.12321549, 0.040360752, -0.026052596, 0.01215628) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15528667, 0.3007948, 0.15466522, -0.13125238, -0.0011526088, -0.2145416, -0.25949463, 0.19492051, -0.042810194, -0.110546015, 0.094603844, -0.060593847, 0.08965021, 0.54611915, -0.12628832, -0.14508155) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.048177995, -0.33341366, -0.3952896, -0.33167624, -0.072270185, -0.20829585, 0.26562828, -0.05919072, -0.19916375, 0.5216693, -0.2601607, -0.21297848, 0.15935789, 0.07628182, -0.626536, -0.41101685) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09219433, -0.06575331, -0.013522432, 0.5338622, -0.11675658, -0.020141236, 0.1739139, -0.042083975, -0.20932962, -0.3081303, -0.22155753, 0.10823611, 0.10005949, -0.22131178, -0.04338208, -0.015605384) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12039096, -0.12127714, -0.045547515, -0.06780454, -0.105913125, -0.052231032, -0.03590728, 0.05444441, -0.10257813, -0.88133496, 0.17971998, -0.21366371, 0.09187696, 0.050347418, 0.039765943, 0.11965761) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10807911, -0.4486831, -0.22748688, -0.39862743, -0.25382468, -0.43794703, -0.11665214, -0.36780158, -0.16655, -0.19180404, -0.18250093, 0.040120374, -0.0856839, -0.34514973, -0.2060091, -0.19742855) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.050142597, -0.052554715, -0.1371245, 0.13286728, -0.11952072, -0.11272502, -0.029464478, -0.2532368, 0.050498135, -0.04354994, -0.07005665, 0.37017587, 0.13163216, 0.34702697, 0.049621545, -0.35162503) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

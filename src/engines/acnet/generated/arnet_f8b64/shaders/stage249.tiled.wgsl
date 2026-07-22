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

  var result: vec4f = vec4f(-0.13468386, -0.11447318, -0.12703995, -0.008447277);
      result += mat4x4<f32>(0.072721705, 0.0296108, -0.053282853, -0.0756035, 0.041861687, 0.07760588, 0.009578137, -0.031667355, 0.094096, -0.069897875, 0.14115481, 0.13980561, -0.073659755, -0.07822606, 0.058230344, 0.085284844) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.45049632, -0.24559194, 0.12105233, -0.24027798, -0.01760484, 0.07916724, 0.15056261, -0.063170455, 0.09299616, -0.020413416, -0.00047453475, 0.06971744, -0.009683858, -0.14839917, -0.12483258, 0.049400136) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20561852, 0.14727499, -0.13828902, 0.0343424, 0.05247972, 0.049287036, 0.011677144, 0.04604259, -0.010039122, 0.0023308836, -0.09451316, -0.09009059, 0.12160255, 0.016639672, -0.09948158, -0.012903294) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12309568, 0.097537026, -0.021435536, -0.0033716126, 0.07575386, 0.046984322, -0.059517436, -0.060294226, -0.13343692, 0.14001106, 0.039062105, 0.08929027, -0.030769171, -0.13142407, 0.07016073, 0.09239246) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17673434, 0.16812544, 0.47729248, 0.6065848, -0.01486235, -0.20039669, -0.36667445, 0.062430657, -0.13026996, -0.3852687, 0.47952688, 0.17294109, -0.04379142, 0.068263106, 0.19293703, 0.07793613) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.03205005, -0.21254705, 0.03976765, 0.07405856, 0.01903478, 0.36115935, 0.042534135, -0.22871828, -0.09908872, -0.09174214, 0.13610736, 0.26164198, -0.01599973, -0.3499841, 0.25332978, 0.2643384) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07669747, 0.07640661, 0.026458787, -0.009203256, -0.0049679116, -0.021741042, 5.7560945e-05, 0.008237302, 0.04890887, 0.24342878, 0.058859717, -0.028891873, -0.06476778, -0.025681743, -0.02821885, -0.023585038) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.11507014, -0.107766464, 0.012137079, -0.044137124, 0.10783151, 0.00027821292, 0.03789303, 0.054956317, -0.1645616, -0.46539444, -0.11875833, 0.13167201, -0.10167993, 0.21799968, -0.0036498518, -0.19334379) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.057235293, 0.04293485, 0.031523645, -0.010502759, 0.13371909, 0.15370832, -0.07957983, -0.029197833, 0.01695185, -0.20290036, -0.08174369, 0.05628788, -0.08930748, 0.050550397, -0.012201732, -0.031996217) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0926091, -0.064594224, 0.043786995, 0.044096556, 0.047711067, -0.048917696, 0.0013663288, 0.049515136, 0.12731837, -0.24994604, 0.10761426, 0.18816301, -0.10585317, -0.029707141, -0.0055699884, -0.06558317) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.04293862, -0.099220246, 0.25189283, 0.029097676, 0.13998823, -0.1341323, 0.07022306, 0.07800743, 0.06691405, -0.333281, 0.1352568, 0.25337297, -0.17307706, 0.09895294, 0.105058804, -0.00034185295) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.1634284, -0.13377292, 0.20845553, -0.064560734, -0.05226582, 0.21825026, -0.08852059, -0.20848386, 0.054120395, -0.036269464, -0.10669575, -0.052136, -0.023376426, 0.15759881, -0.112756245, -0.07205202) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.011839669, -0.28274155, 0.23425047, -0.02512264, 0.15463044, -0.062693745, 0.17212212, -0.02830518, -0.114602834, -0.018110113, -0.14757946, 0.20230576, -0.27000728, -0.017507, -0.046231005, -0.03362008) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.41569722, 0.20510778, 0.47395524, -0.6659392, -0.3611922, 0.14319162, 0.04300541, 0.2831802, -0.20316824, -0.37448958, 0.11345531, 0.16793762, -0.17328973, 0.3492625, 0.15064149, -0.31757015) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.083380386, 0.04142355, 0.05957227, -0.47480872, -0.042990733, 0.2034491, 0.042936537, -0.02462198, 0.08970532, -0.16050766, 0.17621978, 0.06636948, -0.16301955, 0.08507284, -0.03621478, -0.30535927) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.009403003, -0.26624927, 0.02842474, 0.1391798, 0.027071098, 0.088488445, -0.109160006, -0.04780868, 0.040125042, 0.018080905, 0.018775344, 0.023556937, -0.18052366, -0.011625645, -0.07926801, -0.16528012) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.023994545, -0.22787629, -0.04498213, 0.08284116, 0.029202305, 0.32480744, -0.0011493277, -0.32259208, 0.13020124, 0.090528965, -0.040599022, 0.13322327, -0.12282995, 0.024845477, 0.046106625, -0.13837664) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.026093042, -0.07190021, -0.006996819, -0.0112237185, 0.028039493, 0.09637753, -0.014560572, -0.056978907, -0.020681549, 0.07075356, -0.047705702, -0.12756072, 0.043054417, -0.09306066, 0.024319766, -0.0066859014) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

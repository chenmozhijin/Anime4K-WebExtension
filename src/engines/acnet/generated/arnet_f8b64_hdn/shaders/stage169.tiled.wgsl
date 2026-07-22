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

  var result: vec4f = vec4f(-0.003592632, 0.21464984, 0.263035, -0.089629576);
      result += mat4x4<f32>(-0.05982044, 0.31576803, -0.2934634, 0.10184274, -0.016558273, -0.25638703, -0.0058414424, 0.07880234, 0.27039388, -0.35606912, 0.30414045, -0.11244972, -0.29252237, -0.7645925, -0.6574936, 0.32457238) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08261278, 0.1460876, 0.07581065, -0.17041817, -0.051402964, -0.07248557, 0.04996395, -0.060114473, 0.21243614, -0.01658165, 0.29338747, -0.08677814, -0.00821185, 0.060953144, -0.16446003, 0.06833743) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.027592314, -0.0017110744, -0.14878671, 0.086120866, 0.01998528, -0.31068635, 0.034929816, 0.056657385, -0.0045267898, 0.9194274, 0.36249176, -0.29213288, 0.43381765, -0.04800079, 0.42825744, -0.10159317) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.033094056, -0.15713197, -0.086803615, 0.05219582, -0.02377027, -0.23623653, 0.0059075197, 0.033980418, 0.015441387, -0.72818583, -0.28461862, 0.2441391, -0.3774388, -0.39847738, -0.6792839, 0.24392001) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13680784, -0.16281457, 0.41493797, -0.36410147, 0.007899043, -0.39919308, 0.29843634, -0.20100288, 0.030853562, -0.37778938, -0.18090816, 0.28596708, 0.044854052, 0.3265916, 0.42123982, -0.24639136) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.00828388, -0.05006517, 0.067899264, 0.08713332, 0.061986916, -0.13059261, 0.15511502, -0.15924922, -0.23858668, 0.8765552, 0.08029658, -0.21798418, 0.11624216, 0.34739733, 0.3933334, -0.2892735) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04417129, 0.13271052, -0.06495329, 0.08933841, 0.0016032524, -0.226055, 0.077699564, 0.031051086, -0.07276968, -0.69066143, -0.4118922, 0.13870628, -0.34879148, -0.09845864, -0.3547773, 0.1472943) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06796777, 0.03578342, -0.11750218, 0.00042257423, 0.08609101, -0.45599437, 0.1178591, 0.05487326, -0.017723583, -0.22620352, -0.04645516, 0.18625112, 0.08274728, 0.23742536, 0.11055665, -0.09934732) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.027863203, -0.030105446, 0.007908706, -0.016223315, 0.0010183959, -0.17401055, 0.12659168, -0.06766944, -0.21888535, 0.6071026, -0.14922565, -0.16136016, 0.41605383, 0.28314918, 0.5003251, -0.041383818) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0066122347, 0.078815304, -0.059719402, 0.032861542, 0.0067939423, -0.21991657, 0.08109872, 0.017961914, -0.05107412, 0.013338073, 0.12272758, -0.17228302, 0.11503635, -0.93090034, 0.8068171, 0.028793264) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.046862453, 0.14514007, 0.04095574, 0.015483747, 0.004836291, -0.1639659, 0.10289751, -0.0858586, 0.038538735, 0.2890021, -0.2106217, -0.23956217, -0.0416911, -0.15660542, 0.26637483, -0.086070575) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03619665, 0.006572077, 0.102480136, -0.020595344, -0.019865561, -0.011283071, -0.069696516, -0.0445374, -0.03949883, 0.13045827, 0.012672619, -0.090886645, -0.0233956, 0.103140496, -0.09951086, 0.022999203) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.026820514, 0.06795843, -0.2451507, 0.116075635, -0.011961434, -0.19863556, 0.13065144, -0.07131331, 0.0779689, -0.1647584, 0.23409231, -0.11115526, 0.14052671, -0.2077606, 0.18106477, -0.073402144) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.087477304, 0.213146, -0.078226686, 0.19478916, -0.09243827, -0.34321278, 0.03279303, -0.053469088, -0.057728242, -0.3914792, -0.09400678, -0.40545666, -0.12976848, 0.01541399, -0.086004265, -0.040358786) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07024214, 0.08909849, 0.10857969, 0.0096523715, -0.024069684, -0.036399696, -0.12263566, -0.0175096, 0.08607424, 0.043319304, -0.25549152, -0.25734657, -0.027530836, 0.35886624, -0.27732408, -0.06501764) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.045390528, -0.004355717, -0.094745725, 0.08405775, -0.025689147, -0.13502409, -0.073717415, 0.032225773, 0.06777521, 0.0036573983, 0.12184573, -0.04716446, -0.0115711, 0.16014743, -0.16729012, 0.071557604) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.002187347, 0.005389616, -0.08457098, 0.03883609, -0.00025284186, -0.06478493, -0.18912742, 0.0745716, 0.021126777, -0.23995858, 0.12668699, -0.066289864, -0.09197305, 0.3302569, -0.2023502, 0.014098363) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09679707, 0.008870112, -0.03818964, -0.055136345, -0.037210446, -0.06708682, -0.079094976, 0.009838925, 0.039911963, 0.07329856, 0.15425491, -0.030737163, -0.032803874, 0.4031452, -0.2754257, -0.043365482) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

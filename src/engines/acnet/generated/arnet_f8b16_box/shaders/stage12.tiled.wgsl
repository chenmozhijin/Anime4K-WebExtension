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

  var result: vec4f = vec4f(-0.18938614, 0.16399263, -0.098224714, 0.020613838);
      result += mat4x4<f32>(-0.16446526, -0.14278717, -0.14895847, -0.021675559, -0.110974684, -0.23870113, -0.14301486, 0.016082976, -0.03247877, 0.026734034, -0.00833284, -0.06624782, 0.015491849, -0.13774088, 0.05840415, -0.12809812) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.00085558253, -0.024322582, -0.024876418, -0.048776068, 0.09735055, -0.18574128, -0.055500668, 0.076919205, 0.2246056, -0.111163124, -0.03803676, -0.021172652, 0.2629902, 0.10186033, 0.43271026, 0.042124182) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.027616397, -0.12252121, 0.091128364, -0.03557635, 0.14779931, -0.14578779, 0.0955107, -0.0516084, -0.04377778, 0.006339628, -0.010169004, -0.009347006, 0.057063088, 0.006822079, 0.2344858, -0.026626438) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10977276, -0.055446845, -0.02767023, -0.1579446, -0.10145156, -0.29920316, 0.012016143, 0.0378461, -0.07183536, 0.02997346, 0.2559569, 0.16089803, -0.101168476, -0.119434975, 0.07607162, 0.052007243) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.25824976, -0.17595354, 0.23341806, 0.050577242, -0.034539197, -0.80529517, -0.25625682, -0.4029309, -0.62894964, -1.3929783, -0.006083427, -0.9823985, -0.38729417, -1.3288702, 0.23634477, -0.6946923) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0071357167, 0.004656322, 0.2700305, 0.029696506, 0.1275507, 0.009640418, 0.18694837, 0.048521817, -0.009663767, 0.12809354, 0.23578522, 0.07765833, 0.009355733, 0.036253028, 0.220578, 0.055244748) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.19829823, -0.08963145, 0.002601624, 0.017964324, -0.03309646, -0.14858294, -0.12460283, 0.058966987, 0.03156249, 0.17419903, -0.017501857, 0.06928013, -0.110643886, -0.022079086, -0.018206164, 0.007856212) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.009574323, -0.06284926, -0.09048034, -0.007825146, -0.21015468, -0.35156903, 0.0591788, -0.00024668413, 0.031514782, -0.044318654, 0.27451214, -0.052617777, 0.06789177, -0.061331116, 0.08212844, -0.14655963) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1816551, -0.30085018, -0.27662036, 0.17998068, 0.018758528, -0.09222422, 0.18657209, -0.02659081, -0.110305265, 0.05789136, 0.007959161, 0.11391487, -0.0024240634, -0.064175166, 0.16946542, 0.027924612) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08252806, 0.30289605, 0.13696644, 0.046535622, -0.37612033, 0.3899072, 0.4130008, 0.03105072, 0.16414736, -0.046137292, 0.15966748, 0.048135165, 0.01239903, 0.48879024, 0.16905625, -0.15003628) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.03411029, -0.10943069, -0.053052694, 0.04181334, -0.09452972, 0.039479073, -0.43928552, 0.06117022, -0.30519614, 0.12921587, 0.3658355, -0.05706351, 0.2550666, 0.25556296, 0.10777708, -0.027722578) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.010780092, 0.2301626, -0.063615076, 0.021564515, -0.06191987, -0.16493548, 0.020246942, 0.025330441, -0.08863714, 0.042714693, -0.02177039, 0.012003218, -0.1068519, 0.008666628, 0.010474298, 0.0016932205) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.24173261, 0.15812881, -0.28539458, -0.0499647, -0.2991259, -0.15300953, -0.1278775, -0.13383745, 0.28207424, 0.020450657, 0.33507907, 0.30148998, -0.23937231, 0.6940707, 0.012011825, 0.030165806) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18454593, -0.14168751, -0.30497938, 0.13016024, 0.11265137, 0.0872017, 0.19499196, -0.45627093, -0.20254956, 0.11988494, 0.772885, -0.07896853, 0.056895707, 0.098238364, 0.0742385, -0.049045745) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09824719, 0.12089701, -0.066682436, 0.24929355, -0.10594082, 0.10550141, 0.055721007, 0.07142805, -0.056871478, 0.12651786, -0.035459705, -0.11327231, 0.033162583, 0.19795856, -0.20687798, 0.01756811) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08636068, -0.13505733, 0.07893016, 0.018970687, 0.05094867, -0.15916018, 0.3712752, -0.0040304097, -0.09522768, -0.045876812, 0.26756158, -0.07268362, -0.03648, 0.1037341, 0.05915144, -0.0134183215) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21105342, 0.028573807, -0.16984244, 0.15117292, 0.15756592, -0.16006339, 0.0810833, -0.022249097, -0.17646891, 0.21581556, 0.09069333, 0.19048505, 0.097382285, 0.07668513, -0.0155477105, -0.0011884583) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.03931958, -0.10618143, -0.015219146, -0.12297242, 0.08549806, 0.0062396526, 0.029544711, 0.016906034, 0.1606042, 0.103209876, 0.018654425, 0.0755216, -0.0060250154, -0.03818596, -0.032320812, -0.028871328) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

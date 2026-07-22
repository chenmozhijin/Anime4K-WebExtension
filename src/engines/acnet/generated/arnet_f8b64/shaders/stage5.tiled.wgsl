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

  var result: vec4f = vec4f(-0.29904094, -0.06565307, 0.18304166, -0.06525935);
      result += mat4x4<f32>(0.05335687, 0.030568717, 0.24114972, 0.25738454, -0.019755492, -0.21108878, -0.09089572, -0.34130967, 0.301819, -0.23477983, 0.27652383, 0.22712007, -0.10548102, 0.11581335, -0.056927603, 0.31452975) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.02910028, -0.13510893, 0.024694046, 0.1346908, 0.4508326, 0.1089295, -0.14184484, 0.32367858, 0.16766952, -0.250636, 0.5295936, -0.054258797, 0.010226972, -0.0041943938, 0.38954923, 0.2943075) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06266065, 0.25683737, -0.060585916, -0.37790826, 0.31767568, -0.14214079, 0.14050907, -0.44140062, -0.22475421, 0.120895036, 0.5023641, -0.458919, 0.11671455, 0.14384401, 0.07699692, 0.070926584) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.055427186, 0.21206847, 0.06306404, -0.23590194, 0.4091991, 1.0894562, -0.24004078, -0.20298947, 0.27502266, -0.47110868, -0.18586962, 0.5882176, 0.10467807, -0.08585673, 0.42018765, 0.6176967) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.029432349, 0.299106, -0.18997754, 0.5600792, -0.71839064, 0.6712344, 0.5919312, 1.3998017, 0.05202929, -0.26629964, -0.1864225, 0.20782086, 0.2543974, -0.21135153, -0.36146596, 0.3276748) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.029787699, -0.09840666, -0.0649584, 0.29034606, 0.13780268, -0.71419084, -0.17601123, 0.7554705, -0.5255865, 0.41837087, 0.043104835, -0.3092015, 0.13123958, 0.2264679, 0.098506644, -0.0780166) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13546267, -0.20217013, 0.027330913, -0.3837422, 0.10580586, -0.65578836, -0.13960692, -0.66201067, -0.034946226, -0.1208207, -0.59431136, 0.4356672, 0.060031056, 0.23649807, 0.059230756, 0.113420665) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.030363966, 0.15394135, 0.007310358, -0.08357368, -0.050447207, 0.89646757, -0.8254482, -0.45056063, -0.19816038, 0.038938787, -0.53004426, 0.17572378, 0.11060214, 0.2379255, -0.029786805, 0.06614845) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07714216, -0.4583604, 0.1181478, 0.18494532, 0.1217033, -0.9831541, 0.13212709, -0.47224408, -0.42110014, 0.5880366, -0.09053523, -0.12981156, -0.051669814, -0.27114552, -0.1430051, 0.09870866) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1043464, 0.008320907, 0.10702934, -0.21957473, -0.05203995, 0.3790536, -0.065747984, 0.27224755, 0.106443875, -0.01396779, -0.07646282, 0.08762769, 0.01976361, -0.3173609, -0.08716813, 0.00063114165) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13950375, -0.14784546, -0.19541028, -0.4605871, -0.07715711, -0.2177973, 0.117853664, 0.5268832, 0.018376619, 0.0038965933, 0.585399, -0.15163781, -0.077594094, -0.2044408, -0.22295254, -0.03391864) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02742445, 0.08312269, -0.10792806, 0.05167274, 0.01753411, -0.10759272, -0.118584, 0.21709125, 0.05339535, -0.074230336, 0.08640158, -0.11318402, -0.13249621, 0.03602447, 0.3112394, -0.10944306) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.055125844, -0.04760803, -0.20438674, 0.21494989, -0.071717024, -0.081428625, 0.310445, -0.5087716, 0.16457666, -0.28099555, 0.059147432, -0.33589247, 0.08782468, 0.14932226, 0.10863452, -0.052756477) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.15713021, 0.08534867, 0.2590892, 0.2262533, 0.30082765, -0.36816853, -0.15251523, 0.17442244, 0.059623368, 0.17048456, -0.55929023, -0.6394821, -0.07497281, -0.30324548, 0.05783758, 0.02754915) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2017138, 0.24458262, -0.12289386, -0.08600708, 0.3245782, 0.46185616, -0.02140803, -0.29927438, 0.063178174, -0.19404072, 0.06554662, -0.4522766, 0.029406212, -0.4073195, 0.04468685, -0.17701162) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0678459, -0.07441933, -0.07103754, 0.16421585, -0.09138718, 0.052156292, 0.084227964, 0.110795714, 0.15362503, 0.13854684, 0.19840872, -0.03863, -0.030496886, -0.2780385, -0.05489649, -0.10546315) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0070291455, 0.23176746, -0.08984245, 0.069343016, 0.06712224, 0.32716638, 0.21112038, -0.37446958, -0.10609614, 0.0474816, -0.12813395, -0.2686438, -0.0264718, -0.10057339, 0.010886012, -0.30076244) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10189924, -0.06746604, -0.118425585, -0.025403395, 0.11234743, 0.03610056, -0.0008952439, 0.07894887, -0.0556591, -0.046714503, 0.11730156, -0.3466819, -0.13151452, -0.025940588, 0.040354934, -0.510665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

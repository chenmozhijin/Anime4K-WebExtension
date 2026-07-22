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

  var result: vec4f = vec4f(0.032808557, 0.30830234, 0.14928284, -0.2313834);
      result += mat4x4<f32>(0.043249983, 0.12949756, 0.11835212, -0.20131916, -0.07585547, -0.15149371, 0.07065862, 0.2317059, 0.019040674, 0.063687034, 0.021700928, 0.18309224, 0.09205703, 0.029065117, 0.0030662178, -0.097235486) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.024504185, -0.48180598, -0.41603032, 0.29446685, -0.018803041, 0.0029859988, -0.14129071, -0.006236401, -0.0921146, -0.021951033, -0.11878805, -0.1000555, 0.10739865, -0.009494083, -0.028684258, 0.04524735) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.29390788, 0.44460684, 0.19341807, -0.3744312, -0.045321822, 0.11319198, -0.06639253, -0.019456686, 0.029826885, 0.012685289, -0.061142996, -0.08218338, 0.05501434, 0.27590516, 0.16446368, 0.165234) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.020761319, -0.079287045, -0.13076991, -0.14378826, 0.0019145444, 0.09271498, -0.09553309, -0.34839946, -0.027474174, 0.13577184, -0.006735705, -0.14766584, 0.10151498, 0.08779233, -0.07738942, -0.21246104) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14167988, 0.24405384, 0.026371911, 0.31223893, 0.36249018, 0.44278327, -0.46606615, 0.36364132, -0.27465847, 0.25516838, -0.08316363, -0.37303033, -0.31076834, 0.024349673, -0.12063003, -0.10030728) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10544709, -0.09044001, -0.029028378, -0.087386586, 0.116065644, -0.13050562, 0.41475248, 0.1845162, -0.085890934, 0.12824537, -0.23823959, 0.043736786, -0.14764747, -0.03940664, 0.10231783, 0.33355582) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.014138696, -0.08017196, -0.15234278, 0.45103243, 0.1477354, 0.109321356, -0.276336, -0.22218613, -0.08776245, -0.15404055, -0.0025127258, 0.20111, 0.18475571, 0.24534932, -0.05070188, -0.4159635) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.032510597, 0.24952711, 0.32349345, -0.74714357, -0.21264689, -0.06458792, 0.55764174, 0.32475987, -0.29838434, -0.28952906, 0.26099256, 0.26711828, -0.06227004, -0.07786091, 0.023700917, 0.08586566) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09866791, -0.11199414, -0.20207472, 0.40171865, -0.13399823, -0.08567688, 0.02415069, -0.13514493, -0.15173659, 0.14725639, 0.09914533, -0.20840818, -0.032387093, 0.00029763376, 0.06289234, 0.11557147) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.04048186, -0.11540615, 0.006983819, -0.02576153, -0.11721407, 0.07210949, 0.012013768, 0.30379388, -0.068691924, -0.09774622, 0.11326041, -0.006024528, 0.11087415, -0.009752974, -0.047088917, -0.054838423) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15395145, -0.008031296, 0.37361017, -0.000381918, -0.22278684, -0.099387415, 0.3703697, 0.17030382, 0.053842142, 0.04764676, 0.23589125, 0.17707033, 0.0951981, -0.0033686166, 0.13545725, 0.07138505) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.26861063, 0.035407547, 0.28782386, -0.035095863, -0.044303138, -0.234362, -0.20887183, -0.10010933, -0.00016737245, -0.19969872, -0.111798525, 0.036017515, -0.023286957, 0.14766183, 0.20545904, -0.056572665) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13153498, -0.35419932, 0.06340154, 0.14769083, 0.14742583, -0.0016613165, -0.3117652, -0.20567496, 0.36099204, 0.3684464, -0.12454548, -0.5821402, 0.0139539, 0.03859221, 0.0425357, -0.01717823) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.25648767, -0.44469807, 0.45256007, 0.68023056, 0.3501346, -0.040513188, -0.24690226, -0.14028455, -0.0888984, -0.43849757, 0.5550632, 0.11644747, 0.24338879, -0.028651405, -0.53054416, 0.5618781) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.024517097, 0.1805993, -0.54181194, -0.17143224, 0.27796274, 0.2711293, -0.52545923, -0.046966735, -0.015267514, -0.076044, 0.1557787, -0.007542478, 0.1441184, 0.112675205, 0.14139909, 0.2432845) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.171979, -0.08407682, -0.16614895, -0.18090819, -0.048830703, -0.1764735, -0.09916623, 0.14712451, -0.27390635, -0.3511134, 0.20720883, 0.17334838, -0.06349028, 0.059360765, 0.16401021, -0.060890485) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1510146, -0.078278415, -0.25331458, -0.28102836, -0.09188525, -0.06983275, 0.19152549, -0.10335491, 0.24408396, -0.15155879, -0.6594833, -0.004283912, -0.2500631, 0.08061026, 0.26014158, -0.038374748) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15278001, -0.028913887, 0.058124762, 0.30457687, 0.02326151, 0.048153274, -0.08969892, 0.04650626, 0.04505728, 0.025005396, 0.08857896, 0.12151893, -0.16269638, -0.11228686, 0.47941273, 0.058801193) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

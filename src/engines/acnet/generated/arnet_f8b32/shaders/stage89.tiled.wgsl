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

  var result: vec4f = vec4f(0.42074397, -0.055067293, 0.120411634, 0.0028705818);
      result += mat4x4<f32>(0.095704824, -0.3265707, -0.027527705, -0.03477763, -0.08391429, 0.02361911, 0.013431639, 0.16781045, -0.07834648, 0.19453727, 0.1288495, -0.109448016, -0.20788567, 0.3635205, -0.3124947, 0.012252013) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15438673, -0.25443467, -0.14512542, 0.12131639, -0.007336529, 0.18764614, -0.04017205, 0.098182835, -0.10015318, 0.0757506, -0.11688926, -0.09874048, -0.00070450077, 0.009606419, -0.086287655, 0.04356505) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15249844, 0.052219592, -0.053522244, -0.17246296, 0.03546995, 0.0044558463, 0.092212036, 0.16210477, 0.096873656, -0.2357483, -0.09484809, 0.2108201, -0.24611613, 0.34838626, -0.3589168, 0.050254468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13667467, -0.15869583, 0.12119874, -0.0543232, 0.024129253, 0.071261965, 0.06612091, 0.07749422, 0.07822682, 0.32677883, -0.18256639, -0.59628147, 0.10139017, -0.19210428, 0.14228043, 0.06743755) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3502511, -0.57412606, 0.68358594, -0.29240492, 0.44535396, 0.41941077, -0.13263778, 0.28724834, 0.07078309, -0.6672185, -0.46676537, 0.64171755, 0.21332274, -0.3408835, 0.4554374, -0.17044704) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.028653035, -0.23492664, -0.086348824, -0.06937803, 0.16696031, 0.41812876, 0.01804202, 0.1823948, -0.029059691, 0.025356643, 0.14844199, 0.13174732, -0.0023671535, 0.01972679, 0.045544125, 0.009175898) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07935105, 0.091074646, -0.042370133, 0.16703303, 0.012030928, -0.04464039, 0.06479923, -0.012399483, 0.12079224, 0.3405134, -0.017787168, -0.32099208, 0.22154222, -0.3771744, 0.39852053, -0.077338174) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10108846, 0.12667198, -0.061046887, -0.19691978, -0.12423388, -0.43356752, 0.21044055, 0.4918501, -0.006960914, -0.2080401, 0.19144529, 0.09025004, 0.18656501, -0.26022512, 0.24911414, -0.019810619) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.017582798, -0.08652475, -0.025271853, 0.19586761, -0.01786179, 0.26851624, 0.034934472, 0.3061587, 0.18386582, -0.037262868, -0.08979135, 0.012488281, -0.002860217, -0.013389258, -0.0452152, 0.0463435) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.014603193, -0.13987888, 0.065891266, 0.12620264, 0.13558087, -0.053142034, 0.1567581, 0.3673787, 0.017848134, -0.08338619, 0.0039780135, 0.004869063, 0.04080951, -0.101107836, -0.044587415, -0.02900995) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08703675, -0.24408162, 0.3533213, 0.28031453, 0.29212964, -0.1189095, -0.10455163, -0.2665388, -0.10326227, 0.122566074, -0.32280782, 0.35862952, -0.121104, 0.23501717, -0.13954587, -0.20059581) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.052719865, -0.11419049, 0.061634727, 0.13303174, 0.008282625, 0.1818401, 0.025738904, 0.16132861, 0.14535798, -0.022179002, 0.057475932, -0.04426635, -0.19372365, 0.11722095, -0.06964216, 0.01926395) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14846505, -0.10496435, 0.2038096, 0.18418564, 0.029530352, 0.4084674, -0.045090184, -0.18674535, -0.023947297, -0.32540414, 0.22403218, 0.16494583, -0.17730924, 0.173988, 0.07548675, 0.15136813) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.075715765, 0.64365506, 0.3579963, 0.18457608, -0.44178215, -0.7460194, 0.27133638, 0.7031737, -0.6147012, 0.30715346, 0.17639548, -0.19102366, -0.114297114, 0.34022027, 0.26161832, 0.25048777) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.21429306, -0.115212545, 0.18936475, 0.05041105, -0.08789444, 0.5553138, 0.3626252, -0.11906725, 0.01604244, 0.08879605, -0.19686948, -0.1518686, -0.003303628, -0.1761736, 0.23083541, 0.388218) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.026508827, -0.10183586, 0.15335087, 0.33104998, -0.11226741, 0.11177914, 0.046453644, -0.005147183, 0.080414645, -0.08824789, -0.09616253, -0.0073244935, 0.01850996, 0.21622159, 0.011247025, 0.053914856) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.043215856, -0.16936643, 0.3675166, 0.26911998, 0.08568231, 0.05471586, 0.03594954, 0.0019808337, -0.039431173, -0.20486549, 0.07397031, -0.31948236, -0.050758023, 0.265093, 0.159229, 0.14223552) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.02753546, 0.13456348, 0.057186693, 0.21426411, 0.027013147, 0.34997323, 0.07110518, 0.032666128, -0.027165167, -0.18472107, 0.107912906, -0.13814098, -0.018221091, 0.07853857, 0.08854155, 0.16858734) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

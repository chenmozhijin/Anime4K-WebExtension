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

  var result: vec4f = vec4f(0.24495272, -0.07007508, 0.3795133, -0.06830812);
      result += mat4x4<f32>(-0.013820993, 0.5992946, 0.61686254, 0.5046483, -0.009978182, 0.16480733, 0.076489165, 0.0023274512, -0.19636971, -0.077608176, -0.20944574, -0.047459565, -0.04955609, 0.10097475, 0.09623508, -0.15672392) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09415502, 0.14994906, 0.084058985, 0.24767178, -0.18310332, 0.26794744, 0.2581626, 0.12661684, -0.013559347, 0.12435808, -0.046205107, -0.059717625, -0.07572012, 0.11115373, 0.10845584, -0.11245298) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.099618636, 0.57408625, 0.31758377, 0.23709747, -0.13341129, 0.123836406, 0.13693586, 0.10637224, -0.13220994, -0.09945614, -0.056805085, 0.056778546, -0.18206389, 0.108935565, 0.11052119, 0.13172412) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.300214, -0.45093268, -0.4227553, 0.28167275, -0.007056018, 0.28998828, 0.11047244, -0.1918207, -0.26509315, 0.05672452, -0.10868561, -0.24360958, -0.101902224, -0.030832913, -0.015503314, -0.069252) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15525284, -0.32846728, -0.13090833, 0.1618271, -0.19584218, 0.26782528, 0.20366004, -0.13214253, 0.07468271, -0.053424075, -0.18383417, 0.25821608, 0.01335584, 0.11418901, -0.115375936, -0.24029168) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.4808478, 0.15051237, 0.026976056, -0.64513934, -0.21049389, 0.19297577, 0.12141376, -0.08688819, -0.112885796, 0.06519495, -0.0837265, -0.0934108, -0.23925315, -0.050147846, -0.07330707, 0.42104656) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03713847, -0.24600385, 0.011061563, -0.04790723, -0.06264988, 0.15279989, 0.0559951, -0.08000355, 0.34374872, -0.07606294, -0.023426108, -0.19444987, 0.034908995, -0.009303715, -0.013447114, 0.051436625) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0025656577, -0.34366593, -0.21194082, -0.28253475, 0.007427971, 0.22796822, 0.025293047, 0.025272423, 0.32571012, -0.070221476, -0.013420067, 0.08158225, 0.17781186, -0.15088014, 0.11526268, -0.1385252) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.091790825, -0.27244267, -0.34842023, -0.37706068, -0.10595922, 0.20830044, 0.16543244, -0.023356788, -0.082947925, -0.008963632, 0.08532346, -0.15678789, 0.19610475, 0.044796996, 0.010572269, -0.02114652) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.39486855, -0.22333041, -0.19000165, 0.23398682, -0.12619524, -0.053590834, -0.13039225, -0.07991478, -0.26299408, 0.09366063, 0.21946457, 0.01876686, -0.17634086, 0.43558145, 0.20066234, -0.60454595) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.6201506, 0.008692107, -0.29137093, -0.26635954, 0.21623176, 0.12900202, 0.25216758, 0.37440237, -0.5095587, 0.27062082, 0.4307969, -0.44673023, -0.29908887, 0.18243165, -0.046714984, -0.55152184) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.22584791, -0.062277094, -0.2698191, 0.13255519, -0.17299916, -0.12895723, -0.091399655, -0.023395415, -0.43288246, 0.05730887, 0.3099576, 0.051959276, -0.23664385, 0.0758861, -0.043493517, -0.6352265) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.02274163, 0.10241543, 0.22445658, -0.24614961, 0.059277438, -0.14816985, -0.08388122, -0.049362734, -0.23897065, 0.046350032, 0.055112973, -0.06296629, -0.09201009, 0.023619838, -0.043429647, 0.25795615) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.69453603, 0.30367157, -0.024532469, 0.07002451, 0.027391953, 0.2835983, -0.6728978, 0.5243362, -0.0043828236, -0.06141751, 0.09407723, 0.1174739, 0.02247763, -0.20595863, -0.28258803, -0.3699657) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.21410061, -0.08664833, 0.15330057, -0.13079058, -0.15647681, 0.10165277, 0.11633601, 0.0068243095, 0.12785093, 0.044114985, -0.09523515, -0.25991684, -0.12150096, -0.13865393, -0.12475863, -0.0384283) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.34163144, 0.03575796, -0.12947237, -0.4342394, 0.008056156, 0.046704214, -0.092015736, -0.032421157, -0.16864258, -0.050358746, -0.052012675, 0.025806064, 0.33278614, 0.030524028, 0.19546507, 0.73679996) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.55593735, 0.06849087, 0.44325224, 0.56681657, 0.015643228, 0.062098823, 0.08308124, 0.09588522, -0.067933984, 0.062137693, 0.08032901, -0.017765116, 0.13474034, -0.048502978, 0.11650745, 0.4400022) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.16713613, -0.16361327, -0.18862675, -0.06785059, -0.11388128, -0.06482534, 0.14631666, 0.124779545, -0.074318394, -0.1033091, -0.03296007, -0.018265488, 0.36436528, -0.33239612, -0.043281585, 0.5406612) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

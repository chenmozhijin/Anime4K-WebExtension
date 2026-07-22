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

  var result: vec4f = vec4f(0.041761126, -0.11467267, 0.2628649, 0.042916648);
      result += mat4x4<f32>(-0.013321057, 0.20999917, 0.013907664, -0.058619346, 0.13303074, -0.08560824, -0.0776216, -0.2137775, -0.025390323, -0.26091, -0.002649693, 0.22698972, 0.11396897, -0.42894745, -0.21649404, -0.083411746) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0014332837, 0.06477417, 0.057864368, -0.44566104, 0.47977614, 0.38757747, 0.69045407, 0.31479925, -0.16824624, -0.21567585, -0.11706529, 0.024819093, 0.38838282, -0.06497935, -0.20457098, -0.11814037) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.016144188, 0.13267085, 0.21263616, -0.24750355, -0.07298445, 0.12180837, 0.04375129, 0.08182808, 0.06525043, -0.1941219, -0.12633231, 0.23178324, 0.21003446, -0.09343896, 0.26400703, -0.03422537) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14906242, -0.029522546, -0.044313595, -0.37446615, -0.13031219, 0.689696, -0.1450526, 0.07912878, 0.0774965, -0.3560517, 0.10211715, 0.19195062, -0.18694583, -0.14076689, 0.1239417, 0.08114789) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15878151, 0.07179432, -0.55758744, -0.57051414, -0.32016376, 0.3146935, 0.37219694, 0.39684865, 0.03419654, -0.43045253, 0.31312194, 0.195225, -0.021566605, -0.16748966, 0.11689006, 0.3072434) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13179083, 0.1522539, -0.24157283, -0.27441338, 0.035904292, -0.09153082, 0.20996244, -0.22095634, 0.046884846, -0.3830441, 0.20164633, 0.37206537, 0.0005532829, 0.022741709, 0.108081795, 0.19188452) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.071286716, 0.2010016, 0.0662244, -0.09257873, 0.26991186, 0.3632703, -0.26352376, -0.065214284, -0.0006581354, -0.46326458, -0.3213515, 0.2750428, 0.11691706, 0.21187305, -0.41732666, -0.28451973) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0101053165, 0.014047459, 0.1049611, -0.041732173, 0.019726748, -0.12263513, -0.68200475, 0.059627652, -0.1330252, -0.13524324, -0.27917457, 0.475303, 0.14888822, -0.15205914, -0.061209828, -0.1744836) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09525796, 0.17107116, 0.1734684, -0.18392402, 0.020860069, -0.15346442, 0.11681021, 0.20288914, 0.024066426, -0.11300949, -0.07885505, 0.15859678, 0.03879822, -0.10734032, -0.08884795, -0.020508796) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.10529278, 0.42996517, -0.102488324, -0.19435032, 0.026558049, 0.09126188, 0.24045353, -0.058105856, 0.10428082, -0.2951398, 0.004839219, 0.07587741, -0.06864657, 0.23589048, -0.3341649, -0.06960654) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.119892925, 0.22838342, 0.050188456, -0.056645695, -0.030699693, 0.15980333, 0.11946979, -0.07856489, 0.09163393, -0.32506528, -0.020322926, 0.3075723, -0.08289098, -0.040360004, -0.44949484, -0.031858634) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20966685, 0.17427541, -0.13864203, -0.57385063, -0.08168876, 0.008231707, 0.12464829, 0.008691776, -0.028954944, -0.4036411, 0.045488242, 0.31479973, -0.087272756, -0.16011247, -0.27829584, -0.024486486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.029187212, 0.42303225, 0.22809082, 0.4505416, 0.11153173, 0.0023361307, 0.26782817, -0.10160722, 0.0017732427, 0.02799701, -0.20341523, 0.22366199, -0.21663816, 0.19310062, -0.19951628, 0.52270854) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24954395, -0.8189189, -0.15225655, 0.46004936, -0.046738546, 0.2776651, 0.28992665, -0.013606591, 0.0019034903, -0.09733504, -0.33451957, 0.4283835, -0.48914227, 0.03604624, -0.39830586, 0.3286497) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09808039, 0.026152326, -0.4138018, -0.04032707, -0.034328256, 0.18637136, 0.2988329, -0.25901577, 0.06516314, -0.1603488, -0.13338193, 0.22108462, -0.1326177, -0.056860745, -0.20465127, 0.010756439) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07271102, 0.28675, -0.17074753, 0.025569579, 0.17728353, 0.12342609, 0.066918746, -0.042040903, 0.05488205, -0.22596905, -0.065593295, 0.09546875, -0.2605327, -0.10628438, 0.058474824, 0.24529861) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12389578, 0.09130622, -0.17883827, 0.23532611, -0.13343726, 0.009003398, 0.09568387, -0.28822708, 0.06966923, 0.014957055, -0.1927699, 0.04991451, -0.33430985, 0.037588004, -0.30837405, 0.31497723) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.047372922, 0.1394521, -0.16884136, -0.051847257, -0.10699273, 0.22957632, 0.42222393, -0.41204873, 0.038836684, -0.098930776, 0.041865963, 0.014248918, -0.15291898, -0.015624645, -0.092570364, 0.14339325) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.09232616, -0.20245576, -0.4363415, -0.11605022);
      result += mat4x4<f32>(0.11833874, -0.15594056, 0.213628, -0.03235553, 0.24192014, 0.38190627, 0.10876762, -0.03209343, 0.020133417, -0.3209667, 0.16358384, -0.065869994, 0.10356247, -0.3997192, 0.45395043, -0.3834172) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.040434774, -0.3817013, 0.052942336, 0.08216153, 0.09001479, 0.18132539, -0.13732143, 0.17217667, -0.12374864, -0.49149188, -0.33380118, 0.16712122, 0.25462797, 0.39263344, -0.5534709, 0.18041767) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06690861, -0.05928371, -0.006728639, -0.10977531, -0.09335654, 0.32841548, 0.24410035, 0.099890344, -0.015454028, -0.110714965, -0.31684792, 0.023561208, 0.14886537, -0.07770452, -0.27039683, -0.29156876) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.29017404, -0.22813334, 0.27238572, 0.067124225, -0.10067098, 0.42761603, -0.034022618, -0.16274182, 0.10217862, -0.4554765, -0.026946418, -0.2214765, 0.0782946, 0.30289158, -0.26722944, 0.08271871) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5948322, -0.19209555, 0.3093096, -0.33891994, -1.0194035, 0.359784, 0.45504943, 0.24455075, -0.7809122, 0.57016116, -0.36418813, 0.017180763, -0.1790116, -0.7524476, 0.5262921, 0.11275517) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.035151843, -0.17013308, 0.008402583, 0.008148985, 0.8589961, 0.99334246, 0.19298466, -0.40686518, -0.30341828, -0.51802635, 0.124934584, -0.07227297, 0.026500132, -0.043907713, 0.44419366, -0.29374585) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1642572, -0.2422605, -0.020032533, -0.03764478, 0.36535472, 0.11696281, 0.055718586, -0.11785457, 0.0158112, -0.110571235, 0.14283371, -0.0774079, 0.1488091, 0.05128569, -0.16708986, -0.026579073) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.31384507, 0.23294507, -0.19970451, 0.016432673, -0.21410325, 0.101125486, 0.041596416, -0.19711794, 0.11037166, -0.32318938, -0.034654953, 0.057541747, 0.20422125, -0.02591101, -0.22667512, -0.41700238) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0028313193, 0.26413128, 0.1928581, 0.034345753, 0.25475967, 0.215956, 0.22036152, -0.1672613, 0.013620251, -0.052918293, -0.1026138, -0.026945153, 0.08058739, 0.015311793, 0.13919246, 0.26341668) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.29113406, -0.20528518, -0.13743839, -0.097728744, -0.019213716, -0.2579852, 0.07087, -0.10944299, -0.02161163, -0.23250373, -0.13673669, 0.07734428, -0.23475797, 0.29043603, 0.2476485, 0.07160212) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.17806992, 0.11157286, -0.4308754, 0.44011664, 0.028209968, 0.39019343, 0.09135013, 0.103048645, 0.053516485, -0.061493177, 0.0005072575, -0.060664725, 0.20329839, 0.38805777, 1.0197923, -0.0914363) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05651741, -0.36456808, 0.34377915, -0.34668702, -0.055086512, 0.009203734, -0.21214215, 0.03317762, 0.21175814, -0.20501995, 0.18868569, 0.0033285075, 0.16479167, -0.09430116, 0.40990406, 0.048913293) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.032990463, 0.20448638, -0.3878304, 0.21711497, -0.029085578, 0.33821645, -0.066981055, 0.2580253, -0.08960814, -0.15197201, -0.3245874, 0.19168322, -0.16632842, -0.40035194, 0.60621893, 0.0012893459) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.490443, 0.32434237, 0.96550965, 0.6957331, 0.24083962, 0.8098784, 0.66533643, -0.28489104, 0.29369578, -0.39869767, -0.08774687, -0.7631301, 0.83563054, 0.10385602, 0.012586248, -0.2345856) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09645555, -0.0423024, 0.050448094, 0.03122992, -0.22872472, 0.19656278, 0.071568824, 0.031658545, -0.021906992, -0.3678097, -0.15285015, 0.03144294, 0.17154536, -0.21257195, 0.016984845, 0.06068917) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03856639, 0.021519242, -0.07102374, -0.090466395, -0.06520406, -0.008190124, -0.16817981, 0.2790458, -0.11150192, 0.22309141, -0.08019444, 0.07511453, -0.27323103, 0.10622543, 0.21868774, 0.078837566) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.057990994, -0.13232361, 0.25115633, 0.23343034, -0.20569958, -0.6324209, 0.2551435, -0.2456088, 0.1558984, -0.009190216, 0.08284179, 0.18173972, 0.024502292, -0.15918744, -0.25612336, -0.037487928) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16174325, -0.06332727, -0.04267442, 0.0927908, 0.03082975, 0.028167918, 0.15775767, 0.042220827, 0.020110367, -0.14264373, -0.047752455, 0.053357285, -0.23481274, -0.3923661, -0.25971916, 0.16840243) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

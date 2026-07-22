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

  var result: vec4f = vec4f(0.22999492, -0.1344817, 0.02003956, -0.22203259);
      result += mat4x4<f32>(0.3126546, -0.046459146, -0.19642256, 0.62234694, 0.23535934, -0.001051165, -0.10650763, -0.07782194, -0.35063177, -0.04664899, -0.2050805, 0.10842362, 0.009413728, -0.07358274, 0.11046679, -0.045924943) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21955825, 0.11154116, 0.21300021, -0.048240505, 0.63286996, 0.08311777, -0.045479823, 0.28170657, 0.23252085, -0.21855769, -0.18348624, 0.59921867, -0.04051313, -0.11326959, 0.1891251, 0.3637626) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.22448047, -0.19612545, -0.23406547, -0.34758422, -0.13871098, -0.124507315, -0.0969236, 0.07561507, 0.1592405, 0.18440163, 0.2355853, -0.15321113, -0.049229667, -0.029690465, 0.21456058, 0.17537801) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2794623, 0.1335468, -0.23886606, 0.28702587, -0.18937565, -0.13215145, 0.054968007, 0.24297425, -0.43751058, 0.19032903, 0.18669511, -0.41638467, 0.0012790146, -0.21800788, 0.1294602, -0.21826798) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-1.118475, 0.14052345, 0.27018616, 0.13958451, 0.41178513, -0.17574108, -0.42046028, -0.14322641, -0.22821975, -0.22581497, -0.23083974, 0.38173205, 0.08187117, -0.4294446, 0.14452253, 0.09167016) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.8431928, -0.27048865, -0.26596504, -0.4616536, -0.0061753904, -0.019758636, -0.25826812, 0.20892584, -0.3171938, 0.17868426, 0.32989734, 0.31750226, 0.25052825, 0.25629914, 0.055549867, -0.05419857) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16882534, 0.11112186, -0.06657343, 0.27978492, -0.17561291, -0.18062332, -0.3407408, 0.3892469, 0.21833996, 0.07527742, 0.30871043, -0.09667835, -0.17678246, -0.026264494, 0.20428863, -0.36753535) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2676698, 0.12128099, 0.3945215, -0.29014468, -0.15639801, 0.17024809, 0.28611645, -0.08503641, 0.34332648, -0.10592291, -0.6216092, -0.08470869, -0.31193605, -0.10889191, 0.37454352, -0.07646757) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10871516, -0.051868506, 0.360805, -0.30094585, -0.22223306, -0.07157742, -0.1382899, 0.08557967, -0.017587459, 0.0650418, 0.17854954, -0.10637176, 0.103886776, 0.1924016, -0.001950353, 0.12502912) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.20477644, 0.0076884427, -0.20650207, 0.04880598, -0.104108535, -0.026845396, -0.3306153, 0.19135933, 0.014567607, -0.07846592, -0.124795884, 0.035258897, -0.081785865, -0.04464748, 0.20624366, -0.12345667) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.31972513, 0.040415566, -0.38009417, 0.5024635, 0.1401465, 0.05003893, -0.2886716, 0.12247281, -0.22573556, -0.043218005, -0.11661873, 0.009968511, 0.20549528, -0.0026962108, 0.16157988, -0.086955436) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14179361, 0.022276523, -0.027768372, 0.08226651, 0.0041111344, 0.13564815, -0.011111944, 0.074162126, -0.06611906, 0.040559247, -0.094241776, 0.077195905, 0.12757446, 0.13591321, 0.1935289, 0.06300887) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.124405205, 0.28316915, 0.060761053, -0.25375956, -0.3885856, 0.0057880576, -0.250497, -0.08360085, -0.1580718, -0.016457722, -0.38986558, -0.01672798, 0.06287303, -0.0069655795, 0.2973266, -0.2946845) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.35503072, 0.20303753, -0.3051386, 0.2960482, 0.3326717, -0.08659498, 0.38168237, -0.20187381, 0.40498796, -0.56723595, 0.018233774, 0.20332804, 0.19942631, 0.27981064, 0.3642279, -0.042837877) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.39116922, 0.062065467, 0.3457577, 0.30805412, -0.43765277, -0.11854527, 0.06745501, 0.07402179, -0.28125435, -0.13215606, -0.185296, 0.13416427, 0.10997121, 0.1854051, 0.16256587, 0.18185608) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.053347528, 0.032304876, 0.15317993, 0.0733558, 0.028550945, 0.022269825, 0.21310261, -0.09811991, 0.043020304, 0.04403015, -0.61532, 0.26414832, -0.0022478944, 0.13083407, 0.4015851, -0.091135055) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17890048, -0.119228795, -0.13490956, 0.06314061, 0.46886292, -0.21758994, 0.044792663, 0.025703033, 0.44847852, -0.07317385, -0.10512985, 0.05350821, 0.2262343, 0.055636384, 0.013514648, -0.18765152) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.20939414, 0.14954084, 0.0039633783, 0.16491877, 0.3016414, -0.040490687, -0.01516464, -0.07056444, -0.2423103, 0.028817318, 0.07840712, -0.05681858, 0.2466386, 0.025068741, -0.34972662, -0.121462256) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

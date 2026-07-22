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

  var result: vec4f = vec4f(0.17272478, -0.22529632, -0.27531812, 0.12817661);
      result += mat4x4<f32>(0.054423574, -0.05009907, 0.11061064, -0.018102635, -0.30912042, -0.2729513, -0.1235462, -0.013354542, 0.14383708, 0.018660389, 0.15323707, -0.1850994, -0.3521077, 0.106353834, -0.11944328, 0.23773973) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09872298, -0.099879935, -0.10781322, 0.10647188, 0.07519928, -0.24210091, 0.22391155, 0.01586964, 0.16981013, 0.2997224, -0.11266589, -0.07045774, -0.0489889, -0.26742792, 0.58834225, -0.010700485) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.2805712, -0.14051685, -0.021773035, 0.05555917, -0.01666577, -0.2817921, 0.28429633, -0.15429899, 0.13384925, -0.035469227, -0.07613826, -0.09961838, 0.1371393, 0.4816879, 0.19188088, -0.035562392) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.015135393, 0.13653539, 0.025160253, 0.08410962, -0.33520937, 0.45663738, 0.16552296, -0.08225624, 0.06909511, 0.2863679, -0.098951, -0.15829597, 0.17759626, -0.042814795, 0.15287973, -0.10307162) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.76535004, -0.3789551, -0.021910258, -0.21449998, -0.39009303, 0.04178742, -0.5964211, 0.19924258, 0.66496557, 0.47799262, 0.20564146, -0.51982474, 0.096833006, -1.0597694, -0.30209747, 0.22843249) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.26647002, 0.14580432, 0.17917663, 0.022441216, 0.19252145, -0.17401628, 0.14182708, -0.19049262, 0.084747724, 0.07137862, -0.04431757, -0.20020886, -0.013162756, -0.6361139, 0.008125551, 0.057111677) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04760221, -0.33156905, 0.06756588, -0.04161742, 0.058132067, -0.27139866, -0.021456655, 0.15719984, 0.04709267, 0.25647822, 0.22679709, -0.22216599, -0.25566772, 0.24675211, 0.12478884, -0.20674361) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13591328, -0.08048748, -0.3191043, 0.28065377, 0.26199913, 0.13563454, 0.020224242, -0.032164723, 0.15915735, -0.027401514, -0.0854574, -0.17511865, 0.016583966, -0.0030383042, 0.10845701, -0.4064204) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.008131989, -0.04018645, 0.21583505, -0.034035347, 0.056063432, -0.14969431, -0.20725468, 0.44330472, -0.04737297, -0.02047732, 0.026848854, -0.12352208, -0.07112207, 0.084061235, 0.11547868, -0.029093135) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.09170435, 0.030319633, 0.35968423, -0.069625884, 0.037364013, 0.091920584, 0.0057879323, 0.04221988, -0.4105216, 0.13812712, -0.097553186, 0.25888854, -0.04654764, 0.015851595, -0.01785319, 0.008598069) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16789632, -0.27737793, 0.10202388, -0.25348288, -0.17320728, 0.08608184, 0.11416451, -0.11099141, -0.16137579, -0.30411652, 0.019403221, 0.062374756, 0.21175613, -0.19233947, 0.28866628, 0.016475938) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.038741596, 0.13790901, 0.0913084, -0.09771707, -0.018894529, 0.15591483, 0.17814498, -0.14524493, -0.11118046, -0.029253967, 0.079755366, 0.034325164, 0.07055952, 0.27573764, 0.18504913, 0.14890194) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14547746, 0.80273145, 0.60993946, 0.2892466, -0.12229195, -0.13592747, 0.09350689, -0.035211176, -0.3009271, -0.026571201, -0.24270357, 0.39016336, 0.13296676, 0.09237321, 0.20651403, 0.009597375) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.045896832, 0.3551109, -0.112225585, -0.08638867, -0.26850495, 0.1361152, -0.02772036, 0.09823712, -0.549686, -0.22419867, 0.12708788, 0.22919825, 0.20645954, 0.19458699, -0.37611213, 0.3489244) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08006706, 0.03367564, 0.14060916, -0.13213213, 0.05938591, 0.22165887, 0.1938029, -0.20831507, -0.16724057, -0.042572163, 0.07211339, 0.1381835, 0.7078495, 0.24612288, 0.4070705, 0.3981198) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1463125, -0.12760162, 0.06933897, -0.23326081, -0.026998501, 0.08395047, 0.10820033, -0.10296642, -0.24298006, 0.28729534, -0.1635469, 0.1975134, 0.02829611, -0.052955016, -0.049257554, 0.07499661) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.08270885, -0.3150085, 0.011769197, -0.025845878, -0.25044304, 0.17884785, 0.29620993, -0.022385443, -0.16443193, 0.17465627, 0.0034368322, 0.19523664, 0.14297052, 0.31288594, -0.13575593, 0.14062811) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.045876354, -0.25593898, -0.16675887, 0.015408884, -0.03182497, 0.050902095, 0.29095247, -0.22584945, -0.12581818, 0.07405925, -0.12858497, 0.26637143, 0.19823165, 0.2642527, -0.116454445, 0.13088556) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

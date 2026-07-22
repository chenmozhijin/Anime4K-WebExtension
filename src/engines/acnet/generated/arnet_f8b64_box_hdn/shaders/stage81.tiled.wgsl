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

  var result: vec4f = vec4f(0.00057511765, 0.14219645, 0.050972156, 0.11567961);
      result += mat4x4<f32>(0.057492703, -0.11726788, 0.31922457, 0.23480107, 0.08373774, -0.034227997, 0.14525953, -0.038282827, -0.07308369, 0.112498574, -0.13039777, -0.032357752, -0.17209724, -0.20293957, -0.05919788, -0.12949438) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.017744564, -0.1720782, -0.3545446, -0.097277604, 0.105513215, -0.32053164, 0.36485556, 0.14876604, 0.12937215, 0.18748273, -0.120995894, 0.009626233, 0.21580471, -0.013879092, 0.09457449, -0.18602368) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04125678, 0.0233143, 0.014224526, 0.057712894, -0.046246354, -0.048237126, -0.006473725, 0.025277633, -0.021100635, 0.21883895, -0.10189792, 0.1358755, -0.14282924, -0.014529114, 0.05248909, 0.043215) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.089040615, -0.36328757, -0.12646586, 0.49848932, -0.0682472, -0.16598563, -0.029597202, 0.050950903, 0.057134006, -0.10112916, -0.021299388, -0.19979012, -0.18525654, -0.21646555, -0.020230824, -0.28765976) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.06663218, -0.56885844, -0.09655046, -0.5785562, 0.064875424, -0.033316445, 0.27221996, -0.110300094, 0.08951675, 0.7081524, -0.055503547, -0.38511202, 0.0440913, -0.34856662, -0.102726944, -0.041959856) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.062736705, -0.22445397, 0.069699824, 0.3070424, -0.05198485, -0.055107556, -0.13112186, -0.11714421, 0.23726448, 0.4062511, -0.06384275, 0.087653264, -0.18244237, -0.34644166, -0.20206828, 0.08704482) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.108793996, -0.25176838, -0.0635138, 0.12051795, 0.105394706, 0.060241923, -0.035012648, 0.07146173, -0.15736459, -0.7931865, -0.23587868, -0.04072072, -0.04477517, -0.2760793, -0.015433509, -0.10947518) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.04760141, -0.04423155, 0.110712536, -0.15673347, -0.100075565, -0.0035561938, -0.006731563, 0.023919145, -0.11373854, -0.31846884, -0.0037933378, -0.23766543, -0.041205037, -0.23683631, -0.17233106, -0.028129853) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.055660866, 0.036655728, -0.072102316, -0.032396752, 0.033379514, 0.00096968235, 0.041913465, -0.04650073, 0.26480344, 0.14172669, 0.0674917, -0.085798554, -0.05588419, -0.12842788, -0.016391518, -0.090876244) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.016741227, 0.19154963, -0.0023645214, 0.050397206, -0.24447207, -0.06394757, -0.04608698, -0.23784481, -0.061123956, -0.30149472, -0.02032135, -0.28645858, 0.02225741, 0.1814011, 0.01382636, 0.11626708) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.052066535, 0.25600877, -0.019540763, -0.025632579, 0.17931235, -0.044007473, -0.23017597, 0.16308928, 0.08288023, 0.12659709, -0.011875545, 0.2613161, 0.09380925, 0.38058996, -0.13358758, 0.09776672) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06567237, 0.06031961, -0.059233494, -0.08511143, 0.09434148, -0.34396008, -0.21148968, 0.17740947, -0.11473503, -0.16390027, 0.13210763, -0.42019215, -0.017494755, 0.20344876, -0.019846357, -0.092251316) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.007845736, -0.26109627, -0.0034927519, 0.07561632, 0.13586165, 0.19098139, 0.12329893, -0.38125232, 0.051189683, -0.098935395, -0.01903094, 0.1805161, 0.069343664, 0.028804671, -0.047646448, 0.13637541) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13883078, 0.23716426, -0.25517845, -0.4759597, -0.06701175, 0.50799495, -0.6044435, -0.19086848, 0.026909882, 0.043125674, 0.13290659, 0.94061995, 0.15340336, 0.04926609, -0.4055755, -0.2205439) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.10416325, 0.06869749, 0.008279165, -0.15773667, -0.08635052, -0.06271336, 0.097362705, -0.46997234, -0.24371554, -0.11015497, 0.0035662733, -0.0046650637, 0.11580505, 0.09542088, 0.017310075, -0.038499694) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.011778421, 0.040187765, -0.15970466, 0.027068203, 0.12141276, -0.7404787, -0.011879547, -0.33188275, -0.11312822, -0.23675689, -0.008713387, -0.20241702, 0.1755197, 0.52773577, 0.21806054, -0.22170673) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.22632006, 0.35767952, -0.010078209, -0.21487741, 0.47798222, 0.0005554315, 0.06840923, 0.35080373, -0.07249634, 0.37261394, -0.035060592, 0.05543609, -0.03914521, 0.2495444, -0.30352283, 0.06502176) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.05728002, 0.01760025, 0.020889204, -0.09167798, -0.21070841, 0.09038786, -0.14099312, 0.32051507, -0.14904244, -0.22645435, -0.06321531, -0.39714277, 0.1270899, 0.14040565, 0.2235785, 0.09439116) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

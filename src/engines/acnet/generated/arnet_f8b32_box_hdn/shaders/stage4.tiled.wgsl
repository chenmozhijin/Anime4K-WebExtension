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

@group(0) @binding(2) var tex_FEAT_TEX_0: texture_2d<f32>;

fn sample_FEAT_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_0: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_0[tileY][tileX] = sample_FEAT_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.3878246, 0.16575737, 0.06731355, -0.0032432913);
      result += mat4x4<f32>(-0.1126141, -0.04139942, 0.063982956, -0.04404443, -0.14138973, -0.52634114, 0.10881475, -0.44926214, 0.05073354, 0.023780175, -0.037938368, 0.112454325, 0.15845501, -0.0021335874, -0.14754413, 0.08016407) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.071042106, 0.07802916, -0.044141702, -0.1230823, -0.009866875, 0.45345646, -0.039694134, -0.06661731, -0.1123825, -0.25141928, -0.03272609, 0.06877052, 0.08298007, -0.2743502, -0.08354113, 0.039805144) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.16794337, 0.06961568, -0.13733804, 0.06694502, -0.029281244, -0.0391388, -0.115960345, -0.05001706, 0.015985435, 0.22546655, 0.021636289, 0.14058118, 0.16597497, -0.21704528, -0.411469, 0.17099181) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17672224, 0.12864393, 0.0040317494, -0.16928488, 0.45646062, 1.1270906, -0.36635584, 0.6874887, 0.18241721, 0.38942772, 0.0015616469, 0.085187994, -0.13509654, -0.24838571, -0.16780414, -0.02801885) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4776314, 0.09646979, 0.2883806, 0.73295933, 0.055545762, -0.4148263, 0.27497926, 0.07045409, -0.6182619, 0.13628145, 0.40932068, -0.09013797, 0.098419316, -0.4412772, -0.44633967, 0.44328907) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.042081922, -0.21262355, -0.08319676, -0.3266189, -0.019144533, 0.12448117, 0.0823316, -0.10073005, 0.14215161, 0.22590712, -0.14542583, -0.009268935, 0.2901844, -0.26558602, -0.4457589, 0.34559226) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1062525, 0.05263958, -0.1415823, 0.086608574, 0.0014077798, 0.25912222, 0.12816237, 0.039276592, 0.016574137, -0.1250881, 0.14527994, 0.13789484, -0.025972158, 0.07399286, 0.019375497, 0.010150593) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.21078427, 0.099427395, 0.17147332, -0.361919, 0.0027116092, 0.0040114764, 0.17576677, -0.25877514, 0.03664489, -0.13826725, -0.36606562, 0.13591522, 0.12633352, 0.031704657, -0.16249885, 0.0824585) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10070595, -0.21493946, -0.34057593, 0.21830283, -0.053583186, -0.012827319, 0.024560532, -0.010845569, 0.057806812, 0.032513745, -0.052884743, 0.06840942, 0.06322601, 0.20690505, 0.27602133, -0.10103774) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.1976105, 0.26986396, -0.07120055, 0.18126196, -0.2393517, -0.9954811, 0.40582725, -0.08457108, -0.09117506, -0.23932537, -0.08797213, 0.027313843, 0.11139343, 0.059564576, -0.28242263, 0.12026657) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12128557, 0.21656488, 0.090545505, -0.041102085, -0.5982654, -0.09179196, 0.17740358, -0.01667114, -0.15581192, -0.38004452, 0.07105478, -0.05988438, -0.050476853, 0.12325902, -0.38354793, -0.009355002) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15020415, -0.28765428, -0.053065386, 0.07175228, -0.06917511, 0.48722336, -0.14186373, -0.17639512, 0.005008928, 0.16107035, 0.12305589, 0.00019130163, 0.034554288, -0.11189121, -0.123574205, 0.05212023) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15757965, 0.24132693, -0.24227038, 0.18931526, -0.41210902, -0.32978782, 0.075216495, -0.32066342, 0.3127511, 0.32899386, 0.11950992, 0.051556416, -0.17903997, -0.17256057, -0.24120584, -0.05117738) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2642667, -0.6669468, 0.016964573, -0.4161205, -0.22818597, 0.06256398, -0.48689, 0.14494637, -0.03336926, -0.4141494, 0.41436574, -0.001900627, -0.52005464, -0.69832474, 0.20190763, -0.47000045) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1129526, 0.14619596, -0.12194105, 0.1440132, -0.108161055, 0.16720973, -0.38333535, 0.26007912, 0.13429062, -0.39870653, -0.30078986, 0.046760198, -0.011585804, 0.65859556, -0.19250287, 0.09283071) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.059051655, 0.0932295, -0.07941675, -0.06343544, -0.14785902, -0.15532678, 0.30806124, -0.11680008, -0.20776066, -0.031590637, 0.045820046, 0.044979792, 0.07035956, 0.122617595, -0.055712473, 0.132781) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18584886, -0.30280924, 0.0681885, -0.13529272, -0.1868687, 0.25811037, -0.14808564, 0.2655056, -0.007666308, 0.29531664, 0.05840476, -0.053914934, 0.20548442, 0.14561933, -0.21147008, 0.21733078) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0111298645, 0.33924899, 0.10995358, 0.0685777, -0.06816539, -0.45924747, 0.09501813, -0.21597013, -0.022700796, 0.22136942, 0.031647284, 0.023796298, 0.019016929, -0.2655376, -0.27776632, 0.004080632) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

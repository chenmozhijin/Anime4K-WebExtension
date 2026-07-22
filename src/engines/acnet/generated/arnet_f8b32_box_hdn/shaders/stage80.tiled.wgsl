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

  var result: vec4f = vec4f(-0.08006589, 0.32009217, 0.093893066, 0.1311831);
      result += mat4x4<f32>(0.0417027, -0.010510341, 0.11296333, 0.07327085, 0.13900602, 0.0774347, -0.029129375, -0.39284635, 0.04905598, -0.02423967, 0.07563481, 0.10206903, -0.17567194, 0.14373559, 0.09849574, 0.3444829) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15098038, -0.200141, -0.12088344, 0.2836721, 0.13459247, 0.056885842, 0.15639512, -0.20093742, 0.06830079, 0.06675941, 0.19023672, 0.059125986, 0.11635228, 0.32860184, 0.1228969, -0.021942927) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.059349585, 0.07860565, 0.34242752, 0.08207258, -0.009354208, -0.07077765, -0.024754012, 0.062019557, -0.1291362, 0.014241961, 0.08014092, 0.036597144, 0.078985855, 0.051158056, -0.21951799, 0.11038084) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.12739159, -0.22785859, -0.06194906, 0.12985654, 0.19503675, 0.16092873, 0.093647756, -0.9344612, 0.20624928, -0.010315555, 0.13627242, -0.39872295, 0.05382264, 0.26070818, -0.20406675, -0.32805893) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0035520603, 0.274883, 0.36086792, 0.59571815, 0.26941702, -0.42361537, -0.021235177, -0.58052695, 0.14672276, -0.8698729, 0.6867479, -0.010055088, 0.06360673, -0.041855123, -0.85417557, 0.16078025) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24848232, -0.24827805, -0.17891434, 0.1586533, 0.035065316, -0.042605076, 0.06466531, -0.20211022, 0.009737926, -0.2283197, 0.014342293, 0.05231723, -0.036544632, 0.044170193, 0.48044568, 0.11876943) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05433109, 0.14613107, 0.046570536, -0.037108395, 0.21920279, 0.254164, 0.052773405, -0.5810767, 0.15678117, 0.12455996, -0.11801883, -0.26858854, -0.08807953, 0.31928432, 0.081679426, 0.09797097) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.20148727, -0.18600783, 0.13917586, -0.023434684, 0.25454006, 0.13203292, -0.11071973, -0.5181814, 0.042235173, -0.046350166, 0.066553906, -0.05950629, 0.05610536, 0.22461142, -0.20567375, 0.30106077) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.090095825, 0.12749363, 0.026654255, -0.017398834, 0.08306314, 0.054989316, 0.07091781, -0.14306264, 0.011261686, -0.06859518, -0.0800233, -0.054729767, -0.042338606, 0.09038762, -0.11867743, -0.0071831252) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08409544, -0.019816717, 0.1654163, -0.25193825, 0.041088626, -0.0065462133, 0.01612945, -0.21908064, 0.1253765, -0.031287774, -0.022039225, -0.4216429, -0.19993313, -0.012792124, -0.16277142, -0.2729881) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07734146, 0.2746476, -0.14099048, -0.0199305, 0.065762505, 0.051113863, 0.00879967, 0.06619675, -0.00734317, -0.23020406, 0.14018883, -0.12000742, 0.2646275, 0.40151644, 0.12908083, 0.1501805) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14561307, -0.12175998, -0.08012799, -0.00084414374, 0.09273824, 0.064094126, 0.05991976, -0.3031983, 0.0031108807, -0.024493415, 0.02400384, -0.057663064, -0.13859877, -0.08998693, -0.1157484, 0.054726645) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.055618357, -0.09401871, 0.00068748405, 0.07454164, -0.19015211, -0.5716413, 0.49739885, -0.1448445, 0.30321774, 0.0006067507, 0.21310328, -1.0513098, -0.011237267, 0.1272404, 0.026609672, 0.2944211) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.41430408, 0.09615898, 0.60052395, 0.68479323, -0.28867722, -0.597238, 0.018210428, 0.36390218, 0.07744032, -0.7164272, 0.38905048, -0.56645656, 0.16912441, 0.07559319, 0.1989953, 0.66686505) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07135162, 0.24937117, -0.2216703, 0.15218441, 0.031859916, 0.18719141, -0.3974475, 0.36328235, 0.06334361, -0.21263272, -0.04799411, -0.18011858, 0.041342843, 0.15014072, 0.13011093, 0.24317811) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0020981506, -0.017305348, -0.1350204, -0.15867803, 0.38756517, -0.11014575, -0.25494236, -0.69236314, 0.20438506, 0.11014703, -0.020239202, -0.5347967, -0.23483133, 0.16648646, 0.2921074, -0.2759608) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.092664436, 0.13194859, -0.28168973, 0.29524535, 0.12501264, -0.25252822, -0.1649597, 0.41405964, 0.16622776, -0.17218365, -0.1773757, -0.315433, 0.25201622, -0.021360887, -0.41854188, 0.21155228) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.25580698, 0.3210219, -0.23961745, -0.16433185, -0.21078657, 0.25007215, 0.46102726, -0.13899589, 0.094616234, 0.03103233, -0.024356155, -0.10229648, -0.035961404, 0.054973178, 0.088217236, -0.006285085) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

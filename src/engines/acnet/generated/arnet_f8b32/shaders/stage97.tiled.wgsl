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

  var result: vec4f = vec4f(0.1265783, -0.06363041, 0.13398968, -0.09514404);
      result += mat4x4<f32>(-0.19221666, 0.03748361, -0.08272925, 0.057654876, 0.24798106, 0.17084998, -0.23234881, -0.32553682, -0.20182334, 0.14637531, 0.09737839, 0.081513874, -0.121668495, 0.0012401881, 0.031139975, -0.10184711) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3709223, 0.39507028, 0.108636975, 0.15434092, 0.20232297, 0.09369904, -0.14317574, -0.062260944, 0.00067933154, 0.13227971, 0.1689373, 0.0952849, -0.09259158, 0.23956108, -0.18914619, -0.26771116) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.021304395, -0.0025821615, 0.3127925, 0.24514933, 0.26214674, 0.006707922, 0.04186938, 0.041721534, 0.24419126, -0.2599125, -0.053750515, -0.07060133, -0.11040953, 0.071445405, -0.059591528, -0.010202858) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0833213, 0.11736789, -0.099655345, 0.08208082, 0.03231885, -0.038394265, -0.28319013, -0.49769536, -0.22307669, 0.016073728, 0.24177925, 0.2237653, -0.17742716, 0.063124895, 0.35145065, 0.5787677) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0969472, 0.35435677, -0.17253329, -0.085810475, -0.016935645, -0.83440894, -0.08194247, -0.19378437, -0.08318972, 0.036635492, -0.11385268, -0.030833643, 0.3029033, -0.27739155, 0.4096319, -0.0834464) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.118384406, -0.12253939, -0.016212128, -0.04332555, 0.25993767, 0.045045707, -0.23753601, 0.09907505, 0.35211888, -0.32881242, 0.16876924, -0.112843916, -0.11713839, 0.3252538, 0.17624523, 0.11778267) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03662821, -0.01651976, -0.18373676, 0.08415168, 0.040482733, -0.0023145508, -0.038689323, -0.038119584, -0.13766392, 0.218641, -0.09071678, 0.04594787, -0.023493143, 0.24797599, -0.16075309, 0.15810084) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.18918307, -0.53072953, 0.15312126, -0.24134684, 0.16617686, -0.250927, 0.1748048, -0.11388406, -0.093846776, 0.4556106, -0.28219718, -0.026963983, -0.1060042, 0.063064285, -0.37423632, -0.19809712) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.405229, -0.27855447, 0.12530345, -0.05327455, 0.2628741, 0.093730524, 0.06980263, -0.034812734, 0.14101474, -0.25130007, -0.27104557, -0.24640076, -0.110584475, -0.06597711, -0.06366992, 0.1008126) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.12841506, 0.118621506, 0.20143358, 0.07591429, -0.08571757, -0.09781829, -0.094587184, 0.04018189, 0.12872376, 0.105749816, -0.1031024, 0.08635443, 0.025686918, 0.041836537, 0.06449747, 0.10904594) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.031688925, 0.09459774, 0.21460624, 0.082438216, -0.16005252, -0.016521828, -0.16460355, 0.02568461, 0.022802867, -0.31685576, -0.23116833, 0.030255454, -0.15408222, 0.07892981, -0.13129959, 0.022120584) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20805763, 0.17719293, -0.0076697674, 0.070018485, 0.039892454, -0.005001632, -0.05818349, 0.076060034, -0.10442884, 0.16632009, 0.055381007, 0.047220707, 0.33553365, 1.5766734, 0.52313083, 0.34776607) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.019404821, 0.39729768, -0.043223806, -0.026856186, 0.15715319, -0.2132693, 0.16275433, -0.09392982, 0.3697816, 0.41919142, 0.10042914, 0.54709387, -0.03800311, 0.049346168, 0.022723021, 0.034902196) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.010743977, 0.61479735, -0.14356646, 0.10257597, -0.5602196, 0.5931886, 0.28763804, -0.3097519, -0.55765694, -1.0004034, -0.27157295, 0.27584034, -0.0840682, 0.09067912, -0.12086135, 0.04314423) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07478886, -0.08970478, -0.21676677, -0.47175056, 0.039231732, -0.23297822, -0.24772665, 0.18215412, -0.06579916, 0.49360695, -0.028386274, -0.22907665, -0.33357614, 0.047452852, -0.15198898, 0.09141446) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.2163464, 0.15797709, -0.20565987, -0.25490868, -0.14645815, -0.32149285, -0.13026166, -0.10320474, 0.1432531, 0.1523918, 0.008403294, -0.14584196, -0.041888945, 0.014064745, -0.023486787, -0.05823154) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.20732382, 0.3953053, -0.52347666, -0.44947806, -0.49258205, -0.46951714, 0.09854595, -0.20523131, 0.08907972, -0.072276585, -0.028920146, -0.12876537, -0.034801856, 0.043107513, -0.020057503, -0.06413395) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11862331, 0.3117894, -0.37879613, -0.3767134, 0.16744186, 0.05651119, -0.07488817, 0.019308455, -0.1498902, 0.005516026, -0.027253935, 0.04865042, -0.0122413505, 0.05063929, 0.018179484, 0.059136767) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

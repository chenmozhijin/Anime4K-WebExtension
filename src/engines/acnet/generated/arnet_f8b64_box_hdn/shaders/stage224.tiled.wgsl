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

  var result: vec4f = vec4f(0.050497103, -0.09149784, 0.25331435, -0.2726056);
      result += mat4x4<f32>(-0.0103601795, -0.06011792, 0.124507576, -0.10276052, 0.07011021, 0.046527363, -0.035866126, -0.16122477, -0.02372958, 0.09146371, 0.039979216, -0.23479916, 0.0065221805, 0.22918528, 0.026197987, -0.1234305) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.406097, -0.51082456, 0.43285382, 0.121579945, -0.11418733, 0.26499444, 0.008535442, -0.04246606, -0.13811737, -0.20975317, -0.3290325, -0.16284214, -0.031428974, 0.04189451, -0.06688544, -0.048625357) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10181202, 0.03255747, 0.07375157, 0.08441962, -0.17479286, -0.18611017, 0.12829429, 0.12203706, -0.022429299, 0.00093427446, -0.13963597, -0.11628591, -0.0072179274, 0.0114243245, 0.17354368, 0.092657596) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08179285, -0.15537342, 0.012041925, 0.030001426, -0.039785303, -0.03159243, -0.019838044, 0.1742821, 0.24547172, -0.07143837, -0.14676628, 0.006791795, 0.4448122, -0.13278677, -0.651643, 0.22499366) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.45763698, 0.55721337, 0.45598888, -0.08552483, -0.5893507, 0.120924726, -0.17532885, 0.46284127, -0.34642708, -0.15737061, -0.6679394, -0.1365156, -0.15518719, -0.34752858, -0.58489203, -0.015246911) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.081457496, -0.024127642, 0.17288616, -0.006690626, 0.29107064, 0.14564285, -0.15626898, -0.1471908, 0.042809445, -0.10240048, 0.050971556, 0.07848952, -0.06541648, 0.028169652, -0.0038526822, 0.025122678) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2501925, 0.011219076, 0.18557402, 0.091228165, 0.03562242, -0.047484748, 0.04519862, 0.06743565, 0.0405641, -0.013988845, 0.08674045, 0.104145445, -0.18839072, 0.065308385, 0.10280409, -0.22248504) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22096665, 0.033865478, -0.30617326, -0.12495446, -0.039370682, 0.0073023173, -0.10278522, 0.17085814, 0.13129567, 0.09692013, 0.32953578, 0.17648074, 0.13034679, 0.05633783, 0.19940917, 0.11240428) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.012187123, -0.041876543, 0.25271463, 0.07077683, -0.05161633, 0.011333826, -0.024831774, 0.09736596, -0.024120446, -0.036988176, 0.040469185, 0.12936427, -0.06803936, 0.008212195, 0.032467667, 0.01174355) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2762471, -0.13570842, 0.07618395, 0.4950074, -0.009218775, -0.102065444, 0.10356451, 0.027131256, 0.043115404, -0.07931339, -0.012054383, 0.15225141, -0.09390934, 0.07397268, 0.05462535, 0.10595809) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08005804, -0.17717338, -0.5859552, -0.052600157, 0.041623343, -0.11816306, 0.122999765, 0.059173595, -0.03484614, 0.17392975, -0.21835367, -0.113281004, -0.09738761, 0.06058089, 0.005735411, 0.100994915) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02660714, 0.024341293, -0.060565006, -0.1321333, 0.04472927, 0.042424824, -0.013257828, -0.11048323, -0.065643825, 0.028208164, -0.10865227, -0.03158141, -0.0295913, -0.074976325, 0.029608192, 0.12691294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1539987, -0.229883, -0.32118663, 0.10256648, -0.40034217, -0.060558155, 0.14769414, 0.06479115, -0.10431216, -0.092264324, -0.027539918, 0.090700276, 0.14155188, -0.16859141, 0.049968787, 0.115393855) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2840581, 0.28444415, 0.40889615, 0.22738071, 0.040001526, 0.5093822, -0.05683091, 0.3170625, -0.19018845, -0.015803402, 1.1230092, -0.7961856, 0.7494474, 0.21699418, 0.2784577, -0.5409458) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1461308, -0.09804716, -0.0968827, 0.24688174, 0.0939309, 0.07632709, 0.084476545, -0.07722559, -0.24754556, -0.26696438, -0.06498965, 0.1740372, 0.021965997, -0.10501539, -0.13440621, 0.1299415) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12956524, -0.13134937, -0.26924828, -0.12751411, -0.07150488, -0.09085681, 0.034558997, 0.2493759, 0.08412177, -0.11107738, -0.08927986, 0.036477674, 0.026540373, 0.010059225, -0.04105352, 0.0059741344) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.118085824, -0.045158487, -0.35515687, 0.041011807, -0.32690084, -0.2726504, -0.035506707, 0.21507384, -0.07814811, -0.017928489, -0.093060255, -0.12811728, 0.047916546, -0.08998119, -0.04387295, 0.1949794) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.037703328, -0.03949964, -0.15900046, 0.02642006, 0.09494734, 0.020622913, 0.17337713, -0.040344447, -0.15842783, -0.09335997, -0.15852055, 0.052868545, -0.03629786, -0.06830481, 0.0024404246, 0.10834623) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

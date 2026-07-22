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

  var result: vec4f = vec4f(-0.073992744, -0.010879266, -0.011243271, -0.19584459);
      result += mat4x4<f32>(-0.2864939, -0.025751762, 0.054653265, -0.03724115, 0.08648828, -0.07682839, 0.32547852, 0.13333192, -0.75548804, -0.13404082, -0.008173066, 0.39252555, 0.02967529, 0.10724842, 0.07243065, -0.250496) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0022912268, 0.0038596794, -0.064999975, -0.054908544, 0.25898972, -0.02067759, -0.10192926, 0.5096377, -0.3439233, 0.04912123, -0.6458697, 0.23833288, -0.48979658, -0.05312047, 0.16760871, -0.2544013) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.29136094, 0.100420155, 0.11645535, 0.06396081, -0.098139286, 0.055115145, 0.008612919, 0.08096911, -0.30972022, 0.055251867, -0.3817516, -0.011087486, -0.4140694, 0.13962641, -0.011545974, 0.15843745) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.030555544, -0.20538616, 0.15990767, 0.25980246, 0.04259454, -0.18273774, 0.2337442, -0.34162468, -0.15568359, -0.18853764, 0.07621635, 0.30650648, 0.137073, 0.21256359, -0.05700707, -0.11265507) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.018099504, -0.2749632, -0.21501239, -1.2392597, -0.049513794, 0.29590198, -0.80857855, -0.5588863, -0.21982338, 0.043893762, -0.4314529, 0.49409822, 0.12753914, 0.095529154, 0.038009804, -0.1445067) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.28787416, 0.06520145, -0.0339886, 0.026988387, -0.20062768, 0.20087038, -0.07267255, 0.19403502, 0.04120223, -0.014438836, -0.33310702, 0.4750925, 0.3964479, -0.13141394, -0.50910884, 0.27872902) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.47623268, -0.090298705, 0.10414989, 0.59729946, -0.13008966, 0.032573674, -0.0039251475, -0.010701578, -0.42007342, 0.099178456, -0.047879327, 0.32118252, -0.16547781, -0.06193634, 0.40217742, -0.27236232) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1383386, -0.09545396, 0.600018, 0.16883495, -0.25011936, 0.0077139093, -0.29434624, -0.2506232, -0.16005321, 0.05191455, -0.36074898, 0.052961085, 0.14753826, -0.14074999, -0.006894963, 0.10773821) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08856829, 0.0087155495, 0.028287422, 0.20540394, -0.06342291, 0.057426337, -0.37727004, 0.079681195, -0.3739519, -0.0085388385, -0.2628537, 0.48140827, 0.14058931, -0.17182817, -0.2784908, 0.11413833) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.16851094, -0.018666131, -0.3138232, 0.05103801, 0.008924132, -0.08709636, 0.13806123, 0.24005152, 0.078705125, 0.24910839, 0.03294738, 0.1592878, 0.18816915, -0.108633265, 0.14269397, -0.12299376) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.052498844, 0.019695802, -0.300963, -0.41779524, 0.53613865, 0.06453924, -0.037378266, 0.111526854, -0.33177948, 0.023000201, 0.23990768, 0.12312202, 0.36842448, -0.1284659, -0.079386294, 0.52021164) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14035462, 0.12545927, -0.16752434, -0.086734116, 0.19035155, 0.098294735, -0.31160778, -0.046108577, 0.06311827, 0.117271334, 0.29573986, -0.07846677, 0.18324547, -0.11512109, 0.29946497, -0.49669766) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.24561988, 0.12289207, 0.014547917, 0.11611953, 0.022962667, -0.37910512, 0.039525468, 0.31941518, 0.20640774, 0.15056942, 0.17804709, 0.3304022, 0.09222573, -0.28196654, -0.22389628, -0.09138081) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.09705036, -0.6432951, 1.1693748, 0.7876653, 0.2546969, 0.13243502, -0.9069233, -0.61787516, -0.17714983, 0.038588893, -0.44419006, -1.0776837, 0.016777338, 0.2151974, -0.39644393, -0.8082203) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.31370053, -0.28122067, -0.035782155, -0.047468167, 0.15974729, 0.17184429, 0.17058383, 0.29576683, 0.0950883, -0.09322952, 0.1321382, 0.2793717, -0.18910074, 0.21745078, 0.4657385, -0.12924482) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11471719, -0.1892996, 0.007330961, -0.348533, -0.14396386, -0.045483988, -0.0465446, 0.100058384, 0.048948962, 0.092588015, 0.52577025, 0.3591534, 0.17596495, -0.07920073, -0.004910275, 0.18431549) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1725704, -0.07462234, -0.041458197, 0.04628769, -0.07180163, -0.03276033, -0.13112402, -0.24261548, -0.15904942, 0.29904538, -0.24589415, -0.32100776, 0.025558747, 0.104817875, 0.1925886, -0.2538413) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07220259, 0.047374975, -0.08025386, -0.36432016, 0.022656484, 0.16351974, -0.30927455, -0.055304427, -0.027611453, 0.06929562, 0.07971906, 0.21607617, 0.45603526, 0.0031539167, -0.02763219, -0.37018612) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

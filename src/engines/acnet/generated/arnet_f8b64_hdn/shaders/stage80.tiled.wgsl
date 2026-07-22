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

  var result: vec4f = vec4f(0.35516813, 0.09040039, 0.5090339, 0.07943583);
      result += mat4x4<f32>(0.10374178, 0.08992487, -0.0767966, -0.23988912, 0.3204118, -0.024421062, -0.16168223, 0.1917211, 0.079515636, -0.21861309, -0.108926654, 0.17938265, -0.17809784, -0.10550919, 0.107697345, -0.04187816) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.018708847, 0.056054074, -0.040820368, 0.38573912, 0.18764718, -0.0007596068, 0.10400471, -0.080872245, -0.27672344, 0.02941309, -0.37589163, -0.1856932, -0.30333483, -0.0007137186, 0.009884039, -0.20912221) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0722713, -0.014357653, 0.01964327, 0.28062844, -0.2142857, -0.08244956, 0.06358288, 0.22803842, -0.25274053, -0.052969452, -0.20335528, -0.16119674, -0.52593625, -0.15702978, -0.012494353, -0.0064277365) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.12009727, 0.16327167, -0.09895062, -0.08293784, 0.24203908, -0.03188481, -0.21541278, 0.1968606, -0.5560717, 0.10578908, -0.11395795, 0.15003097, -0.44372874, -0.30077878, -0.32814026, 0.24218774) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.46911067, 0.24888076, -0.27249613, -0.08748858, -0.4869562, -0.13271278, 0.1805705, 0.07952079, -0.49463132, 0.07474972, -0.5458776, -0.017182633, -0.5740435, -0.041352294, -0.6357263, 0.11116165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.51735455, 0.027557582, 0.18414016, 0.31791863, -0.49121666, 0.023112131, -0.01738371, 0.3494292, -0.5109522, 0.03855087, 0.24967352, -0.06100591, -0.17497523, -0.117434435, -0.0852971, 0.239619) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.26010627, 0.014717975, -0.060144495, -0.09715056, 0.21075971, -0.014880062, -0.049867567, 0.041576624, -0.09027551, -0.006586461, -0.16139033, 0.16648127, -0.17825393, 0.10848155, -0.15473045, 0.18323904) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18157315, 0.06584259, 0.014755718, -0.34563702, -0.0812081, -0.049720705, -0.28090656, 0.1756668, 0.07862555, -0.08563004, -0.32767534, 0.19878928, 0.18188474, -0.09074675, -0.16299407, 0.15235686) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1537942, -0.0369832, 0.04271985, -0.010205071, -0.086206816, 0.11935637, -0.03884301, 0.16241397, -0.082519114, 0.09338869, 0.25110662, 0.06118919, 0.064169124, -0.011426327, -0.071921654, 0.023106422) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.26001024, 0.043345723, 0.21119109, 0.07910841, -0.14351799, -0.19394386, -0.035475098, 0.030709956, -0.048055436, -0.0038313277, 0.351313, -0.23696557, -0.025676046, 0.0029290926, -0.1929633, 0.036236625) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.4316527, 0.001770908, 0.13469891, -0.1656942, 0.2583241, 0.17553076, -0.2472211, 0.11631469, -0.058990456, -0.07268963, 0.018764751, -0.262136, 0.13165152, 0.045825787, 0.10413436, -0.19253811) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.010189102, 0.13433592, 0.05221984, -0.084249265, 0.27749225, 0.027181601, -0.16749392, -0.15006693, -0.21428801, -0.024499265, -0.020659985, -0.23965776, -0.14202917, 0.064961396, 0.029229261, -0.05533402) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.53885657, 0.024070652, -0.077247135, 0.012775224, 0.0783104, 0.09957695, 0.1603104, -0.23383601, -0.011654466, 0.042206813, -0.024750289, -0.04844663, 0.01606535, -0.0009264084, 0.11691059, 0.08259726) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.6558713, 0.22803026, 0.009735102, -0.07824741, -0.58785033, 0.13735883, 0.10818651, -0.7331352, 0.422102, -0.07287624, 0.03350179, -0.33958107, -0.075702585, 0.019889275, -0.26290685, -0.57502663) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.014746814, 0.08560133, 0.04193002, -0.1863409, -0.2040164, -0.12186029, -0.4408989, -0.6939848, -0.09532369, -0.086048216, -0.070140615, -0.02045252, -0.17986746, 0.13007648, -0.040375073, -0.043351825) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0655113, 0.033511847, -0.0017161773, -0.073676094, 0.038318206, 0.26724935, -0.111297525, -0.08475568, 0.15783912, -0.035198, 0.113040395, -0.016393935, -0.057500873, -0.10216747, -0.09306398, 0.041367482) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13898633, 0.11642424, 0.096062, -0.13202716, 0.7472453, -0.01273425, -0.77090746, -0.23915137, 0.05323422, 0.044181116, 0.34320077, -0.28906363, -0.44927025, 0.07523189, -0.41760543, 0.33012003) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.027985463, 0.038240686, -0.034478728, -0.13952348, -0.0008044122, -0.0393647, -0.0147700235, -0.13526975, 0.087204255, 0.026743347, -0.046588838, -0.006050337, -0.41782585, 0.13756314, -0.096979454, 0.22386166) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

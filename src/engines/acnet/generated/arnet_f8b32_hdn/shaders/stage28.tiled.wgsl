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

  var result: vec4f = vec4f(-0.29702067, -0.20781246, 0.33119714, 0.3133053);
      result += mat4x4<f32>(-0.0035368414, 0.099617526, 0.021040527, -0.02041288, -0.058773264, -0.08033043, 0.06854138, 0.18189499, -0.07610375, 0.09361321, 0.08276554, 0.2011597, -0.0028705779, -0.36578795, -0.085701965, 0.06078986) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.097195506, 0.1455785, -0.034307066, -0.17598304, -0.031172605, 0.101838894, 0.32169476, 0.2982809, 0.006516552, 0.01276503, -0.1466238, 0.1693643, 0.012012423, 0.10744772, -0.110246345, -0.14338419) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09283667, 0.099893235, 0.025744965, -0.027580276, 0.20783022, -0.06406248, -0.113669515, 0.023647137, 0.06992485, 0.10072724, -0.042513918, 0.020762436, 0.14162661, -0.16739944, -0.075235665, -0.00532485) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.33169764, -0.08147313, -0.21822624, -0.40253273, 0.14059657, -0.073411725, -0.20266236, -0.20312986, 0.16295795, 0.11316297, 0.46892828, 0.3797008, -0.051181324, -0.22202736, -0.060764756, -0.1492486) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.06825989, -0.08793928, -0.09109305, -0.13294227, 0.0567055, -0.69718117, -0.97447234, 0.119649366, -0.016271826, 0.14405851, 0.21258248, 0.2337807, -0.21239322, 0.21352507, 0.022626957, -0.22600614) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.055888765, -0.05195758, 0.1332838, -0.032174367, -0.10019733, -0.3159038, -0.076980785, 0.28200805, -0.24384446, -0.11169597, 0.03896209, 0.07897466, 0.09864106, -0.24834335, 0.24814236, -0.1509461) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12557073, 0.24181397, -0.0863339, -0.058370456, -0.048776593, -0.394018, 0.35681692, 0.017812816, 0.02406712, 0.15128368, -0.05543864, 0.00071388244, -0.014271289, -0.16753498, 0.08098776, -0.22951889) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.022464218, -0.18604283, 0.25701, 0.061584607, -0.041128777, 0.04983473, -0.1253803, 0.15895294, -0.14661144, -0.4003926, 0.3722994, -0.037092604, -0.05631429, 0.31525654, 0.14027607, -0.013298561) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08995191, -0.035688274, -0.014908362, -0.015326348, -0.075383574, 0.26410916, -0.18873826, 0.091088355, 0.2518437, -0.2998203, -0.43456244, 0.1667292, 0.017762182, -0.060342304, 0.22297591, -0.09217909) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.045059737, -0.018936854, -0.15105434, -0.18711604, 0.08291583, 0.039264917, 0.018696273, -0.1215539, 0.102226205, -0.0921578, 0.0853517, 0.05671889, 0.028227247, -0.06894961, 0.054058366, -0.06862376) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.057248913, 0.018949425, 0.056902695, -0.16546275, 0.10777778, 0.04409847, 0.009162768, -0.08392282, -0.00094088784, -0.12951197, 0.2411418, -0.10984392, 0.19032595, 0.14667414, 0.1753601, -0.09489145) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.041071523, 0.2728699, 0.20145413, -0.09351916, 0.16424283, -0.21810043, -0.021797683, -0.025880203, 0.07049994, -0.356808, 0.092892125, 0.11140378, 0.19142847, -0.024057396, 0.20309603, -0.029983364) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.006540725, 0.013987864, -0.12738948, -0.09994411, 0.039237257, -0.19663584, 0.121311516, 0.52065563, 0.11066691, 0.015881032, -0.18213727, 0.01840269, 0.090680785, -0.19626014, -0.21538997, -0.34232482) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.06950416, 0.43618783, -0.17265292, -0.5900796, -0.12706529, 0.28683525, 0.24945357, 0.9257937, 0.17060578, 0.33881962, -0.07319175, -0.22722147, 0.21210378, 0.24820907, 0.056615554, -0.33481) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19113497, 0.28024402, 0.26803517, -0.3475872, 0.0966538, 0.35799813, -0.32937008, -0.04134414, 0.20802253, -0.22659574, -0.32707018, -0.11294973, 0.15478364, -0.073092155, 0.20848478, -0.004445372) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.085016705, 0.10484658, -0.17976044, -0.004051043, -0.048916176, 0.11241771, 0.22616251, -0.1458973, 0.061627474, 0.06782828, -0.09860297, 0.15712821, -0.024614057, -0.07159276, -0.21177745, -0.16783461) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.042437427, 0.34148586, -0.3185653, -0.40374267, 0.017928803, -0.12937638, 0.50386727, 0.069616534, 0.04311305, -0.014892094, -0.39395925, -0.023770677, -0.03272844, 0.24791455, -0.0989026, -0.13492438) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.007924167, 0.12831017, -0.24417295, -0.035707388, 0.11004422, -0.23840375, 0.46178207, 0.3426642, 0.118614696, 0.11565514, 0.09435036, -0.09218812, 0.02945138, 0.037354954, 0.18558803, -0.04330001) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

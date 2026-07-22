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

  var result: vec4f = vec4f(0.47519335, -0.042892292, 0.22321439, -0.1463448);
      result += mat4x4<f32>(0.34180644, 0.5255148, 0.28335133, 0.3545155, 0.0058614844, 0.12883596, 0.030041695, 0.26057178, 0.0671157, -0.027367285, -0.08827357, 0.053746287, -0.0199909, -0.12727335, 0.012383647, -0.16340356) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.29358926, -0.044454724, 0.29012725, -0.10366037, -0.32916123, 0.16491005, -0.17337528, 0.27143943, -0.13900135, -0.39322022, 0.00907842, -0.36880577, 0.02566668, -0.28205708, -0.2988798, 0.16975966) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11292059, 0.3126291, 0.5152552, 0.50963616, 0.06437542, 0.03484441, -0.1337159, 0.06858144, 0.107148826, -0.12184058, 0.13456774, 0.12443391, -0.15430678, -0.1211938, 0.06681792, 0.17287765) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.44210556, 0.28648317, -0.24170837, -0.09218188, -0.19585438, -0.11979619, -0.26459795, -0.08830515, 0.046814147, 0.045694504, 0.25545126, 0.2214393, 0.0021304972, -0.32769215, -0.13284545, -0.18612546) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.17122312, -0.4051468, -0.30085784, -0.2134459, -0.17308754, 0.86940336, -0.7162431, 0.1264726, -0.26244754, 0.50171196, 0.2228503, -0.5120614, -0.008879276, 0.24094531, -0.060242943, -0.48107186) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.05135184, -0.24408425, 0.46596238, -0.297992, 0.041392993, -0.19236542, -0.12399996, 0.03215735, -0.3230735, -0.2577459, 0.044516396, 0.20685036, -0.53326905, -0.3379572, 0.033354208, 0.19805627) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1314699, 0.25455555, 0.013871941, 0.038455747, 0.09341608, 0.085064545, 0.017348807, 0.17754988, 0.024528205, 0.007986994, -0.00011141978, -0.042548083, 0.19859676, 0.11572875, 0.08629728, 0.09351947) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.28764924, 0.17266047, -0.20704807, -0.41331702, -0.054261647, 0.04909032, -0.082450755, 0.02270973, 0.16415729, 0.33833823, 0.14704749, 0.06638049, 0.038946886, -0.05953635, -0.038169086, 0.15494508) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.04519467, 0.40242028, 0.11729573, 0.044042304, 0.15101834, 0.1395727, 0.067160524, 0.19677837, -0.035244845, -0.09599912, -0.09700617, 0.011978583, -0.1452267, -0.15955998, -0.050918397, -0.13978274) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.25208604, -0.15912463, -0.3382662, -0.30772954, 0.011503945, 0.17477632, -0.0027099284, 0.054360706, -0.010865473, -0.010306956, 0.04680044, 0.03550607, -0.1745595, -0.15338531, 0.031014528, -0.09872411) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.18925881, -0.11467439, -0.30181986, -0.2711045, -0.1407408, 0.07996751, -0.06307639, -0.086857334, -0.018730631, -0.038332723, -0.042161595, 0.05420727, -0.37501252, -0.3278981, -0.1618595, -0.36724952) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04435644, 0.10586185, -0.034398165, 0.16403584, 0.063555166, 0.08093453, -0.07194572, -0.10052402, 0.021658499, -0.060638662, 0.030458542, 0.013176307, -0.044038422, -0.2811437, -0.16566133, -0.3463406) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.49545902, -0.35919204, -0.5236604, -0.5110136, -0.03716754, -0.32578498, -0.019049557, -0.057044283, 0.01389327, 0.2767979, 0.003542384, 0.21526273, 0.17072709, 0.19067742, 0.41940957, 0.11788285) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.21119064, 0.3194021, -0.26988974, 0.12636352, 0.7011595, -0.82362, -0.40048298, 0.2931883, -0.49318895, -0.12224608, -0.72531, -0.21653336, 0.28732738, 0.3485985, 0.45797142, 0.1447611) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14453717, 0.10401707, -0.118034996, 0.6138186, -0.09102677, -0.023278799, 0.012916209, 0.09134032, 0.725999, 0.10198596, 0.53575736, -0.32222944, -0.19076046, -0.18716145, -0.37450942, 0.38417614) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2734786, -0.33577123, -0.12402373, -0.34921658, 0.08479083, 0.10504954, 0.01155758, 0.002086024, 0.035824303, 0.088900976, 0.07287666, 0.15542123, 0.2650035, 0.40962318, 0.25682187, 0.3636442) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10113849, 0.13358411, 0.048702635, -0.18098953, 0.07167144, -0.2744518, -0.07029678, 0.095450304, -0.027721962, 0.114511795, -0.18180452, -0.26754138, 0.2885315, 0.13531463, 0.2681655, 0.2675891) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20847194, 0.053094693, 0.39839917, 0.19600844, 0.09049862, 0.025522798, 0.09699324, -0.015571687, 0.20371813, 0.06796765, 0.05912556, 0.062119517, 0.27647033, -0.0490678, 0.0708932, 0.32080764) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

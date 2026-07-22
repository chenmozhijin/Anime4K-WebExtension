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

  var result: vec4f = vec4f(-0.25824618, -0.074417844, 0.19222185, -0.21343158);
      result += mat4x4<f32>(0.090094686, 0.32990068, 0.26362985, 0.09153805, -0.13746583, 0.0760403, -0.21794786, -0.3783346, -0.027259659, 0.042892616, -0.13333559, 0.2160633, 0.054610353, 0.100433454, 0.04044264, 0.11423985) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.18193007, -0.008885842, -0.19613795, -0.12843582, -0.044903483, 0.05969814, -0.63858145, -0.5375458, -0.02652483, 0.15344888, 0.012671902, -0.010104811, 0.1280922, 0.0049886284, 0.41764355, -0.24695419) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15138766, 0.022886248, -0.09387513, -0.029420383, 0.17557639, 0.015932165, -0.092139564, 0.025117839, 0.0533811, -0.027042458, 0.23618247, 0.13016683, -0.08571847, -0.083834566, 0.17593713, -0.251148) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13802052, -0.084310375, 0.1169863, -0.05616926, -0.32155058, 0.38692662, 0.049435288, -0.2734894, -0.110757604, -0.10416278, 0.09182167, 0.17181271, 0.35968956, -0.1035305, -0.18932395, 0.263343) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1101081, 0.07158059, 0.76513356, 0.95097655, -0.54903626, 0.14111403, 0.3633134, 0.72132695, -0.08045328, -0.097033836, -0.035392903, 0.15301372, 0.21482755, 0.39284408, -0.61660075, -0.21885549) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11884812, -0.10325068, 0.14314392, 0.47066832, 0.31333128, -0.3873929, -0.2521351, 0.12339726, 0.013912848, -0.22646822, 0.1540049, -0.012912576, -0.26081333, 0.23723468, -0.026893353, -0.32850906) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.068014264, 0.15250246, 0.3240428, 0.2706149, -0.020253511, 0.13626204, 0.08310198, -0.15182115, -0.0022322698, -0.014968237, 0.003653853, 0.015578965, -0.029775033, 0.20098418, 0.012829726, -0.055088535) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.052506197, 0.053070314, 0.10203072, 0.5321364, 0.15731655, 0.1691121, 0.22038004, 0.11745841, 0.00986825, 0.073055446, 0.023569461, 0.24947052, -0.019138265, 0.016561212, -0.17861888, 0.42575625) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.017333431, 0.13353159, -0.045972567, 0.3075368, 0.10565296, -0.104182795, 0.07979801, 0.1043317, -0.062336635, -0.11354216, 0.041865535, 0.18950048, -0.13289881, -0.3430874, 0.011761979, 0.043290652) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16579421, -0.11625337, -0.14203931, -0.07766232, 0.047016066, 0.02838279, -0.06797712, 0.00012882386, 0.20439719, 0.16378526, -0.24134897, -0.23013699, -0.0034585476, 0.16224974, 0.066491604, -0.09896753) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.023796635, -0.17784038, 0.12914322, 0.09210954, 0.040546786, 0.015321077, 0.18695866, -0.43425795, -0.03783876, 0.1940039, 0.4812502, 0.0731736, -0.07906373, -0.23767026, -0.7015381, -0.2151767) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.029686226, -0.0020013717, -0.32352147, -0.37367958, 0.12631986, 0.21446067, -0.009584764, 0.12106263, 0.19831577, 0.17637657, -0.10114024, 0.010068112, 0.047933042, 0.15960774, 0.1180066, 0.16826548) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.20969109, 0.06350375, -0.062283948, 0.2980271, -0.11647662, 0.17228426, 0.24051446, -0.44950196, -0.047748644, -0.71734214, -0.097557105, 0.09141678, -0.33105785, 0.15458563, 0.08466766, -0.20020407) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6702128, 0.106277205, -0.2324155, -0.28805915, -0.305244, -0.40237886, -0.06727046, 0.5106812, -0.14748098, -0.4626254, 1.3961976, 0.38250437, -0.5269129, 0.1552066, -0.10978522, 0.2978386) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12751956, 0.26716742, 0.016431794, -0.19593567, 0.27717015, -0.03300516, 0.17623423, 0.09596021, -0.2869972, 0.037238743, -0.1157857, 0.23117839, 0.15096807, -0.10268789, -0.3119276, -0.026464313) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.26685533, 0.34727702, 0.027574548, 0.036445823, 0.17266172, -0.0047534597, -0.13009562, 0.020383967, -0.06760107, 0.1035412, -0.28769776, 0.0924098, 0.032809515, -0.15220264, -0.07648896, 0.14527673) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.075043686, -0.32798856, 0.13732798, 0.107076265, -0.2458417, -0.23568293, -0.037222892, 0.09568757, 0.19972217, -0.20910358, 0.32012165, -0.7449577, 0.24396004, -0.018387428, 0.21875896, 0.038683888) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.14892213, -0.37286252, 0.22767201, -0.00815484, 0.058301378, 0.35403082, -0.2413342, -0.24105513, -0.19890861, 0.34538302, -0.03303853, 0.30196333, -0.14240605, 0.16095237, -0.21171375, -0.13899513) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

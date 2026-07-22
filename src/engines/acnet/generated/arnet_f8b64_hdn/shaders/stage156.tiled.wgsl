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

  var result: vec4f = vec4f(-0.011895681, -0.021276174, 0.08276439, -0.348324);
      result += mat4x4<f32>(-0.007646087, -0.007104518, -0.092602886, -0.040430702, 0.085386865, -0.26002738, -0.22313936, 0.13726512, -0.07177173, 0.17715578, -0.057934325, 0.018525207, -0.017627189, -0.15767464, -0.047015607, -0.013767796) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.38175693, 0.0189815, -0.2776607, 0.3265187, 0.05065462, -0.32285774, -0.06019817, 0.17230591, -0.10768563, 0.29911235, 0.108357824, 0.03775288, 0.076305725, -0.26222798, -0.047732588, 0.07613119) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18907468, 0.08678653, 0.0023941826, -0.3173866, 0.115507275, -0.2768976, -0.10813403, 0.16795601, -0.080586106, 0.13825987, -0.024512557, 0.018842977, 0.06426874, -0.21509357, -0.12931852, 0.09563833) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07243473, 0.215592, 0.141685, -0.24444142, 0.1305932, -0.2793181, -0.16865441, 0.16472983, -0.108624235, 0.26082334, 0.026044788, 0.056723617, 0.053104397, -0.28708658, 0.019852076, -0.028573183) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.099341065, 0.10364327, 0.254027, -0.5875337, 0.09057806, -0.3442518, -0.06679355, 0.15634036, -0.13310736, 0.37559783, 0.0010929441, 0.021877766, 0.07221049, -0.4081941, -0.050341744, -0.023914913) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.02732239, 0.105566375, 0.16825901, -0.07940729, 0.055093776, -0.34395063, -0.13850258, 0.18315037, -0.14727783, 0.2630838, 0.01183295, 0.027240388, 0.1776985, -0.27756017, -0.045563094, 0.05105029) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(5.3848584e-05, -0.00038561077, 0.14553317, -0.14953862, 0.03332451, -0.14511453, -0.045825552, 0.024108836, -0.0545644, 0.16476214, 0.030995745, 0.010498593, 0.10257483, -0.1942069, -0.023869447, 0.03358702) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22857334, 0.0016768894, -0.015052816, 0.012965192, 0.0036062568, -0.21082631, -0.07490414, 0.043113496, -0.10342659, 0.24758372, -0.03469842, 0.096542634, 0.03539014, -0.24977824, -0.058636863, 0.010397372) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.004926784, 0.054207988, -0.06837826, 0.004415711, 0.0577301, -0.11281282, -0.06926461, 0.0348221, -0.06994442, 0.16230205, -0.026652725, 0.03062164, 0.19936065, -0.23085888, -0.072741486, -0.047497157) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.14994375, -0.039791226, 0.40824848, 0.049226593, 0.07045929, -0.052622683, -0.15763386, -0.03942174, -0.069442734, 0.09520795, -0.06942357, 0.13387385, 0.28762126, -0.26739565, -0.3289157, 0.48672098) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.026655186, -0.1040532, -0.2554824, 0.021819303, 0.000499078, 0.23716632, 0.20162843, -0.30837625, -0.16973686, 0.2804819, 0.026698675, 0.11610341, 0.4082289, -0.3529683, -0.44973874, 0.30029562) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.2550735, -0.2311552, -0.7316982, -0.055087127, -0.15159392, 0.049061578, 0.24708778, -0.13015732, -0.06762666, 0.14592582, -0.035795696, 0.1949436, -0.05085508, -0.11451564, 0.16152157, -0.14265132) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.03203109, 0.14199652, -0.0029112725, -0.007224546, -0.26059875, 0.1120936, 0.17881015, -0.054751955, -0.1445534, 0.18749332, -0.07830499, 0.18197313, 0.58280313, -0.5463957, -0.6547348, 0.4038202) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.18779454, -0.15464583, -0.6062646, -0.033730578, 0.37168792, 0.11274335, -0.24189281, 0.25624365, -0.18512131, 0.34937117, -0.017974563, 0.28457114, 0.6098082, -0.18891823, -0.07673881, -0.675612) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08290882, -0.046536364, -0.25015256, -0.23233975, -0.12920202, -0.06922619, 0.02475647, 0.2815442, -0.14284499, 0.28462452, -0.10177383, 0.24822724, -0.08714388, 0.07297748, 0.08832549, -0.3483983) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.25371337, 0.15644206, 0.78410935, 0.044277873, -0.039778516, 0.1901228, 0.15324815, -0.2046068, -0.12580319, 0.1241113, -0.024277138, 0.1350592, 0.061604377, -0.045748163, 0.0015289577, 0.14641161) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1266694, 0.20298176, -0.110870056, 0.013242289, -0.28471503, -0.025229653, -0.024622954, 0.040284857, -0.12576298, 0.21977824, -0.003513242, 0.19969861, -0.2885246, 0.03980783, 0.3235528, -0.3022188) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13245884, 0.026184626, 0.36019295, 0.017877309, -0.09070148, 0.17642115, 0.1663875, 0.02743674, -0.11231675, 0.12074125, -0.1680984, 0.26804578, 0.1569731, -0.09429058, -0.15413857, 0.19352502) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

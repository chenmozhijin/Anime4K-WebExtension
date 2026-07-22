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

  var result: vec4f = vec4f(-0.0342799, -0.15119115, -0.047398075, 0.13208263);
      result += mat4x4<f32>(0.2587312, 0.2159604, 0.19886214, 0.02825556, -0.059966482, -0.07022471, -0.108714156, 0.4384001, -0.049239676, 0.22506763, -0.1349554, 0.031814113, 0.33212045, 0.5257551, 0.32225037, 0.17860545) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1017376, -0.25230584, -0.63332087, -0.018828623, 0.10600959, 0.15997401, 0.24340074, 0.15056017, -0.011752602, -0.31401327, 0.3010311, 0.13660458, -0.10940159, -0.31350332, -0.19880998, -0.17429247) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.015400413, -0.08640713, 0.020446207, -0.014471233, 0.106676586, 0.04963841, 0.10278888, 0.049375065, 0.010197726, -0.13298364, 0.07535169, 0.077400535, 0.07410023, -0.13644122, -0.13318813, -0.22997892) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20649058, 0.1392998, 0.3842869, -0.3811502, -0.12802546, 0.0015848607, -0.09702769, 0.5816024, 0.06878485, 0.32832494, 0.13788325, -0.091271415, 0.19809799, 0.34457913, -0.20040655, 0.3607458) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1851707, 0.28841043, -0.46943575, 0.09942252, -0.29380757, -0.28152224, -0.09978628, 0.13799773, 0.18004075, -0.048126165, -0.30726397, 0.6931716, -0.44177195, -0.064063124, -0.29089287, 1.3820324) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11391669, 0.33375475, 0.19928122, 0.0774706, 0.049868945, -0.0013536143, -0.09482469, -0.044591937, 0.36306423, -0.687774, -0.04311261, 0.27862954, -0.0009066891, 0.0205829, -0.00015032136, -0.4489894) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07251338, -0.023671567, -0.097193114, -0.10260802, -0.14576529, -0.375245, -0.15208492, 0.04134306, -0.10365106, 0.03266746, -0.031431243, 0.051352814, -0.05278, 0.22244908, 0.065651335, 0.08269243) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0390461, -0.27594364, -0.16416162, 0.20985763, -0.08493635, 0.16049725, -0.014000678, 0.066471756, -0.020198556, -0.18504849, -0.25337613, 0.44562307, 0.07562278, -0.2136435, 0.21082099, -0.01767369) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.024725555, 0.05477774, 0.049152464, 0.057001114, 0.11030921, 0.13348024, 0.055788815, 0.0006217319, 0.23307773, 0.1542541, 0.025550887, 0.07541858, -0.023066444, -0.055315398, -0.0757862, 0.12504998) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.076393425, -0.124935344, 0.075397104, -0.012256347, -0.056959074, -0.16336037, -0.075757764, 0.09349729, -0.1068602, -0.23822364, -0.10419375, -0.020803655, 0.20597187, 0.24624118, 0.08313128, 0.20096348) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.081131466, 0.10253004, -0.025462583, -0.06401063, 0.03683307, 0.133419, 0.1681069, 0.090290084, -0.1577189, -0.15773174, -0.13374366, 0.12554573, 0.14756402, 0.2390578, 0.20729375, 0.048832893) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030874813, 0.073033, -0.25094917, 0.1511664, 0.01328917, -0.033178724, -0.1339273, 0.05090621, -0.10575037, -0.12884435, -0.07864591, 0.01653135, 0.041682817, 0.15850647, 0.04867711, -0.12515414) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04764461, -0.65683526, -0.27985364, -0.0011022263, -0.036028106, -0.0648741, 0.02627508, 0.28338882, 0.17412268, 0.279405, -0.06687332, 0.092822805, -0.20522547, -0.054233283, 0.0733924, 0.03479596) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12642267, -0.25793424, 0.10936044, 0.4329462, 0.15521455, 0.2595122, 0.20356567, 0.40460077, 0.17436522, 0.010035009, 0.77232814, 0.13938798, 0.07531467, -0.019233057, -0.96097875, -0.16270825) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.004996132, 0.41478944, -0.1124226, -0.25806725, 0.23413076, 0.2872938, 0.26154965, 0.0675555, 0.02217256, 0.34653592, 0.10179439, -0.051509377, 0.003218673, -0.19923568, -0.24932931, -0.05846811) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.02778952, -0.20027317, -0.008466272, 0.20567153, 0.0153628, -0.16852106, -0.008316214, -0.11896525, -0.16673748, -0.12311801, -0.073457696, 0.20747943, 0.3004191, 0.014443515, -0.13292393, 0.19036087) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2811783, 0.6093652, 0.20979989, 0.34218827, -0.12855496, -0.38061315, 0.37537345, 0.23445116, 0.5233224, 0.3237871, 0.41232607, -0.18877363, -0.11828297, -0.06549561, -0.71656513, -0.37407485) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09809914, 0.2539689, -0.011239198, -0.113493435, 0.4180784, 0.30559182, 0.7319335, 0.5080125, 0.09538411, -0.06905746, 0.18488857, 0.07863931, 0.24722853, 0.44341093, 0.013455233, -0.54690844) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.073699094, -0.20662528, 0.0065451874, -0.06541986);
      result += mat4x4<f32>(-0.08242912, -0.037668824, -0.12037352, -0.04310021, 0.09307757, 0.105596945, -0.094589375, 0.041860037, -0.059841584, 0.13186267, 0.0068304073, -0.026316606, -0.10771246, -0.04018629, -0.2474234, 0.019251652) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0031626422, 0.08060586, -0.073884875, -0.08545253, 0.3385791, -0.18861143, 0.072433576, 0.112583466, 0.025776692, 0.12402883, -0.11972636, -0.06163171, -0.1925379, 0.13428244, -0.08210682, 0.48443532) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0057049566, -0.0014130714, 0.015105431, -0.0596886, 0.14797716, -0.062355775, -0.022726826, 0.067354, 0.1857729, 0.08012308, -0.10230575, -0.038972802, 0.1238015, -0.27378106, -0.09011853, 0.12841657) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17587322, 0.06889368, -0.07789142, 0.04547238, 0.02658016, 0.07646477, 0.082244955, -0.11137299, -0.11355145, -0.33310995, -0.05633601, 0.34651458, 0.1283162, -0.14049913, 0.11174991, 0.14887784) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.033269543, -0.3397834, -0.24746454, -0.2647519, -0.14450851, 0.48301202, -0.3663025, 0.14577301, 0.44552898, 0.027360855, 0.40831158, -0.22933769, -0.21470608, 0.66223615, -0.22258274, -0.12926465) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07028653, -0.10921106, -0.17248599, -0.0106016295, -0.1749409, -0.19401826, 0.19245344, -0.017355384, -0.26107016, 0.29804915, 0.24437119, -0.34954074, 0.03038877, 0.06430857, -0.06886271, -0.0046020825) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.008599324, -0.13790365, 0.057130728, -0.046872392, 0.062264133, 0.103127375, 0.01538797, -0.011984068, -0.06117234, 0.033298206, 0.14329898, -0.0051223435, 0.1990838, 0.017258028, 0.120420046, -0.21066311) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.024477743, 0.32877356, -0.24014707, -0.13041452, -0.013335017, -0.27085182, 0.01718017, 0.07804849, -0.44318116, -0.24851863, -0.5468354, 0.14576885, -0.2741597, 0.19229595, -0.40991306, -0.42591444) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03645132, -0.017595353, -0.0560842, 0.0115673095, 0.033985622, -0.18363014, 0.011792654, 0.09170294, 0.011193906, -0.18052109, 0.18043026, -0.06357989, 0.017139465, 0.12398914, 0.036252853, -0.07948548) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08190761, -0.04032544, 0.056347076, 0.033184618, 0.11339175, -0.10747898, -0.0038953773, 0.076202095, 0.04840359, -0.1303799, 0.05882814, 0.17082831, 0.12581728, -0.171423, -0.015876787, 0.089335434) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1434128, 0.19470428, -0.0036353078, -0.072914906, -0.060739703, -0.16513586, 0.011074614, 0.14504272, -0.13509502, -0.08405454, 0.10674001, 0.104672104, 0.19793734, 0.22212568, -0.17718036, -0.30535242) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08505989, 0.0032283124, 0.010698717, 0.08762584, 0.017886441, -0.13381469, 0.07822734, -0.04097465, 0.038218148, 0.01383437, 0.039285317, 0.13812242, -0.0017249299, 0.11249571, 0.045905944, -0.111614294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.031288613, -0.18408735, 0.11956904, -0.14127743, -0.03904012, -0.04849471, 0.19460258, 0.101954706, 0.1140598, -0.15695544, 0.19443843, 0.20534201, 0.04670265, 0.24762082, -0.027445972, -0.34610313) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.078444086, -0.08169932, 0.1453664, 0.117513776, -0.75441194, 0.03804846, -0.043943238, 0.6598195, -0.19777079, -0.5993788, 0.15389396, 0.27150178, -0.29478988, -0.51213163, 0.09293707, 0.048014626) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.018887643, 0.019742437, 0.047816515, -0.10360587, -0.079273134, -0.055960204, -0.33015865, 0.008475437, 0.044357818, -0.29102334, 0.072657764, 0.2856956, -0.008777515, -0.16507179, -0.02826964, 0.07449928) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.036787134, 0.009737015, -0.07977807, 0.013221738, 0.06885769, -0.15593709, -0.025113607, 0.11303701, 0.09276903, -0.26149216, -0.0043289303, 0.3449081, -0.04595044, -0.015537772, 0.0021829994, 0.009226967) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3494791, 0.022606974, 0.50396556, -0.31169438, 0.11528893, 0.12784469, 0.24829677, -0.2551147, 0.14352396, 0.25038633, 0.07072178, 0.39178815, 0.15908077, 0.23534438, 0.14171253, -0.38609007) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.17821588, 0.26680133, -0.013069947, -0.12854892, -0.08718185, 0.073507376, -0.008511674, 0.03304237, 0.011479634, 0.06742307, 0.035168394, 0.048119843, -0.009775092, 0.13966353, -0.20182845, -0.116963156) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

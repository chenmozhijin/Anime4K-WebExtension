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

  var result: vec4f = vec4f(0.2002699, -0.045578297, 0.07274895, 0.06854533);
      result += mat4x4<f32>(0.020069912, 0.15318234, 0.021471286, -0.066312075, 0.05879879, -0.09724887, -0.06880686, 0.22462651, 0.09336671, -0.094903015, 0.05624009, -0.007941579, 0.033684816, 0.22638257, -0.0870376, 0.018970406) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07076715, 0.010823245, -0.035361987, 0.2253903, -0.13069727, -0.27783546, 0.15476273, -0.30575794, -0.056601193, -0.05134666, 0.1502131, 0.076546684, -0.07472963, 0.18064986, -0.3144311, 0.21432504) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.042084128, 0.048153687, 0.08149147, 0.045536634, 0.004790093, 0.17256704, -0.3701853, 0.16657966, -0.0644148, -0.03779025, 0.16742289, 0.014834207, 0.027336547, 0.1430535, -0.21711713, 0.005699895) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18110956, 0.32809126, -0.15477178, 0.27515537, -0.21627188, -0.14327855, -0.28857088, 0.43296593, 0.059841055, -0.5070158, -0.14595547, 0.04367358, -0.09763415, -0.10485898, -0.15491171, -0.14252794) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.22879714, 0.70797384, -0.4869149, -0.08225349, -0.35026947, 0.008999596, 0.694786, -0.23620763, -0.16619341, -0.646992, -0.029769994, -0.19646376, 0.5070222, -0.24057326, 0.014864475, 0.3252854) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.012637137, 0.30711743, 0.05389036, -0.050109763, 0.23635419, 0.0067315735, -0.37268826, 0.27637607, 0.0107073, -0.14041382, 0.08970925, -0.044379856, 0.28171232, 0.37460014, -0.29670474, -0.18061543) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10337931, 0.0060614524, 0.05599677, 0.086528696, 0.023176532, -0.099447116, -0.020741941, 0.06376092, 0.13168123, 0.31501508, 0.055401333, -0.01554294, -0.02690855, 0.02851692, 0.037260436, -0.10943119) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1498663, 0.061163366, 0.008186385, -0.041382935, -0.10117903, -0.22800739, -0.15417305, -0.2344988, 0.06518221, 0.10531433, -0.07137394, 0.061438706, 0.053085845, -0.09528119, 0.1585084, 0.11440833) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08256516, 0.09371115, -0.008583017, 0.18235525, 0.16120012, 0.009205826, 0.100660376, -0.021060368, -0.0040638265, 0.010989555, -0.039077222, 0.038752306, -0.018318152, -0.14842768, -0.1904303, 0.18277256) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.011084671, 0.13190039, -0.0745387, 0.15720876, -0.10145151, -0.11756093, -0.2580313, -0.14983208, -0.09149982, -0.10133651, 0.08207204, -0.2064146, 0.03688444, 0.022155339, 0.04940976, -0.030897792) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2612975, -0.08110746, -0.11329786, -0.32204285, -0.18136379, 0.35327086, 0.056762397, -0.1705551, 0.00544782, -0.17725569, 0.21303308, -0.25063893, 0.088291705, 0.013992336, -0.14028342, 0.051166657) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03830785, 0.289319, -0.2221957, -0.42091367, 0.19763975, 0.030757805, 0.38995174, -0.22800618, -0.09657718, -0.16945435, 0.17903745, -0.06847638, -0.010303438, -0.22373928, 0.14758481, -0.024666652) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04182783, -0.012256466, 0.21080956, -0.048890363, 0.0035522624, 0.5218372, -0.3323382, 0.64432865, -0.1427467, -0.57101667, -0.06846105, -0.17701913, 0.21251401, 0.17659582, 0.064246505, -0.1453788) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.38503996, 0.73996353, -0.86233175, -0.22603327, 0.011922652, -0.04629086, 0.14195304, 0.20910397, -0.1626033, -0.805614, -0.29056776, 0.1958281, -0.33881783, -0.5794838, -0.17538674, 0.15768436) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.054719765, -0.05282481, 0.060502227, -0.28341618, 0.32368457, 0.08503143, -0.24345508, -0.026846476, -0.010526063, -0.44220316, 0.40009177, -0.21912257, -0.11353847, 0.17886657, 0.27644467, -0.32247528) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08683549, -0.13066676, 0.01758585, -0.22079884, 0.025733158, 0.014324917, -0.20050746, 0.31227228, -0.048398886, -0.034769055, 0.09755205, -0.18406157, -0.11139786, -0.049814343, -0.14547114, 0.03337375) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.045039967, 0.1179939, 0.0054837535, 0.011694336, 0.004125246, 0.105482616, 0.06324808, -0.17722802, 0.11326235, -0.05799427, -0.18413843, -0.0038121697, 0.09889882, -0.12575519, 0.09113633, 0.017799387) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.053936735, 0.029872788, -0.025981538, 0.11829621, 0.10708241, -0.01894746, 0.19437665, -0.044380624, 0.061232623, -0.0055767, 0.27022976, -0.10834628, -0.07482124, -0.09894505, -0.0047981273, -0.027045459) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

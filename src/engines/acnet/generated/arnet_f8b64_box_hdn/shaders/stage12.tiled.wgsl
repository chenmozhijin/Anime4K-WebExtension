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

  var result: vec4f = vec4f(0.041464645, 0.023299804, 0.10631345, -0.19930464);
      result += mat4x4<f32>(-0.35034198, 0.045757912, 0.09288237, -0.1471393, 0.06831307, -0.05254754, 0.5189894, 0.1518995, -0.69136393, -0.020277977, 0.08172606, 0.6496859, 0.11284653, 0.2115786, 0.011983152, -0.54777455) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0751247, -0.015225132, 0.08030328, 0.051223706, 0.37347695, -0.062361844, -0.09139395, 0.55024564, -0.42359468, 0.0676743, -0.28519413, 0.3751182, -0.3502642, -0.118933044, 0.092179, -0.8153919) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3086803, 0.15887856, 0.0012353313, 0.25889584, -0.06968346, 0.101368435, -0.04767168, 0.07197871, -0.3528641, 0.031126648, -0.6259706, 0.17918701, -0.35946417, 0.114189245, -0.16688731, -0.18946186) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.055504125, -0.17882414, 0.0047907047, 0.017897291, 0.05976418, -0.15994467, 0.35525334, -0.39975858, -0.06191254, -0.12838888, 0.18888335, 0.38935283, 0.14463264, 0.37081608, -0.24454485, -0.17766461) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20342682, -0.33677018, -0.18913263, -1.2122958, -0.0041313483, 0.46493772, -0.934207, -0.53818303, -0.2460895, -0.05682933, -0.27226073, 0.3321716, 0.26983342, -0.06798837, 0.17617722, -0.06628674) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.3994102, -0.041033145, 0.22701989, 0.076958425, -0.24626483, 0.37095863, -0.057027794, 0.14309295, -0.1110349, -0.016402362, -0.6392549, 0.4345463, 0.3531243, -0.25045922, -0.014894101, 0.11695753) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.42838934, -0.24080947, 0.23784138, 0.5764383, -0.17460805, 0.10688475, 0.1882131, -0.07049896, -0.5861525, 0.05824113, -0.01070955, 0.31469628, -0.01927901, -0.051941827, -0.24415442, -0.023497663) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.26383886, -0.06614228, 0.5685296, 0.22956644, -0.26667923, 0.049127866, -0.33512998, -0.21345344, -0.21886334, 0.00095892086, -0.33918366, 0.37196103, 0.02336506, -0.07099569, 0.02237659, 0.17927226) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.019665126, 0.01632734, 0.20981579, 0.10494982, -0.076555245, 0.124694355, -0.3200346, -0.0010653301, -0.50328326, -0.04208698, -0.48336002, 0.58847713, 0.20498767, -0.0840129, -0.035877515, -0.04845469) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.13032469, -0.07521234, -0.41136754, 0.14250854, -0.08072753, -0.010626548, 0.14467224, 0.37789133, 0.13700594, 0.26987126, 0.28213546, 0.5110616, 0.10317142, -0.15599403, -0.07971403, -0.1007149) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.25369826, 0.058375414, -0.26929948, -0.5069239, 0.20499717, 0.022817228, 0.10279335, 0.12012445, -0.29112217, -0.0097090965, 0.074522525, -0.31691074, 0.4308473, -0.035424404, -0.24578446, 0.33466455) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.011009946, 0.07432669, -0.18579967, -0.060925495, -0.16390115, 0.23268071, -0.3029167, -0.222141, -0.108617626, 0.24126764, 0.16030279, 0.70654625, 0.20472416, -0.101426564, 0.39509544, -0.3628482) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.02948501, 0.1880971, 0.055932183, -0.052264098, -0.15222895, -0.34914157, 0.07934072, 0.4215115, 0.5245418, -0.009761028, 0.5174605, 0.3425762, 0.3149714, -0.31693345, -0.2360966, -0.44487673) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.068000756, -0.49970755, 1.3786075, 1.0729014, 0.1458921, 0.14891344, -0.9079852, -0.32590172, 0.05147819, -0.102265924, -0.8605961, -1.4916686, 0.22257808, 0.050156217, -0.34485874, -1.2531728) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.32728648, -0.38441536, -0.012434386, 0.010462701, 0.3478317, 0.16344777, 0.047802035, 0.2575337, 0.037885975, -0.15303011, -0.122116685, 0.4219479, -0.19983414, 0.35029387, 0.54147214, -0.06859287) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18096147, -0.23124728, -0.018117161, -0.31299445, -0.13351399, 0.24687578, -0.02983834, 0.11158547, -0.0015164325, 0.05109101, 0.76880425, 0.42176753, 0.4301673, -0.03855101, -0.18623444, 0.13058607) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.059456527, -0.040363986, -0.18513526, -0.09212915, -0.0643325, -0.09071538, -0.10096656, -0.17173778, -0.54062486, 0.35307136, -0.011771759, 0.042435065, 0.16964568, 0.13530974, 0.3734856, -0.23122671) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.28386793, 0.1204545, 0.041500345, -0.31060317, 0.13020298, 0.23852405, -0.49875584, -0.18283334, -0.11420066, -0.062060095, 0.09247822, 0.21776873, 0.81434304, -0.048212614, 0.050157577, -0.31962752) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.039588585, -0.12644097, -0.156595, 0.22620226);
      result += mat4x4<f32>(0.094063655, -0.051727246, 0.022645261, -0.056961067, -0.08378937, -0.08739674, -0.093106955, 0.022250185, 0.05828517, -0.09302272, 0.056541067, 0.096412085, 0.013106613, 0.079757504, 0.025813796, -0.008747096) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.03530985, 0.004878635, 0.14650454, -0.020727847, -0.17012496, 0.08568226, -0.043037843, 0.069676995, -0.10058001, -0.1062655, 0.05578221, -0.07738717, 0.2641783, -0.3117186, -0.2071136, 0.038668245) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.1483367, 0.066508375, -0.00070987904, -0.056551185, -0.0412413, -0.14335911, 0.028204555, -0.014604479, -0.02337999, 0.15633659, 0.04990856, -0.006624086, -0.095491864, 0.081991695, 0.13472588, 0.065791726) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.034675814, 0.030569538, -0.10934373, 0.018347375, -0.13142605, -0.14327018, -0.19002755, 0.12592217, 0.02319928, 0.06491387, 0.24633658, -0.08985813, 0.074448, -0.018687453, 0.22704254, -0.07668084) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0034075703, 0.034894563, 0.061267264, -0.10817157, 0.15681106, -0.5299311, -0.27190435, -0.23990367, 0.02035199, 0.08297056, -0.036501188, -0.10118195, 0.3225779, 0.3071293, -0.07377868, -0.1234404) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10879205, 0.2777772, -0.018373178, -0.24956125, 0.045334365, -0.17513445, 0.06406124, -0.198409, -0.12837814, -0.3128768, 0.43051776, 0.34365684, -0.034346394, 0.034964968, -0.21520834, 0.23398343) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.05110834, -0.0130816195, 0.17456678, -0.15302047, -0.19304927, -0.019686759, -0.19240783, -0.030565707, 0.12294473, 0.0011325387, 0.25757277, -0.13630868, 0.1337041, 0.045776892, 0.15967526, 0.1457992) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24824134, -0.024436763, 0.04112497, -0.099227645, -0.04445408, -0.23537244, -0.04718405, -0.0232541, -0.30366728, -0.25985703, -0.59094626, 0.27127874, -0.028281828, 0.1880839, -0.05790111, 0.21467209) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.092004985, 0.14080606, 0.02067638, -0.4161111, 0.105809145, -0.115884796, 0.044346005, -0.0051244553, -0.081981264, -0.07866618, 0.019094752, 0.18156143, -0.064395994, -0.060905524, -0.09041804, 0.2327516) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.11304923, 0.021262214, 0.04337732, -0.06443657, -0.071448855, 0.031064741, 0.062059853, -0.05763047, 0.19069019, 0.16234829, 0.100211605, -0.121541, 0.03902255, 0.013224682, -0.038708158, 0.042772964) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13603286, 0.32226253, -0.35446262, -0.43370196, -0.0027647538, 0.22302261, -0.04677066, 0.031475913, 0.14452782, -0.07061391, 0.0909774, 0.09985209, 0.11376837, 0.20702682, -0.12470917, 0.2652017) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.008741278, 0.1596241, -0.2725885, -0.09525871, 0.07667705, 0.08171383, -0.0057254424, -0.011608309, 0.078830175, -0.16890742, 0.183086, -0.14405413, -0.04933902, 0.017368065, -0.23931488, -0.0063105593) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.22255673, -0.033064257, -0.0557389, -0.12262227, -0.04949294, 0.00673839, -0.019462487, -0.05599733, 0.43300563, 0.38878736, 0.117777094, 0.26701468, 0.09687303, 0.107835785, 0.02282632, 0.04770384) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3895991, -0.3189449, -0.5240479, 0.1336362, -0.087380745, 0.66372347, 0.18254906, 0.18457252, -0.45261946, -0.6229505, -0.042100348, -0.558016, 0.06330374, 0.3682127, 0.41883326, -0.24619772) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10293901, -0.14731571, 0.1119534, -0.24877618, 0.15483262, 0.13923004, 0.068809465, -0.11185226, -0.1538968, -0.23741278, 0.01309115, -0.4410567, 0.008162138, 0.17963952, -0.28473142, 0.055570763) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07672642, 0.10249862, -0.106042154, 0.026527671, -0.06327823, -0.15294814, 0.0036841559, 0.142828, 0.27850536, 0.27632284, -0.083898105, 0.09637565, 0.02689218, -0.035707906, 0.04775573, 0.06484387) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.027804159, 0.24942885, 0.06038043, -0.03378332, -0.034387354, -0.09120012, 0.10581965, -0.15652862, 0.30864945, 0.6041257, 0.03186951, 0.21966188, 0.061499085, -0.042013098, 0.014388241, -0.0012593218) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1354776, 0.039698485, -0.09496682, -0.08639498, -0.06164737, -0.08212955, 0.10262315, 0.025302622, -0.05108374, 0.044262644, -0.037717506, 0.003630966, -0.008872511, 0.015237601, -0.023471348, 0.14973322) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

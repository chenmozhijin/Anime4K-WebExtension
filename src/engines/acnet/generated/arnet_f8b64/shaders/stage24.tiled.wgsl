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

  var result: vec4f = vec4f(0.054032385, 0.1288465, 0.010828867, -0.15183645);
      result += mat4x4<f32>(-0.04132073, 0.024923544, -0.08391911, 0.021254163, -0.033553373, 0.114690356, -0.3236926, -0.24900287, -0.013347746, -0.07466561, -0.23992626, 0.19583729, -0.11823808, 0.052872322, -0.16477254, 0.07422745) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.087766886, -0.14363207, -0.0628591, 0.1288379, 0.2879626, 0.035823468, -0.54593486, -0.047149662, -0.3517713, -0.3264343, -0.0015565353, -0.17848787, -0.09063566, 0.029190507, -0.09443469, 0.27691492) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15050882, -0.014454889, 0.05926042, 0.095646515, -0.14238816, -0.052372575, 0.060108826, -0.2641563, -0.28514376, 0.018004265, 0.22058663, 0.13237926, -0.047826733, 0.06789037, -0.25039467, 0.121512145) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.05323551, -0.2070547, -0.015504686, 0.22901739, 0.53975356, -0.0049714404, -0.13318676, -0.21230198, -0.36441964, 0.34031934, -0.42751727, 0.10338408, -0.27406666, 0.052059337, -0.09744763, 0.25871012) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.24852744, -0.023542957, 0.17675963, 1.0942869, 0.40503243, -0.8995678, -0.5146578, -0.29391113, -0.02668084, 0.029551215, -0.20476694, 0.27385235, -0.037467714, 0.54711443, -0.051683612, -0.1703095) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.593733, 0.2031096, 0.104940265, 0.19341859, -0.53853303, 0.17662613, 0.5892249, 0.28297096, 0.09556396, -0.23331796, -0.08496127, -0.03587075, -0.40222847, 0.39395288, -0.33393645, 0.6012621) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1383834, 0.09910138, 0.036928255, -0.23526865, 0.07138279, 0.06585162, -0.019584505, -0.13181517, 0.11136635, 0.13722783, 0.21532054, -0.0891267, -0.07578882, 0.023306174, -0.057754736, 0.03606031) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16926233, -0.08198313, -0.003136256, -0.18957166, -0.041957926, 0.20735858, 0.09311498, -0.047465514, 0.24344058, 0.05140574, 0.011629642, -0.24944298, -0.12192728, -0.02679832, 0.02979667, 0.4530901) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.26941317, 0.022655854, -0.06371241, -0.058778737, -0.016485954, 0.075931296, 0.18028264, 0.028002383, 0.08942744, -0.026767943, 0.13890512, -0.098994926, -0.0018900889, -0.0194091, -0.17669834, 0.26356) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16549611, -0.07828685, -0.06121594, -0.09288024, 0.02169652, -0.052184135, -0.28169516, 0.18018533, -0.0632379, 0.11563351, -0.0003246725, -0.050291564, 0.2885645, -0.10371078, -0.058493793, 0.30532575) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3680396, -0.15196747, -0.07373343, -0.2750608, 0.39297926, 0.394177, -0.1264913, 0.021125512, -0.0371326, -0.055813245, -0.0117209945, -0.24691997, 0.8100267, 0.344486, 0.10823264, 0.335284) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15518723, -0.15375862, -0.14486742, -0.21767014, -0.5568401, -0.1689231, -0.2651361, -0.10399028, 0.22119147, -0.06789995, -0.039301045, -0.22603703, 0.05740231, -0.19568256, -0.2723475, -0.27996674) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.02841662, 0.3906506, -0.20853844, 0.21174455, -0.032906063, 0.55655146, 0.23529899, -0.27710727, -0.11152731, 0.12649204, -0.09720686, -0.11645657, 0.23182288, 0.57010895, -0.49359658, 0.20306404) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.016513683, -0.7177906, 0.814293, 0.74967676, 0.24039581, -0.125094, 0.2518402, -0.33335677, -0.32994887, -0.03861556, -0.2731257, -0.87217456, -0.0007544741, -0.30716923, -0.44967255, -0.20388265) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.009800085, -0.077373624, -0.12877886, 0.12894018, -0.27445588, -0.044645417, 0.101906456, 0.0065393588, 0.4525679, -0.10744619, 0.060451064, -0.054984156, -0.46348605, -0.10943977, -0.1183652, -0.18125427) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.059149478, 0.09528903, 0.07427181, 0.08171793, 0.23720247, -0.43627325, 0.06533436, 0.06958023, 0.2435279, 0.11395849, -0.05742593, 0.1607249, -0.0380444, 0.15739842, -0.0006389472, -0.29681692) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.26402903, 0.119299635, 0.007343825, 0.10654864, -0.09644249, 0.23642534, -0.12175011, -0.11680204, -0.0103285145, 0.22918221, 0.16268419, 0.31327152, 0.037901152, -0.1696509, -0.015513642, -0.3369147) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1900844, -0.039901465, -0.086395025, 0.0936205, -0.63849694, -0.27542302, -0.12967679, -0.44691935, 0.21753006, -0.049255267, 0.07108019, 0.10854258, -0.3377191, -0.11281172, 0.17008823, 0.054667227) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

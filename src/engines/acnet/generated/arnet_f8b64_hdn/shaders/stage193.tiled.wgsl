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

  var result: vec4f = vec4f(0.48802432, 0.15646386, -0.04491317, 0.036179047);
      result += mat4x4<f32>(-0.059923887, -0.041428957, -0.20350866, 0.032167792, -0.002601796, -0.07575923, -0.0023301938, -0.07708067, 0.043969296, 0.043550655, -0.038677096, -0.047333766, 0.06797118, 0.038736694, 0.032493494, -0.019467276) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0047699804, 0.06347021, -0.007796292, -0.12472604, -0.10532141, 0.06831787, 0.044525612, -0.1838295, 0.124669254, 0.17080577, -0.10219263, 0.0034640457, 0.0029876297, -0.09785867, 0.10686497, -0.038589522) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07510548, 0.050234806, -0.06539982, 0.1271318, -0.066008925, -0.14215593, -0.023371732, -0.04989525, 0.039375037, -0.020133512, 0.026697941, -0.016118327, 0.023081446, 0.026534567, 0.018440694, 0.026990538) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.044857275, -0.0042790105, 0.25506252, -0.07696838, 0.08863529, -0.034627307, 0.089232124, -0.044523306, -0.19206335, -0.019563753, 0.1956768, -0.06449833, 0.04826938, 0.0041728416, 0.08122332, -0.11724997) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.11703113, -0.5747289, 1.0144246, 1.0219179, 0.6946472, 0.22698359, -0.042818863, 1.1817952, 0.2527078, 0.29869246, -0.47005916, 0.027438905, -0.4200166, -0.03389834, 0.5543028, 0.14629231) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.024983931, -0.12034888, 0.12322532, 0.18924928, 0.029411063, -0.1787143, 0.14242347, 0.0028058963, 0.06471619, 0.21464768, -0.5757723, 0.07963052, -0.012504997, -0.12298125, 0.41222697, -0.20839743) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04093657, -0.025270075, -0.08472776, 0.03286831, -0.17647, 0.03422677, 0.08173052, -0.1087008, 0.06151534, -0.027333353, -0.10204693, 0.010098817, -0.004333375, -0.022776615, 0.099654555, -0.06925192) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0140055325, 0.31050828, -0.016389046, 0.0045168735, 0.057441883, -0.02196549, -0.026927361, -0.17992102, 0.062096298, 0.17538747, -0.36936888, -0.3102014, 0.0031951154, -0.30624354, -0.07358788, -0.01030792) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14718077, 0.10652772, -0.19995765, -0.07391234, -0.1494631, 0.028402714, -0.020535633, -0.07319472, -0.040609166, 0.018597947, -0.30246413, -0.09627837, 0.11903189, 0.012690945, 0.05309116, -0.12644479) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.12878485, 0.32060263, 0.1808329, -0.17333886, -0.22608607, 0.17899835, -0.3447997, 0.08873805, -0.032651797, 0.0015404138, -0.062289845, 0.09059785, 0.0681959, -0.07788688, 0.008405166, -0.16660672) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15112594, 0.04401287, -0.059415296, -0.10373208, -0.065472156, 0.0036855172, -0.4475556, 0.19750918, -0.21766347, 0.13269733, -0.18753493, 0.0058905086, -0.030111976, -0.20219356, 0.28241926, -0.41552034) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.18530196, 0.3411082, -0.24675618, 0.0012616672, 0.14397125, -0.2441386, -0.27305037, 0.23535836, 0.009818367, -0.1253936, -0.045261573, -0.091694355, -0.003939414, 0.119270444, -0.06323181, -0.41496298) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.19420223, 0.036436737, 0.55898064, -0.25122702, -0.0990796, 0.5442761, 0.26009938, -0.27171353, 0.033159383, -0.27114427, 0.03924414, 0.1773388, 0.012142257, -0.05410867, 0.12473861, -0.20417042) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.033720557, 0.12785017, 0.22620045, 0.022474894, 0.088874675, -0.21440218, 0.10201995, 0.12330057, 0.38311785, -0.09201653, 1.2381864, -0.5461207, -0.1368306, -0.25036487, 0.3692094, -0.21068102) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.119353175, 0.1281953, -0.460821, 0.050128665, 0.25871116, -0.25577202, -0.055698704, 0.12458445, -0.078452796, -0.17696092, 0.23353556, -0.20721076, -0.14715023, -0.16904718, -0.14657944, -0.23150657) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.102682434, -0.26339403, 0.1899623, 0.019154377, -0.09458553, 0.19341946, 0.262218, -0.20443228, -0.03950794, 0.23688008, -0.114505835, 0.119682595, -0.010135437, 0.022389306, -0.07867924, -0.050068285) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.07316479, -0.41161016, -0.11395154, 0.1910813, -0.095075525, 0.09340379, 0.35791466, -0.29310673, -0.04184401, -0.06325459, -0.015704855, -0.055943064, 0.013467866, -0.05774993, 0.027335247, -0.04475137) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16511038, -0.31477386, -0.24695309, 0.24298748, 0.12154511, -0.3851065, 0.38896933, -0.10551701, -0.08273815, -0.15973687, -0.05746408, -0.15482534, -0.0077514304, -0.037687384, -0.010153909, -0.19223055) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

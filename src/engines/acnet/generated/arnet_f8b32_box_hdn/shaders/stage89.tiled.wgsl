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

  var result: vec4f = vec4f(0.7273197, -0.1465648, 0.23020124, -0.010003405);
      result += mat4x4<f32>(0.12141064, -0.06218846, 0.16355672, -0.25378203, -0.07001036, 0.27853107, -0.019729102, -0.08289399, 0.119981244, -0.10835078, -0.09222677, -0.08772166, -0.15428542, 0.21720475, -0.2350685, 0.0028617952) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.30165198, 0.3229152, -0.29570803, 0.29800132, -0.1597499, 0.4282056, -0.058901664, -0.03555652, -0.012494704, -0.08428489, 0.0039832667, 0.100478135, 0.09927053, -0.105159946, 0.0062855477, 0.028850667) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05688574, -0.10889093, 0.14019608, -0.17645171, -0.18420042, 0.40892214, -0.0015792719, -0.08446673, 0.16736941, -0.18437327, -0.013907342, 0.10509591, -0.14657615, 0.32063434, -0.23479208, -0.11738008) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.23999351, -0.13135369, 0.17179546, -0.21343221, -0.09682675, 0.3966006, -0.016996382, -0.09130426, 0.045587458, 0.12172728, -0.03202155, -0.23175906, 0.20469062, -0.17773028, 0.28066915, -0.094108544) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.59882784, 0.13835245, 0.9286199, -0.10084422, -0.11384624, 0.58497167, -0.026805224, -0.038501926, 0.2842583, -0.843498, -0.15904473, 0.49354628, 0.025465965, -0.09200374, 0.60782164, 0.058253605) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20144098, -0.50261945, 0.13177362, 0.039881334, -0.15580073, 0.42375803, -0.08503319, -0.0059932494, 0.028775763, -0.09723359, -0.019507578, 0.01374038, 0.040660124, -0.08719535, -0.08358306, 0.09993526) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18835111, -0.5023893, -0.035092037, 0.108812094, -0.08816933, 0.3215818, 0.031097254, 0.0356809, 0.14177611, 0.07138059, -0.14519519, -0.19431981, 0.018241111, -0.12684374, 0.245518, 0.0908404) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06247996, 0.19543155, 0.14760126, -0.23241533, -0.14737123, 0.37282783, -0.002931729, 0.004201221, 0.10772088, -0.3231292, -0.07435381, 0.07318677, 0.17293532, -0.14134322, 0.14815609, -0.036480416) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.055584017, -0.27383864, 0.026650889, 0.020492673, -0.16110367, 0.31949612, 0.02806954, -0.01583812, 0.13886401, -0.1394105, -0.046315804, -0.05512761, -0.039669167, 0.026662054, -0.18474132, -0.054415204) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07950402, -0.29607424, -0.065384604, 0.011677577, 0.22087367, -0.34425068, 0.22048739, 0.110531576, 0.10731603, -0.15755774, 0.04048843, 0.10216776, 0.07684162, 0.0034085808, -0.08788231, -0.07825356) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.085858054, -0.5350108, 0.18750004, -0.05495896, 0.39274552, -0.271578, -0.3351838, -0.5758778, -0.05577489, -0.33309847, -0.14167342, 0.025743559, 0.083626084, -0.18115759, -0.03661129, 0.115311) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.25324374, -0.40312648, 0.006171952, 0.032834504, -0.021327054, -0.03790742, -0.10099016, 0.0113107, -0.07525486, -0.01562842, -0.026449172, 0.050857127, -0.098161645, 0.45380157, -0.104925305, -0.11967782) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.35597074, -0.56062794, -0.06773099, -0.0010499567, -0.027897233, -0.05542433, -0.2930552, -0.5530309, -0.074361235, -0.27377573, 0.18850368, 0.38431495, 0.13586065, 0.48031527, 0.056895524, -0.32214123) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.08753103, -0.196747, 0.17146741, 0.15937036, -0.7355892, -0.9831647, 0.21531402, 0.2692587, -0.4554689, 0.35764503, 0.31452757, -0.3307192, 0.2559304, -0.17279935, -0.20078671, -0.04522934) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30840567, -0.78467447, 0.12936221, -0.015224556, 0.03609348, 0.34128785, 0.13699998, 0.082718246, 0.087112695, -0.13873048, -0.058488052, 0.035504863, 0.08600223, -0.10760043, -0.044823967, -0.16992332) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.106177226, -0.3477521, -0.04249181, 0.03174767, 0.017441904, 0.06933509, 0.022066459, 0.22931728, 0.09662938, -0.1580222, -0.10924726, 0.06446954, -0.051716406, 0.15540746, -0.121233, -0.21149163) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10322391, -0.8903508, 0.09128325, -0.022530228, 0.098717816, 0.47645608, 0.043774262, 0.586311, 0.2437265, -0.1842296, -0.1586453, -0.35750917, -0.14790374, 0.34743062, 0.029395636, 0.27103338) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.035065666, 0.04006591, 0.048913885, 0.03861678, 0.07488152, 0.22357453, 0.013036321, -0.2754857, 0.01853198, -0.051274233, 0.02090619, -0.031024275, -0.04794347, -0.13119417, 0.117183134, 0.051290117) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

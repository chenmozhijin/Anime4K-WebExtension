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

  var result: vec4f = vec4f(-0.03887861, 0.13523504, 0.6149278, -0.19925992);
      result += mat4x4<f32>(-0.0064120553, 0.000758892, 0.01637982, -0.092009775, -0.012900508, 0.11780318, 0.040036697, -0.12983596, 0.13497968, 0.03575137, -0.067423575, 0.04956479, -0.123228095, 0.11282923, 0.14301346, -0.18263382) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.061817415, -0.036983527, -0.20649944, 0.025410987, 0.04710566, 0.024244428, -0.08422453, -0.060339157, 0.020602442, -0.027985794, -0.08509476, 0.10773242, -0.26687118, 0.057784718, 0.018028757, -0.14983222) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0138283465, 0.005077853, -0.071227215, -0.044731047, -0.0029551939, -0.12965563, -0.1097392, -0.011752219, -0.061773267, -0.10128882, -0.077481896, -0.1299748, -0.09967177, -0.020605838, 0.06701319, -0.11818872) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04643212, -0.06596677, -0.14199817, 0.1459881, 0.27973586, -0.3381927, -0.42308065, -0.038516384, 0.065314636, 0.08725334, -0.06663738, -0.50608516, 0.08543336, -0.023352515, -0.008005585, 0.010350637) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.44020498, 0.5597673, -1.097236, 0.032827437, -0.29672337, 0.37966496, -0.15077177, -0.56239843, -0.07383602, -0.39893866, -0.34821463, -0.66391456, 0.81936485, 0.19381176, -0.20449899, 0.16652872) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09549536, 0.10596743, -0.1078065, 0.0723122, 0.24555166, -0.052542564, 0.28983355, 0.38379288, -0.17655692, -0.17339309, 0.028284524, -0.021496007, -0.09868072, -0.055903997, -0.07697117, -0.13735552) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.01937931, -0.023353009, -0.01951696, 0.029173223, 0.024732834, 0.040234577, 0.1084804, 0.01714539, 0.0364273, -0.09840017, 0.21395764, 0.107707255, -0.10400016, -0.053401634, 0.012890006, 0.063104756) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.04249057, -0.056457054, -0.06231297, 0.017688459, -0.050329644, -0.03941763, -0.047338463, -0.24056059, 0.36238605, 0.111244746, 0.08633335, 0.14623989, 0.089579, 0.07816012, 0.011928569, 0.31896323) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.049362365, 0.0018932426, 0.025092008, 0.0116253635, 0.091914654, -0.007078197, -0.0069252537, 0.047516197, 0.111918695, 0.033448823, 0.08799309, -0.073778436, -0.13940449, -0.009688531, 0.015406771, -0.0778719) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.045355383, 0.110250026, -0.08305332, -0.06550038, -0.27116174, -0.009772716, 0.100973696, -0.18888602, -0.11383094, -0.27230835, -0.22206457, 0.07005454, 0.004646165, -0.109182425, -0.08482617, -0.08359113) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06060635, 0.13537621, 0.01428772, 0.05497372, -0.18984093, 0.15242065, 0.06556414, -0.10928676, -0.012730702, 0.025763312, 0.006930812, 0.19253618, -0.0725326, -0.21844116, -0.21632804, -0.014823184) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.019482844, 0.030398311, 0.06493442, 0.10447467, 0.120397024, 0.02933811, -0.0416582, -0.021624442, 0.012117223, -0.03742798, 0.0093422355, 0.15689941, 0.014460293, 0.033396777, -0.002954274, -0.06774529) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17972158, -0.24455485, 0.30372566, 0.3479925, 0.4330356, -0.8170423, -0.8154984, -0.06264932, -0.116553605, -0.47772592, -0.25738317, -0.2722286, 0.1075711, 0.13472997, -0.23340249, -0.029198347) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.008311177, -0.10936356, -0.36398453, -0.25461438, -0.01941451, -0.070239455, 0.20664246, -0.52110636, 0.29457173, 0.32415885, -0.23240198, -0.904227, 0.41027787, -0.050149385, 0.031610902, 0.49257556) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.052100107, 0.014108016, 0.11552202, 0.21387416, -0.2537814, -0.0043586367, -0.05368894, -0.49246362, 0.081369646, -0.0854338, -0.13368322, -0.06625447, -0.14680547, -0.16984744, -0.028292956, -0.08154945) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17715563, 0.13062434, 0.04220821, -0.027036587, -0.18482883, 0.19232714, 0.366223, 0.05642234, 0.011776218, -0.024180058, 0.08836882, -0.038882338, 0.02090474, -0.08561769, -0.080967784, -0.078518875) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09497193, 0.07429977, 0.099765815, -0.030180657, -0.12586977, -0.013805574, 0.25187513, -0.05887191, 0.08884412, -0.023994682, -0.012104476, 0.08357472, -0.03313215, -0.06253263, -0.02554025, -0.004940011) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.045715366, 0.00050998904, 0.0014976774, 0.14175236, -0.12788746, -0.0660474, 0.05883245, 0.11509935, 0.13618718, 0.051371176, 0.07171547, 0.013059205, 0.06408524, 0.28575858, 0.20991577, -0.09227278) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

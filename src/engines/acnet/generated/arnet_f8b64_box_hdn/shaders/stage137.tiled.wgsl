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

  var result: vec4f = vec4f(-0.033086613, -0.068518296, 0.16794398, 0.028627776);
      result += mat4x4<f32>(-0.2196796, -0.41327503, -0.13773175, -0.06325413, 0.19008219, 0.06376939, -0.007101913, -0.053682648, -0.3369524, -0.08204096, 0.049245708, -0.15760505, 0.2606605, -0.22553101, 0.3759769, -0.170155) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.013976106, 0.207191, 0.10019545, 0.019005435, -0.157301, -0.2898048, -0.19088154, 0.20264317, 0.02478256, 0.29162663, 0.28230536, -0.4925841, 0.072350144, -0.052360322, 0.1084074, -0.10701186) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18855727, 0.21475184, 0.1854644, 0.040468358, -0.11689917, 0.021536967, -0.07606961, -0.21443775, -0.02087489, 0.36738095, 0.20952716, -0.1885611, -0.017297877, -0.1718758, 0.032115106, 0.11682425) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.22747976, -0.8161993, -0.12069384, -0.15142177, 0.1839422, 0.1775565, 0.5292399, 0.10602414, 0.11981818, 0.07709384, 0.2770637, -0.029256089, -0.12663126, 0.030861832, 0.043967973, -0.36904547) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.055788077, 0.43095213, -0.3241009, 0.17740397, -0.02290722, 0.17838755, -0.37133315, -0.14230132, 0.06874605, 0.092835814, -0.18019836, -0.099818386, -0.047362506, 0.0018368302, -0.19208187, -0.22071655) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.16133, 0.32588547, -0.10855956, 0.13712893, -0.07480924, -0.07009737, -0.46621588, 0.41859826, 0.12183009, 0.21394192, 0.2891712, -0.025027234, 0.16536379, 0.061990447, 0.2305892, -0.040474724) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16480811, -0.07146942, -0.12823433, -0.32560122, 0.38070425, 0.1499851, -0.17736556, 0.36618334, 0.04739608, -0.06720666, -0.29074273, 0.41853374, -0.05490759, -0.22742847, 0.2551302, 0.0018630921) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15534636, -0.06889939, 0.014095442, 0.051628996, -0.031916387, -0.13876972, 0.38385418, -0.16912203, 0.124393314, 0.1828595, 0.5025203, 0.37122247, 0.07798853, -0.35048878, 0.013366825, 0.11190663) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.017014138, -0.06822856, -0.041613843, 0.068753585, -0.17219, 0.2704299, -0.21675138, -0.17351413, -0.00800963, -0.14785153, -0.28549454, 0.31524006, 0.08183123, -0.05643983, -0.053470463, 0.052513413) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.2403187, -0.28454548, 0.30227402, 0.08046943, 0.09973861, 0.0028371604, -0.028001016, 0.009832774, -0.1921288, 0.5310322, -0.37489146, 0.18100967, -0.072304755, -0.12573929, 0.18882686, -0.10317102) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3304571, -0.15201448, 0.2791109, -0.42274883, -0.3579816, 0.046118036, -0.052780196, -0.15050244, -0.06631877, 0.00070368574, -0.083746105, 0.08788526, 0.30970743, -0.4138945, -0.5663953, 0.79219764) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.040283296, 0.21981244, 0.25598216, -0.05020521, 0.11075454, 0.10405497, -0.15946975, 0.2191046, -0.081877545, 0.04959503, -0.32806087, 0.217777, -0.17126563, 0.08033445, -0.09162714, 0.014587329) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.010857048, -0.28120658, 0.03865212, -0.019410145, -0.12688161, -0.014500091, -0.13319829, 0.1583649, 0.093874745, 0.3326263, 0.048509907, 0.1988536, -0.08708014, 0.22365558, -0.255072, -0.03263398) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.31702456, -0.17702904, 0.037426967, -0.06444353, -0.100447, -0.09007903, 0.41482005, -0.26899496, -0.2742458, 0.0409068, -0.14526826, 0.4212873, 0.16882205, 0.038646378, -0.29962128, 0.30025107) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06670651, -0.24222796, -0.5069671, 0.22469372, -0.114699945, -0.21807738, -0.22904532, 0.2553099, -0.13066876, -0.39896536, -0.05701153, 0.031386346, 0.019301936, 0.12631685, 0.12911047, -0.13710374) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.18204863, -0.20326394, -0.112533815, 0.09823006, 0.004975285, 0.08896275, 0.07238159, -0.14866306, -0.121475756, 0.1775502, -0.18198802, 0.15786667, -0.25976086, 0.06187228, -0.18409698, -0.18276717) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.19907402, -0.019852826, 0.41791725, -0.011371144, -0.3158297, -0.22475833, -0.5096439, 0.2446406, -0.07122128, 0.034035128, -0.28189293, 0.13391344, -0.23270363, 0.14102586, 0.31395888, -0.34347633) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11834713, -0.10108373, -0.04177213, 0.46539894, 0.0657618, 0.0048234677, -0.015478419, -0.07510736, -0.17167455, 0.19507359, -0.4929547, 0.34744188, -0.04097057, -0.00930123, -0.086149044, -0.20422737) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

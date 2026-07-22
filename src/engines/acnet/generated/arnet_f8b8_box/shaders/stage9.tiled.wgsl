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

  var result: vec4f = vec4f(0.049373988, 0.25813428, -0.13214888, -0.022839403);
      result += mat4x4<f32>(-0.07126855, -0.24888712, -0.037390105, -0.05406215, -0.1092346, -0.0034967111, 0.008891644, 0.020716105, -0.15683259, 0.16351865, -0.15904276, 0.05780232, 0.11008522, 0.10224048, -0.61894834, 0.058252517) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21307684, -0.12157817, 0.020478675, 0.081513725, 0.047838546, 0.0043529538, 0.07310646, -0.0037751494, 0.19742827, 0.16403371, 0.04950524, -0.03385544, 0.27792564, -0.220919, -0.4074004, -0.02516097) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.027384687, 0.06825888, -0.013543723, -0.051791012, 0.020123566, 0.040421296, -0.16358323, -0.00927328, -0.06574925, 0.02410933, 0.03291477, 0.0052809874, -0.054038137, -0.16313308, -0.07838724, -0.0021985937) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.53081614, -0.54398894, 0.5628841, 0.6816942, 0.030817809, -0.054465793, 0.12987986, 0.0058020954, 0.16680731, 0.11122355, 0.48454323, -0.38600016, -0.14020158, -0.21828665, -0.2447556, -0.18954405) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.34278467, 0.030257555, 0.13044041, 0.43169734, -0.36653528, -0.015661845, 0.6873202, -0.6039187, -0.22194184, -0.35290354, 0.24801064, -0.08004449, -0.14852326, 0.057591833, -0.01395671, -0.025777204) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04634781, 0.02216606, 0.36052695, 0.1981138, -0.19887993, -0.12640424, -0.095626846, -0.08109892, -0.1640912, 0.044598132, 0.17445384, -0.10607322, 0.011246423, -0.09493262, -0.041871984, 0.010854617) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16037998, -0.030513141, 0.11815415, 0.10929076, 0.25929263, -0.033055488, 0.05817486, 0.067619294, -0.09042039, 0.047511514, 0.29807588, 0.2394785, 0.015373083, -0.029437995, -0.14191616, -0.04888462) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.06686803, -0.21263623, 0.04407469, 0.03726328, -0.35425702, -0.7084362, -0.30737218, -0.28984052, 0.048239127, 0.02049528, 0.05342938, -0.032764297, 0.054970615, 0.06584206, -0.13096313, -0.018479917) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0071404427, 0.012224161, -0.09375547, -0.076613754, 0.001371309, 0.18237793, -0.016262762, -0.0067549753, -0.0068161795, -0.044270035, 0.1246588, 0.022461921, 0.00654896, -0.047603283, -0.043559197, 0.026979603) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.18394159, 0.09680498, 0.1683763, 0.08395164, -0.027923578, 0.036137506, 0.2324747, 0.11026512, 0.08535781, 0.0986597, 0.13328189, -0.21245517, 0.110218674, 0.0031579726, 0.22393553, 0.048921563) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19473948, 0.023520838, -0.08985866, 0.5378938, 0.030912697, -0.2296569, 0.57240283, 0.35024363, 0.116277255, -0.17898749, 0.22198835, -0.23627304, -0.19174638, -0.084734716, -0.011428878, 0.031381603) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.028672377, 0.074021734, 0.2594466, 0.04120167, 0.1410026, -0.44011745, -0.01935333, -0.060659666, -0.088733144, 0.0027889223, -0.045076136, 0.035115447, 0.21744603, -0.16739835, -0.05610028, -0.052978795) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.104077525, 0.4265651, -0.032474246, 0.2095302, -0.014102015, 0.18895248, -0.08166111, 0.00045788757, -0.14518476, 0.48436245, 0.07423403, 0.18981391, -0.09601961, 0.29884687, 0.1457735, 0.08583067) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28979814, 0.15916328, 0.17781287, -0.15562367, -0.123084225, 0.04301324, -0.071079634, 0.27262136, 0.06277302, -0.38471445, 0.21582986, -0.581279, -0.028112667, -0.5265028, 0.64048713, 0.1151589) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.19793527, -0.10530478, 0.21704964, -0.008131968, 0.3437505, -0.16582823, -0.039322414, -0.07625053, -0.07351149, 0.07665634, 0.14875929, -0.14102286, 0.02903571, -0.26383972, -0.12314303, -0.19156882) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.047745887, 0.07905425, 0.18237466, 0.06147824, 0.047936916, -0.09878022, 0.014740672, -0.0343897, 0.041287664, -0.13412835, 0.28004062, -0.067979805, 0.086975634, -0.10876432, 0.06667547, 0.018270101) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.5691467, 0.4609971, 0.19257943, 0.1295698, 0.09381343, -0.11883901, 0.17737877, 0.084192924, 0.29666364, 0.28354296, 0.049759984, -0.038635798, 0.25305417, -0.25384995, -0.20156465, -0.18267001) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.29540393, -0.12792116, 0.35441744, 0.2756446, 0.13396713, -0.22880532, -0.12077984, -0.015775627, 0.13166532, -0.05435382, 0.0075238063, 0.032187972, 0.07963669, -0.22004735, 0.06726409, 0.011895151) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.38066348, 0.06468005, 0.5356549, -0.0709297);
      result += mat4x4<f32>(-0.0767079, 0.081954814, 0.009920497, -0.13455756, -0.093720645, -0.071256615, 0.01589539, 0.124781854, 0.037478574, -0.010119625, -0.13118625, -0.00043729148, 0.0044228313, -0.08839695, -0.052232925, -0.18265168) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19251876, 0.026579505, -0.035387397, -0.22219221, -0.45057717, -0.011287463, -0.53529495, 0.6841883, 0.3058232, 0.16755255, 0.065125525, -0.1746937, 0.118340686, -0.027178962, -0.20281541, -0.10378637) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.20281722, 0.025082974, 0.11863818, -0.20592196, -0.09768093, -0.08118497, -0.22970547, 0.08277263, 0.041699853, -0.16223623, 0.030610615, -0.4784799, -0.0428862, -0.0429368, 0.02895337, 0.06630239) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2005641, 0.047070485, 0.08132329, 0.06526253, -0.09157426, 0.10942589, 0.25066215, -0.22936958, 0.12257981, -0.16410837, 0.04172757, 0.074552745, 0.12342979, -0.1675984, -0.195324, -0.19099149) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.67736983, 0.17612919, 0.019470518, -0.12444993, 0.11767567, -0.3509253, -0.30429822, 0.07288032, 0.1564969, 0.3234621, -0.35089916, -0.8335319, 0.5690514, -0.37548038, -0.12563309, -0.22447103) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.28790867, 0.060825706, -0.067315295, -0.06394726, -0.18830168, -0.08921637, -0.26768202, 0.022100098, -0.0134811215, 0.29169607, -0.6539612, -0.67535836, 0.079454735, -0.11860599, -0.22988774, -0.11816042) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14861645, -0.008935526, 0.008935416, 0.11569036, -0.09847871, -0.040294033, -0.0067562745, -0.038073782, 0.15202151, 0.07237683, 0.26165178, -0.267109, 0.04469125, 0.23253289, -0.34795848, 0.095313706) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4378188, 0.02133888, -0.22642784, 0.2484429, 0.3042269, -0.057898033, 0.049907, -0.2806478, -0.05843241, 0.2888242, -0.23673671, -0.50462496, 0.27283204, 0.035265792, -0.0948853, -0.18105194) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.36867803, 0.020414418, 0.033903968, -0.018067352, 0.18746877, -0.046058062, 0.2030949, -0.29838434, -0.4151127, 0.27108055, 0.36990735, -0.20462234, 0.0030700765, -0.23499054, -0.14249678, 0.021814894) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.19936192, 0.108398594, -0.021434978, -0.41076192, 0.121968105, 0.17922206, 0.19415216, -0.4283511, 0.12863334, 0.07727253, 0.020517271, 0.13857795, -0.17374437, 0.029402014, 0.041588996, -0.15412036) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16807698, -0.038121562, -0.11287847, -0.2251815, -0.2563953, -0.13845569, 0.09994661, 0.12605909, -0.23016453, 0.07415332, 0.113991074, 0.1839882, -0.053644434, 0.07019347, -0.0059273103, -0.13106948) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.123467974, -0.07663917, 0.019993883, -0.100888774, 0.022263652, -0.066770084, 0.07160685, 0.7784528, -0.15170595, -0.01907981, 0.06529432, 0.00451102, 0.013025053, 0.06076294, 0.00825258, -0.03625531) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16917318, 0.2555803, 0.50153536, -0.44768727, -0.003025021, -0.04743894, 0.58625257, -1.0332304, -0.18676406, -0.0010456388, -0.23973364, 0.24544677, -0.1514566, -0.028006397, 0.19938196, -0.14615658) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6364828, -0.3223993, 0.18623336, -0.15106495, -0.1860803, -0.22971654, -0.6780349, 0.22731847, -0.70443255, 0.111610875, 0.026319439, 0.16033079, -0.22718784, 0.39895627, 0.13103107, -0.17604582) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.19892327, -0.3172146, 0.075525776, -0.20178345, -0.025453802, 0.18850192, -0.22466038, 0.6367155, -0.15682365, 0.008090735, -0.067337096, 0.17187716, -0.09119457, 0.18935308, -0.046986785, 0.013280262) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.005835704, 0.031203473, 0.14114407, 0.03258264, 0.39242005, -0.004897737, 0.2697299, -0.5310681, -0.24172848, 0.19176923, -0.16896798, 0.36209634, -0.13020688, 0.01981512, -0.07618731, -0.11228454) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16359207, -0.057772662, -0.04936976, -0.07204657, -0.26767248, -0.20420747, -0.082463756, 0.17226729, -0.7541385, 0.46717703, -0.0019712336, 0.26088417, -0.10064949, 0.14482224, 0.008753862, -0.31963795) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.026322316, -0.039915796, -0.09714455, 0.10320932, -0.26666436, 0.20389538, 0.0021885808, 0.42836154, -0.010646215, -0.06429419, 0.031005077, 0.005316065, 0.13663289, -0.089189924, -0.30912971, -0.32082546) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.15556537, 0.012156508, 0.021771323, 0.07153477);
      result += mat4x4<f32>(0.06772355, 0.100257315, -0.049640298, 0.04033185, 0.057203732, 0.25242993, -0.026980069, -0.045837488, 0.0064312657, 0.1465986, 0.15091869, 0.04750542, 0.05463845, 0.25805292, 0.0713556, 0.28028056) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.43743145, 0.46232623, -0.20084292, -0.25011143, 0.21795939, 0.34693176, 0.08480375, -0.19670048, 0.059419427, 0.37467465, 0.16563216, -0.3401799, 0.08035733, 0.34977683, -0.24182022, 0.43165606) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15296884, 0.2781425, -0.0020619156, -0.112566575, 0.21025269, 0.5278244, -0.19415486, 0.15520251, -0.05139806, 0.2108135, -0.020892875, -0.044839244, 0.06393394, 0.14893954, -0.072998576, 0.18990694) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.050732825, 0.15119502, 0.3419401, -0.2013724, -0.10923325, -0.11065948, -0.08912689, 0.04873872, 0.10034578, -0.2999061, -0.104312725, 0.064840086, 0.08283379, -0.09290999, 0.21368492, 0.11688448) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.36564574, 0.5712593, 0.16497515, -0.18117762, -0.09711249, 0.16379581, 0.036286853, 0.12643889, 0.18681742, -0.14788759, -0.09814239, -0.6799984, -0.21299253, -8.2098035e-05, -0.16502756, 0.32984757) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.027165662, -0.12503794, 0.1015716, 0.14175534, 0.0037365886, 0.29727483, 0.1243336, 0.07077178, -0.031804357, -0.08379676, -0.040434647, -0.16953409, -0.075191036, -0.06959689, -0.01243759, -0.017523834) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14247783, -0.14730711, -0.05950639, 0.18318157, -0.22432055, -0.36385438, -0.18178268, -0.23729707, -0.14558911, -0.29297715, -0.051768404, -0.17974079, 0.041710205, -0.38628167, 0.0001460659, -0.12480264) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2208173, -0.48437884, -0.13521732, -0.07781696, -0.054612473, -0.20765202, 0.026141796, -0.26739398, -0.1823893, -0.27553108, -0.21476072, -0.34967214, -0.34166294, -0.9286558, -0.21262503, -0.44829085) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.124601595, 0.056638867, -0.15437022, 0.023885569, 0.026412325, -0.20560013, -0.041557606, -0.15911698, -0.07156218, 0.018020554, 0.10513611, -0.07995163, -0.10387951, -0.3316376, -0.009328282, -0.13250025) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.22031991, 0.014512364, -0.25667837, 0.00480982, 0.028543986, -0.07672547, 0.2643801, 0.049175538, -0.09013022, -0.36169103, 0.29363966, 0.3023344, -0.14732589, -0.41147053, -0.061585154, -0.105376154) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11729326, 0.047614623, 0.18527724, 0.02512304, -0.26824415, -0.0040107667, 0.24828783, 0.43374386, -0.10774074, 0.16171274, 0.153277, 0.33992678, 0.049725994, -0.5103685, -0.21666586, -0.2543559) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06267196, -0.016156452, 0.06720389, 0.023494262, -0.06075362, 0.012979249, 0.112246946, 0.0138345, 0.1221665, 0.26958042, 0.058597405, 0.14352557, -0.024287988, -0.10406427, 0.020082865, -0.30356824) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.09987006, 0.13165042, 0.37585214, -0.31876978, -0.005698248, -0.23521566, 0.0013446413, 0.41234404, -0.15967917, -0.62540436, -0.22262135, 0.07927656, -0.23073229, -0.24585563, -0.15679654, -0.07899232) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.04055434, 0.2935907, -0.10739839, 0.17210932, 0.050605197, 0.039098956, 0.2641072, 0.44370335, -0.12736514, -0.19144505, -0.4017224, 0.035619028, 0.14650676, 0.52231777, -0.2176181, 0.018849703) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.15200032, -0.0016520609, -0.03646312, 0.026035316, 0.050975308, 0.36713928, 0.008857608, -0.34282774, 0.20418635, 0.5322951, 0.113137625, 0.10625273, 0.25106826, -0.22274734, 0.30210817, -0.03447258) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0924809, 0.08093218, 0.1634633, -0.09525103, -0.0108108595, 0.2909333, 0.1368281, -0.23452216, 0.0027705624, -0.059188347, -0.0137291765, -0.30974093, 0.12636872, 0.2278487, 0.0050648265, 0.4498069) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.026160872, 0.10050654, 0.042094015, -0.16322447, 0.407847, -0.23901854, 0.33572212, -0.19540322, -0.024285005, 0.33141866, 0.07889844, 0.17564988, -0.11615889, 0.49166778, -0.062014338, 0.6492696) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.020351885, -0.016159393, -0.0071500167, 0.17167102, 0.025985746, -0.42345846, 0.23422797, 0.068273835, 0.004318945, 0.11756658, 0.13038939, 0.4123831, -0.10355015, 0.24892686, -0.17213705, 0.26685664) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

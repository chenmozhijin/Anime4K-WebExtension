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

  var result: vec4f = vec4f(-0.12948991, -0.28050852, 0.22117473, 0.11464019);
      result += mat4x4<f32>(0.04391543, -0.13869178, 0.00047433926, -0.030327149, 0.08826648, 0.10270716, 0.15718427, 0.008825867, 0.030548029, -0.012347166, 0.046959806, -0.043189835, 0.18020806, -0.04137378, 0.005478392, -0.21848187) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13665588, -0.19273984, 0.03068776, -0.29598945, -0.013790708, -0.24233218, 0.056738224, -0.2720725, -0.057206877, -0.16334417, 0.036696933, 0.065244354, -0.08532367, -0.104645185, 0.14869398, -0.12197596) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09175599, 0.0019316842, -0.01751461, -0.23538727, -0.014632696, 0.10202995, 0.042970132, 0.055802256, 0.038918264, 0.19325398, 0.095445834, 0.070481986, 0.15050577, 0.060528617, 0.16758576, 0.1445034) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.011522432, -0.1306647, 0.20120716, 0.20962498, -0.15366848, -0.1437431, 0.12376688, 0.07396961, 0.20254508, 0.012931863, 0.27233475, -0.26225355, 0.23091595, -0.3405078, -0.07812378, -0.09911674) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.109589525, 0.8747024, 0.13788667, 0.41666043, 0.5514816, -0.7071925, -0.3461034, -0.67290103, 0.3123256, 0.12483883, -0.00924227, -0.29665232, 0.5498897, 0.62520206, -0.67975193, -0.4400029) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.066120766, -0.05472827, 0.023720335, 0.16471703, -0.07761577, -0.08070809, -0.11841236, -0.2574825, 0.01352341, -0.048716366, 0.099626146, 0.019494936, -0.13290927, -0.19171228, 0.122030705, 0.16208035) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0196973, -0.11333929, 0.10771288, -0.044224177, 0.031014228, 0.09800109, -0.102642894, -0.046477556, -0.10794801, -0.019491736, 0.08744968, -0.09936815, 0.06605578, 0.255114, -0.039725933, -0.12540191) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.072564386, -0.27847153, -0.09782583, -0.2313914, -0.11163167, 0.4759054, -0.0015854186, 0.22312324, 0.18605858, 0.20759834, -0.6553147, -0.71165866, 0.036020376, -0.41778785, 0.00953349, -0.19107181) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.017708989, -0.014494044, -0.085856006, -0.13982074, 0.021767605, 0.07114787, 0.08474996, 0.07121126, 0.11970648, 0.11181426, 0.063959636, 0.043736976, 0.09116088, 0.021345261, -0.08731229, -0.13149127) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0071740737, -0.20756045, 0.045016307, -0.24958895, 0.10597878, -0.2259466, 0.10648363, -0.19385897, -0.009456848, 0.054326225, -0.0669337, -0.0023071368, -0.13193715, 0.26554868, -0.004668444, -0.036461033) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.32587275, -0.13924678, -0.03953413, 0.3541248, 0.063190825, -0.5460355, 0.12731983, -0.42152387, 0.014905056, -0.20470318, -0.092913166, -0.3690944, 0.00441742, -0.017895471, -0.14057122, -0.16828519) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07323891, 0.47109714, -0.08848807, 0.24026254, -0.29668626, -0.3121386, 0.030199617, -0.023039946, -0.019729236, 0.09289651, -0.16982764, -0.41583994, -0.009229551, -0.11312369, -0.12931584, -0.3503763) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07766377, -0.36979333, 0.15952729, -0.25521806, 0.0761223, -0.3368411, 0.04838379, -0.39965707, -0.01346502, 0.18349914, -0.14471665, -0.12462301, 0.017179383, -0.051993642, -0.15558772, 0.08809309) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.04738387, 0.34298506, 0.00036439454, -0.40851936, -0.07417837, 0.07151576, -0.013404318, 0.6504544, 0.1918537, 0.035510313, -0.6180186, -0.01302804, -0.34311077, -0.18768172, 0.7827772, 0.57783437) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1045448, 0.27276194, -0.16306555, 0.07889464, -0.16401282, 0.09682621, -0.04963069, -0.35447425, 0.045376863, 0.02041086, -0.13232596, -0.3672342, -0.00563311, 0.19246756, -0.12017961, -0.074874334) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08020963, -0.27940595, 0.093880355, -0.18044941, 0.10648142, 0.12326436, 0.038163945, 0.1594273, -0.05666598, -0.10847972, -0.009569247, 0.031250566, 0.01860632, 0.011912646, 0.014833801, 0.05256218) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.03570976, -0.2929122, 0.024891926, -0.011984064, 0.11621928, 0.25644597, -0.07144811, 0.11345291, -0.07845814, 0.09840631, 0.043443862, 0.33401942, 0.033934057, -0.0006630195, -0.003946594, -0.15793607) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1521885, 0.3520192, -0.1721748, 0.37785584, -0.10110454, 0.37494087, -0.14470278, 0.058226697, -0.035602998, 0.039046317, 0.033830464, 0.19936763, -0.011211862, -0.051032722, 0.089727044, 0.078411855) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

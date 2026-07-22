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

  var result: vec4f = vec4f(0.05853319, 0.045015678, -0.006380818, -0.100892365);
      result += mat4x4<f32>(-0.016570438, 0.105419554, -0.04172954, 0.30124712, -0.10602896, -0.107655086, -0.06528355, -0.1595247, -0.08099775, -0.041057635, 0.11309822, 0.11969091, -0.13856988, -0.034450892, -0.02788296, -0.28766784) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.021805506, 0.030488066, -0.17271668, -0.048974637, 0.078738995, -0.12283425, 0.13713247, -0.010566703, 0.047315903, 0.09862328, 0.24897093, -0.1658509, 0.35159874, 0.004148411, 0.07006939, 0.15304695) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06888237, -0.067851074, 0.15935667, 0.01965647, -0.07903888, -0.37580246, -0.07325699, -0.0036209435, -0.031335153, 0.17756774, -0.2113949, 0.22456488, -0.001712085, 0.0035688542, -0.051032178, -0.14713687) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0024738947, 0.06137666, 0.004203918, 0.35530007, 0.022868844, -0.034291223, 0.15154463, -0.19678858, 0.091137074, -0.02178506, -0.07395796, 0.10307382, 0.21487671, -0.16027948, 0.16839992, -0.40708148) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.019646626, 0.041380953, -0.0035201753, 0.61275834, -0.21688057, -0.35034475, -0.061199173, -0.04167529, -0.0100653265, -0.10325226, 0.0646113, 0.3423761, -0.28899038, -0.16890612, -0.023579635, 0.90174276) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.022516184, 0.082356, 0.1924883, 0.004532232, -0.087055326, -0.35366747, -0.11526567, -0.10033022, 0.1287813, 0.50854987, -0.10241881, 0.62458503, 0.23623024, -0.022939838, 0.037972894, 0.22778279) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12821513, 0.46389073, -0.020581532, 0.002316181, -0.024968386, -0.07117416, 0.030278578, 0.00660291, -0.08819886, 0.02117581, -0.048599146, 0.26674187, -0.07665011, -0.14027001, 0.1741653, 0.13231999) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21961002, 0.6176754, -0.017472472, 0.07049602, -0.06838786, -0.3534035, -0.017311733, -0.11467251, -0.00937894, -0.20744465, -0.2364634, 0.20344414, -0.038670156, -0.21975161, 0.07575928, -0.24288127) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0017536057, 0.22174108, -0.026838036, 0.03218653, -0.061335612, -0.38282952, 0.0670993, -0.10698524, 0.12777793, 0.27462873, 0.09146189, -0.123791344, 0.11841327, -0.26585668, 0.07693275, 0.07140594) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.1907004, 0.14902477, -0.100352794, 0.23713768, -0.015247636, -0.062636375, 0.14052041, 0.04580724, -0.06717663, 0.28182235, -0.1488138, 0.1658784, 0.07179395, 0.17215355, 0.070448816, 0.061770257) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.01615239, -0.14013435, -0.12547484, 0.3865537, 0.0414377, -0.04098608, -0.12941132, -0.16365208, 0.040658172, 0.056864217, -0.07278225, 0.21889284, 0.13639157, 0.24117196, -0.107506946, -0.07260714) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08547119, 0.047603052, -0.053444136, 0.06083153, -0.045143377, -0.008510661, 0.11543741, 0.04145431, 0.09913206, 0.33065197, -0.16164559, 0.11837032, -0.12841469, -0.19600277, 0.072758116, -0.12210969) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.124822244, -0.03031618, 0.469648, -0.15505776, -0.16939265, -0.45743218, -0.28054592, 0.073465936, 0.0077826264, 0.2457046, 0.045399573, -0.114948176, -0.07449856, -0.020159133, 0.32209605, 0.15640447) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.22460957, 0.24193977, -0.25435433, 0.21804729, 0.03406231, -0.35430843, -0.8542093, -0.34593394, 0.08343865, -0.1914265, -0.031862434, -0.17519757, -0.47138566, 0.61648715, 0.22869243, -0.66331637) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06024391, 0.24663383, -0.10396032, 0.045959637, -0.10428391, -0.13559918, -0.15179835, 0.23337802, 0.104538694, -0.30425033, -0.042154815, -0.09099846, -0.18930905, 0.19573674, 0.030635906, -0.20209625) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.27771685, 0.20168106, 0.17494766, 0.069564946, 0.13908058, 0.3597653, 0.18384546, 0.079346046, 0.18923864, 0.4277358, -0.13235761, 0.38026562, 0.066730775, 0.036173094, -0.0013153814, 0.15362546) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09104852, -0.013300039, 0.03840574, 0.22653523, -0.15074596, -0.4903625, 0.011771245, -0.07545365, -0.12782723, 0.23332056, 0.15225956, 0.11841339, 0.050927095, -0.11588082, -0.22610112, -0.022774791) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.024472708, 0.013558817, -0.054086737, 0.047955614, -0.11730068, -0.028453467, 0.05071763, -0.2370471, 0.0626538, 0.0020462729, 0.14947544, -0.02636699, -0.0056860214, -0.049692508, 0.012557746, -0.28750712) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

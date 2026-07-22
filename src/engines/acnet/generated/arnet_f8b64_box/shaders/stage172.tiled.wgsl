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

  var result: vec4f = vec4f(0.268401, -0.055689976, 0.2250669, -0.061259266);
      result += mat4x4<f32>(-0.101679705, 0.4376244, 0.56328714, 0.07728186, -0.015067727, 0.063726224, 0.0194873, 0.039178573, -0.023531934, -0.039545547, 0.13079254, 0.607083, 0.1614845, 0.03511633, 0.038322385, 0.10980526) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.071967565, 0.15665899, 0.20156944, 0.12518157, -0.16667698, 0.07205308, 0.15696988, 0.17854868, 0.06805725, 0.14754215, 0.109819226, 0.09933957, -0.14662166, -0.017872686, 0.05692064, 0.1839147) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.014859305, 0.5332545, 0.49705586, 0.031667598, -0.15988244, 0.05749394, 0.19283372, 0.16550781, -0.13337223, -0.07950142, 0.09832635, 0.019181406, -0.091961, 0.01988113, 0.12386326, 0.19718783) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15519652, -0.38402635, -0.4014613, 0.17339227, 0.035023026, 0.11954901, 0.20126456, 0.08807315, -0.27266365, 0.22970845, 0.06317775, -0.01907877, -0.085188575, -0.032993335, 0.011689095, 0.01218087) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.12264788, -0.31826508, -0.26510108, 0.335596, -0.18747626, 0.07931039, 0.15162638, -0.38933513, 0.07737778, -0.087736346, -0.10014662, -0.14029808, -0.0072494587, 0.14500612, -0.15582784, -0.4639367) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.32249573, 0.101267524, -0.25960976, -0.52839446, -0.007612659, 0.09437504, -0.0031361184, 0.08504049, -0.18884961, 0.008315635, -0.016080687, -0.12556079, -0.22961195, -0.11528938, -0.12711506, 0.12565656) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.041260727, -0.18846337, -0.029040748, -0.010440104, 0.04051956, 0.10723699, 0.108031064, 0.022767276, 0.24652262, -0.071742944, 0.0061280425, -0.15865767, 0.12598306, 0.04218978, 0.014683218, -0.15171033) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.082073286, -0.3005101, -0.1838161, -0.008752329, 0.09097997, 0.124917276, 0.16539463, -0.019583752, 0.3169514, -0.16629353, -0.032442067, 0.03800758, 0.38532415, -0.14067498, 0.22482316, -0.24195115) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0115765035, -0.18475567, -0.18723616, -0.16846561, 0.0949635, 0.12159868, 0.19737661, 0.027359147, 0.08246437, -0.06163549, -0.040327836, 0.05296777, 0.04470982, 0.0053982073, -0.039187342, -0.15137057) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.3443325, -0.18410787, -0.18105887, 0.28231406, -0.046814222, 0.092983045, -0.030343922, -0.041437246, -0.083051965, 0.11397806, 0.24894007, 0.05586918, -0.12095003, 0.3981445, 0.19343519, -0.2406269) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3952198, -0.03702756, 0.09180443, 0.031095238, 0.3344125, 0.013593924, 0.055687588, 0.29601896, -0.4451836, 0.20705526, 0.7205052, -0.37340066, -0.16854903, 0.19644636, -0.092757255, -0.41980284) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07038782, 0.08665442, -0.13488367, -0.092543036, -0.03392713, 0.071599, -0.012144251, 0.044623658, -0.10465655, -0.04030882, 0.20151593, -0.18522128, -0.14440559, -0.020145167, -0.054604005, -0.32800123) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.046732023, -0.0198085, 0.14067723, -0.19893089, 0.0982011, 0.01459626, -0.013508089, 0.015573292, -0.024186166, -0.04182767, 0.07181724, -0.09896394, -0.15604793, -0.016201582, 0.019446103, -0.14359586) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4615432, 0.2241883, 0.052077554, -0.23887357, -0.14500606, 0.012321792, 0.1850509, 1.0533046, 0.009297305, -0.0059788562, 0.022851918, 0.18973364, 0.10785783, -0.17246161, -0.4682364, -0.17636393) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.012127637, -0.10568317, -0.10497558, -0.089872226, -0.07084729, -0.1097665, 0.17627622, -0.01748364, 0.12330803, -0.016668051, -0.09182037, -0.15919818, -0.052349236, -0.14429814, -0.24862699, -0.05945438) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23132156, 0.07719472, 0.16878192, -0.5058508, -0.055517133, -0.020578565, 0.07587564, 0.018188834, -0.065143645, -0.043539524, 0.044805065, 0.044779498, 0.24489076, 0.050505217, 0.25353223, 0.5334193) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4556218, 0.15728718, 0.26664552, 0.7153995, 0.14979309, -0.040485617, -0.008579594, 0.003090489, -0.004181444, -0.0016133568, 0.04792589, 0.100503966, 0.017316224, -0.08047032, 0.16356668, 0.2808627) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.025322843, -0.14633954, 0.07893891, -0.05011531, 0.043506756, 0.06550614, 0.023408262, -0.121468835, -0.033865545, -0.08549008, -0.045232106, 0.110878386, 0.23906407, -0.24023181, 0.07388321, 0.45034543) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

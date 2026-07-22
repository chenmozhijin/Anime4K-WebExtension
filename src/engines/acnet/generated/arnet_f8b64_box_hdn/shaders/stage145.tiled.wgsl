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

  var result: vec4f = vec4f(0.30350015, 0.09895387, 0.36268276, -0.032468434);
      result += mat4x4<f32>(-0.12106718, -0.08223703, 0.109096155, 0.10833682, 0.01362925, 0.053449735, 0.15286154, -0.10166489, 0.13155895, 0.04277498, 0.023275178, 0.10224142, -0.13173106, 0.22891091, -0.20658709, 0.043050315) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.014317813, -0.030892124, 0.0070994706, -0.27054155, -0.08992411, -0.05817331, -0.13542257, 0.085585035, 0.22156261, -0.12882695, 0.117310196, 0.26015276, 0.366873, 0.13202016, 0.33552817, 0.14693193) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.14430894, 0.05286288, 0.009963708, -0.27065402, -0.013342342, -0.2556195, 0.27381656, -0.13836008, 0.012971211, -0.19695403, -0.030784907, -0.11447466, -0.059614737, -0.05744461, -0.0190339, 0.08410917) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11160618, -0.21690069, -0.16390413, 0.0049022045, 0.16212423, -0.22307025, -0.004200144, 0.16353856, 0.08018545, -0.21334451, 0.12788296, -0.0879787, -0.0279634, 0.072620235, -0.387959, 0.11917079) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.10695434, -0.1130643, -0.58206445, 0.016948583, 0.18543197, 0.09845654, -0.33410618, 0.22171295, -0.0665304, -0.37691215, -0.45172003, 0.3956386, -0.09109715, 0.53382564, -0.22804983, 0.17805387) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13697314, -0.043701153, -0.36029935, -0.111788064, -0.10343438, -0.41294953, -0.03290526, 0.30695263, 0.32158068, -0.20562199, 0.4353882, -0.21418042, -0.1045065, 0.35060996, -0.121609725, -0.33098274) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10741503, 0.20469406, 0.10578593, -0.1419868, -0.023189623, -0.11185323, 0.006563973, -0.01968142, 0.097958125, 0.0058575375, -0.2017518, 0.045983046, -0.08378631, 0.13013946, -0.11134038, 0.12226084) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.046701428, 0.26647162, 0.08655468, -0.05663883, 0.08825818, -0.16935293, 0.22954737, -0.21564901, -0.1528321, -0.3727368, -0.50933844, 0.14988598, -0.29658285, 0.113941535, -0.52498764, 0.109987296) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.17242146, 0.003206493, -0.080842055, 0.013412652, -0.12627076, -0.18845691, -0.072131604, -0.066017486, -0.13430896, -0.10866963, 0.072430566, -0.21966732, 0.23746118, 0.041859895, 0.2484094, -0.10900462) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.039769907, 0.09990767, -0.13151452, 0.094344065, -0.027278624, 0.21607697, -0.088443056, 0.08225532, 0.47448266, 0.098094665, 0.271823, 0.1333765, -0.084586, 0.019052941, -0.09144764, 0.01248288) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.004773961, -0.052825384, -0.06472081, 0.1580549, -0.028873265, 0.18842508, -0.14787346, 0.07071847, -0.18431252, -0.021799974, 0.4277822, -0.37217668, 0.090250984, 0.07490105, -0.022059707, 0.045839366) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.006445076, -0.32263547, -0.1735139, 0.08423663, -0.071639664, -0.021246804, -0.00056784484, -0.08451781, 0.42976025, 0.1310802, 0.28932062, 0.08118264, -0.045021787, 0.013736196, -0.03911075, 0.16691813) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.024738895, 0.34385604, -0.57289976, 0.27807766, 0.025458746, 0.39549464, -0.3038412, 0.09810648, -0.20679238, -0.31160182, -0.123276114, -0.115230724, -0.07282705, -0.51874936, 0.014656273, 0.08273705) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.10867583, 0.64765656, -0.13761602, -0.2650245, -0.15180625, 0.8804825, -0.9102277, 0.2924715, -0.09087495, 0.29436767, -0.07312259, -0.27133858, -0.135337, -0.083220765, 0.17835082, 0.1760052) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.064310886, 0.5031077, 0.23792619, -0.51722884, 0.02376287, -0.012993491, -0.040820614, -0.12073015, -0.0001674419, 0.043543637, -0.14813726, 0.22778778, 0.021483485, 0.42932627, 0.14321178, 0.17939347) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13522293, -0.11010129, -0.3627105, 0.11666448, -0.24097295, 0.02254914, -0.09118177, 0.022327468, -0.31603238, -0.07809544, -0.20149139, -0.16691023, -0.06319356, -0.04953261, -0.3369498, 0.16494857) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.036878325, 0.24267364, -0.09150945, 0.22028035, -0.0390317, -0.2675029, -0.2414081, 0.199747, 0.06741338, 0.25042796, 0.091286294, 0.05855244, -0.11311814, 0.0758483, -0.19660893, 0.24423061) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04354169, 0.06128421, -0.08721806, 0.34894344, 0.03491097, -0.10781444, 0.038078904, 0.028933829, -0.08140494, 0.032877896, -0.08362992, 0.045744322, -0.030734297, -0.32315063, -0.07173478, -0.052459437) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

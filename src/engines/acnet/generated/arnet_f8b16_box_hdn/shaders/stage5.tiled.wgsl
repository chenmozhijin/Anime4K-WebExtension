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

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_1[tileY][tileX] = sample_FEAT_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.05777313, 0.020930061, -0.06684683, 0.39100054);
      result += mat4x4<f32>(-0.07315473, -0.0019759766, -0.02005875, -0.056616466, -0.15891528, -0.15757844, 0.19609319, -0.023919694, 0.1707504, 0.10162207, -0.032278437, 0.08811845, -0.2871173, -0.023293706, -0.062562376, -0.3019733) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21241748, 0.16717462, -0.10168107, -0.05782357, 0.18267417, -0.077782296, -0.03438954, 0.14480299, 0.4620846, -0.18409331, -0.20362416, -0.008651552, 0.73943233, -0.3637534, -0.009508465, -0.39689764) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08548826, 0.19748561, 0.11039292, -0.2626267, -0.076040834, 0.099272154, 0.013650593, -0.017049897, -0.024611004, -0.040293727, -0.08619925, -0.07224487, 0.050485622, 0.15117952, 0.15130733, 0.09266606) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09713868, 0.1651002, 0.1474317, 0.17919424, 0.34825778, -0.62255466, 0.11280168, -1.0643314, -0.013575821, -0.03829669, -0.38324103, 0.14945301, -0.14622737, 0.20171936, -0.20331998, 0.24145956) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.39633584, 0.75612783, -0.045769464, 1.1543251, -0.07181864, -1.1515218, 0.03722379, -0.47924712, 0.6121822, -0.23015115, -1.2574306, 0.73686105, 0.0007856592, -0.20912288, 1.1125958, -0.5966436) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.070434384, 0.956643, 0.13121189, 0.31640255, -0.09474032, 0.1209015, 0.0017644825, 0.04199216, -0.07901914, -0.08133394, 0.4971494, -0.17052937, 0.32826397, -0.4045068, 0.3900173, -0.10202928) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.02093323, -0.052072413, -0.039145056, -0.005001165, 0.3177902, 0.4432758, 0.30144718, -0.05858931, -0.10972662, -0.0009340926, -0.07494312, 0.09331772, -0.15739964, -0.26748168, 0.034356274, -0.005064602) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.11419353, -0.35905945, -0.28257918, -0.06737488, -0.11135925, -0.016655905, -0.006757228, 0.19092184, 0.052175578, -0.16182223, 0.46341145, -0.20214373, -0.7744371, 0.2805984, 0.42632285, -0.43657547) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.18940063, -0.03277461, -0.049174123, -0.24841663, -0.009242075, 0.009431069, -0.016466137, -0.09744047, 0.03173729, 0.21524695, 0.023850115, 0.14510545, -0.20775849, -0.10068937, 0.18360569, 0.09694957) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.47720563, 0.22509937, 0.039201792, 0.018938167, -0.069273315, -0.13265237, 0.10877807, -0.13173589, 0.2531817, -0.076534905, -0.02725044, 0.047726143, -0.7207257, -0.6567767, -0.7102742, -0.01232594) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.24588718, 0.30449346, 0.6177143, 0.1444822, -1.4665073, 0.22047496, -0.28261334, -0.07176974, 1.1226956, -0.38739088, 0.02868206, -0.24936055, 0.1728972, -0.008514498, 0.02762349, -0.04541632) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.016075527, -0.018854145, -0.077603325, -0.013360773, 0.35839754, -0.22488964, -0.05971492, 0.036212012, -0.33202803, 0.30197865, 0.019966114, -0.0318403, -0.35799104, -0.64253765, -0.24468425, 0.67448616) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11810307, -0.17190032, 0.03302322, 0.1280526, -0.07907989, 0.24881916, 0.108865656, 0.23319031, -0.01884207, -0.18135566, -0.097665474, -0.22689784, 0.117182665, -0.1514793, -0.058010355, 0.37344563) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-1.0329912, 0.35807636, 0.023990035, 0.29656458, -1.5437208, -0.7458185, 0.7493215, 0.082054734, 1.1431422, 0.039821137, -0.65471786, -0.2574589, 2.468945, 2.1568758, 1.6459209, 0.12087932) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30467376, -0.32855242, 0.18548518, 0.1498741, -0.008278489, -0.21428013, -0.085999854, 0.14517425, -0.19702716, 0.46516323, 0.028841011, -0.15385172, 0.79548395, -0.035271056, 0.5283784, 1.1488357) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.15358284, 0.084125765, 0.031430844, 0.019472657, -0.028307093, 0.059502166, -0.048315544, 0.13258491, 0.049973972, -0.08827254, 0.006770642, -0.038800225, -0.5056407, -0.50607914, -0.16166161, 0.5995314) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14429054, 0.18816239, -0.08212485, 0.12024027, -0.38364622, -0.08839129, -0.007786951, 0.027815856, 0.32636672, -0.025986675, -0.043399993, -0.085233636, 1.3191707, 0.17338356, 0.692383, 0.35409248) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12842934, -0.11133787, 0.016500514, -0.0293376, 0.061178517, -0.06994971, 0.04291224, -0.024438795, -0.06834897, 0.12427566, -0.0074561983, 0.021848772, -0.08687819, -0.76111466, -0.34069255, 0.22569007) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

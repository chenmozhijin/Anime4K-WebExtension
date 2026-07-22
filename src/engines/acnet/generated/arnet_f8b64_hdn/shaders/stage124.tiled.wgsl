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

  var result: vec4f = vec4f(-0.19363311, 0.14980444, 0.035696395, -0.23745713);
      result += mat4x4<f32>(0.09063648, 0.07844948, -0.075767376, 0.14868622, 0.40999287, 0.025082156, 0.11393406, 0.1442779, 0.08975008, 0.087350324, -0.073679425, -0.1434934, -0.25472614, 0.15814087, 0.1274348, -0.31340984) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.086072445, 0.15348694, 0.03521935, 0.20380512, -0.13229436, 0.19776326, 0.051097434, 0.04243247, 0.12395292, -0.10998356, -0.022238677, 0.15797174, -0.54558325, -0.07548916, 0.14485092, -0.4007575) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.00220735, -0.13262494, -0.17022522, 0.13511188, 0.0067561697, 0.076885775, -0.025583383, -0.09766072, 0.27213868, -0.0031347636, 0.15386106, -0.15118647, 0.015811741, 0.078299, -0.25120294, -0.21245751) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06717124, 0.20671107, 0.40994015, -0.23575863, -0.088795796, -0.053101644, 0.061093047, 0.03393679, 0.24582694, -0.36582118, 0.11041523, 0.2088221, 0.1475875, 0.19767761, -0.20888205, -0.10438105) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.26028743, 0.15931638, -0.09242603, -0.48138043, -0.6406284, -0.048808575, 0.2961867, -0.017116053, 0.5015831, 0.0669003, 0.33432004, -0.01490791, 0.16117965, 0.055947855, 0.2362294, -0.33347696) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.05750763, -0.09329568, -0.028377539, -0.089759424, -0.022851517, 0.051526655, 0.13683304, -0.18365425, 0.28171995, -0.07517119, 0.18466076, -0.052498877, 0.0014536962, -0.089442186, -0.05418063, -0.25280234) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.00903518, -0.0017785612, 0.15230529, 0.039993364, -0.033107083, 0.079167865, 0.005544973, -0.088161185, 0.40429026, -0.008008955, 0.43796164, 0.029037535, -0.025993288, 0.15844113, 0.058854844, -0.1949911) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.20742875, -0.33636525, -0.30904663, -0.111572206, -0.22101656, 0.057053015, 0.09902608, 0.064595446, 0.31456426, -0.0040109116, 0.12278059, -0.076509014, 0.14223374, -0.054716453, 0.057774585, -0.16172192) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.16477309, -0.12171105, -0.19215299, 0.028595852, 0.049381588, 0.03213546, -0.3611021, -0.12638251, -0.07396885, -0.1737819, 0.05625283, -0.007280372, 0.127817, -0.043374453, -0.4387236, 0.058599412) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.35558784, -0.08045145, 0.22305562, 0.20641433, 0.054020077, 0.31346658, 0.06712762, -0.46006352, -0.4409526, 0.04350788, -0.08662522, -0.25483462, -0.25581235, 0.06819002, 0.20700604, -0.039061252) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.31848702, 0.21297674, 0.19380483, -0.4135638, -0.26983395, -0.5676269, -0.32624146, 0.48473516, -0.24361365, -0.19099328, 0.12953414, -0.31048986, -0.18684949, 0.024308912, 0.3547797, -0.11541228) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18215252, -0.20359871, -0.089056246, 0.05772476, -0.31446913, -0.07424211, -0.26374927, 0.18091147, -0.112980954, -0.17776048, -0.028019682, -0.05392842, -0.094829015, -0.049331214, 0.37522867, 0.070300594) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.35044232, 0.04480778, 0.15116452, -0.018264016, 0.14439124, -0.30711526, 0.15919028, 0.010064888, -0.12774171, 0.101053774, -0.1714056, -0.16716771, 0.23112363, -0.13887222, 0.22936165, 0.32326886) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.56302243, -0.17400825, 0.29071996, 0.1352423, 0.08025328, 0.253565, 0.39915532, -0.067942396, 0.85822874, 0.26074442, -0.21943349, 0.272823, 0.26636094, 0.1414423, 0.22372068, 0.5495474) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.2564451, -0.18698266, 0.08176192, 0.11902052, -0.25209337, -0.21712142, -0.45268443, -0.108285375, 0.21367776, -0.118719004, -0.15811968, 0.24650201, 0.03549745, 0.24833399, 0.43462107, 0.25193188) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12220652, 0.018792395, 0.08924053, 0.036397625, -0.4136246, 0.030384656, -0.1223638, -0.150996, 0.005044607, -0.061469007, -0.0930315, -0.0724721, 0.041996542, 0.19129331, 0.20650098, 0.3944971) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21230909, -0.082656495, 0.082623646, -0.040833846, 0.47464412, -0.014887169, -0.019132396, -0.3781652, 0.03346696, 0.052957926, 0.067852356, 0.08215564, 0.020033207, 0.09387101, -0.03570926, -0.17543902) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2104578, -0.18200135, -0.11667427, 0.07785428, 0.033009764, -0.046130907, 0.33273157, -0.19801666, -0.10130603, -0.04456477, 0.45009804, 0.17692071, 0.10851231, 0.06632213, 0.41436675, 0.06268512) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

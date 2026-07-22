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

  var result: vec4f = vec4f(0.36575457, -0.22375976, -0.25516215, -0.078533664);
      result += mat4x4<f32>(-0.1879324, 0.10708826, -0.07770345, 0.0836193, 0.067301154, 0.19659051, 0.12947233, 0.01617381, -0.1581347, 0.047568552, -0.1576682, -0.025143314, 0.08272914, 0.1781866, 0.0573037, -0.004414296) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.048372377, -0.39973313, 0.09858891, -0.03602072, -0.12110074, 0.32194605, 0.3921721, -0.06325075, 0.07810162, 0.24213226, 0.04825458, -0.021459047, -0.10258314, -0.0056737144, -0.15578996, 0.07712502) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07866268, -0.08838448, 0.005825457, 0.17562908, -0.1928522, 0.22503966, -0.0878091, 0.25659624, -0.113098815, 0.18650113, -0.03367183, 0.1335686, -0.23783778, -0.0048496793, 0.08748293, -0.06057465) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1479943, -0.5455926, -0.3300227, 0.36531144, 0.31913134, -0.17148714, 0.19739595, -0.15708807, 0.031363413, 0.2569264, -0.04748147, -0.42747793, 0.16308886, -0.453329, 0.16191955, -0.2421883) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13627361, -0.7524419, 0.19454803, 0.058204018, 0.13160604, 0.03535578, -0.17084293, 0.27326414, -0.3306748, 0.3822588, -0.23325506, -0.2770058, 0.04783701, -0.10744256, -0.18401413, 0.42945948) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.337502, -0.04203126, -0.23947728, 0.26328796, 0.4106206, 0.056405485, -0.15840879, 0.32461023, 0.6042254, -0.24460027, 0.102079, -0.22400968, -0.049016345, -0.3365493, 0.32799166, -0.16655304) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1534994, 0.040588193, -0.18289733, 0.15257455, 0.10710642, -0.41259414, 0.02293512, -0.08767722, 0.12225998, -0.45069873, 0.2631708, -0.23832959, -0.116472125, 0.06879828, -0.028934257, -0.034595933) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13911279, -0.53670704, 0.10621742, 9.692402e-05, -0.3368403, 0.22755656, -0.52224684, 0.16844994, 0.03150342, 0.21606179, -0.2763121, -0.12233715, -0.02966759, 0.08440111, -0.05401321, 0.121387586) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.25416434, -0.044041898, 0.044090956, 0.123123296, 0.023145363, -0.5311514, 0.12221317, 0.0018538022, -0.24539424, -0.032390445, -0.20183478, -0.04449704, 0.06910072, -0.0015670224, -0.11396706, 0.11981525) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.05778761, 0.19450097, 0.01264125, -0.020545823, -0.10930849, -0.27490723, -0.02918791, -0.16893603, -0.118016474, -0.25518188, -0.11830651, 0.21912396, -0.25987786, 0.14638868, 0.048311476, 0.17796843) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15777414, 0.2403054, 0.122596346, -0.23029932, -0.10155357, -0.104081094, -0.17675138, 0.063056596, -0.25244457, -0.07509785, -0.076690905, 0.064242475, -0.21621479, -0.4653804, 0.5422251, -0.009814916) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09767182, -0.176749, -0.12860247, 0.005832845, 0.35797715, -0.12690932, 0.10350506, -0.44138485, -0.14677592, 0.038304992, 0.008232833, 0.018559655, -0.17631538, 0.05075052, 0.22157457, 0.11721019) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1346331, -0.31036213, -0.058699615, -0.13355204, -0.18299997, -0.056753907, -0.5725331, 0.48849452, -0.21322069, 0.006851094, -0.30095533, 0.20690504, -0.050297618, -0.08388575, 0.38432494, -0.15245856) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.8123786, 0.065944575, 0.5225203, -0.21326274, 0.17460197, 0.054899048, 0.12820971, 0.24725465, -0.13778052, -0.65988594, 0.0325338, 0.025898922, -1.2226455, -0.8202491, 0.33960855, -0.1593841) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.34225738, 0.4191511, 0.023553783, 0.09217057, -0.046589717, -0.25790405, 0.088656306, -0.37676206, -0.086793095, 0.03647967, 0.070583306, 0.15841478, 0.38773042, -0.040546414, 0.12722862, 0.11738751) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17724855, 0.15496898, 0.15565975, -0.1616907, -0.3258711, -0.10406102, -0.02747352, -0.091396205, -0.09467014, -0.051913533, -0.17815699, 0.05018685, -0.082686454, 0.24486044, -0.06695014, 0.14834751) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08324641, -0.195773, 0.3317197, -0.22691227, -0.0745514, 0.30860454, 0.0543295, -0.08837008, -0.28886572, -0.13827418, -0.03660036, 0.13925524, -0.25648716, 0.043619953, -0.14244705, 0.24459863) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10888225, 0.59095377, -0.1491061, 0.2452936, -0.030052787, 0.48165298, -0.14754072, -0.06913267, -0.110832, 0.00093775115, -0.03049495, 0.15467995, -0.11256737, -0.19418775, 0.16318123, 0.016779976) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

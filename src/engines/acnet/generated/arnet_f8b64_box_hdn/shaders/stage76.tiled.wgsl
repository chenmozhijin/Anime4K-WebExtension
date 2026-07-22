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

  var result: vec4f = vec4f(0.049097117, 0.03047324, 0.33286095, -0.0024951787);
      result += mat4x4<f32>(0.0452292, 0.084174044, 0.050114535, -0.1945082, -0.14394355, 0.041797355, 0.058241013, -0.050717283, -0.1790473, 0.022822944, 0.10744252, 0.06811663, -0.3116778, -0.16030343, -0.029657494, 0.11920112) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09928161, 0.275314, -0.36730963, -0.24386334, -0.5582176, -0.018594023, 0.11185949, -0.2133979, -0.08179132, -0.07528526, 0.03802029, -0.18709934, 0.5058601, 0.08955974, -0.19804257, -0.005449467) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.033585433, -0.0464403, -0.18893647, -0.17953159, -0.04950726, 0.21117397, 0.10625968, 0.023685751, -0.08734608, 0.07352778, 0.0023301756, -0.024622327, -0.123430155, 0.06040401, 0.058504872, -0.03454448) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.029802589, -0.0987393, 0.19634518, -0.024150442, 0.017929811, 0.14861093, 0.25469062, -0.1742872, 0.11122747, 0.14648932, -0.033102605, 0.020058144, 0.15594448, 0.17566781, -0.2706325, -0.0072856345) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07186501, 0.3667233, 0.033291552, 0.38246593, -0.1947199, -0.042260464, 0.055938475, -0.008800797, 0.15200283, 0.17034234, -0.057993863, 0.32716256, 0.7960767, -0.24581097, -0.01652057, 0.05536449) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.27060637, -0.01882307, 0.22944403, 0.07726534, -0.30638188, -0.057979967, -0.17666475, 0.2304535, 0.05380653, 0.20902991, 0.109419644, 0.23788318, 0.068690106, -0.08914278, -0.1465163, -0.2027737) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11477313, -0.042213157, 0.104196355, -0.011389764, 0.2787665, -0.1072892, 0.3793243, -0.13500994, 0.018093493, 0.10056261, 0.38643104, -0.09675194, -0.096036494, 0.07775568, 0.13429634, -0.08624568) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.32612818, 0.04862636, 0.104345955, -0.000798223, 0.40101415, -0.09430739, 0.16586056, -0.013256299, -0.014241271, 0.019462755, 0.39050063, -0.15891421, -0.025131607, -0.1807923, 0.08019456, 0.1667331) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12784706, -0.046672657, 0.042884815, 0.10978261, 0.087740116, -0.021471616, -0.103054866, 0.08357309, 0.05081678, 0.0032971045, 0.13100046, -0.13697086, 0.2903249, -0.07201754, -0.13963611, 0.0192236) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.094815165, -0.13340911, -0.044268735, 0.10377354, 0.04584856, -0.012272684, 0.023946019, 0.063278995, 0.5784901, 0.1367863, -0.3720719, 0.040816132, 0.15230918, -0.11673529, -0.09335191, 0.1653061) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21658096, -0.13492443, -0.07021332, -0.18770438, -0.10360171, -0.1345581, 0.1286888, -0.12556587, 0.34620437, 0.025222652, -0.12894963, -0.3157146, 0.106808074, 0.62526435, -0.54393697, 0.29985502) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03552695, 0.0037246137, 0.1229929, -0.10793339, 0.055128314, 0.026335549, -0.05429765, -0.045603476, -0.022296311, -0.16083355, -0.17369945, -0.019136773, -0.4734677, -0.027199699, -0.10781292, -0.09027406) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.52037114, -0.14915457, -0.18265179, 0.020778943, -0.006106156, -0.093420334, -0.19775452, -0.10322423, 0.6456908, -0.05012187, -0.13863535, 0.008696455, 0.12409027, -0.27582452, 0.22320728, 0.1371875) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.27816713, -0.25792435, -0.17975572, -0.2967791, 0.3970531, 0.037560157, 0.057632584, -0.0124835195, -0.1526625, 0.09556112, -0.33810624, 0.20666175, -0.2828767, -0.28398186, 0.28399736, -0.021388315) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19276977, -0.057661712, -0.016282773, -0.103392206, -0.0292912, -0.0920887, -0.18470863, -0.2254683, -0.09179662, 0.07108377, -0.21278024, -0.14315814, 0.07178298, 0.30966035, 0.47056982, -0.07274102) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.44439393, -0.111442454, -0.15179196, 0.02111119, 0.16710989, -0.0009540996, -0.20888574, -0.12982593, -0.592984, 0.046301343, 0.46769577, -0.13703424, -0.18398461, -0.0029301948, -0.4875306, 0.15836574) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.24733476, -0.16383159, -0.014304483, -0.05255315, 0.04879575, 0.33200657, -0.7580297, 0.042396896, -0.5536058, -0.19732426, 0.026736952, 0.34904167, -0.37779328, -0.27373964, 0.55428344, -0.26735598) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.25047657, -0.012910131, -0.05089613, -0.066793405, -0.39555126, 0.091669746, 0.009803824, 0.110206105, 0.17106932, -0.08636157, 0.3054495, 0.028473807, 0.35813037, -0.14914446, 0.16215433, -0.43278342) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

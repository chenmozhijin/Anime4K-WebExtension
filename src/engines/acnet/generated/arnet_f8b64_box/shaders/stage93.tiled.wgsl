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

  var result: vec4f = vec4f(0.121537045, 0.12549332, -0.0071507776, 0.09265356);
      result += mat4x4<f32>(-0.03220712, -0.075606875, 0.003137618, -0.018136097, -0.05336625, -0.13606703, -0.013096317, 0.32567376, -0.06728829, -0.062014453, -0.010785849, -0.06271719, 0.09400112, 0.08708435, -0.092250854, 0.07832178) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12198843, -0.048267715, 0.15797994, -0.016983517, 0.14433132, 0.047175307, 0.02969135, 0.113947704, 0.11874999, 0.16994523, -0.028199704, -0.044771392, 0.09358741, 0.10642497, 0.117139876, -0.3318165) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17591545, -0.052700914, -0.057164673, 0.117318146, -0.0023937419, -0.20230582, 0.10347572, -0.34750032, -0.2695164, 0.23140271, 0.00794444, -0.04988941, 0.00095970894, 0.013241232, -0.08901435, 0.10227518) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.075871035, -0.30093533, -0.10225749, -0.047507025, 0.00787131, 0.31196076, -0.10220679, 0.043609146, -0.08123789, 0.16873142, -0.030062918, -0.012136438, -0.10051885, 0.10784568, -0.021886723, 0.52427465) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16696867, -0.28988332, -0.13283639, -0.30547798, 0.15491249, 0.17371835, 0.2713711, 0.6673729, 0.27510586, 0.028823216, -0.15685567, 0.7485363, 0.037670575, 0.16724053, 0.2957005, 0.7019989) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.22705495, -0.23587388, 0.06625124, -0.43173566, 0.066219315, 0.12522206, -0.12562649, 0.304172, 0.08548206, -0.09106144, -0.12236713, -0.2563132, 0.14528224, -0.323151, -0.00088916166, -0.04218336) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.031912845, -0.10201997, -0.006063699, -0.0132896295, -0.019210247, 0.01653125, 0.015474857, -0.042312585, -0.064519756, 0.21266468, -0.220451, 0.21409775, 0.24388146, -0.43302357, 0.21089534, -0.16940054) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12715103, -0.23187432, -0.02771329, 0.08488529, 0.005065427, -0.06024778, -0.065249525, 0.19499974, -0.06981574, -0.03646029, -0.24584457, -0.104581304, 0.14115345, 0.22994548, 0.011921477, 0.10122077) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1524418, -0.12631397, -0.03276252, -0.08853344, -0.0713433, 0.1112345, -0.1350626, 0.18310179, 0.095504425, 0.35846773, 0.11826172, -0.22715972, -0.17479792, 0.19799857, 0.0752727, 0.16344896) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07967799, -0.2647912, 0.15390971, -0.06645365, 0.30650616, 0.3143838, -0.3209612, 0.21479496, -0.017640268, 0.051147167, -0.058425136, -0.046833944, 0.007744585, 0.11095475, -0.04084314, 0.11376097) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2124771, -0.40333867, 0.29184487, -0.2814282, -0.34626395, -0.22468108, -0.20568751, 0.21145715, -0.058185082, 0.0162221, 0.04451713, 0.08718206, -0.058748107, -0.016445393, 0.06123745, -0.06295255) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07666416, 0.018959003, -0.09924002, 0.12500991, -0.16612668, -0.2278019, 0.2118837, -0.05486388, -0.054518, -0.0209559, 0.022279024, -0.0016210757, -0.023260692, 0.010719888, -0.1518336, -0.0003594659) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3243122, -0.89462334, -0.3577199, -0.21667826, -0.025513958, 0.07208073, 0.19329311, -0.29335758, 0.046752866, -0.13071245, 0.2262105, -0.173027, -0.15225835, -0.13748138, 0.045653723, 0.030446915) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.46871176, -0.52608603, 0.18734963, 0.003987558, 0.20063576, 0.03246317, 0.20506847, 0.33164132, 0.056500275, -0.2457322, 0.08218858, -0.31175315, -0.021571118, -0.10292153, -0.0890334, -0.6809554) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18867713, 0.12863834, -0.25754136, 0.48152435, 0.49685064, 0.08465235, -0.18923706, -0.06823341, 0.04533565, -0.25348127, 0.12485185, -0.13690972, 0.087503925, 0.120972015, -0.10526979, 0.023986163) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08957679, -0.18388286, -0.1621037, 0.004826434, -0.074263334, -0.1526926, -0.16258715, -0.32480434, 0.17653185, -0.18453099, 0.29846078, -0.4300475, -0.077914126, -0.0075674844, 0.08488803, -0.110791065) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1590341, -0.17188333, -0.15708049, -0.0060299207, -0.1313179, -0.31435317, 0.11265454, 0.032205824, 0.3659577, 0.1710518, 0.06341482, -0.27223688, -0.086491466, 0.18805163, -0.3119119, -0.5665147) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10188087, 0.14058608, 0.038210914, 0.14860152, 0.159541, 0.02131847, -0.0039988696, 0.19924274, -0.06462427, 0.042880822, -0.040479045, 0.17617351, -0.10882614, -0.03892572, 0.017826794, 0.0093167415) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.2935325, -0.0033432543, 0.2726435, -0.031785715);
      result += mat4x4<f32>(0.10614058, -0.07168282, -0.012673512, 0.11019415, 0.21756455, 0.13152988, 0.03711091, 0.06850501, -0.008173166, -0.12429323, 0.082631156, 0.005982937, 0.046635784, -0.0041658534, 0.47900125, 0.053519145) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.024376504, -0.22653466, -0.14097703, 0.14868298, 0.15546894, 0.15233834, -0.05357535, 0.11262738, -0.04426644, 0.17247185, -0.20138617, 0.13793223, 0.15197626, 0.010440838, -0.20778471, 0.06441096) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.023651928, -0.15554436, -0.10499073, 0.12684453, -0.0050386786, 0.22332965, 0.17849731, -0.08997539, -0.040463403, 0.09964636, -0.1885139, 0.06066856, -0.058953915, 0.3132007, -0.0726896, 0.3511862) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.019793695, 0.017660359, -0.088357545, 0.015209463, -0.3793775, -0.852452, -0.14644177, -0.11726494, -0.24305607, -0.2050816, 0.12970014, -0.17646061, 0.14053008, 0.082922034, 0.019014565, 0.15461522) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1771055, -0.109402604, -0.0054405406, -0.12863095, -0.21799698, -0.5614587, -0.38366032, -0.24313694, -0.015621551, 0.17270459, -0.2522239, -0.25682396, 0.26775575, 0.1831352, -0.32986826, 0.021761687) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.3785214, -0.38020292, -0.1884126, -0.28632447, 0.24620317, 0.11811765, 0.1708918, 0.3223602, -0.12506591, -0.18484798, 0.27625594, 0.49562597, 0.1363673, 0.23845172, -0.08929791, 0.43871486) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.035488807, -0.13729168, 0.019819684, 0.10398598, -0.23919562, -0.26423788, -0.37570146, -0.123619825, -0.02396411, -0.07440483, 0.3826136, -0.22906622, 0.14686947, 0.11552464, 0.1012994, 0.17835888) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.025517782, -0.079939775, -0.05708468, 0.031758543, -0.19616331, -0.48179173, -0.20764385, -0.040357254, -0.17351083, 0.010675412, -0.39583507, 0.17777091, 0.10109558, 0.12633297, 0.023051102, 0.014660104) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0745209, -0.19251803, -0.012718398, 0.121541984, 0.117434956, 0.084088564, 0.051455136, -0.012623815, 0.05287768, -0.04523686, -0.058660887, 0.01202761, 0.14981303, 0.11245523, 0.094048284, -0.18871702) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.098064624, 0.048583526, -0.028541224, -0.06480438, -0.046269648, -0.069379754, -0.20126338, 0.008112165, 0.020411406, -0.020162474, -0.014256098, -0.0009953692, 0.042256135, -0.00404055, -0.21258694, 0.13020112) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.11923164, -0.014867661, -0.032783728, -0.24545065, -0.03255015, 0.024388224, -0.2539482, 0.021694265, 0.19025192, 0.17855476, -0.017986335, 0.23722698, 0.063809365, 0.17943765, -0.47638094, -0.0036040882) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.01826635, 0.004623037, 0.009856963, -0.058827277, -0.0017772628, -0.12193664, -0.0010803089, -0.027383205, 0.06617982, -0.07063884, -0.0037794642, 0.028158175, -0.012073338, 0.061949007, -0.33363628, -0.06922544) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16955328, -0.058507297, -0.013625697, -0.10016699, 0.013489374, 0.13972215, -0.49000102, 0.18700723, 0.0102515025, 0.26993307, 0.067101166, 0.06974618, 0.016402172, 0.09888821, -0.20618603, 0.090481006) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.61342055, -0.80981, -0.36507747, -0.49398836, -0.15344895, 1.0029644, -0.62285006, 0.12109889, -0.58362675, -0.7039408, 0.31812575, -0.4413446, 0.0009133885, 0.5223329, -0.07485367, 0.12851997) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.17242406, -0.09292578, 0.090780206, -0.31732693, 0.12416436, 0.051688645, -0.157386, -0.028691256, 0.013859157, 0.10403274, 0.20113003, -0.066655666, 0.045396086, 0.10069559, -0.4416014, -0.05890451) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.052305624, 0.067773186, -0.0204264, -0.0396456, 0.116803825, -0.17390971, -0.060994275, 0.043399222, 0.12011628, -0.059798345, -0.0019264007, -0.0029588745, 0.063414164, -0.17472978, 0.08384598, 0.04876508) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13552548, -0.06497014, -0.078333005, -0.16008195, 0.02206587, 0.06747223, -0.09916832, 0.15673262, 0.18052693, 0.114373155, 0.15129273, 0.17171489, 0.124685735, -0.0006770115, -0.041757647, -0.12815876) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.040037554, -0.06658884, 0.09973789, -0.109322585, -0.022483138, -0.039297648, 0.01555307, 0.22509927, 0.11325914, -0.0058064484, 0.04853695, -0.0030832503, -0.010245396, 0.10476923, -0.11621843, 0.10775562) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

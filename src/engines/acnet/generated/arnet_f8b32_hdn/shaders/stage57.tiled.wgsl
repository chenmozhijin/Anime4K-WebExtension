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

  var result: vec4f = vec4f(0.4116046, 0.23108734, 0.10609056, 0.24619627);
      result += mat4x4<f32>(-0.16857831, -0.00058848754, 0.14152774, -0.017573968, 0.11188912, -0.050425556, -0.1586103, -0.043110725, -0.2287173, 0.14437182, 0.047081787, 0.13179444, 0.120124556, -0.19647542, -0.11345458, -0.29061562) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.43646783, 0.10839468, -0.05522259, 0.22582714, 0.20579936, -0.1933906, 0.12138025, -0.3475193, -0.12689531, 0.28154805, 0.05407143, 0.15539217, 0.18086189, -0.28851685, 0.0882616, -0.3050954) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.4053073, 0.29892322, 0.08352432, 0.28910595, -0.014964183, -0.046198886, -0.0055011446, -0.054937314, -0.047128327, 0.055490904, -0.027730402, -0.039998367, -0.11661592, 0.081583336, -0.061573286, -0.27613696) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06012269, -0.13643743, -0.0070145126, 0.01110179, 0.58497304, -0.1275394, -0.09571793, -0.35999542, -0.21944895, 0.41875833, 0.108457364, 0.15311536, -0.16041869, -0.3006857, -0.22107276, 0.006504551) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2423058, -0.011024418, 0.17460667, -0.1348998, -0.506011, -0.4296835, 0.039571974, -0.5381713, -0.32352355, 0.5511753, 0.18034521, 0.29987383, -0.3209235, -0.69874614, 0.07187474, 0.011482691) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.005968066, 0.28231633, 0.22247422, 0.31179693, -0.5717448, 0.15000542, 0.27737036, -0.28652245, -0.17548442, 0.11383318, 0.08625837, -0.06631554, -0.23500517, 0.06903208, -0.1372627, 0.0077460636) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.02400397, 0.18059209, 0.18446565, 0.26846138, 0.1545615, -0.077511385, 0.1162441, -0.2235167, 0.00415371, 0.01527686, 0.13996808, 0.10295347, 0.47568175, 0.096733525, -0.14895129, 0.034470778) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(1.3082324, 0.09258064, 0.0847024, 0.026785845, -0.26662636, 0.09212685, -0.19696096, -0.3518375, -0.16236758, 0.3357483, 0.20031682, 0.29164222, -0.023031, -0.21335112, -0.239439, 0.042791024) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.492527, -0.2788234, -0.08335625, -0.2027757, -0.12710412, -0.34060484, -0.09510058, -0.29630473, -0.13306382, 0.18977472, 0.06245444, -0.013054253, -0.44280654, 0.18811718, -0.05735183, 0.18511301) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.21502277, 0.017001456, -0.009381108, -0.068451755, 0.028689455, 0.1579326, -0.09805834, 0.031390846, 0.021928726, 0.1902844, -0.29119343, -0.009158892, 0.061744444, -0.07022517, 0.23280141, -0.049331307) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.095576294, 0.084811434, 0.008849151, 0.08201902, -0.24173345, 0.40072238, 0.24060765, -0.11367935, -0.24156922, -0.2516388, -0.13928379, -0.2967917, 0.012173067, 0.07957075, -0.17488933, 0.06113285) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16227718, -0.02318801, 0.018956447, -0.06340602, -0.1663639, -0.025946924, 0.14691779, -0.08420567, 0.0003731669, -0.10190763, -0.06748025, 0.0373441, 0.14528671, -0.28748432, -0.042393386, -0.028130934) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5625106, -0.11198975, 0.03635211, 0.018769067, -0.035007596, -0.09805942, 0.059069324, 0.27283174, -0.26467967, -0.013868526, 0.15044528, 0.2008472, 0.16330755, -0.14523935, -0.10805781, -0.26514626) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.26116973, -0.13961987, -0.15642044, 0.07047491, -0.35502443, -0.07957869, 0.21953043, -0.29422316, -0.5226507, -0.080672614, 0.41985554, -0.47601935, -0.14543788, -0.4244897, -0.6033126, -0.37607744) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.44835943, -0.30856758, -0.13678242, -0.033756368, -0.12634087, 0.37547106, 0.25666654, 0.06792784, 0.15084566, 0.13925062, -0.13941443, 0.476027, 0.1496361, -0.42832386, -0.0009559154, -0.3301969) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.23725137, -0.030854123, -0.073271565, 0.21117254, -0.3662681, 0.21900114, -0.122887924, 0.04809415, -0.004247403, 0.07874924, 0.050716028, 0.19068761, -0.17722192, -0.059330612, -0.20026784, -0.5401578) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0977324, -0.2384729, 0.16704622, 0.29877383, -0.09318503, -0.2222017, 0.03573767, -0.33118764, 0.0013966133, 0.0006370909, -0.004384806, -0.13891365, -0.11778578, -0.114962906, -0.16737442, -0.43113375) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20914087, -0.11636056, -0.055212736, 0.047889184, -0.09068549, 0.061137326, 0.05566335, 0.072730675, -0.07226059, -0.046488073, 0.16354816, -0.09318461, 0.017427359, 0.008998701, -0.060720064, 0.15569574) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

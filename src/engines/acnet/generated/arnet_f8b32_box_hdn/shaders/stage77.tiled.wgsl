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

  var result: vec4f = vec4f(-0.15511917, -0.07968062, -0.2637335, 0.2912199);
      result += mat4x4<f32>(0.1599513, 0.35229382, -0.00952781, 0.5322986, -0.025235634, -0.23351258, 0.027925743, 0.2002763, 0.061322045, -0.2118927, -0.012345181, -0.1083238, 0.112866126, -0.099735245, -0.05496729, -0.13270828) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.15190616, -0.38556832, 0.09955721, -1.0131183, 0.019324403, -0.07575331, 0.0606309, 0.075856306, -0.07803092, 0.1731258, 0.096076146, 0.0943705, -0.10344409, 0.07043262, -0.22623171, -0.3968723) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.051194943, 0.55035776, -0.40164655, 0.42604637, -0.10715245, 0.09978687, 0.062019344, -0.07774026, -0.059579086, -0.16310138, -0.027348708, 0.024356492, -0.29972866, -0.043414213, -0.22826399, 0.08123161) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.009845284, -0.12745818, 0.12733029, -0.25729975, 0.11428392, 0.42422903, 0.045844864, 0.6878512, -0.046636328, 0.31213605, 0.048596755, 0.016517555, 0.07075272, 0.0038488063, -0.035680767, -0.18605912) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.109299175, 0.13397518, 0.2649653, -0.08384172, -0.11723405, -0.57333887, -0.46934623, -0.7752974, -0.2627356, -0.17371956, 0.4229279, 0.92243606, -0.6032986, -0.007720275, 0.29324055, -0.49588233) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0500871, -0.2597226, 0.25396922, -0.17198426, 0.10733275, -0.17660761, -0.2717083, 0.122116566, -0.063046895, -0.10328943, 0.17721796, -0.056594387, -0.41268024, -0.53797007, 0.033724964, -0.30040577) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.048734557, -0.10140817, -0.097072504, -0.21109073, 0.049340688, -0.11367621, -0.1196519, -0.076701395, -0.24397096, -0.14561436, 0.0016767469, -0.19629645, 0.03369798, -0.024110297, -0.11152104, -0.053848237) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12181975, 0.7694651, -0.082064085, 1.1605542, -0.1898209, -0.38134462, 0.19183776, -0.37429363, -0.4481086, -0.07998092, 0.19716795, -0.0705392, -0.2703668, -0.21874368, 0.008360704, -0.26615512) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.012279795, 0.17068169, 0.070432134, -0.33478144, -0.06963328, 0.033775818, 0.18190227, 0.055125058, -0.15000275, 0.2739207, 0.24743618, 0.21796712, -0.026702242, -0.12854767, 0.026561487, -0.061844464) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.058075022, -0.05494658, 0.08277893, 0.18643858, -0.09850992, 0.08954785, 0.09249124, -0.073362894, -0.1704488, -0.18217644, 0.015205439, -0.018436667, 0.11177571, 0.08597629, -0.12998557, -0.11524937) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14640188, 0.20893322, 0.13408515, 0.29258493, 0.0603932, -0.111812964, 0.25094637, 0.5431063, -0.21345305, -0.19570796, -0.26421803, 0.34476012, 0.14088544, -0.17327659, -0.1001319, 0.011912516) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06854039, -0.20736061, 0.5479192, -0.19268025, 0.2543705, 0.0673814, 0.14893207, 0.008690634, 0.031466123, -0.08911346, -0.00961423, -0.061482854, -0.10515144, 0.029175771, 0.01517538, 0.042847186) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.013253177, -0.02329469, 0.13119651, 0.22730473, 0.07334873, 0.014176735, -0.12952565, -0.2524249, -0.22322637, -0.5732747, -0.31327492, -0.8313139, -0.027090259, -0.15086325, -0.017726298, -0.14240253) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.00017972868, 0.20739959, 0.123329185, -0.5154792, 0.23014031, 0.3500431, -0.5021001, 0.3013577, 0.022659225, -0.06174976, -0.047334176, 0.63019305, 0.12640874, -0.21453165, -0.36116815, -0.84377813) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.056900505, -0.20231287, 0.29313478, -0.32658732, 0.26462415, 0.5110401, -0.22340304, -0.612856, 0.062029455, -0.015282843, 0.058438838, -0.014117515, -0.12685402, 0.051461417, -0.35284042, -0.07640536) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.40927902, -0.19143385, -0.021343023, 0.060830455, -0.014618915, 0.025123542, 0.006664235, -0.11848335, -0.17482255, -0.06858122, 0.2607163, -0.018759478, -0.030865699, 0.17490004, 0.08469618, 0.030821107) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15555818, 0.106391124, -0.08653697, -0.054343473, -0.18737014, -0.03469445, 0.066453606, 0.2534798, 0.42102307, -0.0013457964, -0.18124159, -0.28309357, -0.2631703, 0.0025585725, 0.31889325, -0.4353759) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.2363197, -0.012708802, 0.06513892, 0.085103676, -0.003239679, 0.20828392, -0.028814081, -0.24114908, -0.037714187, 0.016497966, -0.10582855, -0.010304473, -0.13446821, -0.043314416, 0.13152936, 0.1400191) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

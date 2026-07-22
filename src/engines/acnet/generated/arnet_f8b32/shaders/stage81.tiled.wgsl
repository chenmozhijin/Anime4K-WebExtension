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

  var result: vec4f = vec4f(0.27617058, 0.10130859, 0.14186028, -0.16987126);
      result += mat4x4<f32>(0.07191057, -0.104825035, 0.13874708, -0.013815327, -0.05420365, 0.0751899, -0.20432612, 0.02604664, 0.060381304, -0.09945679, 0.10371276, -0.013427485, -0.08346519, -0.0693695, 0.13896236, 0.020929957) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.108373396, -0.15918374, 0.22221474, -0.02926141, -0.07534258, 0.118770905, -0.3000612, -0.028910173, 0.06480818, -0.15196584, 0.16602838, -0.008990717, -0.017083418, -0.33660266, 0.05332938, 0.27881348) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06598892, -0.1305218, 0.13799001, 0.013187238, -0.024398893, 0.014844845, -0.13962193, -0.025648562, 0.05985933, -0.07334985, 0.12442292, -0.0041594645, -0.13421088, 0.14635685, -0.11916455, 0.12860438) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09719702, -0.10585552, 0.19565615, -0.06464425, -0.12578773, 0.15478839, -0.32231304, 0.079372816, 0.09101536, -0.19273937, 0.18584524, -0.061037425, -0.053029068, 0.020486405, 0.047065083, -0.19049452) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.1363337, -0.14854217, 0.3253887, -0.006445165, -0.08866283, 0.13117906, -0.43736964, 0.09817736, 0.1440088, -0.322766, 0.2878169, -0.0808281, -0.2902702, -0.68390006, -0.00088029966, 0.50302243) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09507034, -0.14129569, 0.2070962, -0.02807162, -0.06364334, 0.13804442, -0.2798846, -0.010950555, 0.10767316, -0.13022925, 0.1939386, -0.021805482, -0.2693312, 0.07768345, 0.039055854, 0.21615711) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.071945876, -0.08549983, 0.13287312, -0.017662495, -0.078094885, 0.056671433, -0.21700367, 0.06935337, 0.05637082, -0.106882475, 0.12029952, -0.049067438, -0.04859385, 0.06150161, 0.08533088, 0.15111086) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10234494, -0.14836612, 0.23241192, -0.04815511, -0.09384633, 0.1488026, -0.3085167, 0.06687559, 0.10621365, -0.15667492, 0.17120513, -0.053962216, 0.032445863, -0.025708588, 0.020173375, 0.107439585) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06971029, -0.0769081, 0.13403243, -0.019104782, -0.08298929, 0.14314376, -0.238383, 0.0537853, 0.0859978, -0.08670751, 0.13581221, -0.04312473, -0.042146254, -0.0068891966, -0.05252931, -0.00875912) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.023475884, 0.3249738, 0.12423857, 0.15533888, 0.16489662, -0.031202925, -0.09298049, -0.10218256, -0.08607021, 0.17618541, -0.17441903, 0.04832623, 0.040788148, -0.40390915, 0.13668308, 0.12629119) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.068355806, -0.07494243, -0.1573103, -0.017323963, 0.105486766, -0.08026859, -0.061071288, 0.12188722, -0.11440296, 0.2716581, -0.31576613, 0.06328967, -0.016376063, -0.023758793, -0.41636175, -0.026537959) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.021550357, 0.13650155, 0.020000732, -0.05083274, -0.021608708, 0.006608971, -0.025826959, -0.058390327, -0.095844574, 0.18004216, -0.20374136, 0.05040046, 0.02707274, -0.37983558, 0.089862555, -0.2897422) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0129234195, -0.120459035, 0.053185686, -0.20597969, 0.078015596, 0.06937393, -0.16571906, -0.051010836, -0.114776336, 0.2391145, -0.2424429, 0.08366135, -0.20824897, -0.24292152, -0.041180525, -0.27321494) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.112442106, -0.28416845, 0.35409608, 0.6216116, 0.027256355, -0.2793905, 0.122797765, 0.14991361, -0.17901647, 0.35382977, -0.43887103, 0.11585312, 0.06754511, 0.21831435, -0.14964688, 0.35285285) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.20822914, 0.079644985, 0.035913788, -0.029331801, -0.036333825, 0.10723337, -0.09948639, -0.38381213, -0.1174793, 0.20352815, -0.2546664, 0.08306815, 0.026248856, -0.34185478, -0.015974829, 0.02780692) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.069217324, -0.0063899737, -0.016519567, 0.009026589, 0.12965089, 0.035292022, -0.26543778, -0.13042441, -0.06393336, 0.15216568, -0.14844324, 0.0714895, -0.26768336, 0.1485001, 0.13679425, 0.20657867) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16957672, 0.21980143, 0.025224704, 0.30263108, 0.084045425, -0.18994898, -0.2649235, -0.18672997, -0.09766404, 0.2022167, -0.22538906, 0.11069465, -0.013534831, -0.18094203, 0.20522848, 0.1695507) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.17297965, -0.26013717, -0.18129548, 0.30050647, -0.09013039, -0.020311277, -0.0139542045, 0.057191025, -0.060502913, 0.12543827, -0.12700203, 0.06892806, 0.13382146, -0.027788319, -0.04861505, -0.044467073) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

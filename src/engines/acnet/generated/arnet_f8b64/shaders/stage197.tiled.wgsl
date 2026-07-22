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

  var result: vec4f = vec4f(0.24714398, -0.024133345, 0.12437728, 0.19342852);
      result += mat4x4<f32>(0.021567728, -0.042660575, -0.017159479, 0.058484323, 0.013727623, -0.09787971, -0.080822185, -0.0496919, 0.040734693, -0.2534974, 0.10441561, 0.13024029, -0.02865808, -0.031256884, 0.34793857, -0.021301858) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0978799, 0.1080415, 0.0038154086, -0.0155674955, -0.079646185, -0.057028454, -0.021781465, 0.056732707, -0.044320546, -0.0034245471, -0.11603036, 0.08674311, 0.08392685, -0.090483464, -0.22834231, 0.003988307) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.046368197, 0.12019258, -0.048956722, -0.11865424, 0.022686336, -0.18524365, 0.04028782, 0.0025541869, 0.03590634, -0.0057475464, -0.15049483, 0.030805526, -0.28734753, 0.17753407, -0.07245483, 0.10027168) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.016528405, -0.046736702, -0.049964845, 0.021092098, -0.41782725, -0.6765073, -0.3015902, -0.05094005, -0.07075878, -0.108091235, 0.14599836, 0.10739877, 0.14415915, 0.12811323, 0.108420596, 0.114610575) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14931688, 0.16915421, 0.19920683, -0.2458246, -0.30852, -0.45963934, -0.14346012, -0.09635071, -0.013621334, 0.13928007, -0.27464065, -0.26769507, 0.33696893, 0.1641633, -0.21835369, 0.035283264) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.25513387, 0.00035670106, 0.081498764, -0.54362386, 0.0713421, 0.0376338, -0.018120361, 0.13909854, -0.2622486, -0.09507826, 0.2199307, 0.56239754, -0.118518524, 0.03739492, -0.0141721405, 0.22119068) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.045551937, -0.07082021, 0.0022942736, 0.08298318, -0.19139217, -0.38933858, -0.35338545, -0.05163803, 0.16828217, 0.008650583, 0.36510977, -0.1643414, 0.028406126, 0.16994442, 0.17171979, 0.041092116) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13401897, -0.004312802, 0.10655104, -0.059376117, -0.14834893, -0.3200395, -0.1242918, 0.021723168, -0.24984784, -0.114197575, -0.37991872, 0.21081696, 0.035599396, 0.12509038, -0.15903625, 0.036857728) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.055426493, 0.01864425, 0.016433414, -0.12711489, 0.04901368, -0.019535452, -0.018971706, 0.1277094, 0.006901563, -0.022549707, -0.05696992, -0.00079647504, 0.03672772, 0.09269758, -0.031619135, -0.07463171) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.13167177, 0.0044305217, -0.05582247, 0.12489014, -0.041206263, 0.010384691, -0.13670014, 0.02158847, 0.21879733, 0.19856991, 0.14973694, 0.0054540886, 0.06317639, -0.05342898, -0.046705786, -0.075171545) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.04992139, -0.08806653, -0.20609915, -0.16242069, 0.0036103819, 0.0051480364, -0.12065444, 0.057949986, 0.009735423, -0.028103232, 0.069548465, 0.16276208, 0.034998793, 0.25235394, -0.4800109, -0.028142508) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.049418554, 0.038737003, -0.049526397, -0.12701167, 0.028338192, -0.0930893, -0.062156312, 0.03947045, -0.014312514, -0.27210134, -0.18070863, 0.13428292, -0.026978163, -0.002114941, -0.36308613, -0.0015163982) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.27496278, -0.009184871, -0.034826275, -0.17604928, -0.03807615, 0.17729758, -0.30962083, 0.12951511, 0.1982838, 0.7145495, 0.22680148, 0.22315507, 0.019980038, 0.15419532, -0.29685375, 0.1237344) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.51703936, -0.2290256, -0.37893358, -0.16307169, -0.30097228, 0.5716963, -0.392126, 0.35465398, -0.47967625, -0.7608125, -0.2550148, -0.6547441, -0.067623496, 0.3969917, 0.031717874, 0.052262984) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.17533211, -0.10991133, -0.09498148, -0.21785414, 0.055937223, 0.13234693, -0.32375062, 0.013180945, -0.067936055, -0.17961183, -0.046034455, -0.17054664, -0.011236373, 0.1229448, -0.36095935, -0.078779325) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10067782, 0.08895165, -0.11269254, -0.04569692, -0.011975373, -0.056605317, -0.086516835, 0.040045094, 0.21057971, 0.44053885, 0.29247078, -0.031945854, -0.0013965862, -0.10359588, 0.022652386, 0.104687065) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.034997813, 0.20654301, -0.2268854, -0.26226762, -0.058944788, -0.13361499, -0.065205425, 0.029942293, 0.29886353, 0.628334, 0.20057435, 0.2707579, 0.060023736, -0.041158903, 0.035523556, 0.019583661) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11975142, 0.075528644, -0.15397236, -0.07101838, -0.060918566, -0.15562086, -0.06042287, 0.2319683, 0.06943907, 0.031101178, 0.006119982, 0.10540122, -0.08452415, 0.017998446, -0.069210336, 0.1500812) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

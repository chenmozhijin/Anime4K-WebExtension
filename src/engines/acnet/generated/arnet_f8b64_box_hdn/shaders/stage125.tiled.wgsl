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

  var result: vec4f = vec4f(0.20215388, 0.13123208, 0.29350486, 0.3562763);
      result += mat4x4<f32>(-0.041159328, 0.20481232, -0.06850933, -0.04880093, -0.15709564, 0.17869893, -0.027913854, -0.24144013, -0.030439248, 0.062202185, -0.045904487, -0.09587667, 0.033526722, 0.049174853, 0.009434066, 0.071029164) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.22827196, -0.7289426, 0.553704, 0.26827937, 0.106497124, 0.32661077, -0.46843272, 0.30133805, -0.06536987, 0.079588994, -0.1704784, 0.035139512, -0.05545353, -0.08770384, 0.5102438, -0.31381425) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030200947, -0.16358253, -0.0609796, -0.042881034, -0.027585706, -0.005519172, 0.066126354, -0.04361802, -0.0052743177, -0.09463874, 0.10438147, -0.2317492, 0.026180696, -0.2359672, -0.022695458, 0.15727338) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.28117323, -0.05690668, 0.03835138, 0.12583128, 0.013086083, 0.38717976, 0.32888287, -0.16707334, 0.18700844, -0.11187093, 0.30111885, -0.014629329, 0.32038984, -0.2316841, -0.4425878, 0.20480193) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07697296, -0.17422685, -0.37671152, -0.06457892, -0.07922146, 0.3697341, -0.33134136, 0.2095409, 0.18186685, -0.17351854, -0.1455296, 0.28213817, -0.1015035, -0.15362749, -0.09837998, 0.14958724) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.044845942, 0.0078034755, 0.28773424, -0.3165958, -0.0017505075, 0.18731797, 0.048311915, -0.14687099, 0.020672875, -0.2229196, 0.1965589, -0.17155801, 0.048537314, -0.30366853, 0.18471663, -0.30914295) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.015779668, -0.113344245, -0.07972616, -0.17077094, 0.02093391, 0.018574178, 0.07442073, -0.060242325, -0.12424613, -0.26208156, -0.33298114, -0.17319003, 0.10893772, -0.19529627, 0.26027045, -0.0791126) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.28881195, -0.008410732, -0.1739496, -0.12088189, -0.094851084, -0.11229192, -0.17439122, -0.02031799, -0.066006355, -0.45914975, -0.30923152, 0.0775313, -0.16708982, -0.6944483, -0.40704072, 0.29462677) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06427609, 0.12696701, 0.118027836, -0.21006829, 0.005471692, 0.0075923307, 0.05254669, -0.057095394, -0.0069437455, -0.07346402, 0.020488556, -0.1225678, 0.008245846, -0.25328785, 0.19479647, -0.16454244) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.018759713, -0.18279621, 0.028901098, -0.05050996, 0.121774994, -0.39299718, -0.23455195, 0.5847388, 0.04266791, 0.01521421, -0.1098386, 0.15535393, -0.10205986, 0.12324609, -0.1402242, 0.1926313) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12738612, -0.015489892, -0.07155782, -0.4396049, 0.03909045, -0.03126881, -0.5385814, -0.74762416, -0.121393435, -0.0931053, 0.14354958, -0.21413857, 0.027547264, 0.22784778, -0.22585091, 0.024789263) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.024304237, 0.005431303, 0.13062751, -0.16753317, -0.19174045, -0.34379134, 0.06474309, 0.2259001, -0.0155910645, 0.1867868, -0.09642917, -0.029911276, -0.029627515, 0.02426473, 0.15394336, -0.14973906) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16527647, -0.3383806, 0.11568399, -0.35489935, -0.38890746, 0.13503094, 0.061804242, 0.15947743, 0.007656129, -0.07215597, -0.21391384, 0.12336763, -0.047934335, 0.032708094, 0.31012416, -0.08829882) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.11325419, -0.46148592, 0.33955124, -0.49706066, 0.1260905, -0.60837716, 0.15667185, 0.748381, 0.012599451, -0.17142472, 0.2789008, -0.7965742, 0.056048095, 0.6255345, -0.49748653, 0.3212986) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0145401545, -0.11532323, 0.18397288, -0.29506165, -0.08665679, -0.28253338, -0.034204233, -0.08970547, 0.00033270245, 0.26736286, -0.31492624, 0.12199839, 0.01644892, -0.05368678, -0.40024757, 0.20645967) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13642262, -0.2436944, -0.06600974, -0.08124118, 0.1314378, -0.06400785, -0.30441296, 0.037388057, -0.00815824, 0.08090368, -0.04007321, 0.043613624, 0.015147163, -0.18689269, -0.23017459, 0.2667045) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.114791304, -0.3754898, 0.038836528, -0.28589484, -0.24111259, 0.13845155, -0.30179265, 0.051139127, 0.06659182, 0.23629269, 0.18659554, -0.06274802, 0.008902965, 0.12779635, -0.13984062, 0.17083085) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07278464, -0.16841574, 0.12994531, -0.18882273, -0.14394557, -0.23531863, -0.20633689, -0.056553323, -0.035936654, 0.21465038, 0.0055776946, 0.1451025, 0.08642628, 0.8769538, 0.22848755, -0.36925212) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_1[tileY][tileX] = sample_FEAT_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(0.020192334, 0.14323476, -0.028524451, 0.32967642);
      result += mat4x4<f32>(-0.046803065, 0.005921869, -0.07464903, 0.0016288183, -0.1968556, 0.105524644, 0.03577271, 0.062985644, 0.15942958, 0.09927016, 0.014289942, 0.14145069, -0.16290629, -0.03648587, -0.090967715, -0.100278355) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20654495, -0.07157459, -0.02935246, -0.12215281, 0.05911288, -0.19370405, 0.0055665453, 0.13879746, 0.2552039, -0.04494848, 0.042801812, -0.04185366, 0.63853073, -0.34278142, 0.14252774, -0.2882228) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.13569014, 0.24056442, -0.010700244, -0.20470954, -0.040210046, 0.059158172, 0.019888252, 0.009340484, 0.019520512, -0.0074808565, 0.05821687, -0.043746356, 0.017033875, 0.14538392, 0.09110729, 0.14202899) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04367882, 0.14663412, 0.024764976, 0.043059833, 0.23173061, -0.48147762, -0.018185358, -1.0158643, 0.09050314, 0.049100757, -0.2405235, 0.044881362, -0.16344044, 0.18350239, -0.29791844, 0.19226111) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.38041624, 0.5973676, 0.0031389145, 0.9163976, -0.058438934, -0.94999504, -0.021599995, -0.49608088, 0.3960222, 0.026928078, -1.1810812, 0.7075898, -0.12882462, -0.3182565, 0.75503135, -0.5174284) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.012709125, 1.0032034, -0.033948813, 0.08466678, -0.00021553006, 0.088629715, 0.051163662, -0.032297708, -0.004761253, -0.13656534, 0.38069618, -0.13870664, 0.39603034, -0.33577392, 0.40832636, -0.21535565) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04402137, -0.01950512, -0.013616629, 0.036954667, 0.1099972, 0.3645845, 0.15953013, -0.0034648338, -0.078462236, -0.10401612, -0.24811114, 0.06708759, -0.10295946, -0.12691222, -0.024352763, 0.062443852) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.040559456, -0.35573253, -0.117247164, 0.006864406, -0.23367135, -0.008347592, -0.06420796, 0.108099066, 0.103988394, -0.1371324, 0.22856987, -0.033941276, -0.7282169, 0.21888478, 0.38340053, -0.40851367) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.18001823, -0.02303172, 0.08161125, -0.106778085, 0.019654525, 0.006208086, 0.018739818, 0.01778342, 0.045748074, 0.043829545, -0.0834522, 0.051441774, -0.09862723, -0.13118078, 0.21922086, 0.03821311) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.26321393, 0.05916067, 0.010112636, 0.22573505, 0.18278815, -0.049722586, 0.15730321, -0.16605839, 0.08483153, -0.07512222, -0.09766898, -0.022722632, -0.4851192, -0.50198776, -0.43100983, 0.060552914) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.41842806, 0.33665147, 0.5562707, 0.041391492, -1.1626793, 0.31380355, -0.19471002, -0.13223965, 0.9471764, -0.451825, -0.15963246, -0.18321057, -0.2769383, -0.15281382, -0.70423985, 0.09048734) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.067566775, -0.10073303, -0.013340937, 0.033500083, 0.410151, -0.0400011, 0.00020040058, -0.009503798, -0.1917746, 0.19671907, 0.009870197, -0.020083388, -0.9143555, -0.34787127, -0.6674374, -0.058265746) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.027618496, -0.103802666, 0.12856865, 0.2094997, -0.032996967, 0.31690684, 0.08605712, 0.19287258, -0.03170308, -0.18730794, -0.04501754, -0.21067639, -0.23791532, -0.73263943, -0.23510186, 0.6259249) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.8300237, 0.020313075, -0.16237165, 0.24405855, -1.1080414, -0.5076531, 0.59949803, -0.21146727, 1.0016216, 0.13907482, -0.42190158, -0.11861185, 2.2004197, 2.2986782, 1.2732359, -0.07037724) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.05392468, -0.025012145, 0.06175787, 0.19751269, 0.30087575, -0.27831787, 0.092523314, 0.09243123, -0.19504729, 0.26243865, -0.04300587, -0.15797916, 0.6242594, 0.3417555, -0.038583893, 0.11973178) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06046456, 0.0102406675, 0.037968684, -0.022685973, 0.104224965, 0.059736118, -0.07289957, 0.137497, -0.06927535, -0.073414005, -0.008078289, -0.047746137, -0.11901059, -0.010571217, -0.14419074, 0.6444366) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0630466, 0.22563332, -0.009758655, -0.03113203, -0.1582054, -0.102397375, -0.06885084, 0.028530056, 0.13119765, -0.052072003, -0.002248529, -0.032169405, 0.6596879, 0.35417193, 0.27759096, 0.40483844) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.008615682, -0.07591326, 0.007874674, -0.09909144, 0.1891961, -0.075182416, -0.0066665737, 0.062436786, -0.14169224, 0.10227155, -0.0036326537, 0.007843743, -0.25569865, -0.34034076, -0.14867105, 0.35072508) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

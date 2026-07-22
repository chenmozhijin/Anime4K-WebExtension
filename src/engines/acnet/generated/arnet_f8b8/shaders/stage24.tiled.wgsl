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

  var result: vec4f = vec4f(0.04604136, 0.28753757, -0.017035099, -0.22537354);
      result += mat4x4<f32>(0.05623934, -0.31725317, -0.3218192, 0.2709574, -0.07027554, -0.077358246, -0.03338031, 0.29166204, 0.05532498, -0.08569432, -0.14231233, 0.1566369, -0.04549789, 0.021934377, 0.026597528, 0.03227638) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.058940783, 0.11600686, -0.07711348, -0.023682205, 0.34996805, -0.55192393, 0.45938256, 0.38555893, 0.14960939, -0.051484488, 0.1398451, 0.09156693, 0.06515433, -0.45406032, -0.16346316, 0.257505) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0021125604, -0.21626566, -0.07909783, 0.13434814, 0.17498979, -0.21674013, -0.0936662, 0.098953746, -0.054187573, 0.25182176, 0.20988561, -0.19068526, 0.43264592, -0.13065295, -0.14967668, 0.21758306) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06379337, -0.21205844, -0.31529242, 0.23752984, -0.09408981, 0.02123655, -0.26779655, 0.07754447, -0.14270657, 0.06997281, -0.1701245, -0.027170742, 0.14031067, 0.024067456, -0.05634223, -0.071568124) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18068415, 0.14453672, -0.087390006, -0.07932325, 1.0799301, -0.12444241, -0.4187627, -0.2427466, -1.1329019, 0.107859455, 0.95109546, -0.1704385, 0.44253656, -0.52068394, -0.25147238, 0.11959046) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06815371, -0.301138, -0.12662709, 0.08031249, 0.032864857, -0.05467238, 0.147805, -0.09196312, -0.00049551023, -0.026501622, 0.05429674, 0.09946547, -0.1207827, 0.05154998, -0.5938665, 0.3707915) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06903015, -0.16685177, -0.24277227, 0.1814775, 0.019025631, -0.024309589, 0.021846017, 0.06774223, 0.15223701, -0.023073595, -0.04198058, -0.07507548, -0.0110603785, 0.05441973, 0.077007376, -0.026451763) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08678529, -0.107364595, -0.08639431, 0.021560535, -0.09925293, 0.05025683, 0.31723619, -0.15019721, 0.046455555, 0.008044475, -0.004078181, -0.12643905, -0.17974618, -0.019737741, 0.20861712, -0.033698633) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.05031342, -0.21004863, -0.067952275, 0.054550085, -0.08472838, 0.06244538, -0.070147015, 0.027745824, 0.0618305, 0.027583744, 0.05930004, -0.041196167, 0.010496714, 0.02613808, -0.13383797, 0.046175323) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.17722109, -0.0674898, -0.10617527, -0.034814376, -0.023341237, 0.05553783, -0.22064322, 0.097509146, 0.050648227, 0.14788824, -0.17876185, -0.050743695, -0.015591785, 0.03185243, -0.024324281, 0.037362143) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21018724, -0.083196886, -0.15077688, -0.030690102, 0.19408883, -0.113721326, 0.049074467, 0.14915068, -0.5115545, 0.23360418, -0.544458, 0.07180276, 0.31662253, 0.051234435, 0.11367194, -0.11347192) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0845997, -0.1764839, 0.005307965, 0.10505721, -0.11270266, -0.09698296, 0.1076233, 0.006278783, -0.36156073, -0.11145643, 0.15176074, -0.0999701, 0.08319218, 0.065971516, -0.061918765, 0.0032972447) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1142957, -0.10671811, 0.4622062, -0.16659163, 0.0016099652, 0.003883725, -0.14388256, 0.05212246, 0.07845312, 0.014880565, 0.034655597, 0.07636836, -0.04370292, 0.16526017, -0.009203267, -0.07643313) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28729218, 0.010987167, 0.2886764, 8.8392655e-05, -0.14384876, 0.31345263, 0.3265145, -0.60367507, 0.049454316, 0.5232249, 0.224242, -0.04018926, -0.6031521, -0.18163511, -0.1461593, 0.35227892) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1199396, 0.07848945, -0.13484384, 0.21830048, -0.08716306, 0.0062083956, -0.15525626, 0.21654376, -0.024651697, -0.07497884, -0.14729095, 0.1566868, -0.1718431, 0.1103398, 0.18194722, -0.25464615) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.020311786, -0.14207216, 0.15741, 0.0021982396, 0.035332862, -0.10521413, -0.064886145, 0.09039884, -0.1080854, -0.07638371, 0.018664917, 0.058790553, -0.10187026, -0.06085095, -0.033552587, 0.024140356) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24133496, 0.0019799126, -0.12182045, 0.109381415, -0.15780231, -0.06281771, 0.071548454, -0.00985125, 0.07878729, -0.15824649, -0.42813078, 0.24256028, -0.14093943, 0.16519181, -0.4267368, -0.110105984) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10946176, 0.091833, -0.11739446, 0.08558089, 0.15774319, -0.019065827, -0.02456792, 0.055074807, -0.026374275, -0.043504357, -0.09933058, 0.058224093, -0.20857714, -0.2295117, 0.045962922, 0.08217442) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

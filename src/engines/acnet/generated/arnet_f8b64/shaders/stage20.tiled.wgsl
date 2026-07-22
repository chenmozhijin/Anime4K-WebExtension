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

  var result: vec4f = vec4f(0.30101064, -0.062338825, -0.02607094, -0.08992082);
      result += mat4x4<f32>(0.113184296, 0.042970218, -0.2635701, 0.042939264, 0.022930061, 0.09170457, -0.3384241, 0.31203043, 0.042145915, 0.13105795, -0.055928603, -0.072632216, 0.015942883, 0.053594466, 0.015947051, -0.3410942) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.26055333, 0.03290178, 0.13135636, 0.41312993, 0.09334804, 0.10317432, -0.22706842, -0.22455105, -0.067690045, -0.066015705, -0.010308075, 0.23200007, 0.09229846, -0.07839589, -0.076046966, -0.136577) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.061465494, -0.13251443, -0.11926679, 0.11693616, 0.11702213, 0.013441303, 0.02642842, -0.12579128, -0.27792668, -0.11790943, -0.16374834, -0.13498002, -0.009925126, 0.13181913, 0.051454373, 0.0037793266) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.15493108, 0.72510153, -0.51175725, -0.3271065, 0.53280336, 0.0042056115, -0.2015315, -0.41603765, 0.15135652, 0.427755, -0.31850597, -0.3617523, -0.09610431, 0.011941528, 0.0048209215, -0.33231547) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.94481784, 0.47146547, 0.7136533, 0.5856626, -0.12344729, 0.0011416659, -0.28098673, -0.26145837, 0.15226634, 0.16567858, -0.17733143, -0.8436338, -0.11977575, -0.4527042, 0.60219353, 0.2325308) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.107889466, -0.0036870744, -0.1224067, -0.0055727456, -0.043305416, -0.1335176, 0.22377954, 0.43749398, 0.05324043, -0.011453344, -0.38844717, -0.2603092, -0.2685441, 0.13143279, -0.4475775, -0.39780205) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.052065566, -0.049529552, -0.2544614, -0.14483206, -0.07732506, 0.21872264, -0.014396583, 0.097125016, -0.1226138, -0.31335804, -0.038923763, -0.11917581, -0.14530535, 0.047425464, -0.0031246631, 0.02525513) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.34093115, 0.09642904, 0.0062316773, -0.15353405, -0.21337326, -0.102437586, 0.097354084, 0.3306156, -0.15665361, -0.110636614, -0.21986224, 0.022987695, 0.09210337, -0.06696178, -0.2517039, -0.13891572) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.17502475, -0.1426221, -0.10468103, -0.0041666864, 0.24337782, 0.061497148, 0.2895997, 0.1427084, -0.09417466, -0.02495731, 0.09560797, -0.26517463, -0.046096012, -0.01737175, -0.19416435, 0.1483999) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0076215765, -0.03166789, -0.013156531, -0.0035341808, 0.004475454, -0.16704783, 0.13201597, 0.07924158, -0.15977685, -0.10397056, 0.099543795, 0.09919399, -0.23011918, -0.051488735, 0.07179473, 0.20638402) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.37059444, -0.08480897, 0.081033245, 0.10084818, -0.035325933, -0.09619591, -0.005933714, -0.116249874, -0.025575023, -0.0035604662, 0.13168965, 0.052911066, -0.004462821, 0.011348614, -0.13402706, 0.24662092) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.17113832, 0.16205513, 0.24620582, 0.4593819, 0.014400669, 0.044343784, 0.07655021, -0.09909827, -0.17702344, -0.025310872, -0.090730466, 0.12051289, -0.110261515, 0.056491043, -0.17476098, 0.11707569) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.08486927, 0.13265859, -0.02063854, 0.1437098, 0.0062445467, -0.68446463, 0.49786693, 0.5492426, -0.3647454, -0.20706287, -0.0529917, 0.29531863, -0.34954256, 0.17994522, -0.15440847, 0.35691038) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12378941, 0.18185245, 0.3489705, -0.20489527, 0.50501555, -0.6100023, -0.4821333, -0.3789992, 0.39946705, 0.05301717, -0.39669752, -0.3712702, -0.25419927, -0.13794225, -0.2745418, 0.3267212) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1621673, -0.10642669, -0.20765239, 0.00027390468, 0.25179935, -0.094423294, 0.04551283, 0.03751338, 0.26915184, 0.027304243, 0.45055968, 0.25954843, 0.2701926, -0.0014410734, -0.21501215, 0.37951317) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.107531875, -0.023566708, 0.035691883, 0.105167694, 0.01266719, -0.114580475, 0.21073733, 0.13130984, 0.10314713, -0.000553533, -0.025276793, -0.12166401, 0.14995964, 0.02223523, -0.08144501, 0.26556468) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0659507, 0.067073934, 0.17531079, 0.13491528, -0.23853844, -0.030982304, 0.106459424, 0.22320808, -0.032532092, -0.07910116, 0.032006092, 0.10291957, 0.07641656, -0.02172986, -0.16173358, 0.3026899) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.17571822, 0.22974661, 0.12337829, -0.06856228, -0.101815775, 0.121392585, 0.013622515, 0.11980005, -0.04205302, -0.058788415, -0.0026639744, -0.2087207, 0.110113196, 0.076990195, -0.104218, 0.12263532) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

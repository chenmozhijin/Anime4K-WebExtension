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

  var result: vec4f = vec4f(-0.0066851866, 0.13667323, 0.4388831, 0.19536223);
      result += mat4x4<f32>(-0.014275466, -0.23630501, -0.1965423, 0.047824215, -0.12778717, 0.20180213, -0.11147904, -0.06072951, 0.09589276, -0.2157868, 0.056170836, 0.048709907, -0.0407109, 0.08516942, -0.054681595, 0.00091427454) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.074696034, -0.45473152, 0.17326826, 0.13076465, -0.2452476, 0.37904343, -0.2028766, -0.09250814, 0.23251168, -0.13573433, 0.13370462, 0.08376532, -0.1840714, 0.18411803, -0.10539947, -0.07087605) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.072018616, -0.1582765, 0.42269284, -0.14638084, -0.149186, 0.23593827, -0.06557346, -0.09592628, 0.073116384, -0.10979127, 0.010493936, 0.06677503, -0.12773718, 0.24887605, -0.108464725, -0.06358996) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17406237, -0.2741835, -0.07745552, 0.115973294, -0.11569955, 0.2732505, -0.09310185, -0.064992435, 0.121423155, -0.30083358, 0.09846441, 0.060819127, -0.19080721, 0.13699478, -0.19969252, -0.0022468197) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.23780786, 0.4367821, 0.50505644, 0.05184732, -0.27390882, 0.41978112, -0.17924552, -0.14864352, 0.22795473, -0.3081264, 0.115379475, 0.08807625, -0.16849028, 0.6194423, -0.21050431, -0.096557885) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.041453857, -0.13039406, -0.037951812, -0.013247294, -0.20581532, 0.37769544, -0.19283576, -0.10421052, 0.09193514, -0.20178305, 0.089498855, 0.101216316, -0.20405357, 0.2638768, -0.118889414, -0.06739531) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.014191079, -0.119853795, -0.017363736, -0.03512133, -0.054137066, 0.1738848, -0.05879752, -0.030291267, 0.09060627, -0.17267147, 0.08813289, 0.021275673, -0.079435535, 0.094997264, -0.118569426, -0.0005839444) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.096827924, -0.39183596, 0.10833025, 0.007894609, -0.16535884, 0.2811589, -0.18559787, -0.054472994, 0.12239446, -0.25071025, 0.098086424, 0.06597805, -0.12452254, 0.36437958, -0.036916904, -0.08741507) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09489289, -0.222316, -0.10988599, 0.12976305, -0.111933395, 0.13291459, -0.03361956, -0.06400616, 0.06920908, -0.0553058, 0.04180301, 0.0083419895, -0.15935315, 0.33095604, -0.17534074, -0.12785426) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.21216491, -0.2083357, -0.04990605, -0.16264395, 0.04445809, 0.29706767, 0.122184224, -0.15467514, 0.061444685, -0.25224203, 0.021832932, 0.06248053, -0.07154275, -0.29409122, 0.15294695, -0.09177243) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.02469307, 0.2613592, -0.04452749, 0.023945259, -0.11896767, 0.1376038, -0.3035079, -0.080414765, 0.15478206, -0.3673967, 0.07140446, 0.10214508, -0.035752375, -0.14958233, 0.3609976, -0.00651863) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.28998995, 0.65384895, -0.010222465, 0.33061102, -0.04489828, 0.075746424, -0.05392914, 0.0047726957, 0.08561263, -0.23874027, 0.024675338, 0.077519745, 0.032322656, -0.17353408, 0.12640396, -0.03264523) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.043452185, -0.25384036, -0.02963853, 0.029375771, 0.0060215965, -0.1769319, -0.085983396, 0.07794991, 0.11175977, -0.34396642, 0.07469563, 0.074957706, -0.25006545, 0.008779327, -0.18942958, -0.08719383) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.26950154, 0.43081743, 0.16453888, 0.24509455, -0.10570655, -0.43951437, -0.56895816, -0.057490375, 0.28158197, -0.5852943, 0.1119475, 0.16883452, -0.11534138, -0.09201594, 0.56953627, -0.003598022) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15797241, 0.42451847, 0.14817014, -0.011110493, -0.0985196, -0.057739805, -0.20155907, 0.18828455, 0.15879351, -0.38233456, 0.066045284, 0.1218156, 0.11574976, -0.21453707, 0.41756693, 0.2827661) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.258869, -0.5237399, -0.06711465, -0.20148265, 0.018468168, 0.03290291, 0.03389166, 0.048918627, 0.07768686, -0.18916355, 0.11297903, 0.009527881, -0.04690187, 0.05623396, -0.4334353, 0.24865246) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1267258, -0.22286277, -0.05374877, 0.12609868, 0.043815583, 0.10986403, 0.10789818, -0.10342349, 0.09555836, -0.4113794, 0.06907888, 0.083719954, 0.14563589, 0.3590241, 0.264538, 0.36006296) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19792755, -0.24450071, -0.10241867, -0.11560835, -0.045135204, -0.012029956, 0.06948006, -0.09275988, 0.10588451, -0.14879325, 0.0012672825, 0.067332745, -0.045003712, -0.18335122, -0.112681784, 0.09082334) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

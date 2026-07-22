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

  var result: vec4f = vec4f(-0.030626563, 0.08009926, 0.018293, -0.30889738);
      result += mat4x4<f32>(-0.025413465, 0.13027778, -0.0045582675, 0.03506042, -0.032201808, 0.06308554, 0.043695487, 0.12129106, 0.009259609, -0.9312253, 0.7410151, 0.6371555, -0.08160836, -0.025171205, 0.045099624, 0.05083756) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.45055032, -0.114644, 0.29038608, 0.43228862, -0.077098705, 0.26678547, -0.8236535, -0.46651655, 0.24912205, -0.31306142, -0.21897939, 0.120454445, -0.020655842, 0.003210327, -0.034153115, -0.025474347) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.031606197, -0.007400555, 0.07524981, -0.023337854, -0.15223938, 0.14949875, -0.04566842, 0.022426166, -0.03584556, 0.23019825, -0.080455, -0.07274647, -0.16418867, 0.048832234, -0.046542197, 0.13457383) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06205558, 0.044918437, 0.0098169595, -0.12169927, 0.0350123, -0.2517506, 0.2665568, -0.0060828407, 0.060632203, -0.41283926, 0.3768172, 0.15288408, 0.10910277, -0.03348808, 0.058538716, -0.10224136) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4322422, 0.20090114, -0.85658455, -0.20426987, -0.0899846, -0.2929023, 0.30662322, 0.2996528, 0.17165284, -0.36532497, 0.17729203, 0.042553082, -0.43173397, 0.029886315, 0.48893622, -0.2110656) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.016974892, 0.2517813, 0.0110954745, -0.039902747, -0.0014152436, 0.25738347, 0.081254646, -0.15596788, 0.068855956, 0.047190655, 0.03389936, 0.0019428103, -0.003059841, -0.06268893, -0.22260393, 0.39258254) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04801215, 0.12931803, -0.015214087, -0.27698678, 0.11026009, 0.17841601, -0.13247332, -0.022633148, -0.104039565, 0.26032344, -0.19418564, -0.043132197, 0.04839751, 0.017724736, 0.014414601, 0.023064822) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.29167303, 0.05857977, 0.07612873, -0.22866583, 0.023295378, 0.008681728, 0.16660103, -0.023192385, -0.07792077, 0.26835167, -0.23534358, -0.06690811, 0.035433453, 0.14342971, -0.06507827, -0.06179894) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.059913997, 0.08661413, -0.059229676, 0.096927606, 0.049401306, -0.07332476, 0.051945027, -0.0068913978, -0.055711806, 0.14151931, -0.08823232, -0.07892153, 0.02380068, 0.13146184, 0.012162834, -0.051245917) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.11785088, -0.16331685, 0.10394631, 0.14711872, 0.05808918, -0.07387093, 0.03186934, 0.15596333, -0.03441834, 0.17774618, 0.005455081, 0.06900885, 0.018955555, -0.09879196, 0.017319346, -0.067860335) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.12010332, -0.013235223, -0.107328124, -0.2923052, 0.087589495, -0.07147328, -0.2265988, -0.39305043, -0.2041913, 0.3463097, 0.07091763, -0.108016886, 0.3280713, -0.03254709, -0.10131854, -0.35470393) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12608263, 0.02533386, 0.01406174, 0.007164232, 0.03939954, -0.025661973, -0.05325315, 0.011133172, -0.042279333, 0.0645865, 0.005569811, -0.008472547, -0.025018582, 0.04034723, -0.05133005, 0.0312529) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.278117, -0.03623458, 0.18962602, 0.4012252, -0.11532615, 0.07643637, 0.01577532, -0.31195962, 0.29108357, 0.06660491, 0.15422845, -0.97014606, 0.08262585, -0.098863475, 0.022860344, 0.12645122) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.25545818, -0.13822116, -0.6193353, 0.1819147, -0.10525481, -0.0066566905, 0.11481179, 0.28121746, -0.109768234, 0.48942798, 0.038173445, -0.24173562, -0.5673033, -0.27617887, 0.69276386, 0.13356435) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.038935393, 0.18124822, -0.030492958, 0.054115858, -0.08953711, -0.016711697, -0.06966528, 0.018180132, 0.034219593, 0.03760238, 0.031546663, -0.05876695, -0.0023761797, -0.14205277, 0.110495746, -0.05362882) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.036374882, 0.10276753, -0.084872216, -0.2472155, 0.08787216, 0.14889303, -0.10382059, -0.009660292, 0.09210081, 0.14963445, -0.25248665, 0.1308204, -0.014873795, -0.16302386, 0.11129107, 0.15254499) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.19888078, 0.041427497, 0.110516675, -0.05262628, -0.045273345, -0.06266218, 0.28647432, -0.038004342, -0.0714416, -0.032296423, -0.055669095, 0.12588623, -0.27663374, -0.063341245, -0.07610087, 0.13917764) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08652557, -0.054525755, -0.018688079, -0.0135815, 0.12750466, -0.0036787281, 0.022998953, -0.04926083, -0.07372036, -0.08517959, -0.0038083396, 0.030165745, -0.002881952, 0.0026813908, 0.030897524, -0.07913893) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

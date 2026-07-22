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

  var result: vec4f = vec4f(0.2517082, 0.049101826, 0.124772005, -0.2512191);
      result += mat4x4<f32>(0.0067893346, -0.011677414, 0.061496716, 0.1566348, -0.026889792, 0.06375014, 0.07768253, -0.20363665, -0.11761181, 0.08395931, 0.1018491, -0.3208749, 0.026877098, 0.07667197, 0.08377861, -0.072365314) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.37661222, -0.28034836, -0.08388196, 0.01946095, -0.092113905, 0.20603718, 0.1843082, 0.000877824, -0.022374097, -0.038313825, -0.18294224, -0.1007693, -0.006295853, 0.07183537, 0.040247507, -0.0010550213) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05549477, -0.023379903, -0.043138385, -0.014239747, -0.23200248, -0.03521206, 0.10562492, 0.0816189, -0.0056448258, -0.023426173, 0.036339577, 0.042187974, 0.038283657, -0.0029869587, 0.014553735, 0.034675356) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0649367, -0.10756974, -0.043848705, 0.15184285, 0.010117952, 0.01977481, -0.05843892, 0.09346408, 0.11586529, -0.07204362, -0.06519819, -0.29128304, 0.2817059, -0.28524998, -0.15448342, 0.47912714) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.43720448, 0.45913997, 0.041050732, -0.045752604, -0.46185133, 0.14744316, 0.037572037, 0.38363844, -0.26311755, -0.39658377, -0.10135655, 0.07696766, -0.01711751, -0.18523815, -0.04712925, 0.10698516) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07733636, -0.13105544, -0.083184525, 0.025777493, 0.26261708, 0.20199765, 0.18158284, 0.0008234313, 0.0340616, -0.0052743717, 0.04214137, 0.088679336, 0.021019178, 0.040586565, 0.124726094, 0.03700961) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.046874434, -0.07543104, -0.06856634, -0.072695576, 0.05635757, -0.03983061, 0.01145243, 0.05512832, -0.025768103, 0.0974103, 0.046994947, 0.20923913, -0.3015052, 0.006864737, 0.25798577, -0.22883993) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15432753, 0.13093013, 0.022167131, -0.024292761, -0.022839611, 0.06955365, -0.014125665, -0.010160046, 0.017788028, 0.22872347, 0.079059124, 0.14698295, -0.077080615, -0.013299104, 0.016587256, -0.09697196) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.030983303, 0.016482085, -0.02905252, -0.077206165, -0.036974717, 0.02895051, 0.011401789, 0.0012070864, -0.0035686984, -0.015881129, 0.07378589, 0.13630837, -0.041615468, -0.029799238, 0.041001495, 0.11110393) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.12228153, -0.039314456, 0.22376971, 0.5438877, -0.081132896, 0.048106965, 0.07403798, -0.0244578, 0.16803887, -0.00580185, 0.013858908, -0.103663765, 0.10553719, -0.06825379, -0.08043323, 0.17319375) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0026193385, -0.18415362, -0.20579919, 0.13430804, 0.04046032, 0.050492346, 0.12710224, -0.0078598, 0.18949805, -0.03948615, -0.10947276, -0.08565988, 0.065602005, -0.21108231, -0.103908, 0.30242306) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.059523642, -0.028972594, 0.15785432, 0.107816406, 0.05798935, 0.018453555, 0.03219942, -0.046980564, 0.00994083, -0.061649974, -0.18396991, 0.01090793, 0.05221445, 0.021647045, -0.036025736, -0.026311876) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.287899, -0.17866889, -0.120499805, 0.20624311, -0.3578067, -0.05448377, 0.31959227, 0.19288525, -0.022918936, -0.2299555, -0.09766586, 0.07826949, 0.15979064, -0.138775, -0.19758266, 0.12389932) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.09934917, 0.374081, 0.2308645, -0.18671533, 0.26528808, 0.14457421, -0.11954687, 0.29278317, -0.18430439, 0.042509608, 0.8078236, -1.0246803, 0.65812176, 0.2863425, 0.03125128, -0.44999146) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07076939, -0.2384256, 0.05336818, 0.27787182, 0.03797653, -0.07334888, -0.018707585, 0.08351732, -0.08632367, -0.1331128, 0.30924603, 0.08212431, 0.037199795, -0.06925006, -0.15508081, 0.030103242) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07170218, 0.00036938125, 0.03250661, -0.053875186, 0.032400675, -0.21097091, 0.13610141, 0.40040123, -0.061118618, -0.16839561, -0.12454304, 0.07873928, 0.0044390745, -0.07722028, -0.036852825, 0.13502063) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.029104045, -0.13019861, -0.051073216, 0.12261307, -0.23307896, -0.24707331, -9.5876625e-05, 0.16554025, -0.046418913, -0.16271374, -0.19229375, -0.2910784, 0.05914033, -0.09591369, -0.066600196, -0.03505057) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.016328398, -0.09633701, -0.079377696, 0.11205755, 0.10449221, 0.16820674, 0.11924142, -0.15203576, -0.048373822, -0.053477272, 0.083812125, 0.12251773, 0.035955507, -0.0776753, -0.076975316, 0.10853931) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.07558835, -0.34339574, 0.007675933, -0.045478377);
      result += mat4x4<f32>(0.011083164, -0.00966441, -0.011024856, -0.015731754, 0.00087139313, -0.053137816, 0.017312206, 0.03139945, 0.095923185, -0.01866742, 0.03792872, 0.026880423, 0.2100569, -0.03167522, -0.057158027, 0.0928298) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.12981509, -0.063356906, 0.036241032, 0.15437557, -0.14014287, 0.012404317, -0.07358644, -0.013181054, 0.087681726, -0.049263235, 0.018057799, -0.011023763, -0.013142912, -0.3178736, 0.041224875, 0.26692662) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.015294077, -0.060126532, -0.086008124, -0.0050454545, -0.028826967, 0.020311976, -0.06044894, -0.046948407, 0.045819562, -0.029353285, 0.054173764, 0.04704715, 0.0073980736, 0.09354182, 0.0027233046, -0.1358388) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.028225709, -0.18354975, 0.028399548, 0.12514873, -0.012783523, 0.23857288, -0.117174104, -0.21621232, 0.09534103, 0.08082507, -0.05818617, -0.081151776, -0.024643593, 0.2835816, -0.27719486, -0.13642855) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17027916, -0.1309164, -0.21525845, -0.2052232, -0.44339535, -0.32488608, 0.3353681, 0.16123122, 0.15721008, -0.028632106, -0.60412556, 0.08347444, -0.003795029, -0.12306305, -0.22629379, 0.09335245) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.027116308, -0.09354843, 0.20570613, 0.10437813, -0.08875441, 0.042058315, -0.024665782, -0.061087698, 0.038499225, 0.049765587, -0.108897224, 0.050441373, 0.052640785, 0.24879494, -0.04751523, -0.036898218) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06534432, -0.026655298, 0.0045692944, -0.010678587, 0.043559145, 0.13465133, -0.024497706, 0.22921139, -0.042663913, 0.08530581, -0.0416665, -0.041151572, 0.30798513, 0.1011294, 0.15263502, -0.058196083) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10012405, 0.12908702, 0.044200037, 0.024298858, -0.16610946, 0.20191705, -0.44437566, 0.68569493, 0.021224212, 0.16152282, -0.058238193, -0.060915206, 0.18336073, -0.32181665, -0.012663139, 0.19067478) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.009399766, 0.035008155, 0.015574448, -0.10056563, -0.13552363, 0.0883773, -0.057373993, -0.026863988, 0.025295662, 0.059437685, 0.010656558, -0.06941668, 0.07432203, 0.095014356, -0.15882525, 0.057666197) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.009999062, -0.006248173, 0.02027726, -0.012234384, 0.0647336, 0.10701336, -0.14091, -0.09921916, -0.026484158, -0.11237642, 0.022489049, 0.075447254, -0.12319127, -0.042750746, -0.046519272, -0.035541937) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.11372954, -0.022101147, 0.0017925213, -0.06667519, -0.053695224, -0.030340673, -0.06900586, 0.011528929, 0.20444718, 0.07699783, -0.0978728, -0.06331827, 0.36915347, 0.14927042, -0.17403495, -0.17845434) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.043784004, 0.1354284, -0.011871057, -0.073738, 0.09091785, -0.425671, 0.13259315, 0.34444192, 0.019398352, -0.07364962, -0.014176951, 0.024167472, -0.03753828, -0.23852743, -0.011287166, 0.13575469) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14492162, -0.11468255, -0.027358016, 0.023506163, 0.08855915, 0.40716854, -0.35940966, -0.52470726, -0.025173359, -0.07368604, 0.042384233, 0.18224445, 0.047554433, -0.15017334, 0.13244629, 0.07460947) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.22011848, -0.24986655, -0.39131108, 0.383903, -0.012529588, -0.19803122, 0.3806098, 0.19500127, 0.105127454, -0.24883361, 0.67028385, -0.015508529, 0.21105555, 0.07336205, 0.41961062, 0.032378588) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.19163339, 0.15940513, -0.19573292, -0.16622029, -0.12664844, -0.165728, 0.54160154, 0.3946097, 0.063824154, 0.099398255, -0.015569867, -0.037752017, -0.16825554, -0.019133687, 0.06682662, -0.07490873) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.027621672, -0.05151177, -0.023523932, 0.06009464, 0.06270152, 0.11771704, -0.18954372, -0.10801423, 0.068588644, 0.04829426, -0.057142604, -0.007762775, -0.21961986, -0.19903597, -0.17907235, 0.07974221) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06331801, -0.036606487, 0.012643298, 0.044172633, -0.025618833, 0.24519536, 0.006589093, 0.04170012, 0.05768824, 0.21442917, -0.036292747, -0.051449835, -0.42679173, -0.074037455, -0.3817554, 0.006543883) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.042908926, -0.016249456, 0.016785353, 0.040686462, -0.096201934, -0.35204765, 0.20898081, 0.18836819, -0.05763727, -0.054504994, -0.049889088, -0.020630658, -0.21163236, 0.14802715, -0.2778156, -0.018960278) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

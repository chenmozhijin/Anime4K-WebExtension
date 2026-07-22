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

  var result: vec4f = vec4f(0.29775122, 0.06053297, 0.16133684, 0.2176567);
      result += mat4x4<f32>(0.06423006, 0.1256028, -0.019886458, 0.06774881, 0.03402245, 0.17615466, 0.04588753, -0.023971975, -0.0031743494, -0.1899751, -0.096931584, 0.073162876, -0.06933109, -0.13837014, -0.010679797, -0.118188985) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.04834428, 0.18838365, -0.14834303, 0.06260908, 0.032473043, 0.282618, 0.055482194, 0.13680783, -0.17122054, 0.23413815, -0.01419414, -0.076581456, -0.057088934, -0.25485787, -0.037508704, -0.10214152) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.056830995, 0.20407398, 0.023270162, -0.005425803, 0.07838484, 0.10490784, 0.025373025, 0.06408631, -0.05544602, 0.18189488, -0.15053628, -0.039729964, -0.063744135, -0.23061003, 0.0516573, -0.09918605) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15624714, 0.37150756, 0.11505977, -0.0050804927, 0.06775326, 0.24299668, -0.04918209, 0.19187978, -0.19701676, -0.051543716, -0.32318696, 0.07075682, -0.09931004, -0.3244796, -0.0062564975, -0.087715454) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.040770326, 0.4179707, 0.012909566, 0.19534269, -0.066987984, 0.3761497, -0.12334071, 0.11325334, -0.15608466, 0.32936987, 0.20339416, -0.1996948, -0.14854012, -0.38205776, 0.004318861, -0.21454227) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.028766679, 0.16782252, 0.039995115, -0.014881981, 0.007917825, 0.2585801, 0.02672048, 0.058055785, -0.16449156, 0.2009449, -0.18171145, -0.038943216, -0.114746355, -0.32985213, -0.034746666, -0.17559527) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.056935478, 0.29791757, -0.005216919, 0.07158015, -0.048792843, 0.20632757, -0.02444787, -0.0046035503, -0.20594594, -0.09476873, -0.054265484, 0.08185557, -0.078004405, -0.1629617, -0.019932115, -0.06845119) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11212753, 0.324753, -0.08622577, 0.19055825, -0.010680747, 0.31058824, -0.007695386, 0.015143962, -0.19102255, -0.17820585, -0.18766658, -0.009065237, -0.07136684, -0.30069622, -0.054524295, -0.14262456) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.005514332, 0.23068081, -0.039979495, 0.07517179, 0.016069092, 0.1617334, -0.024756398, 0.066903576, -0.13141768, -0.13765904, -0.14210041, 0.082942314, -0.021609468, -0.24250697, 0.012318735, -0.05596935) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.081286155, 0.3106819, 0.012029686, -0.22981367, -0.06561544, -0.2314145, -0.05281443, -0.0898523, 0.38537568, -0.018377632, 0.12044209, 0.0005704543, -0.011991541, 0.20970055, 0.052408684, 0.041143138) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16834563, 0.083631404, 0.16671576, -0.11488073, -0.0079657985, -0.2624022, 0.060084295, -0.048311915, -0.08381493, -0.13004623, -0.063485034, 0.15185682, -0.050756387, 0.1820073, -0.040099278, 0.0147374915) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04840675, -0.10223533, -0.021538958, 0.03620745, -0.008223634, -0.06520915, 0.007304085, -0.07767232, -0.032584604, 0.007856772, -0.2545953, 0.09876874, -0.058055714, 0.1216009, -0.0632479, -0.0267604) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14613065, -0.03211939, -0.6094244, 0.11664133, -0.096512444, -0.45363647, -0.051237855, -0.06773612, -0.38421455, -0.32964778, -0.31626117, 0.35412675, -0.01664387, 0.3692778, -0.0022817745, 0.06987495) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.41744652, 0.0067087286, -0.5109855, -0.18178177, -0.040977832, -0.38214973, 0.08860755, -0.39358762, -0.1967389, 0.06349201, 0.2807914, -0.27913195, -0.023456926, 0.43421695, -0.23108205, 0.14711493) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.023659913, -0.14563018, 0.13433015, 0.047287066, -0.031760287, -0.25105506, -0.019502727, -0.031379674, -0.14104494, 0.25868857, 0.12090388, -0.5051976, -0.074084334, 0.29825616, -0.0667191, 0.087836705) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18758625, 0.2366933, -0.10926221, 0.3202377, -0.1452727, -0.43491867, -0.14005804, -0.051670913, 0.1297575, 0.078856185, 0.47338358, -0.03333641, 0.05856229, 0.16679358, 0.07351302, 0.030556308) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.30787602, 0.29749122, -0.090859585, -0.22660655, -0.18838412, -0.48162657, 0.025262468, -0.1747578, -0.08255984, -0.18929479, -0.17068942, 0.35390145, 0.0759528, 0.31692725, 0.027288994, 0.11616177) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.051510006, 0.15749782, -0.11863509, 0.12776135, -0.06977646, -0.3042916, -0.05603212, -0.05071767, 0.18025267, 0.19090089, -0.25945282, 0.033207502, -0.033932798, 0.25236022, -0.029486205, 0.011253536) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

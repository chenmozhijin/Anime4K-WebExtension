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

  var result: vec4f = vec4f(0.022870539, -0.027368521, 0.116453364, 0.008042633);
      result += mat4x4<f32>(0.09711027, 0.09771424, 0.0026588028, -0.0928328, -0.025359306, -0.10611753, -0.0644156, 0.09308959, 0.09289493, 0.2944309, 0.069872476, -0.18208024, 0.1349046, -0.028394578, -0.09913351, -0.10678176) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06035457, -0.10526333, -0.13533166, -0.04839061, -0.09345189, -0.007710241, 0.09436036, -0.0664121, 0.26768312, 0.048136313, -0.1358323, 0.10645558, 0.13706069, 0.17638117, 0.27715498, -0.19274251) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.043428227, 0.1591421, 0.24060968, -0.1589062, 0.047740165, 0.0069489027, -0.1393347, -0.029534545, 0.03535424, 0.37742272, 0.18429321, 0.2183332, -0.0146568315, -0.020040624, 0.27676517, -0.021990051) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2043608, 0.1407594, 0.3668086, 0.16968356, 0.14399134, 0.36985886, -0.27856398, -0.15812561, -0.13199547, 0.27179894, 0.26207656, -0.028162776, -0.13509092, 0.06532591, 0.22330528, -0.099725336) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.25893962, 0.32440254, 0.35947332, 0.18135113, 0.29377523, -0.16346255, 0.024823293, -0.030476304, 0.21836276, -0.065034814, -0.41347677, 0.35323736, 0.052956533, -0.065691285, 0.027652977, -0.250541) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09135686, -0.028497327, -0.018322293, -0.080983356, 0.20396076, 0.18793099, -0.2581657, -0.21610679, 0.14205475, 0.40080726, 0.08903479, -0.20065407, 0.27215043, -0.29431355, -0.08469264, 0.17592652) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23631367, -0.027159594, -0.20400478, -0.1184257, 0.007730433, 0.12361007, -0.17812325, -0.16191755, -0.09914983, -0.087802045, 0.20381889, -0.0064614746, 0.014399722, 0.061441403, 0.19685772, -0.112285234) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.070998766, 0.2587681, -0.22523412, 0.016973473, -0.2767473, 0.28841504, 0.053054832, 0.0801344, -0.047801178, 0.07897234, 0.13333139, 0.0063882656, -0.28607556, 0.07212014, -0.28860167, 0.26717317) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16559835, 0.19231652, -0.04237085, -0.07920438, 0.11261298, 0.006598354, -0.3046587, -0.0685309, -0.015743025, -0.076394714, 0.403552, -0.021056008, -0.16432813, -0.02385597, 0.5618421, 0.028017279) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.02473952, 0.058014777, 0.017980991, 0.024881175, -0.058630235, 0.020695336, 0.11644419, -0.2874834, -0.105920285, 0.13664521, 0.06527079, 0.1360185, -0.08646071, -0.0058223056, 0.040031884, 0.004682582) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10745449, 0.03920622, -0.1240289, -0.011750536, -0.059030604, 0.17393368, -0.13830945, -0.3437585, 0.15098761, 0.22592983, 0.2071584, -0.00032289137, -0.21958269, 0.059444014, 0.46354538, -0.35875782) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11168636, 0.09774561, 0.1668512, -0.09591001, -0.031544987, -0.012181265, 0.06690571, -0.051410623, 0.048054107, 0.019053446, 0.08673732, -0.030869065, -0.10068204, -0.07298291, 0.028833503, 0.100186415) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.15464583, -0.055725534, 0.037496384, 0.009318905, -0.034792803, 0.13422187, -0.2380808, 0.5996843, -0.1840223, -0.25079092, -0.2990703, -0.3723489, -0.11050927, 0.10814458, -0.055669565, -0.2993848) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30688974, 0.20977265, -0.3706956, -0.32271752, 0.1846654, 0.5467062, 0.08670103, 0.13143961, 0.22359104, -0.003863924, 0.12031, 0.03666606, 0.46882448, 0.049460553, -0.37667513, -0.25630608) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1258554, -0.02802252, -0.24449232, -0.09529329, 0.055462915, 0.11476222, -0.075549655, -0.066522256, -0.02554462, 0.084270485, 0.49997744, 0.36882284, 0.18422922, 0.07787016, -0.7398792, -0.014416233) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.059644014, 0.08290208, -0.15940624, 0.0008200773, 0.071768366, 0.6873203, -0.05164599, 0.14603308, -0.054307785, 0.20607157, 0.059327334, -0.0007853995, -0.12614365, -0.10568478, 0.08532935, 0.17112936) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.25682086, 0.07301933, -0.39655492, -0.27113307, -0.091154575, 0.26078224, 1.0464315, -0.66222554, 0.071830094, 0.21621878, 0.038600177, 0.14337799, -0.28595933, 0.016785368, 0.35981655, -0.25298285) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.14520623, 0.22935541, 0.0997773, -0.117770344, -0.18978256, 0.17313215, 0.13905923, 0.0047784997, -0.0458984, -0.27837744, -0.028232764, 0.050143823, -0.08048121, 0.10753897, 0.15408279, -0.121917024) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

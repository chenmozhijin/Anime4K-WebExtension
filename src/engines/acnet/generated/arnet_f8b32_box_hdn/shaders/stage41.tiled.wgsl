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

  var result: vec4f = vec4f(0.20282511, 0.06971962, 0.31002307, -0.2635931);
      result += mat4x4<f32>(-0.096111305, -0.08608927, 0.055896766, -0.064272195, -0.004841255, 0.28674757, -0.034690917, -0.15712292, 0.10832296, 0.026962496, 0.018445114, 0.08612847, -0.2897909, 0.52763206, 0.017209418, -0.34943563) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.053923436, 0.0019661656, 0.10132375, 0.016888363, 0.015413065, -0.27753192, -0.74610394, -0.36369738, -0.066911355, 0.024563722, 0.21467154, -0.049035132, 0.15868156, -0.07110775, -0.08038244, -0.08221509) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.008067212, 0.024116715, 0.05463126, -0.00039263826, 0.10427661, -0.33395162, -0.10227849, -0.16977455, 0.004079422, 0.08490626, -0.17184138, 0.11948518, 0.24137929, -0.00758857, 0.014154581, -0.12058941) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.26540482, 0.10444194, -0.1248817, -0.034154806, 0.19545697, 0.5143342, 0.46838462, -0.074088305, 0.36662075, -0.11076397, -0.04473626, 0.29890653, -0.3469501, 0.5423737, 0.28656858, -0.13981977) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.456877, 0.048589304, -0.0755949, 0.22137459, -0.15484291, 0.35792503, 0.114870824, -0.4816482, 0.52816236, 0.19718906, 0.2439664, 0.36268833, 0.35156655, -0.14465947, 0.20141955, 0.42957103) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14726469, -0.015469126, 0.06912861, -0.10393592, 0.23091455, -0.31830525, 0.110063255, -0.3590356, 0.18458024, 0.2984829, -0.16797696, 0.016224558, 0.31361434, 0.052265454, -0.15476337, 0.2796254) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04865771, 0.13485472, 0.079159416, -0.06129532, 0.5756587, 0.12137309, -0.096792944, 0.28135666, 0.14770547, 0.056454066, 0.011465539, 0.28006288, 0.13227971, 0.33258003, -0.07402265, 0.094926216) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15903164, 0.313131, -0.07962086, 0.16522641, 0.015548082, 0.06350727, 0.005064492, 0.0024743297, 0.56412524, 0.3049129, 0.18996316, 0.27793398, 0.19377783, -0.15436487, -0.22236602, 0.33900443) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.18875562, 0.020599214, 0.01884183, -0.0020079233, 0.18733764, -0.34944636, -0.22101784, -0.18465589, 0.019832306, 0.14056918, -0.09449001, 0.16706717, 0.15634976, 0.054308943, -0.007491006, 0.048362806) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2774655, -0.027619995, 0.25405088, -0.15142435, 0.075695604, -0.26359007, -0.09045188, -0.12900022, 0.3408722, 0.022699453, -0.08836782, 0.1304043, -0.296756, 0.03572633, 0.037245035, -0.10691115) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.30900988, -0.21174517, 0.27496666, -0.04973739, 0.009628096, -0.22996348, -0.1528142, -0.08726235, 0.30626866, 0.12398082, -0.28809437, 0.12232159, -0.2780749, 0.21532057, 0.14341415, -0.2428249) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.098390214, 0.31656733, -0.08544017, 0.052337453, -0.00069901225, -0.24546015, 0.18837373, -0.31084737, 0.23747213, -0.15000947, -0.033391688, 0.28448, -0.37124458, 0.089332886, -0.06775102, 0.13621214) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.43442547, 0.22610396, -0.3076023, 0.054375544, -0.018191734, -0.23553102, -0.17440374, 0.061217442, 0.042776145, -0.18762717, -0.029145144, -0.008407514, -0.3403319, -0.27843636, 0.013350113, 0.03164665) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12502812, 0.113347895, -0.115372136, 0.26978695, -0.4941999, -0.47521907, -0.43484488, -0.19995908, 0.66831344, -0.22407682, -0.22754686, 0.39912295, -0.24519485, 0.015998017, 0.60780424, -0.19310147) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.27916494, -0.037345354, 0.067644306, 0.18477936, -0.25937077, -0.31511748, -0.0046244822, -0.20105827, 0.057379056, 0.28448835, -0.16760395, -0.27284163, -0.5462905, 0.18017393, 0.03175906, 0.20928238) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.30461344, -0.27330902, 0.25231737, -0.31332093, 0.1372193, -0.087521926, -0.22389828, 0.03964427, 0.15870441, 0.1691818, -0.05068039, 0.16728635, -0.5811612, -0.17041208, 0.22407216, -0.19776088) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.35739943, 0.4698825, -0.15652156, 0.12280739, -0.50647306, -0.8091356, -0.08266415, -0.39089176, 0.038056515, 0.1490395, -0.014339502, 0.16197729, -0.1523614, 0.20091692, 0.41782048, 0.1513566) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.14484762, 0.048843414, 0.03995998, -0.16615105, -0.32098398, -0.33107412, 0.063179955, 0.08490418, -0.1335714, -0.10595159, -0.15726633, 0.088736996, -0.42862242, 0.10364573, 0.024288967, 0.20465527) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

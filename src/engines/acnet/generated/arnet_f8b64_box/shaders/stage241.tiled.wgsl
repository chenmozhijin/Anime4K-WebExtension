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

  var result: vec4f = vec4f(-0.05755845, -0.096325316, -0.120717436, 0.067021966);
      result += mat4x4<f32>(-0.014853533, -0.07847896, -0.033883993, -0.027408564, 0.009116102, 0.031860746, -0.09803908, -0.11336733, 0.052333444, 0.07348907, 0.056214046, 0.035259515, 0.023491515, -0.026559213, -0.009606176, -0.041872203) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1062851, -0.0831752, -0.1083534, -0.14359137, -0.016713291, 0.11158606, -0.027462095, -0.07759567, 0.067356855, -0.016551016, 0.027039915, 0.10748363, -0.055631984, -0.07312002, 0.0015443775, 0.05519337) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.09934371, -0.027886167, -0.04727224, -0.036674526, 0.022927156, -0.039133985, 0.019177353, 0.01879557, 0.3206029, 0.12251973, -0.14675543, 0.09489754, 0.17959715, 0.21067643, -0.08786783, 0.1217617) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0069972067, -0.05113196, -0.015097514, -0.16451526, 0.019525941, 0.06614559, -0.005233782, -0.10769961, -0.10052711, -0.05614186, -0.030938113, 0.10299433, 0.07188167, 0.014195092, 0.039681308, -0.111254625) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0058722994, -0.15022711, 0.14606522, -0.27130362, -0.37836164, -0.29132974, 0.31628656, -0.09561674, 0.11887564, 0.2527042, 0.2446992, 0.13356896, -0.19538586, -0.49863172, -0.13888043, -0.0021984328) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18839704, -0.19671376, 0.21845323, -0.09530952, -0.040048517, 0.037597973, 0.029355252, 0.0066716266, -0.10307074, 0.10156619, 0.10561139, -0.3930747, -0.15432005, 0.24768238, -0.1691516, 0.35569224) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.023336153, 0.17201327, -0.05106555, -0.12823153, 0.00060412317, 0.07337087, -0.00033926097, -0.11600197, 0.030351525, 0.0345524, 0.06512088, -0.013215196, 0.010674696, 0.017500633, 0.032677833, -0.03156338) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0018667271, 0.084643595, -0.14807147, -0.13206288, 0.023351131, -0.21662743, 0.12762286, -0.1680844, -0.010135341, -0.1356246, 0.17464133, 0.17543285, 0.015491794, -0.010209001, -0.015308774, -0.020754918) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0040939157, 0.042905673, 0.012705528, -0.18081586, 0.008407837, 0.049570132, -0.10697263, -0.029784452, 0.07677858, 0.18742138, -0.05248644, 0.042012304, 0.006854122, 0.08467099, -0.068798035, 0.022625562) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.020314943, -0.10013413, -0.004993399, 0.045551185, -0.04172095, 0.078206174, 0.07770824, 0.0028193009, -0.07324518, 0.02204622, -0.018836115, -0.070772, -0.0031169327, -0.0444523, -0.08901686, -0.020743465) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.017553784, 0.02272877, -0.0012308093, 0.043102514, -0.095527604, 0.13912852, -0.054510932, -0.09028882, 0.08779657, -0.03331212, -0.055706043, -0.0035000732, 0.06143382, 0.118420556, 0.06621185, -0.020151462) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.077616036, 0.20003052, 0.06591728, 0.013511894, 0.006616696, 0.034750126, -0.020749291, -0.016132781, -0.017118251, 0.03708518, 0.06916909, 0.020864801, -0.018122438, -0.08392517, -0.032771625, -0.0012196833) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.042551696, -0.023775207, -0.05387826, -0.0697876, -0.16119815, -0.1100423, -0.07164141, 0.08759437, 0.34168255, 0.054751836, 0.39590973, -0.21097565, 0.027587453, -0.050984, -0.05680428, 0.038068395) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.33346716, 0.45428112, 0.46780625, -0.32762343, 0.46679607, 0.71900886, -0.25248623, -0.30611575, -0.2757029, -0.1299559, -0.21762547, -0.20803778, 0.83044237, -0.44081575, 0.103034176, 0.7198532) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.011198614, -0.04186579, -0.016140183, -0.06659101, 0.017897928, 0.22177859, -0.017832609, -0.14703666, -0.10624376, -0.16425362, -0.047301073, 0.31621838, 0.21230608, 0.21204288, -0.0186516, -0.093694404) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.025423424, -0.054570198, 0.037689462, 0.033527113, 0.020176591, 0.23266722, -0.050840113, -0.1196678, 0.077847764, -0.0028350712, 0.025974356, -0.014953103, -0.089844614, -0.10787892, -0.09301682, -0.027673498) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.028501617, -0.011508286, 0.11460098, 0.0016029545, -0.03207215, -0.089094974, 0.084521666, 0.034443308, 0.061936077, 0.029065976, -0.0843125, 0.019274551, 0.07721886, 0.10240799, -0.11796663, -0.068198025) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.014064181, 0.008991926, 0.044556048, 0.031918876, 0.024446579, 0.0059724925, 0.010020258, 0.009983474, -0.015693948, 0.0010522738, 0.040550068, 0.0644261, 0.057787314, -0.045199238, -0.021618055, -0.053215925) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

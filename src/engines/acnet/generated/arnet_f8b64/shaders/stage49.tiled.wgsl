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

  var result: vec4f = vec4f(-0.1114006, -0.04450979, 0.009146207, 0.17830664);
      result += mat4x4<f32>(0.18679179, -0.13648707, 0.068893865, 0.04408178, -0.03451737, -0.20636666, 0.03437203, 0.0060901553, 0.019334521, -0.07785374, -0.15614109, -0.13886428, 0.03447473, 0.021663742, 0.062964596, 0.24252172) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.13180496, -0.022591032, -0.2502913, 0.38156286, -0.04518567, -0.28301892, -0.20963198, -0.23980395, 0.1328151, 0.1278096, -0.44966117, -0.54094905, -0.003725722, 0.25203073, 0.58734536, 0.25116906) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1053656, 0.34481287, 0.24074976, -0.05143106, 0.05721627, -0.17154759, -0.08421455, -0.13286689, 0.08265697, -0.19058725, -0.1248812, -0.16711687, -0.085716724, -0.104624756, 0.20494026, -0.13224307) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.040491015, -0.14538391, 0.13565336, -0.14359245, -0.10554734, -0.5383548, 0.012126807, -0.054740276, 0.15667269, -0.008265208, 0.02833808, 0.029947694, 0.0013273687, 0.08539157, -0.28000203, 0.3438339) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16000473, 0.068077445, -0.062497284, -0.10484655, -0.0050447076, -0.5314475, 0.0894914, -0.17310824, 0.41051978, 0.2891494, -0.22229822, -0.4473995, -0.34998, 0.09013993, -0.2192898, 0.26741022) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04522687, 0.2796977, 0.025136312, 0.28406882, -0.12692036, 0.09538683, -0.082379766, -0.3034892, 0.19204745, 0.39222124, -0.011318357, -0.0015429291, -0.17769854, 0.4304978, 0.094949566, -0.23012376) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11279701, -0.0277148, -0.014661113, 0.19688493, -0.027523793, -0.12636505, -0.034984402, -0.1357166, 0.027882619, 0.19148085, 0.27695206, 0.1251493, 0.087142475, 0.077607416, 0.046327267, 0.10096383) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13575694, 0.22696592, -0.25182462, 0.1163058, 0.066045776, -0.23091443, -0.056963697, 0.085301176, 0.39969924, 0.20810953, -0.1449248, -0.14475214, -0.32496437, -0.5473026, -0.29699528, -0.16505256) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.024884503, 0.36864966, 0.10232374, 0.12648495, -0.032670066, -0.02370397, -0.07537267, 0.0878562, 0.05142429, 0.17520605, 0.00026470877, -0.0223252, -0.1700918, -0.04351757, 0.13389213, -0.04702444) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08984582, -0.059974357, -0.03497901, -0.064541265, -0.002975118, -0.029503139, 0.0033001828, 0.33273578, -0.027854264, -0.0012112964, 0.0069457972, 0.04392059, -0.067035764, 0.022874089, -0.100737736, 0.007609806) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.17506136, -0.07724148, -0.20557015, -0.17610918, -0.118043646, 0.07876886, 0.06586999, 0.3844393, -0.002540853, 0.012178954, 0.081443734, -0.15315384, -0.022467624, -0.10575411, -0.23470987, 0.35365906) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07983719, -0.1822793, 0.23393005, 0.20165887, -0.13810258, 0.103436954, -0.3680573, 0.068220384, -0.013179088, 0.041426796, -0.06369718, -0.09882815, -0.00086586305, -0.0678889, 0.24461162, 0.11839847) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07516495, 0.16079159, 0.083672844, 0.066604756, -0.108064234, -0.5460984, -0.4450973, -0.080729514, 0.13309485, 0.08010318, -0.026466405, 0.21460673, 0.011213903, -0.03616953, 0.2617555, 0.019372199) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21068493, -0.13977015, -0.474938, 0.36490092, 0.15287831, -0.2846696, -0.17280956, -0.16872188, 0.2215839, 0.024009213, 0.21920334, -0.29481602, -0.06391195, -0.13555248, -0.29143915, 0.20365264) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.012491588, -0.038635895, 0.34795123, -0.12216961, 0.050133344, 0.3200628, -0.20932986, 0.0038630336, -0.04593218, 0.07880564, -0.06397502, -0.05828675, -0.12088273, -0.24458344, -0.1595271, -0.029717157) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05486922, 0.13317978, 0.057794232, -0.0108602755, 0.0059267674, 0.16390626, -0.052020304, 0.039103683, -0.019243117, 0.3602225, 0.2728685, 0.10945265, 0.07158584, -0.26470193, 0.10980688, 0.013997047) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19953468, -0.28158203, -0.11857047, 0.053103644, -0.063150436, 0.18688156, -0.13365556, 0.3347031, 0.073217645, 0.50962985, -0.016641218, 0.09736497, -0.17240492, -0.5822015, -0.2274146, 0.14591408) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.03324396, -0.091882095, -0.042284124, -0.038696226, -0.09301419, 0.23707803, 0.08953145, 0.13497439, 0.033294003, 0.19122276, 0.0012487592, 0.24479324, 0.025597421, 0.13852549, 0.0030331463, 0.08727668) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.24771075, -0.119827166, 0.24302575, -0.019745005);
      result += mat4x4<f32>(0.12087939, -0.0024977855, -0.04830896, -0.03840165, 0.11233594, -0.10175407, 0.08996969, 0.43778464, -0.14987312, 0.034355108, 0.03999391, -0.19703287, 0.024946652, 0.16327709, -0.11021585, -0.26734155) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2855648, -0.041156635, -0.12728417, -0.047147144, -0.2551032, -0.003956167, -0.063052826, 0.37545478, -0.043045897, -0.01670837, -0.084713295, -0.09141362, -0.11471155, 0.11945068, -0.10115495, -0.59619623) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06477321, 0.050140686, -0.117179655, -0.10779884, -0.08530554, 0.04710022, 0.12261078, -0.059178326, -0.3798769, -0.22094767, -0.04831203, -0.2463701, 0.08782944, -0.009286431, 0.059009988, -0.025290519) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.024087036, -0.12621209, -0.08055873, -0.14694433, -0.013852159, -0.20405905, -0.0103153065, 0.22467591, 0.31490237, -0.22495717, -0.32975546, 0.21323688, 0.13161756, 0.13756938, 0.31140038, -0.13482998) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0899276, 0.05929317, 0.053085063, -0.28233922, -0.06623915, -0.30930945, -0.5101162, -0.245922, -0.68243253, -0.3680227, 0.24965836, -0.2672581, 0.21198604, 0.4184991, -0.45152304, -0.15577455) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08615015, -0.16175933, -0.25928086, -0.03541395, 0.14010952, -0.020321395, -0.2833271, -0.0028103981, 0.26683423, -0.17560297, -0.16462147, -0.08152052, -0.044293556, 0.09751822, 0.00021258023, 0.0425627) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.28431118, 0.2953187, 0.2049639, -0.107848614, 0.19568828, -0.010296444, 0.024680723, -0.062021624, 0.04053005, -0.2085135, -0.2673339, 0.22313803, 0.11147348, 0.094370835, 0.013037909, -0.12463342) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1952848, 0.02166988, 0.041140553, -0.013043596, 0.2957528, -0.042350207, 0.39886677, -0.3333737, 0.123660155, -0.022744, 0.27703243, -0.26924467, -0.09366322, 0.07939329, 0.0005416399, -0.0048294524) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.3842247, -0.1780451, -0.35133865, -0.06650363, -0.05740309, -0.059587583, -0.00717519, -0.0322589, -0.043887664, -0.0146483425, 0.17679392, -0.15648748, 0.0068712668, -0.026525188, 0.030597253, 0.043600876) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.13406518, -0.09888006, -0.068249874, 0.011122946, -0.1082109, 0.047000315, -0.112964064, 0.09560524, -0.3858581, 0.074030094, -0.009562983, -0.30484253, 0.13199309, 0.03449629, -0.043126754, -0.13467842) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0798653, -0.016364781, 0.040081933, -0.061491657, 0.1422358, -0.0065855565, -0.08497915, 0.13285448, 0.008597892, -0.08232813, 0.08099185, -0.15296079, 0.17836401, -0.18199687, 0.09744808, -0.036833663) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12054005, -0.022282984, -0.11719236, 0.06496231, 0.022903422, 0.12971148, 0.09761305, 0.13231951, 0.091391884, 0.07923184, -0.13423267, -0.033769403, -0.3183929, -0.05552508, 0.034998763, -0.0814922) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.4297323, 0.17909543, 0.064770214, -0.16334064, -0.20278658, 0.17002018, -0.25326908, -0.47228846, 0.2668538, -0.21244848, -0.09831935, 0.19365479, 0.07872544, -0.36950418, -0.014448572, 0.12103734) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0020054467, 0.060268637, 0.2369448, 0.47621453, -0.56812537, 0.2242373, -0.24301466, 0.169216, 0.45584446, -0.04753533, 0.31612393, -0.2690751, 0.13244128, 0.16412018, -0.30482712, -0.7018009) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14481714, 0.021857733, -0.03871906, -0.14462589, -0.31193915, 0.073799856, -0.13382922, 0.16045472, -0.24932107, -0.10644374, -0.018267984, -0.3386779, 0.05548287, -0.043250464, 0.10013993, 0.278787) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.024939725, 0.007036099, -0.02782871, 0.042711016, 0.17678529, -0.039257117, 0.21023622, -0.121334516, -0.16459405, -0.14623459, -0.37026513, -0.028550116, 0.06429128, 0.023356296, 0.26100296, 0.08916685) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13580693, -0.0916411, 0.2207795, 0.14753035, -0.035065427, 0.10583085, 0.05186866, -0.09276377, 0.021992642, 0.13224901, 0.6210782, -0.35449633, -0.15582196, 0.08787145, -0.19674537, 0.022711867) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.038877256, -0.007618991, 0.04683788, -0.121412925, -0.18088211, 0.15728208, 0.24637775, 0.09425208, 0.15198211, 0.029731357, 0.08455516, -0.16601233, -0.023367519, 0.0183448, 0.03838531, -0.023552055) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

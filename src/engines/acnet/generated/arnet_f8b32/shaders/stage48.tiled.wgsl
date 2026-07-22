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

  var result: vec4f = vec4f(-0.11499289, -0.07625538, 0.10790934, -0.084274);
      result += mat4x4<f32>(-0.15062633, -0.009215308, 0.042425252, -0.0029901194, -0.018648412, -0.27943456, -0.15371764, -0.027893972, 0.13576405, 0.26491335, -0.0075912206, -0.3145436, -0.1754547, 0.14193226, 0.014558842, 0.39196643) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0394285, -0.2525747, -0.028414117, 0.0133402, -0.104896985, -0.33036783, -0.007564369, 0.3565567, 0.034334686, 0.16993457, -0.05184618, -0.021205813, 0.08542466, -0.09458873, -0.2929912, -0.40152553) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.057281025, 0.07374414, 0.029141894, 0.09576249, -0.13956286, 0.12955247, -0.038136084, 0.044113033, 0.025486937, -0.24879421, -0.2721509, -0.09199991, 0.31773156, -0.09329381, -0.0498236, -0.031796496) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.075308904, -0.108702175, 0.15054065, 0.029470202, -0.032918416, -0.32484272, 0.25077656, 0.15204881, -0.04335305, 0.35620758, 0.024523254, 0.33672413, 0.052098107, 0.17296438, 0.06112643, 0.22615002) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.110420056, 0.10631709, -0.17315112, 0.32555348, 0.09849104, -0.58315635, 0.25088847, 0.21011475, 0.058943823, -0.09320525, 0.38065958, 0.18728854, -0.026168194, -0.028863735, -0.12491461, -0.48822993) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.104304165, 0.4694116, 0.22133465, 0.121921375, 0.036193382, 0.13744338, 0.04921593, -0.2808589, 0.21167722, -0.31253278, -0.25806037, -0.13436718, -0.17149293, -0.17303109, 0.49763638, -0.39572367) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.12160453, 0.08987397, 0.13667229, -0.117570885, 0.04219665, 0.1621183, 0.09272898, -0.15731736, -0.039951667, -0.02693396, 0.09945434, -0.005089153, -0.32863963, -0.11122885, -0.15153429, 0.49618876) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15592316, 0.24033532, -0.17381394, -0.24702315, 0.28761265, -0.2097349, 0.13439162, -0.19554262, -0.07333326, -0.31957954, 0.30918652, -0.078637734, -0.12952587, -0.054740097, -0.35939106, 0.18661925) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.107823394, -0.11715618, -0.017351018, -0.012217923, -0.074058115, -0.032584507, -0.29410693, 0.11872886, 0.080333345, -0.09168701, 0.055749018, 0.05196527, 0.009593819, 0.108905114, -0.3790942, 0.123906136) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06286094, 0.335096, 0.01534512, -0.14346758, 0.2143786, 0.113930844, 0.013119486, -0.20163547, 0.014209094, -0.105143525, 0.15514967, 0.1617887, 0.004787137, -0.07238849, 0.07879479, -0.18763827) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.190025, -0.28353444, 0.014376407, -0.11115568, 0.18846409, -0.10219536, -0.19016467, -0.3347037, -0.32110205, -0.22610514, 0.06974177, 0.07775118, 0.05335741, 0.21962851, -0.08706046, -0.36599576) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.19316913, -0.14695056, -0.3014094, 0.20805588, 0.37058482, 0.19568431, 0.13953304, -0.62666494, -0.044564303, -0.32383126, 0.05276729, 0.008785128, -0.00790118, 0.20278034, 0.071753204, -0.16486481) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0052108965, 0.542535, 0.2615447, -0.32032248, 0.06514884, -0.014948763, -0.2815002, -0.08240674, 0.13387112, 0.030243471, -0.10835051, 0.3792579, -0.039588902, -0.17397282, 0.24155721, -0.11486791) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07363687, -0.123386644, 0.3737142, 0.71108997, -0.20903094, -0.32519153, 0.0048743407, 0.2589881, 0.29406428, -0.15359277, -0.435704, 0.35569102, -0.040796302, 0.23765184, -0.0038927745, -0.28955212) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.30559197, -0.5078088, -0.39842063, 0.13259238, -0.15703772, -0.08946641, 0.3021837, 0.3450819, -0.11221339, 0.26596653, 0.16766803, 0.03318263, -0.08947472, 0.11589741, 0.19343159, -0.070197314) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.061999008, 0.16232777, 0.11086656, -0.23881085, -0.07595081, -0.069489986, 0.14940915, 0.097764894, -0.2191019, -0.17033783, -0.050630137, 0.1819116, -0.009585188, 0.032488275, 0.025861088, -0.036533445) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.05437264, -0.15483974, 0.12377513, -0.33654687, 0.091667406, -0.27614102, 0.16307926, 0.1014323, -0.33575445, -0.103631616, -0.04276553, 0.24731977, 0.05415677, 0.12728678, -0.12886064, 0.1344627) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19162476, 0.17765938, 0.08364426, -0.06984214, -0.2907152, -0.12793998, -0.08840011, 0.4451741, -0.16012295, -0.13182594, -0.08839299, 0.034644943, -0.06504568, 0.035843138, -0.05781594, 0.19339968) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

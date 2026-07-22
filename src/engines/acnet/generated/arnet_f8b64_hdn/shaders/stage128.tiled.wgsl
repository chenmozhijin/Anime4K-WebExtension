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

  var result: vec4f = vec4f(-0.05111648, 0.12089055, -0.035039935, -0.36704585);
      result += mat4x4<f32>(0.116045795, 0.06438652, 0.30521572, -0.042759698, 0.05313722, -0.072725736, -0.16767965, -0.22187361, -0.07022015, 0.038724944, -0.25239354, -0.07719301, -0.18972744, 0.04129959, -0.21410626, -0.088076055) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.13024893, -0.22656895, 0.028632399, 0.0787621, 0.623466, -0.41848704, -0.38771734, 0.4320952, 0.4091355, -0.0069814143, 0.059999317, 0.057651825, -0.8788219, -0.17936146, -0.42904237, -0.60040706) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.21508312, 0.040563013, 0.14571144, -0.037810687, 0.015518047, 0.14481886, -0.06254108, -0.017294595, -0.008085038, -0.075337194, -0.15646377, 0.12727937, -0.010666554, -0.042764664, -0.039109122, 0.19458884) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.01698473, 0.06565537, 0.034218635, -0.16582367, -0.1785009, 0.016258396, -0.16479972, -0.27627435, 0.08750687, -0.19631517, 0.12026153, 0.14740382, 0.08628668, 0.16721019, 0.16107564, -0.29583687) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.30356893, 0.3628994, 0.15842307, -0.35610473, 0.011833751, -0.24191812, 0.068614826, 0.13355702, -0.17860676, -0.27364963, 0.47658724, -0.33745083, 0.68201333, 0.35992056, -0.29873943, -0.03252771) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.17318456, 0.019693442, -0.061400753, 0.024265015, -0.19708066, -0.42073756, -0.42232546, 0.20929472, -0.12501475, -0.44226128, -0.85497266, -0.14752966, -0.24865791, -0.08309987, 0.4222957, 0.33200485) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0037497573, -0.05770216, -0.11498898, 0.14139327, 0.097606085, 0.07050378, 0.008253326, -0.14599526, 0.11160114, 0.05033191, -0.112201154, 0.025598746, -0.1702248, -0.07293195, -0.009511425, 0.1345602) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.37481862, -0.31930923, 0.21911211, 0.93174046, 0.0321709, 0.013815463, -0.12418415, 0.04587191, 0.056737915, -0.11659369, -0.31357506, -0.088180564, -0.0050821663, -0.049751744, -0.16399707, 0.045458306) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10692877, 0.05699836, 0.029615551, 0.110911965, 0.117586054, -0.105567165, -0.10318078, 0.11086081, -0.2039002, 0.10353439, 0.09654051, 0.11786472, 0.059077553, -0.14357173, -0.31853083, -0.2844927) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.19879512, -0.115750626, -0.0010803741, 0.36143866, -0.08036619, 0.024858445, -0.010809684, -0.027189812, 0.025228288, -0.10843067, -0.19236122, -0.020778509, 0.057971228, -0.0021821796, -0.066142865, -0.1439481) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.42300072, 0.24615343, 0.33978042, -0.36922237, 0.17736177, 0.2353635, -0.21465398, 0.024428936, 0.04273982, -0.17128299, 0.18119301, -0.02602255, 0.3477032, -0.38477695, 0.11807882, 0.10610574) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0150020765, 0.028745698, 0.38408437, 0.16369095, 0.06216163, -0.014492227, -0.19122149, -0.21222673, -0.029066859, 0.05063429, 0.09587721, -0.13613999, -0.16421396, -0.106166, -0.08692827, -0.012457778) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3623792, 0.14758529, 0.15734732, 0.23752831, -0.007744233, -0.012692296, -0.12107323, -0.056056157, 0.19354975, 0.23509128, -0.16295858, -0.23751394, 0.022086779, -0.13971792, -0.039587222, 0.092491984) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.012606717, -0.10259915, -0.27465263, -0.36660376, -0.43842494, -0.27309185, 0.06942187, -0.22887549, 0.11509829, 0.14827989, 0.10830441, 0.34760946, -0.17816533, 0.25027177, 0.0715035, -0.5449182) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2360143, 0.033088062, 0.20832846, 0.1941591, -0.056291528, 0.030764634, 0.047234923, -0.3198755, -0.140381, 0.24508323, 0.028984215, 0.13713035, -0.084664464, -0.09386949, -0.14253828, 0.052317034) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08068502, -0.069179274, -0.06409998, -0.04348866, -0.09035297, -0.2156267, 0.14327382, 0.09595136, 0.029672008, 0.038184945, -0.11202857, 0.15959649, 0.121357776, -0.012750365, 0.10265504, 0.01680501) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1207251, -0.13048851, 0.3772255, 0.1271263, -0.24523546, 0.04286734, 0.48189628, 0.015452423, -0.24079148, 0.1919593, 0.01719465, -0.42782336, -0.019519784, 0.13368616, 0.030005354, -0.089282475) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.024020147, 0.13508044, 0.6066859, 0.2390645, -0.030697588, -0.10994617, -0.27936321, 0.06312576, -0.1309095, -0.023125965, -0.39880696, 0.022216586, -0.024676863, 0.09586414, 0.099253744, 0.024733702) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

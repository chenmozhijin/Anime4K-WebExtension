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

  var result: vec4f = vec4f(0.41225088, 0.032594446, 0.2242556, 0.15569946);
      result += mat4x4<f32>(-0.14894712, 0.20092002, -0.066709794, -0.028771896, -0.16054423, 0.031444646, 0.0041799904, -0.09903392, 0.14499559, -0.103258595, -0.03096349, 0.032752447, -0.13857648, 0.13684343, -0.009012359, 0.06905008) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.05175043, 0.18973331, -0.2959102, -0.35577774, -0.15946183, -0.00062749477, -0.056706764, 0.034349922, -0.46649584, -0.089690045, -0.008598432, -0.5016554, -0.004521325, 0.084701926, 0.15984051, 0.2254823) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08167547, 0.053394254, -0.07253019, 0.085293576, 0.004407844, 0.12166339, -0.08978114, -0.0916351, -0.10893268, -0.2796648, -0.3372918, -0.2282468, 0.40918154, -0.008688151, 0.117541514, -0.116918154) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08926434, -0.15648384, -0.24121428, -0.07704833, -0.07527011, -0.044989165, -0.09684492, 0.31530008, 0.025445223, 0.20118341, 0.038642872, -0.23156276, -0.1167624, 0.10165924, 0.17822969, 0.0938163) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24385825, 0.21539885, -0.613562, -0.2744781, 0.008654816, -0.64058906, -0.27566102, 0.16048916, -0.10218423, 0.20601735, -0.49893692, -0.16738692, -0.30649367, 0.18831585, 0.34774637, 0.007874423) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.33177108, -0.17420582, -0.57317066, -0.33546853, 0.14796215, 0.11269629, -0.06285798, -0.047123026, -0.035154235, 0.03006041, 0.26170006, 0.22767565, 0.17747311, -0.052833233, -0.42948243, -0.2779825) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.061820947, 0.06740746, -0.091009334, 0.014229315, -0.2650237, -0.11699679, -0.19183354, 0.3420841, -0.016729968, -0.09515873, 0.10744431, 0.080951706, 0.24180155, 0.0026116665, 0.047344077, 0.0150093315) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10698437, 0.117372535, 0.023098314, -0.100376256, -0.31436962, 0.018552393, -0.25214288, -0.08547793, -0.06116552, -0.14052649, 0.011903784, -0.026906136, 0.2949988, 0.08773789, 0.26159498, 0.072503135) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.46563146, 0.15686531, 0.12603134, 0.0755298, -0.16562195, -0.16878779, -0.37684983, 0.01092347, 0.083415516, -0.12725076, 0.12066648, -0.0285168, 0.029607764, -0.020214139, -0.14315432, 0.057231665) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1461147, 0.1322892, -0.066466756, -0.09797012, -0.099804826, -0.05358228, -0.19240125, 0.49468943, 0.0013644943, -0.10010481, -0.10901038, 0.032607686, -0.19722009, 0.0075182556, -0.003016665, 0.0056122425) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.32963273, 0.09654204, -0.09566962, 0.12187481, 0.14338198, -0.019056814, -0.00858083, 0.27210295, -0.105516374, 0.14795284, 0.2268732, -0.30052057, 0.17475572, 0.16011071, -0.17300531, 0.1760526) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.057609536, 0.04238451, 0.031109333, 0.20844308, 0.19492434, 0.01569174, -0.009285441, -0.07808248, -0.21203117, -0.03244762, -0.0435976, -0.07397843, 0.1249404, 0.10235126, 0.13421446, 0.2370379) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13973138, 0.12178107, -0.050129455, -0.31289476, 0.1336246, 0.038844567, 0.12462241, -0.4550074, 0.24980263, -0.10780347, 0.09526184, 0.3443949, -0.21240745, -0.23255475, -0.03426838, 0.11528325) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.29238147, 0.2238068, -0.1228584, 0.47855753, 0.56727105, 0.069592856, 0.19163483, 0.37086117, -0.17953461, 0.12717676, 0.16341057, 0.29242745, 0.087819666, -0.09638007, 0.21986847, 0.40433148) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.039752048, -0.033292916, -0.17473823, 0.3392858, -0.20514601, 0.09043817, 0.22787574, 0.16931471, 0.21387695, 0.012570457, 0.22247496, -0.13194655, -0.35150358, -0.17189376, -0.3060862, -0.13053757) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12559646, 0.1395007, 0.2110464, -0.08397897, -0.0010757317, 0.12064327, -0.10043232, -0.26653448, 0.32757524, 0.10527102, 0.38029394, -0.25936016, -0.22637512, -0.049928218, -0.1794973, -0.10443098) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12818238, 0.10511181, -0.08160694, -0.15841624, 0.26678157, -0.18766049, -0.2641018, -0.021444412, -0.061098557, -0.12247055, -0.31614727, 0.17887723, 0.14750913, -0.13654855, 0.27789593, -0.2788146) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06761444, 0.11815533, -0.097846724, 0.07346739, 0.22062291, 0.033287052, 0.006769746, -0.16528693, 0.10510369, -0.06680427, -0.10454088, -0.16623022, 0.4403755, -0.011577655, -0.09270957, -0.07043441) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

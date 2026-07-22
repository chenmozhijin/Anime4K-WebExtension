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

  var result: vec4f = vec4f(0.12844518, -0.0640305, 0.37988317, -0.398585);
      result += mat4x4<f32>(0.09699177, -0.0894473, 0.07377836, -0.0428731, -0.36427605, -0.18037993, -0.058225144, 0.4796215, 0.15697834, 0.35765928, 0.08300593, -0.13803983, 0.119996555, 0.1294632, 0.055691015, -0.2023431) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.078257695, 0.10708604, 0.13461477, 0.36194947, -0.23147221, 0.018653952, 0.12272876, 0.055132087, 0.09973576, 0.048449222, -0.06827783, -0.07572886, 0.07530054, 0.09688712, -0.13850842, -0.20140429) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030034518, -0.029635532, 0.024682365, -0.035432193, -0.18100916, -0.28013337, -0.0430458, -0.0001602505, 0.08601434, -0.028663026, -0.045449782, 0.11805106, -0.04483429, -0.0292814, -0.12167791, -0.20831203) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.060725916, 0.08194092, -0.013889169, -0.04166212, -0.052352138, -0.010311001, -0.21155053, 0.38278505, 0.21258293, 0.29849222, -0.045003124, 0.104121335, 0.10419469, 0.084273726, 0.13740425, -0.018441118) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.43454576, -0.13334331, -0.2310879, 0.7173239, 0.059680276, 0.036797255, 0.29716498, 0.059517127, -0.16725671, 0.8578433, -0.57294965, -0.013736098, -0.10445521, 0.6293399, -0.0273073, -0.024651881) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.058318228, -0.03722048, -0.09229404, 0.27554375, -0.343972, 0.28319988, -0.19836284, 0.12781559, -0.09491684, 0.09713334, 0.19107307, -0.13612472, 0.17500775, 0.38805562, 0.53501445, -0.48271486) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.05137363, 0.024101218, -0.08744867, 0.18445405, 0.020458061, 0.1539408, -0.18168747, 0.012338509, 0.0867698, 0.05310955, -0.08135476, -0.026190989, 0.07027069, -0.0025621175, -0.06259364, -0.13921739) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.038509127, -0.15966772, 0.1992184, 0.10332426, 0.08529774, 0.03618982, -0.40543053, 0.06007397, 0.03577121, 0.1963988, -0.1298781, 0.09607781, 0.07524275, 0.228591, -0.62595975, -0.12484252) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0826454, -0.01971421, 0.12594935, 0.032354202, -0.16702966, -0.034281142, -0.18094215, 0.29627374, 0.046058495, 0.31881824, 0.167357, -0.06299442, 0.093117215, 3.394281e-05, -0.04932534, -0.23179) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08930505, 0.12513657, -0.024664387, 0.11840523, 0.060247403, 0.36074948, 0.08021551, 0.5161469, -0.079390824, 0.21697262, -0.05329225, -0.25642177, 0.22130148, -0.08035286, 0.14173765, -0.073037274) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.19541273, 0.015108714, 0.073483065, 0.13658942, -0.036414064, -0.20733951, -0.17683972, -0.45072472, 0.11588743, 0.2897314, -0.29164532, -0.5568595, 0.06467039, -0.074200004, 0.045542058, 0.115387425) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15443595, -0.029894507, -0.10705174, 0.22374262, -0.13018864, 0.06313345, 0.19080682, 0.07174269, 0.19487447, -0.19389598, -1.0166321, -0.55842817, 0.0014114963, 0.076371394, 0.03150066, -0.049015936) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.09046794, -0.2656377, 0.116311714, -0.16275746, -0.049328, -0.703252, -0.19789582, 0.58609295, 0.055598103, 0.028506314, -0.37036565, -0.0665957, 0.23637708, 0.05218256, -0.094782926, -0.3478733) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28987962, 0.16412497, -0.10150087, -0.2924392, -0.014433645, 0.39550996, -0.4316436, 0.25749266, 0.0013098666, -0.081343934, 0.06962188, -0.07293019, -0.29774547, 0.23789932, -0.26053253, 0.0626629) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.070481256, -0.017486023, 0.2033087, -0.16104782, -0.07808066, -0.069697395, 0.11593504, 0.03964229, 0.00067541737, 0.16002044, -0.13620615, -0.19998455, -0.06688068, 0.13541128, 0.15299512, -0.051655617) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16743827, -0.23061332, -0.16794054, 0.052159473, -0.15250653, -0.8521144, -0.031991266, -0.22295874, 0.061241932, 0.0039873044, 0.028901104, -0.07117636, 0.06560571, 0.24018702, -0.06529635, -0.3091323) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.011091379, 0.32189187, -0.33095282, -0.2835858, -0.1239651, -0.1855696, 0.18518858, 0.48169222, 0.18538962, -0.026203375, -0.339743, -0.08933915, 0.22856274, 0.3136524, -0.6212958, 0.10886391) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.041628916, -0.033961657, 0.03186044, -0.12651075, -0.06677868, 0.017227452, 0.18432927, -0.13967323, 0.15034379, 0.016197376, -0.16255347, -0.16776188, -0.025011329, -0.07486919, -0.09565509, 0.09179036) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

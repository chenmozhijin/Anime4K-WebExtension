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

  var result: vec4f = vec4f(-0.047919974, 0.038124185, 0.29389942, -0.12255351);
      result += mat4x4<f32>(-0.09502001, 0.04431509, 0.08201456, 0.0045464337, 0.021997157, 0.02806639, -0.023835111, 0.0017808997, -0.12928158, -0.012060307, 0.059115704, -0.03894331, 0.0630357, 0.02134328, -0.03899766, 0.021604668) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.05256878, 0.03634317, 0.08117519, -0.08229873, -0.06499581, 0.14107522, 0.054656435, -0.053185716, 0.023536388, 0.026689462, 0.07092834, 0.049102716, -0.16746333, 0.13017741, -0.0050564245, 0.1425376) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04952302, 0.039606962, -0.037276313, -0.031462517, 0.0007729095, 0.14312378, 0.107382365, 0.0053782193, -0.026050113, -0.11085284, -0.023746733, 0.06516564, 0.17505476, 0.22691797, -0.06198871, 0.041229468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06849576, 0.10421549, -0.01647675, 0.022055913, 0.16342238, -0.018823478, -0.17558154, 0.28723264, -0.06677287, 0.04116938, -0.051563486, 0.13447829, -0.030679524, 0.0120001435, 0.04753399, 0.07803759) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12439299, -0.47386274, -0.037404515, 0.06517761, -0.011025078, 0.07626451, 0.5374226, 0.043872382, -0.049040146, -0.29459193, -0.038912337, -0.19819081, 0.46209672, 0.110533394, 0.18798395, 0.1972027) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07590121, 0.023476759, -0.036308143, -0.25469023, -0.10165769, 0.11088317, 0.08222088, -0.28791198, -0.09290522, 0.053789545, -0.07184051, 0.28357697, -0.043528654, -0.07035706, -0.23737763, 0.2546) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.021713892, 0.014121083, -0.015401812, 0.0959781, -0.15599146, -0.075564116, -0.08262126, 0.18289243, -0.03441278, 0.11096738, 0.106408246, 0.012544945, -0.07339284, 0.015553849, 0.06130155, -0.05808706) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.03929119, -0.018146064, -5.5393404e-05, 0.04631793, -0.19540672, 0.027324691, -0.026851626, -0.17754073, 0.14321229, -0.19691972, 0.097614534, 0.03300709, 0.10383766, -0.082422614, 0.02068486, -0.052048735) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.018395945, 0.050075307, -0.013626457, -0.048367485, -0.07005193, 0.2274701, 0.007402428, -0.19685692, -0.057965185, -0.03389444, -0.13074338, 0.15154114, 0.060803805, 0.068138644, -0.07596205, -0.07238469) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05095726, 0.0327573, 0.026680864, -0.0023387969, 0.14335568, -0.0111819925, -0.14974158, -0.052550096, -0.0056163333, -0.032565475, 0.026129434, 0.17633569, 0.045009717, 0.0046854466, 0.02181309, 0.08667118) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.83659434, 0.4389326, -0.43593448, 0.28832123, 0.07833325, -0.016010845, 0.05538577, -0.023278257, 0.48772225, -0.16612414, 0.18571553, 0.4313251, 0.030030664, 0.03330545, -0.16214569, -0.10464915) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08494013, 0.20667857, -0.1325544, 0.051985104, -0.11606909, 0.023565944, -0.032374028, -0.014340065, -0.004491315, -0.15073822, -0.10217519, 0.20155202, -0.120406926, -0.7413961, -0.75851387, -0.1773176) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06266646, 0.056152888, 0.00667575, -0.02743077, 0.17666663, 0.027091987, -0.08501408, -0.17039482, 0.11987404, -0.14647253, 0.20938951, 0.2940056, 0.022925396, 0.00891476, 0.050784614, 0.013282368) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.42885822, 0.47950587, 0.52095735, 0.27760968, 0.3017605, -0.27466273, -0.11747688, 0.2368949, -0.32293352, -0.3572676, -0.53620666, -0.31065091, -0.12573692, 0.1388258, -0.06092434, -0.27263948) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.18639725, -0.0029379749, -0.029417876, 0.18037823, -0.046054, -0.06998471, -0.2297943, -0.015501605, -0.05184347, -0.039744813, -0.054821208, -0.03041559, 0.11683349, 0.12971215, -0.07679727, -0.4190048) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.096087925, 0.09887984, -0.0061997757, -0.029112007, -0.022866942, 0.061509416, -0.014574843, -0.13403963, 0.086341865, -0.07701076, 0.05844683, 0.037657473, 0.029366776, -0.0004866434, -0.022429625, 0.0037281858) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.043389164, -0.08454282, 0.012884739, 0.012040209, 0.009033396, -0.09085847, -0.113605246, 0.0012430495, -0.26050898, 0.013923257, -0.105171606, -0.040775698, 0.033952072, 0.03810667, 0.030612454, 0.043946624) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.007559137, 0.06356624, 0.0030461226, -0.008297914, -0.024091734, 0.062586844, -0.093363486, 0.0022381633, 0.047126133, 0.029928004, 0.021783113, -0.11596573, 0.0026879192, 0.089214884, 0.0782294, 0.13355514) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

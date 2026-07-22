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

  var result: vec4f = vec4f(0.26611236, 0.13784337, 0.020248141, 0.21675684);
      result += mat4x4<f32>(0.04853816, -0.04019345, -0.16733721, -0.0617043, -0.25632513, 0.058597047, 0.09121904, 0.10788822, 0.008668639, -0.2519273, -0.044232234, -0.053641815, 0.14736606, -0.07794327, -0.081503496, -0.03461842) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3345821, -0.028183158, -0.09608892, -0.019513482, 0.0106078945, 0.04533477, 0.45646486, 0.25715175, 0.06233001, -0.39472276, -0.011834016, -0.07099982, -0.1015464, 0.07371813, -0.087776706, -0.2333666) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.00083404355, 0.20414959, 0.04718587, 0.096286334, -0.08204367, 0.006170749, 0.123172686, 0.0018676647, 0.050131753, -0.18434212, -0.02989444, -0.08053018, 0.0086973775, 0.20376317, -0.028162546, -0.029548349) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.37907487, 0.15201548, -0.016397042, -0.25557533, -0.1576169, -0.08677705, 0.14254417, -0.051342808, 0.07793996, -0.159813, -0.05466231, -0.021274518, 0.07298789, -0.0052487743, -0.054372035, -0.09157391) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.40479782, 0.024036776, 0.14786409, -0.122492045, -0.40427792, 0.259185, -0.27144554, -0.33805215, -0.46947622, -0.35427624, 0.30929032, -0.13517435, -0.4531901, 0.3902404, 0.2169042, -0.3395822) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07276699, 0.13401634, -0.09809, 0.10391651, -0.35420042, 0.4032262, 0.17599119, -0.05830105, 0.14873283, -0.31538782, 0.027202966, -0.10970906, -0.054166306, 0.35414547, -0.12535277, 0.33026463) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.107224636, 0.22981106, -0.072508685, 0.14700116, -0.13958946, 0.16248527, 0.060984742, -0.0020104286, 0.22494689, -0.044184353, -0.06293224, 0.031611435, -0.009397722, -0.10723959, -0.06594364, -0.06746206) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.16301511, -0.082526766, -0.025680587, 0.048835836, 0.14194559, 0.17451698, 0.047459748, -0.08545984, -0.43604577, -0.13322672, -0.03470482, 0.076165594, -0.021527288, 0.0802578, -0.16862382, 0.19001442) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.054567758, 0.1454216, 0.022713805, 0.0260984, -0.13275854, -0.16285342, 0.059767056, -0.17651376, -0.11208918, -0.06644435, -0.11280069, 0.02847719, 0.056913085, 0.07042886, -0.0129651055, 0.05778488) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08054181, 0.0062434305, -0.037735414, -0.05542706, -0.2221583, -0.07730475, -0.29013592, -0.011333002, -0.072749905, 0.13685872, 0.10980391, 0.044343334, -0.0013247011, -0.16488586, 0.08735379, -0.29123232) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.39183304, -0.0011423414, 0.058507547, -0.003850304, 0.3167593, 0.053032454, 0.07967774, -0.035438996, -0.54049075, -0.49710754, -0.055707842, 0.6042261, 0.05532009, 0.07575107, -0.102678165, -0.01310974) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2219139, -0.3786, -0.016645381, -0.1088632, -0.0010975505, 0.027483692, -0.0281296, 0.051841833, 0.16949885, -0.019723313, 0.09198897, -0.46239144, -0.088172615, 0.06237076, 0.02146369, -0.03386589) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0743087, 0.19046652, 0.04373206, -0.019913575, 0.08700651, 0.028536458, -0.11982436, 0.3540115, 0.015430616, 0.07706788, -0.13685463, -0.32540864, 0.19455451, 0.26553413, 0.13745473, -0.6885352) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.034931935, -0.22616358, 0.29015246, -0.23409586, 0.32568535, -0.05925556, 0.032521453, -0.6102614, -0.40907457, -0.23177755, 0.091856286, -0.37250397, -0.6742212, 0.35114267, -0.04386116, -0.7939713) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04463574, 0.12517413, 0.028814219, 0.18990244, -0.20110694, 0.18959424, -0.055751007, 0.38394758, 0.057198912, 0.10251774, 0.009128555, 0.018955097, -0.10964258, -0.07434919, 0.17148478, -0.12821797) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12443907, 0.2528939, -0.091215536, -0.017002705, -0.17269352, 0.24510792, 0.08328254, 0.19505684, -0.0035272986, 0.03854691, -0.10273332, 0.14356878, -0.1082987, 0.22056581, -0.095919885, -0.09299876) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09538037, 0.25400096, -0.07003575, 0.16333142, -0.1967334, -0.029199978, -0.018252878, -0.2667728, 0.17498374, -0.18481098, -0.19523898, -0.14328818, 0.15104577, 0.06437886, -0.1034428, -0.24811727) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07758956, 0.013043982, -0.019853944, 0.13633491, -0.099577986, 0.35158023, 0.025544576, 0.08707601, 0.1667551, -0.0049674986, -0.06631641, 0.08989947, 0.08191266, -0.16492845, -0.09320026, 0.12233356) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

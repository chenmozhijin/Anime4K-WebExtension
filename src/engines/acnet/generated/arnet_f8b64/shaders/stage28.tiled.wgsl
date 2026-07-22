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

  var result: vec4f = vec4f(0.07400881, 0.04495264, 0.2008792, 0.07056564);
      result += mat4x4<f32>(0.12081527, -0.0049457294, 0.07304442, -0.071149126, -0.122042954, 0.09009051, 0.030405749, 0.09129107, 0.113443725, -0.08261168, 0.14526704, 0.07347147, -0.26371047, 0.027981512, -0.060080435, -0.12399001) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.33609667, -0.0653926, -0.19382095, 0.38856778, 0.07232907, -0.30154136, 0.1193784, 0.35328376, 0.04824196, 0.24338372, -0.09774164, -0.4747413, -0.15578157, 0.19461161, -0.06872234, -0.17052092) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2674535, -0.074518636, 0.015106096, -0.042313747, -0.32153475, -0.19962296, -0.29328775, -0.1767915, -0.03599307, 0.08407099, -0.060431227, -0.03535648, -0.030798161, 0.084264934, 0.19078028, 0.25879663) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06391384, 0.2646658, 0.16655646, -0.15491557, -0.10628905, 0.13694945, -0.038026854, -0.18563837, -0.05440159, -0.15751395, -0.12815794, -0.49094966, 0.15532112, -0.59926075, -0.2220835, 0.35962266) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3207725, 0.098193824, -0.12782045, -0.21768318, -0.32116142, -0.27855843, -0.09801081, 0.24767476, 0.78618413, -0.0145982215, -0.19234851, 0.021507759, -0.36416653, -0.2173744, -0.06854928, -0.5034455) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06545166, 0.05211193, -0.0035486994, 0.19717081, 0.15902801, -0.35779327, -0.35380262, -0.05853728, 0.017436113, 0.0862836, -0.28863743, -0.19716823, -0.09892936, -0.0414753, -0.14909, -0.009435247) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.23319086, 0.107950404, -0.20636095, 0.11971664, -0.067020126, 0.0422246, 0.0061698547, 0.0161959, -0.43001512, -0.09058272, -0.109054685, 0.09493333, -0.2495434, 0.01612139, -0.13561943, -0.14932622) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.43052816, 0.02555959, -0.1421921, 0.15542927, 0.06766705, 0.1474562, 0.029568635, 0.023488604, 0.31874254, -0.09387996, -0.3447972, -0.15747137, -0.55155194, 0.12563522, 0.10212714, -0.18707918) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.028135072, -0.0057702335, -0.2709729, 0.21325332, -0.2613321, 0.07386787, -0.16177306, 0.14899458, -0.0037988503, 0.0051725013, -0.048981983, -0.029423317, 0.29363567, -0.18800701, -0.29738057, -0.0023465783) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07217364, -0.15971369, 0.07006183, -0.14737761, 0.039641127, -0.0682625, 0.0028182121, -0.09121838, -0.06722289, 0.12689662, -0.053977113, -0.16810146, -0.1391234, 0.241839, 0.07650848, -0.2985451) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19519489, 0.09794502, -0.22635634, -0.34132612, -0.030756408, -0.18966381, -0.22928391, 0.29584348, -0.21456502, 0.05447964, -0.10677582, -0.04568219, -0.10367669, 0.10326677, -0.23950256, -0.46769634) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1535195, 0.13011797, -0.12570646, -0.14177929, -0.14105965, 0.021886341, 0.039055694, -0.061117735, -0.2897627, -0.012671156, 0.002109174, -0.05954409, -0.12981972, 0.007744197, 0.006411335, -0.053607184) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.31226155, -0.18912269, -0.021617886, -0.11320811, -0.51798064, 0.19098064, 0.028828362, -0.30601186, -0.3263491, 0.07554944, -0.23787867, 0.3427053, -0.0044720923, -0.09808175, -0.44192687, 0.44345143) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.838573, -0.34686014, -0.49439234, 0.7444049, -0.17299752, 0.5654361, -0.37856632, 0.27862853, -0.5037348, 0.2545577, -0.07076366, -0.04299712, -0.23532534, 0.2749758, 0.056457274, 0.006870943) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30316928, -0.07202941, 0.2193596, 0.30168974, -0.3265176, 0.21696673, 0.36899993, 0.12037874, 0.35445768, -0.12132938, -0.3124227, -0.2583353, 0.0049692392, 0.19889027, -0.18112186, 0.051627703) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2715074, -0.29505703, -0.30275533, 0.13238525, 0.0217585, -0.19777033, 0.08007767, 0.07777206, -0.0019778104, -0.067140706, 0.0822161, 0.29282886, 0.32122123, -0.009896523, -0.032906532, 0.031517025) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09518403, -0.23067829, -0.15220597, -0.03820497, 0.33270866, -0.1339715, 0.013977735, -0.04318725, 0.15265396, 0.037900276, -0.003986053, 0.23041385, 0.19545147, 0.039227348, 0.11923154, 0.08434938) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13481008, 0.06675134, 0.19476688, 0.13707432, -0.34901357, 0.02164358, -0.027896594, -0.048279505, -0.062269725, -0.0054231626, 0.07224194, 0.075936414, 0.0009747688, 0.0324678, -0.0012524619, -0.013355313) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.0024235684, 0.14119601, 0.9073412, 0.05031787);
      result += mat4x4<f32>(-0.07462858, 0.03639223, -0.011291111, -0.031036843, -0.052561596, 0.16125484, -0.041184105, -0.18073922, 0.062299542, 0.098140925, -0.048963822, -0.10142413, -0.26298332, 0.16270147, -0.07953198, -0.26255232) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10338369, -0.1285596, 0.17432746, -0.12927093, -0.1339272, -0.22528079, -0.27387622, -0.008290276, 0.011235316, -0.052566793, -0.12913531, 0.044394296, -0.26474574, -0.10724616, -0.12845717, -0.31380603) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.051530924, -0.056989003, -0.0074410066, -0.057390656, -0.0074264035, -0.120693505, -0.14254832, 0.14245284, 0.05443876, 0.0033842246, 0.10202324, -0.08194118, -0.17305176, -0.06967611, -0.1395629, -0.012374545) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.058934964, -0.3106888, 0.23053178, 0.02352341, 0.08273478, -0.3765176, -0.42753744, 0.033348292, 0.2891622, 0.46813962, 0.070799746, -0.5725144, 0.1226043, -0.14931607, -0.18044342, 0.14930543) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.41564444, 0.8673879, -0.73638386, 0.22946708, -0.51629794, 0.012801154, -0.3075099, -0.028008023, -0.36761028, -0.4010146, -0.6498514, -0.74169993, 0.8165759, 0.3413037, -0.2284979, 0.5370765) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.043538783, -0.09527396, 0.21537149, -0.0035156726, 0.0642256, 0.09529821, 0.030325707, -0.0595, -0.07321066, -0.0008162428, -0.03564651, -0.041409653, -0.17197992, -0.090620734, -0.13902582, 0.13860352) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.022658613, -0.02810571, 0.11519268, 0.044779804, -0.3038954, -0.06721282, -0.22168075, 0.031816553, -0.08712869, -0.05628613, 0.40677762, 0.24815878, -0.06286292, -0.021384718, -0.12016762, 0.025737217) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.083766215, 0.052514732, -0.0151550025, -0.08085048, -0.0034466945, 0.123586655, -0.2588428, -0.1089776, 0.2225982, -0.003693162, -0.16319045, 0.1152603, 0.1074124, 0.017975137, -0.029961262, 0.12615943) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.009422304, -0.069960594, 0.06674284, -0.013301734, 0.022418894, -0.076483734, 0.057162154, 0.09900503, 0.0666318, -0.0061213104, -0.04624946, -0.06296536, -0.061261285, -0.0012639681, -0.07197537, -0.052362353) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.00066922314, 0.0075868494, -0.111002974, -0.07859278, 0.03433118, -0.046050806, 0.16708793, -0.05494612, -0.10034975, -0.20411232, -0.11388145, -0.104063116, -0.008528746, 0.024235398, -0.03865947, -0.29437327) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10188496, -0.23418146, 0.2257563, -0.12295931, -0.08910108, 0.0006100559, -0.3466815, -0.20140146, 0.12541282, -0.013317465, 0.20214446, 0.19313443, -0.13732956, -0.10264324, -0.32526138, -0.29724765) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.060301654, -0.17121977, 0.029270846, -0.09760702, 0.0020928653, -0.09664904, -0.06534677, -0.18711545, -0.01582833, 0.0065447437, -0.30468276, 0.02909513, -0.05513111, -0.05675232, -0.10740339, -0.13241564) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.13143232, -0.4057557, 0.39128062, -0.06867013, 0.27566513, -0.44807452, -0.47837085, -0.45536503, 0.026413208, -0.37971988, -0.009686122, -0.033537395, -0.0116359405, 0.34907708, -0.1374371, -0.21780653) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14523552, 0.82886314, -0.8597286, 0.2691093, 0.21567066, -0.681469, -1.0201812, -1.5082139, 0.268259, 0.64334583, -0.46386558, -0.88424253, 0.58859783, -0.10595341, -0.011362892, 0.6459753) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.010786125, -0.027496334, -0.020696217, -0.01132345, -0.2716665, 0.024856241, -0.6373071, -0.55557775, -0.12937856, -0.030004289, -0.12133773, -0.00047608564, -0.089343786, -0.28887635, -0.086080305, 0.039575957) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08183703, -0.021956941, -0.03551314, -0.045676883, 0.2181149, -0.0030354902, -0.069094405, -0.2927756, 0.07585802, -0.06100123, 0.050327428, 0.051586624, 0.13099742, 0.025425728, -0.045791317, -0.08920889) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.01476948, -0.08721847, 0.010756758, -0.05117477, 0.23355746, 0.04784581, 0.444438, 0.35097766, -0.09991764, -0.17096235, -0.035672296, 0.104912825, 0.03882684, -0.1215623, 0.13511623, 0.09473708) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06009217, -0.011088894, 0.08313187, -0.04769781, -0.46531224, -0.041574895, 0.09401943, -0.033036917, -0.017154545, -0.08277268, -0.20568813, 0.02992515, -0.02343584, 0.044190865, 0.16611414, -0.13191685) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

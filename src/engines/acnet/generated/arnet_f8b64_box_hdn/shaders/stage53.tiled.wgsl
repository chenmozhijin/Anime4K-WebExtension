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

  var result: vec4f = vec4f(0.025738567, -0.05356493, 0.25730503, 0.1536685);
      result += mat4x4<f32>(0.10882521, 0.15481831, 0.031316552, 0.20758806, 0.03094893, -0.14765732, -0.0067917495, 0.037243538, 0.22229314, 0.025903229, -0.16188204, -0.0064197774, -0.05322433, 0.08930839, 0.0642482, 0.12835488) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06438441, 0.07119474, -0.2169499, 0.41223377, -0.04246523, -0.1810866, 0.0740335, -0.37333438, 0.16007917, 0.15653148, 0.1669368, -0.014567418, -0.15245879, 0.13281411, -0.3163544, 0.17569004) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0113902865, 0.0630441, -0.067510374, 0.22257227, -0.0018099649, -0.110765524, -0.17038275, -0.06400238, 0.015016054, -0.04770153, 0.015210966, 0.12577482, 0.06383651, 0.023830844, 0.077147126, 0.3967617) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11414587, -0.029239554, -0.46759292, -0.23140095, 0.022613933, -0.46145362, -0.43219668, -0.20580304, -0.0077404585, -0.19461553, -0.11615931, 0.45813757, -0.082247145, 0.14447777, 0.1389314, 0.41771302) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.008610579, -0.11640926, 0.05006325, -0.11747543, -0.2138629, -0.42863294, 0.17831762, -0.11445298, -0.15411144, -0.4744233, -0.34993514, 0.014645713, -0.061747324, -0.045471005, -0.70009375, -0.06590173) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11173027, -0.3805303, 0.16931383, 0.39610714, -0.08344282, -0.008190168, 0.081621826, 0.12007692, 0.12071898, 0.3924137, 0.09861108, 0.16884471, -0.11161134, 0.2001304, 0.03566585, 0.33429065) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14857465, -0.28262815, -0.28721052, 0.2536781, 0.022884693, -0.2702076, 0.08398178, -0.12542424, 0.013067333, 0.10311901, 0.1945983, -0.29937413, 0.16718653, 0.32879522, -0.102455616, -0.025194226) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.35288003, 0.14237228, -0.023515731, -0.2218612, -0.09924619, -0.16191082, -0.10975267, -0.18638434, -0.19825672, -0.41891974, 0.044463985, 0.35725486, 0.10166067, 0.12725364, -0.27972472, -0.11019771) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0006588125, -0.17841099, -0.013756429, 0.33313176, -0.12249983, 0.039280113, -0.054555748, 0.2427507, 0.07262875, 0.021037072, 0.018797537, 0.32232046, 0.18206929, 0.45792943, -0.024905184, -0.048390973) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.16020131, 0.19979799, -0.059208456, -0.05468761, 0.019441886, -0.16132364, -0.6019042, 0.06218443, 0.023133237, 0.19836381, 0.27357543, 0.16475417, -0.054794814, -0.30509508, 0.1027995, -0.1765097) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16768266, 0.051075354, -0.48240006, -0.6154198, -0.13569628, -0.7382799, 1.3323659, 0.92715955, 0.06958875, -0.18670033, -0.13972488, -0.051042747, -0.07021025, -0.13886297, 0.2437814, -0.64560294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05779583, -0.010908236, -0.14962693, -0.03795189, -0.26645666, -0.13185173, 0.21149328, -0.045454398, 0.11313685, -0.05811769, -0.0927065, -0.3188303, 0.01194873, -0.15184166, -0.3456418, -0.2501176) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1302924, -0.19104485, -0.1656896, -0.3592708, -0.07862596, -0.13713753, 0.014177277, -0.14031419, -0.29649824, 0.41142285, 0.011819877, -0.12671663, -0.2550111, -0.6633384, -0.30842286, -0.21495506) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2599663, 0.19229242, 0.07592743, -0.48548675, -0.042273182, 0.37893003, 0.19944978, 0.09269192, 0.49526975, -0.42522746, -0.008798591, 0.5192476, -0.2743817, -0.18911776, -0.06777994, 0.4515001) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.013947393, 0.03770638, -0.13533463, -0.2149864, -0.13566355, -0.16463779, -0.19324547, 0.2832458, 0.0045015058, -0.4730052, -0.095083304, -0.007885014, -0.067017496, -0.16299652, -0.01666741, -0.09989598) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0588913, 0.0841867, -0.040639102, 0.025069773, 0.033884432, -0.004119173, 0.15965655, 0.004850519, 0.057632647, 0.29851452, 0.053597096, 0.31982896, 0.004673655, 0.49950927, 0.13985035, -0.0034289397) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1536764, 0.14209664, -0.0076265503, -0.13348839, -0.06569123, 0.12787247, 0.037643496, 0.1653974, 0.13498716, 0.29240358, -0.048535205, -0.15852381, -0.08568837, 0.2761751, -0.2042946, 0.07247877) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.057758566, 0.17800403, 0.027418667, -0.063911006, -0.082463965, -0.05099077, -0.13344389, 0.032938045, 0.12054906, -0.17743418, 0.071551345, -0.529338, -0.0070296493, -0.087804504, -0.008756005, -0.37871483) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

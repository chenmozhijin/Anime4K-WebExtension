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

  var result: vec4f = vec4f(0.3339765, -0.072822124, 0.27577952, 0.030231142);
      result += mat4x4<f32>(0.13857795, 0.06528414, -0.19518566, 0.31429392, -0.023001114, 0.04829152, -0.06958949, 0.10623845, 0.101392746, -0.14865704, -0.14415765, -0.12310185, 0.11932564, 0.14602105, 0.014603863, 0.03317576) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.20903496, 0.02666765, 0.18718272, 0.18586946, 0.13603967, 0.03928262, -0.28076124, 0.3654365, 0.12933742, -0.04229764, -0.24168883, -0.16345605, 0.013087704, 0.063868105, -0.14137797, 0.124413416) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.12861413, 0.070423484, 0.17300585, -0.1220982, -0.06311651, 0.10460871, -0.02450679, 0.190943, -0.011694713, -0.08376851, -0.08573967, -0.056322634, -0.19160238, -0.16111866, 0.0029240872, -0.06305759) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.024153141, -0.07579218, -0.13884163, -0.08714209, -0.07790053, -0.09551704, -0.1229304, 0.124085985, 0.5133535, -0.08297649, -0.31108078, 0.045843616, 0.22942354, 0.02667503, -0.15019053, -0.015503255) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.669568, 0.26026973, -0.039588176, -0.0009362449, 0.1661561, 0.028169403, 0.10710485, 0.29328343, 0.3012219, -0.13475162, -0.26179105, -0.20661877, -0.19463779, -0.15982169, 0.03282311, 0.4254923) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.17318858, 0.25722942, 0.059835505, 0.07202221, -0.15924108, 0.03550248, 0.0041277017, 0.28844365, 0.03058319, -0.041339017, -0.15614906, -0.090272725, -0.02647299, -0.18965535, -0.30104205, 0.19341506) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10929448, 0.049777735, 0.004578278, 0.06444781, -0.04002007, -0.057161078, -0.09258455, 0.08644885, -0.18981585, 0.046158735, -0.15752926, 0.14434426, -0.17569053, 0.01331353, -0.2105352, 0.012059644) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.37254313, 0.16085072, 0.1559679, 0.08043056, -0.103334464, 0.02501519, -0.030752577, 0.026405789, 0.2947611, -0.20471966, -0.30035225, -0.018183403, 0.15869963, -0.16130485, -0.18011881, -0.27037585) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19285353, 0.14978972, 0.07554537, -0.026326964, 0.012356205, 0.013666661, 0.104766, -0.010377945, 0.010031803, -0.109041475, -0.024691395, -0.02503804, 0.50087476, -0.0010713869, 0.11126658, -0.124050006) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06584119, -0.0071458267, 0.03984401, -0.28849787, -0.09931556, -0.015906105, 0.07252788, -0.047572542, -0.19825198, 0.016109644, -0.023119517, -0.0851921, 0.086390965, -0.054827068, 0.14853902, -0.11238977) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.123858996, 0.042548187, -0.24040201, -0.3586258, 0.18533422, 0.0770849, -0.12221741, 0.196397, -0.20938483, -0.19096486, -0.3381313, 0.24290991, -0.2880977, 0.11207681, 0.43083602, -0.10195133) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.23746733, -0.12447093, -0.3068167, 0.20676446, 0.2909877, 0.07356012, -0.13074996, 0.14847176, 0.09859626, 0.1630165, -0.01325204, 0.24546766, -0.026002875, -0.017880145, 0.14744683, -0.31331715) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.284978, -0.0727183, 0.15797949, -0.109705634, -0.28861466, -0.054765157, 0.032741744, 0.09276089, 0.08229543, 0.03417845, 0.08416345, -0.2054246, 0.038314596, 0.0752414, 0.29943824, 0.339384) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.27600816, -0.3892603, -0.38482252, -0.71751344, 0.032811835, -0.2950763, -0.22005704, -0.17309698, -0.21876548, -0.2178097, -0.24641126, 0.12721112, -0.1621492, -0.24129859, -0.23292334, 0.41746894) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.5403384, -0.12145305, -0.27164298, -0.06921202, 0.31990805, -0.11281773, -0.06828998, -0.1001725, -0.45380837, -0.019393984, -0.08797136, 0.136542, 0.23729263, -0.23802894, -0.22068936, 0.099438086) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.15963675, 0.028290166, 0.017203962, -0.042106424, 0.12782243, 0.041002527, 0.14583242, 0.07813794, 0.050761368, -0.15268521, -0.11286467, 0.13278559, -0.15885063, -0.040580515, 0.040468268, 0.12173808) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.33790642, 0.08514984, 0.14296295, 0.15990934, 0.34787667, 0.1438939, 0.09982466, -0.040853757, 0.21526107, 0.24776527, 0.5986772, -0.5341586, 0.20156051, -0.37859645, -0.3437289, -0.15089749) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19077545, -0.17246486, -0.14271939, -0.03938597, 0.30129153, -0.0041987994, -0.059818067, -0.071271844, 0.14747928, -0.046770595, -0.22422089, -0.09959977, -0.10826163, -0.013488921, 0.052927762, -0.019473359) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

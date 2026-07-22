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

  var result: vec4f = vec4f(0.052694254, -0.07233279, 0.06301365, 0.06875395);
      result += mat4x4<f32>(-0.038079876, 0.18341869, -0.065304704, 0.09194344, -0.08065608, -0.07798234, 0.011225541, -0.111680396, 0.0938405, 0.1240522, 0.13168567, -0.0056284335, -0.22649695, -0.17365268, -0.113490514, -0.09912152) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.024521478, 0.21385698, 0.1321459, -0.24683538, 0.16368498, 0.15756772, -0.050540194, 0.24804914, 0.011492689, -0.010572782, 0.21340257, -0.1121131, -0.0892683, -0.16129763, 0.009677097, -0.154351) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05937705, 0.005274586, -0.05325995, 0.03578129, 0.08802306, 0.053102285, 0.27380356, -0.083888784, 0.08585385, -0.08862766, 0.080286436, -0.074732736, -0.07660394, -0.11482675, 0.1649665, -0.2218263) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1455644, 0.05491735, 0.11789253, 0.0010075358, 0.035830222, 0.1504899, 0.14407061, -0.18153124, -0.016297687, -0.012133909, 0.095051885, -0.08670297, -0.24956994, -0.31523773, -0.012389176, -0.1990484) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20126413, 0.014366717, 0.37438568, 0.099335164, 0.081570804, 0.31651536, -0.11160557, 0.108128786, -0.07880053, -0.25269473, -0.3113431, 0.025102971, -0.31786072, -0.25486887, 0.011595565, -0.32308203) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.25388277, -0.08335175, -0.20035332, -0.025741206, 0.15143861, 0.16788778, 0.4963747, -0.2784909, 0.037989557, -0.04493854, 0.19739987, -0.19829486, 0.010626717, 0.15090756, -0.036550485, 0.023161842) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17436045, -0.3191159, -0.028367274, -0.19515002, -0.11435489, 0.0015860588, -0.10904213, -0.027415177, 0.2485729, -0.09398839, 0.3482976, 0.0052090758, -0.037395146, -0.26809886, -0.16131687, -0.008518378) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.033558186, -0.5271048, 0.2776544, -0.25407523, -0.042802874, 0.0073415064, -0.31834492, 0.1764611, 0.03713286, 0.05045651, -0.065159895, 0.19003332, -0.07431384, -0.18018524, 0.0032251717, 0.09985672) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.272114, -0.49520585, 0.13234414, -0.3084136, 0.0767391, -0.17571405, 0.22072423, -0.21559078, 0.16379924, 0.01714971, 0.20549525, -0.02197153, -0.20581165, -0.17513624, -0.19402203, -0.104518935) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.14161068, 0.19812359, 0.031388845, -0.23481148, 0.0141961, 0.122893654, -0.35120958, 0.24819972, -0.117051005, -0.031303607, -0.11278235, -0.13783436, 0.21896425, -0.13986768, 0.15087377, 0.20789982) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3324936, -0.038163316, 0.41412982, -0.002893347, 0.003252817, -0.18709916, -0.7334451, 0.49267825, -0.04072577, -0.0841933, -0.03563366, 0.2283176, 0.10595581, 0.31320512, -0.049348217, 0.28033838) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14106783, 0.08759129, -0.0022560568, -0.05612769, 0.008470421, -0.2858382, -0.28989062, 0.4720778, -0.13758427, 0.044892445, -0.12575278, 0.13783221, 0.053642638, 0.019980472, 0.11144195, 0.009791336) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18136367, 0.066684194, -0.021826494, -0.023740867, -0.32434827, -0.45195943, -0.7868099, 0.4439258, 0.28702834, 0.2668611, -0.5257987, 0.28013414, -0.19046299, 0.15590297, -0.5826714, 0.18217257) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.09152199, -0.09760666, -0.19009203, 0.088689096, -0.16219242, 0.16271982, -0.22370794, 0.10091584, -0.07110722, 0.11435399, -0.39333305, -0.07468213, 0.09846781, 0.25863135, -0.11249109, 0.17791209) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.047416154, -0.36517447, -0.256056, 0.3660794, -0.049646605, 0.31010008, -0.4510817, 0.28346208, 0.09875285, -0.051545832, 0.076938264, -0.008237457, 0.045609765, 0.103454076, 0.016698971, -0.015090388) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17693956, 0.19184151, -0.093635224, -0.032421857, 0.3080702, -0.17761473, 0.010695746, 0.20542528, -0.3558019, -0.21455984, -0.12844205, -0.029425357, -0.25091824, -0.10676108, -0.31676632, -0.012719558) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.020380285, 0.19912267, 0.080818385, 0.033397887, 0.018147916, 0.045392465, -0.18432552, 0.29777724, -0.16067706, -0.2881541, -0.28530037, 0.12231787, 0.063651025, 0.46542758, 0.05116617, -0.050863747) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.026026761, -0.1906436, -0.11139782, 0.13804802, 0.07301513, 0.019693289, -0.1668717, 0.27732825, 0.09246072, -0.16354948, -0.17331779, 0.27346212, -0.016749928, 0.014843002, 0.08622918, -0.1631823) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

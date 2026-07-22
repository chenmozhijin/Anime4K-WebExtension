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

  var result: vec4f = vec4f(0.06732929, 0.225989, -0.022403117, 0.12771238);
      result += mat4x4<f32>(0.13834196, -0.16762696, 0.15231942, 0.13473149, -0.25323203, 0.004787596, -0.2100479, -0.19431256, -0.19844715, -0.009728172, -0.07900586, 0.000119819626, -0.018743144, -0.16185832, -0.11133654, -0.1732833) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.02644849, -0.051778805, 0.0024094826, -0.15344363, 0.022115417, 0.14891717, -0.024687856, -0.15044211, -0.16813348, 0.07300564, -0.07672826, -0.08714827, 0.02678595, -0.066186614, 0.22966574, -0.22674672) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03258135, -0.016828299, -0.008961467, 0.075171016, -0.092109, 0.23900393, -0.09670257, -0.21663941, 0.048584178, -0.0670834, -0.16289687, -0.00052152167, -0.028454538, 0.012168496, 0.08045409, -0.05401167) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18257427, -0.012306739, 0.17804359, -0.08478214, 0.098264106, 0.01098283, -0.08922098, -0.09859913, 0.067912854, -0.08684419, -0.014375631, -0.0050492305, -0.11836784, 0.08631354, -0.092110805, 0.0115974145) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19413388, -0.1712458, -0.2740545, 0.87358737, 0.08689359, 0.5525457, 0.06630505, -0.1020455, 1.1041954, 0.9987038, 0.943706, 0.4605627, 0.37711155, -0.05550418, 0.6612304, -0.032603484) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14384606, -0.08381355, 0.15778969, 0.113204435, -0.042927638, 0.21460986, -0.39495414, -0.38886288, 0.040519524, 0.029551527, 0.0063948133, -0.08051944, 0.15539707, 0.14397965, 0.298705, -0.16689423) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.12978083, -0.119918615, -0.048781835, 0.025680555, 0.004691042, 0.12466295, -0.022212116, -0.21224356, -0.012266088, 0.015954979, -0.17929798, -0.15995024, -0.039429072, -0.06794279, -0.007297539, 0.21206634) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.22501062, -0.19533567, 0.14529419, 0.044541147, -0.048320014, -0.006319744, -0.117310755, -0.31967714, -0.054209158, 0.039389297, -0.014482737, -0.016804388, 0.0051733223, -0.05153704, 0.10909478, -0.0061310604) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16138119, 0.15956812, 0.075580224, -0.16102336, -0.2840226, 0.065561414, -0.130038, -0.09988689, -0.03089901, -0.032002017, -0.11839129, -0.00788021, 0.066652864, 0.0029298197, 0.1862183, -0.08682805) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.15025492, 0.037099, 0.22640228, 0.0836336, -0.40841332, 0.19852242, 0.36860672, 0.09056785, 0.010367857, 0.19307812, 0.11450775, -0.22125089, -0.0850094, -0.07805635, 0.022758551, -0.092612445) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21461298, 0.030072613, 0.28171277, -0.065832004, -0.0118626915, -0.45490503, -0.10230599, 0.2877598, -0.4278288, -0.3973179, 0.12461444, 0.04405971, 0.09882117, -0.14951864, -0.24258918, -0.09339433) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11499634, 0.021933883, 0.21954058, -0.04322756, -0.16893634, -0.18132393, -0.16852061, -0.11613797, -0.04718085, -0.21371123, 0.36887547, 0.2756514, 0.010571645, -0.1821606, -0.069080785, 0.15502585) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.26869446, -0.12393643, 0.28593466, -0.4610976, 0.5939151, 0.07564835, -0.0071158474, -0.49441922, -0.25188318, -0.39626822, -0.049411383, -0.11037377, -0.3168121, -0.28086698, -0.21582705, -0.5931691) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.33569664, 0.17716514, -0.38155237, 0.050527997, 0.029256776, -0.09453377, 0.19848786, 0.27954644, 0.5747944, 0.32200605, 0.47863242, 0.38203928, 0.1462605, -0.276507, -0.055761438, -0.12675115) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15440974, 0.56367797, 0.055049777, -0.12021712, -0.05841755, 0.19245498, 0.011178636, -0.032642286, -0.011652925, -0.39078957, 0.1748858, 0.038089693, -0.042264603, -0.13250007, -0.11275449, 0.10116064) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04256228, -0.024708113, 0.14899658, -0.022496777, -0.11823473, 0.1605834, 0.057072982, 0.115449555, 0.11765937, 0.06683959, 0.2291479, -0.02800622, 0.11780285, 0.08353103, 0.025509348, -0.15312985) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1406191, -0.24645601, -0.019962508, -0.007794504, 0.095481925, -0.069847494, 0.1210414, -0.024893872, -0.054344002, -0.17878978, 0.048612542, -0.05424036, -0.37754276, -0.11848223, -0.021664621, 0.16143152) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15924291, 0.25771406, 0.08629313, -0.22136699, 0.06612905, 0.077857345, 0.03589003, 0.037692506, 0.19657357, -0.12328766, 0.12267997, 0.10657674, 0.00867531, -0.080869615, -0.08784526, -0.031692863) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.3497269, 0.1763957, 0.25582382, -0.11303422);
      result += mat4x4<f32>(0.0049067633, -0.0290312, -0.0713422, -0.13473545, 0.041383818, -0.07024711, -0.049082182, -0.04953629, -0.057623398, -0.006169321, 0.19212836, 0.31121296, 0.14478675, -0.095083974, 0.10234595, 0.08676062) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.009121479, 0.123746246, 0.08426129, -0.030017039, 0.2515218, -0.094960384, -0.025817921, 0.023144176, -0.11805693, 0.20354494, 0.44775933, 0.35656595, -0.24959546, -0.14187877, 0.020607183, 0.23209761) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.008958236, -0.011397645, -0.029342478, -0.053432, 0.07345826, -0.026584836, 0.020908281, 0.014126103, 0.16365235, 0.09995958, 0.108073674, 0.19852515, 0.027966913, -0.12646917, -0.050631307, 0.060985696) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09132397, -0.06141988, 0.25141573, -0.0024126566, 0.16025554, 0.27357394, 0.18073942, 0.018202586, -0.07852001, 0.022946598, 0.22087473, -0.04750537, 0.100918345, 0.13343759, 0.119507, 0.05439168) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.121391065, 0.9616126, 0.5226512, 0.41103694, -0.23481645, -0.050505474, -0.9692754, 0.71165514, -0.44531944, -0.2738159, 0.1644853, -0.8109992, -0.827828, -0.058163304, 0.42214954, -0.05806901) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.32760248, 0.12469354, -0.25144315, 0.12821838, -0.18631291, 0.017276578, -0.10219053, -0.007555234, -0.16417406, -0.16438864, -0.026336849, 0.007308083, 0.13419731, -0.0898812, -0.12658733, -0.03402976) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06675518, -0.10760684, -0.061185364, -0.098108955, -0.08549642, -0.13134396, -0.030701164, -0.037023734, -0.018837634, 0.01313199, 0.10863298, 0.27992165, -0.014698051, -0.01231462, -0.14066128, -0.14190048) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10204591, -0.33898956, -0.10779359, 0.22182894, 0.16950317, -0.3831407, 0.01151509, 0.46129993, -0.02280744, -0.004657017, 0.34019494, 0.3115547, -0.083166055, 0.082079306, -0.16167538, -0.39620215) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.028923893, -0.12200675, -0.14718182, -0.2655009, -0.16378883, -0.16059601, 0.030586995, 0.15472075, 0.027908424, -0.34146246, 0.077479616, 0.27755287, 0.023189383, -0.06619688, -0.004414103, 0.067129835) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.022703802, -0.12853307, -0.03652984, 0.018208565, -0.0064609908, -0.09147249, -0.046084665, -0.10049934, -0.028907754, -0.28689003, -0.42806798, -0.32267764, 0.057471853, 0.17426535, -0.0667954, -0.08051494) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15458837, 0.091998935, 0.047158867, 0.02200876, 0.047175594, 0.17208625, 0.085205734, 0.0072360947, 0.19319808, -0.22090013, -0.14197847, -0.19948214, 0.029885717, 0.14678833, 0.123326376, -0.21900387) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16941644, 0.00853133, -0.020159265, 0.00014779328, 0.14906687, 0.24260141, 0.03149072, 0.028443035, -0.0857133, 0.031880036, 0.0028295568, -0.018833388, 0.15627816, 0.20293552, 0.04359908, 0.011869538) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.051680025, -0.06266142, -0.02042358, 0.1250724, -0.034117326, -0.018063908, -0.12977889, -0.037518278, -0.12642367, -0.7057468, -0.16827567, 0.6001923, -0.05524838, 0.46471083, -0.027328359, -0.25874633) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.32622623, -0.07411082, 0.27962354, -0.3775351, 0.21508645, -0.5101982, 1.0032607, -0.44147447, 0.5105307, 0.082417265, 0.038539607, -0.18161488, 0.27669516, -0.7473805, 0.25073493, -1.2614063) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.046536308, -0.14322934, -0.08664314, 0.20932841, 0.41442195, 0.89781576, 0.027973799, -0.12155521, -0.057196543, 0.036559913, -0.02169863, 0.060404014, 0.08087484, -0.09122808, 0.025250785, 0.03445104) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11171914, -0.037066277, -0.060995154, -0.040108636, 0.010502304, -0.028156241, 0.04205428, -0.027611941, 0.05304034, -0.09395637, 0.16511543, 0.035435732, 0.021715665, 0.08478156, 0.00016311434, -0.034424104) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08642298, 0.033846054, 0.0018348715, 0.2691484, -0.047822792, -0.13235475, 0.014041102, 0.23162296, 0.031877577, 0.1588007, -0.09205443, 0.021673573, 0.2125503, 0.29008386, 0.06058252, 0.11899523) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0074377116, -0.16022791, -0.013890357, -0.038475346, -0.23006329, 0.12491136, -0.056054775, -0.112776205, -0.02949925, -0.009697073, 0.045764916, 0.0873615, -0.028279087, -0.026730984, -0.017266646, 0.018479161) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.3018499, -0.21142726, 0.18089871, 0.010979926);
      result += mat4x4<f32>(-0.0942961, -0.28897962, 0.03330909, 0.43370745, -0.043207016, -0.07268912, -0.15339176, -0.16716026, 0.01956417, -0.29786232, 0.015393069, 0.06899141, 0.030429333, 0.23894677, -0.14520574, -0.14561349) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.22534506, -0.0133883795, 0.38987666, 0.07994069, -0.08634837, 0.11389132, 0.008816789, 0.15688102, 0.15920931, -0.12635323, -0.23893811, -0.2452567, 0.10230488, 0.24551016, -0.17034985, -0.19201344) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.03506148, -0.124987364, -0.0077817333, -0.03942741, 0.1935578, -0.026243154, -0.007579332, -0.021830017, -0.032154597, -0.05801705, -0.009897629, 0.10670696, -0.04820057, -0.16457488, 0.090911016, 0.011530808) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.026630953, 0.21405043, -0.15689696, 0.5136204, -0.17268372, 0.11897542, -0.050438, -0.28027353, 0.26333997, -0.056375667, 0.012187297, 0.41649258, -0.076353826, 0.10849774, -0.05238243, -0.17397416) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.40971652, -0.18947224, -0.36037222, -0.32431987, 0.055394482, 0.15845706, 0.20775108, 1.112106, 0.32308468, -0.28295222, 0.11430489, -0.1566982, 0.4964273, -1.3573111, 0.15386252, 0.48809305) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.15759228, 0.16415964, 0.017793383, -0.043374952, 0.12925458, 0.07124956, 0.17094761, -0.01950402, -0.024754014, -0.068871394, -0.15710941, 0.0290427, 0.010879411, 0.4493356, -0.24390829, -0.039864697) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1018991, -0.15779726, 0.062594876, -0.002644368, -0.46093738, -0.06219734, -0.016152764, -0.2242082, 0.43482262, -0.02476721, -0.19592436, 0.19220656, 0.2047703, -0.12661038, -0.11529106, 0.0694226) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.35268617, -0.14713956, -0.09341972, -0.19174246, -0.041694727, -0.28119382, -0.25101146, 0.38904747, -0.047474544, 0.19576555, -0.03857357, -0.27447143, -0.27909842, 0.5117308, -0.023883585, 0.26055047) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0010156463, 0.114528544, 0.054567713, -0.029474232, 0.34329167, -0.019353496, -0.2334095, -0.12158644, -0.30819848, 0.14253919, 0.1673606, -0.030253591, 0.42429456, -0.41910574, -0.1000689, -0.44464588) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.35359836, -0.14019054, -0.20605779, 0.071792126, 0.24539529, -0.1454413, 0.035372753, 0.1809103, 0.21962231, 0.20057641, 0.07446019, -0.41059378, -0.10089125, 0.21820875, 0.09032183, -0.22336169) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.05242267, -0.36959165, -0.27142733, 0.15520939, 0.12903784, 0.15395522, -0.08220911, -0.4896425, -0.28265288, -0.013347357, -0.106571004, -0.43203336, -0.13527568, 0.043255016, -0.18603382, 0.47403443) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.010455722, -0.111278385, 0.024220664, -0.08863582, -0.09800389, -0.40756148, -0.08141576, -0.1295718, -0.038081404, 0.45209277, 0.1642977, 0.7418072, 0.3001246, -0.40232334, -0.071910284, -0.10497292) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.18548323, -0.12400552, -0.14395416, -0.43683654, -0.066309564, -0.4220992, -0.27714846, -0.17576061, -0.14853914, -0.4423916, -0.11749125, -0.15197976, -0.003788582, 0.46170673, 0.12846059, 0.17045026) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13491003, -0.42260504, -0.38870275, 0.29457158, 0.22331831, 0.0699394, 0.13056973, 0.38012052, -0.5496377, -0.5515097, 0.37812614, -0.6790905, 0.25335303, 0.2896844, -0.46737668, 0.67929494) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.22503468, 0.33558726, 0.24215218, -0.1261958, -0.0052696513, 0.76532763, 0.2706044, 0.4475314, 0.2963274, 0.63606745, -0.35948935, 0.419723, 0.34007293, 0.021969365, -0.025273502, -0.12651639) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.30262816, 0.13756144, 0.24110277, 0.024248052, -0.13642119, -0.29846317, -0.076941796, -0.20065928, -0.08503956, -0.07505301, -0.032726254, 0.025524097, 0.025688577, -0.26712173, 0.12313667, 0.13481136) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11989152, 0.6482164, -0.27652004, 0.34365135, 0.14246091, -0.07500841, 0.023052692, -0.021375768, -0.11062287, 0.19060165, 0.21020639, 0.18704017, 0.10111486, 0.29961574, -0.35500166, 0.052343156) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.111020416, -0.31851527, -0.15821017, 0.0056238538, -0.15855736, -0.39904416, -0.13011843, -0.035763964, -0.028586159, 0.28098208, 0.08070675, 0.29270902, 0.1549653, -0.11140338, -0.046315826, -0.17677115) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

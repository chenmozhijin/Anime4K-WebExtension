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

  var result: vec4f = vec4f(-0.033446245, 0.14794934, 0.19199103, 0.14159147);
      result += mat4x4<f32>(0.102038376, -0.18700786, 0.13874927, -0.08347206, -0.0013156724, -0.066397965, -0.050576117, 0.24926117, 0.03383935, -0.2821563, -0.31182384, -0.47911924, -0.06408042, -0.13414155, -0.13332775, -0.117709175) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.002281894, -0.23235051, 0.13671254, -0.21899308, 0.09880451, -0.20222867, 0.12876107, 0.28931317, 0.07229825, -0.1728327, 0.102327526, -0.35782415, -0.0155029185, -0.05871467, -0.10971933, -0.18074128) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.010890512, -0.041300956, 0.05493041, -0.20644255, -0.12630092, 0.12238618, 0.34639058, 0.48450997, -0.093570136, -0.26565123, -0.18464687, -0.1691866, 0.1156318, -0.21310045, 0.10556006, -0.17266428) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.28310648, -0.37861317, 0.27773455, -0.7165651, -0.037138093, 0.07399925, 0.11993415, 0.29795286, -0.001675783, 0.06772708, -0.3713925, -0.23006372, -0.13749228, -0.11759315, 0.42097226, -0.09791988) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.28972036, 0.05948381, 0.4593938, -0.056724984, -0.14027886, -0.2964939, 0.037693147, 0.7621397, -0.028615944, -0.11889105, 0.206415, -0.11835952, -0.27020335, 0.2854611, 0.22590385, -0.19435477) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15661891, -0.43911237, 0.17346734, -0.03512426, -0.12833574, -0.017311482, -0.23139675, -0.035412554, -0.13298507, -0.2562006, -0.121869914, -0.033593003, -0.050939523, 0.22045197, -0.01667533, -0.24456486) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.040252756, -0.12529942, 0.15092422, -0.2106538, -0.13903701, -0.24846518, -0.10290735, 0.14644276, 0.037563253, 0.14504068, -0.05764009, -0.2853801, -0.004963693, -0.30111232, -0.00012539838, -0.114826605) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.39053845, 0.19919346, 0.08229345, 0.11855925, -0.05900222, 0.09930611, 0.027664829, 0.3447405, 0.038895633, 0.19224341, -0.2401476, -0.35463133, 0.03962961, 0.07995084, -0.0143549, 0.117828324) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.13811406, -0.22744161, 0.0083195595, 0.21221209, -0.15506954, 0.047112208, -0.16901146, 0.21074536, 0.0933921, 0.117367335, -0.15616253, -0.08355582, 0.08320874, 0.11805856, -0.09313963, 0.13450237) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.087958954, -0.22593242, 0.15225433, 0.2866496, -0.15314056, 0.07547649, 0.04068807, -0.12064898, 0.055099424, -0.03844641, -0.06305339, 0.048711855, 0.0018406082, -0.087002784, 0.13382474, -0.21193501) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10556315, 0.042471003, 0.14122073, 0.14063106, -0.19831865, -0.14040966, -0.0742311, 0.31783426, -0.053272005, -0.098764524, 0.28845873, 0.13236637, -0.009831645, -0.050197966, 0.06604155, -0.021216998) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.019696232, -0.031405967, -0.009808728, 0.16017799, 0.030463694, 0.11885129, -0.057628658, 0.1397516, -0.1441033, -0.084956855, -0.08524197, -0.00025845182, -0.1471556, -0.23729481, 0.20858364, -0.028067458) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.021346617, -0.5377246, -0.20277742, 0.13974145, 0.19681837, -0.15595737, 0.23265322, 0.045377225, -0.06010049, -0.28774408, -0.13846387, 0.016218118, -0.071825415, -0.28553745, 0.045253225, -0.105274536) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.045900322, 0.0073071243, 0.17791098, 0.31177354, -0.10330588, 0.009656043, -0.0363093, 0.9832264, 0.027647387, -0.1641028, -0.20132993, -0.17581959, -0.14223057, 0.0013773852, -0.23493324, 0.012081561) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11048579, 0.27142546, 0.13343333, 0.16084722, -0.01161829, 0.047874495, 0.06898266, -0.11639293, 0.1509272, -0.10789962, -0.14378455, -0.077408776, -0.061370715, 0.32835624, -0.08498948, 0.058215156) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14780657, -0.14076075, 0.16425723, -0.12568092, 0.16697283, 0.112177774, 0.11567435, -0.0895269, -0.14917165, -0.15276106, -0.0040330235, -0.24501583, 0.29460332, 0.11153747, 0.022867192, -0.5016946) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0314177, -0.14375198, 0.11706573, 0.20815447, -0.12498999, -0.41949594, -0.0034467275, 0.19045608, 0.11183952, -0.07591805, 0.20011029, -0.4613011, 0.1471927, 0.13782366, -0.24352276, -0.31123883) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09343213, -0.14612472, -0.03648879, 0.112070665, 0.01850297, 0.14111954, -0.018762924, 0.4395588, 0.24107532, -0.20263894, 0.0603873, -0.29882318, -0.009576939, 0.1629919, 0.040103864, -0.1648821) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

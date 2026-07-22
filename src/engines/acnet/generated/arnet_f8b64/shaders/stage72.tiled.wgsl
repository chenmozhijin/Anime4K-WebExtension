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

  var result: vec4f = vec4f(0.1319933, 0.013278642, 0.29306298, 0.14665078);
      result += mat4x4<f32>(-0.06055135, 0.046527203, -0.3053725, -0.4359088, -0.112073675, 0.028241739, 0.018590633, -0.12810817, -0.1522858, 0.059494626, -0.10378101, 0.01634604, -0.24338487, 0.11755501, 0.16691229, -0.14156534) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.044045173, -0.0026977467, 0.14972913, 0.14342715, 0.024592603, -0.02165668, 0.1294132, -0.5112265, -0.33730268, -0.20258695, 0.12851368, -0.41899997, -0.0146800745, -0.038190037, 0.2165922, -0.12886038) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.048723545, 0.0690038, 0.062427755, 0.028448455, 0.14127102, -0.14067358, -0.056304973, -0.17934099, 0.0017002384, -0.06977588, 0.06400037, 0.001794685, 0.12223811, -0.055326454, 0.08965528, 0.008845888) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04800168, 0.23387876, 0.18068103, -0.19270882, 0.08289433, -0.23344187, 0.10683483, 0.11574134, -0.14347546, 0.08414331, -0.062758036, -0.30096835, -0.24800888, 0.11631296, 0.3853109, -0.28521523) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42042866, -0.11924874, 0.20847349, -0.5491624, 0.14163332, -0.12029552, -0.3424778, -0.14521526, -0.14566186, -0.20542246, -0.6032704, 0.7168719, -0.029888244, 0.103634045, 0.07644908, -0.28386745) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24792634, -0.06323349, 0.21944092, 0.16228853, 0.5446222, -0.12071229, -0.11701288, -0.04748049, 0.48867232, -0.27772844, -0.7035535, -0.19669199, 0.09274495, -0.07153619, -0.21471545, -0.3779346) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04951026, 0.29183266, 0.1318563, -0.26073208, -0.085156046, 0.0021204383, 0.14688799, -0.06809982, -0.11011941, -0.0024160366, 0.33552524, -0.25180355, 0.18485792, -0.13032621, -0.00051079586, 0.15482634) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.46643606, -0.047353886, 0.34331635, 0.16165154, 0.12793793, -0.057340097, 0.04736939, -0.13143846, -0.31200436, -0.16783951, -0.035375472, 0.3759048, 0.065476075, -0.26612514, -0.14530455, 0.16577809) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2185368, -0.001381752, 0.07000342, 0.16566609, -0.023748642, 0.01736984, 0.046153538, -0.035712447, 0.51979244, -0.16881935, -0.091268666, -0.14872979, -0.20526026, -0.090637915, 0.028589975, 0.05500715) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.17890249, -0.08203831, -0.16550767, 0.04216504, -0.06411555, -0.012174467, 0.1311035, -0.053032774, 0.17344448, 0.054990478, -0.023766262, -0.1835865, 0.11007752, -0.054367173, -0.14662205, 0.3013054) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15677975, -0.22019044, -0.22734173, -0.6313087, 0.3324197, -0.11060768, -0.09544072, -0.0013034812, -0.14218262, -0.09267401, 0.06741821, -0.4246415, 0.18936066, 0.183912, -0.11284937, 0.56752056) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04831273, -0.23608431, -0.09785609, -0.4094004, 0.16645816, -0.0824261, -0.07340341, 0.13286123, -0.043280266, -0.11456083, -0.08340217, -0.15055285, -0.16809723, 0.19607264, -0.06497715, 0.07424715) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.056546245, 0.1200401, -0.000869629, -0.16968043, 0.49854043, -0.01646435, -0.10383979, 0.015215841, -0.028874889, 0.087077014, 0.18360242, -0.14008859, 0.33594078, 0.16372302, -0.31314036, 0.2667025) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21465552, -0.038014326, -0.14549527, 0.24193142, 0.15563427, -0.05797124, -0.29883906, -0.1713362, 0.35229403, 0.07721917, 0.22609726, 0.08743794, -0.18916425, -0.11747965, -0.2708194, -0.010200755) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.012770165, -0.26660326, -0.029554117, 0.13199165, -0.17013171, -0.0024642802, -0.17199454, -0.089011125, -0.080502816, -0.0046977745, 0.5872827, 0.014083554, -0.48854116, 0.0101716025, -0.2557391, 0.04617678) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04749891, -0.14038777, -0.045409076, 0.009514975, -0.31995168, 0.1330973, 0.3146095, -0.36564174, 0.0133372275, -0.046029862, 0.12113066, -0.020540165, 0.18003279, -0.06064118, -0.3525681, 0.026977932) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.046604473, -0.051759847, 0.15287921, -0.020758158, -0.15263711, 0.1865796, 0.15570442, -0.07943474, 0.313419, 0.032999817, 0.31942496, -0.23052773, 0.17862308, -0.06794748, -0.16626872, 0.08764217) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.33185747, -0.10347143, 0.09175167, 0.0239364, -0.11541904, 0.02175181, -0.041234188, -0.14813073, -0.25329408, -0.12271228, -0.06702945, -0.082267776, -0.03596924, 0.0029732208, 0.012620997, -0.07039509) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.2678784, -0.23875527, 0.13031352, -0.05696555);
      result += mat4x4<f32>(0.0040589212, 0.19116823, -0.07242641, 0.13444348, 0.052712347, 0.17704114, -0.18575008, -0.25757486, -0.0350076, 0.048738237, 0.16688132, 0.04446736, -0.025998693, 0.24236386, -0.08806732, -0.07671802) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.28897932, 0.33312172, 0.15823115, -0.024745053, -0.087716684, 0.2801017, 0.02116349, 0.13869219, -0.17765433, 0.25211287, 0.16115922, 0.2695485, 0.11880731, 0.14953892, -0.08818694, -0.30551025) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05525906, 0.08769985, 0.24360424, 0.29787332, -0.13144952, 0.2679405, 0.051222347, 0.024186281, 0.27470088, -0.56002265, 0.06453646, 0.10202403, -0.026513405, 0.12790123, 0.010630085, -0.10389043) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.018596835, 0.054555893, -0.20630424, -0.06163842, 0.093501054, -0.011086355, -0.18663561, -0.31424856, -0.18018502, 0.15222509, 0.0795861, 0.13965486, -0.18399101, 0.094354264, 0.29773712, 0.46811056) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0718987, 0.018806227, 0.107037686, 0.20190203, -0.023640623, 0.23057641, -0.15119432, 0.091153026, -0.16713083, 0.32411513, -0.25164172, -0.14361429, 0.13950866, -0.37097314, 0.3391981, 0.18093416) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18148847, 0.038714573, -0.13698001, 0.06306516, -0.0012333933, 0.13518882, -0.30725908, -0.07789314, 0.2874169, -0.5801643, 0.20126973, -0.11666417, -0.06905671, -0.21927549, 0.2683607, 0.28382462) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08019793, 0.15964493, -0.20707147, -0.07235562, 0.029644528, 0.07913023, -0.213132, -0.15178487, 0.044389114, 0.19132933, -0.2263345, -0.13421148, 0.045387425, -0.0593874, -0.011438766, 0.227945) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.02787105, -0.37036082, 0.17983803, -0.07311833, -0.047135774, 0.17222027, 0.072322644, -0.17722489, 0.031618305, 0.21335874, -0.2907563, -0.18573737, -0.04259758, 0.062166356, -0.041435752, 0.0025747602) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.27171722, -0.35418352, 0.17639309, -0.10442192, 0.028018957, 0.17112696, 0.01192938, 0.13812238, 0.019295748, -0.07904847, -0.09183915, -0.01586059, -0.0054930416, -0.02745617, -0.025699317, -0.029198565) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.038060702, 0.03625196, 0.142872, 0.15543386, -0.062858306, -0.016730646, -0.015827324, 0.024028406, 0.017403757, -0.037238155, -0.0970777, -0.099922016, 0.018351521, -0.10830009, -0.029040815, -0.10262133) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.040618025, -0.039431605, 0.12294649, 0.028797338, 0.047288314, -0.1376823, 0.044420432, -0.08405734, -0.10302289, -0.2109204, -0.31814927, 0.07595533, 0.40747702, 0.38490593, -0.1633236, 0.6117919) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05643514, -0.02312567, 0.13521843, -0.0350899, -0.0039397003, 0.06995114, 0.0039114244, 0.10965239, -0.28302893, 0.10156016, 0.06417768, 0.21915594, 0.53857356, -0.24547054, 0.24243692, -0.88471967) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.104111984, 0.2125888, -0.30988598, -0.20847517, 0.08852558, -0.027507694, -0.02412908, 0.00802092, 0.24111673, 0.29223576, -0.23813285, 0.40702853, 0.0058356407, 0.11675881, -0.022255173, 0.10326789) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.07183942, 0.33763558, -0.13143818, 0.10711682, -0.42056784, 0.46938798, 0.19731417, -0.48802432, -0.50765926, -0.46246025, -0.1868982, 0.36556336, -0.05547418, -0.52626485, 0.2896908, 0.3592719) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.21388482, -0.063739285, 0.0236812, -0.4696482, -0.023104431, -0.29248026, -0.084840834, 0.19692145, -0.11951441, 0.5695461, -0.119952075, -0.13347939, -0.08685357, -0.40127116, 0.11238646, -0.10781872) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.17631136, 0.190919, -0.35021198, -0.41489175, -0.032905605, -0.016061503, -0.05888568, -0.1049325, 0.0886434, -0.08132202, 0.13781857, -0.17302352, 0.00870941, 0.005107751, -0.03905064, 0.042764198) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.27162367, 0.09582579, -0.37236077, -0.33527967, -0.3922668, -0.6091723, -0.17420879, -0.45362163, 0.21348062, -0.13309906, -0.00050111365, -0.11118902, -0.03126042, 0.12907705, -0.04445323, 0.041103173) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.008266451, 0.18639155, -0.14122628, -0.24725743, 0.2046282, -0.14011781, 0.014821967, -0.17192036, -0.042642783, 0.03511797, -0.022717755, 0.015225819, 0.09107515, -0.07009967, -0.05214558, 0.006861897) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

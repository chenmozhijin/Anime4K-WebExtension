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

  var result: vec4f = vec4f(-0.107238956, 0.35891476, 0.48729196, 0.21954143);
      result += mat4x4<f32>(0.033037316, 0.107228085, -0.060828965, -0.06818419, -0.003526972, 0.02425116, 0.1567502, -0.024238078, 0.0149997445, 0.07706652, 0.024501909, 0.018150007, -0.02227096, -0.03328134, -0.042078804, 0.018216927) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08789365, 0.036142528, -0.12464791, -0.12029195, 0.028275285, -0.118432015, 0.08854736, -0.061617192, 0.064608626, -0.04351937, -0.005907049, -0.09888205, 0.47087908, 0.33864304, -0.13534541, 0.14257208) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.011786935, -0.12869275, -0.18527679, -0.07019632, -0.06385667, 0.021794995, -0.00955005, -0.16363606, -0.09307277, -0.032153394, 0.059046533, 0.03162958, -0.04594749, -0.20052688, -0.14436896, -0.07804414) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.009217814, 0.18099882, 0.1525521, -0.14944382, 0.11608666, -0.08386543, 0.009423038, -0.39864177, 0.13739651, -0.2064988, -0.27341977, 0.1507775, -0.1283872, -0.05119741, -0.35087597, -0.10708835) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.47737134, 0.15437, 0.34449738, -0.24731049, 0.41486043, 0.018632913, -0.15084405, -0.054033764, -0.049794003, 0.2493298, 0.044138234, -0.8242692, 0.2565392, 0.31762484, 0.07277662, -0.44946468) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11005269, -0.17133696, 0.1383688, 0.1868794, -0.007862397, 0.0034253362, -0.37617886, -0.30670592, -0.28236493, -0.115205005, 0.3573438, 0.13902064, -0.09415346, 0.032184687, -0.082168624, -0.16020401) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0043011275, -0.06345415, -0.15367934, -0.09579863, 0.025289804, -0.16889648, 0.019963803, 0.037980728, -0.09610181, -0.121437274, -0.07315523, 0.12567705, -0.18308362, -0.015243646, -0.08926049, -0.12816109) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.082250096, -0.28001425, 0.09070677, 0.3433427, 0.10134965, 0.03450847, 0.15746233, -0.2118603, -0.50630665, -0.22196917, -0.26160055, 0.77153224, -0.48033318, -0.057470877, -0.18339139, -0.36308694) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.25244382, -0.05034393, -0.3432499, -0.029176848, 0.017440464, 0.08066305, 0.05283666, -0.112515666, -0.111961015, -0.0145338755, -0.13172002, -0.012960006, -0.07781145, -0.04845224, -0.21381612, -0.11828217) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.054809075, -0.09774458, 0.06595746, -0.0420886, -0.009091999, -0.14960907, 0.010277311, 0.03661847, 0.002416865, 0.17281225, -0.009279442, -0.051091265, -0.013127292, 0.018201355, -0.10305998, -0.062205136) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.054701924, 0.19685596, -0.22610211, 0.113835715, -0.35865542, -0.11935626, -0.13490754, -0.08178527, 0.13352309, 0.106848024, 0.3090052, 0.04603226, -0.43720567, 0.2511419, 0.24248777, -0.24310288) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.23681027, 0.04700698, -0.11985816, -0.09659372, -0.0031874808, -0.0029137388, -0.015888777, 0.048433095, -0.104654215, 0.2118923, 0.4042789, -0.112141706, 0.038758747, 0.11728237, -0.18977305, 0.006997325) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10042436, -0.20560876, -0.14960928, -0.0048757927, -0.17015815, 0.04898341, -0.031138692, -0.1899111, -0.062041853, -0.06255072, 0.015114498, 0.09827477, -0.14273077, 0.0155511275, 0.1506848, 0.049669497) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.083473414, 0.11113935, -0.3471882, -0.7426181, -0.46261477, -0.5438689, -0.62123203, -0.60883534, 0.17710277, -0.28057423, 1.1724991, -0.16956007, -0.5640193, -0.49171412, -0.3470799, 0.24847546) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18016857, 0.004721609, -0.15075041, -0.25047052, -0.048340566, 0.044707123, -0.09157759, -0.14289443, 0.3491403, -0.05491011, 0.49497193, 0.15623297, 0.0722144, -0.04925802, -0.036050487, 0.10484854) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03331675, -0.06019688, -0.05510317, -0.15264946, 0.029410278, 0.08866125, -0.08237183, -0.3495715, -0.24786356, 0.048064787, 0.071327984, 0.18991654, 0.02285517, -0.0059916736, -0.005378998, -0.02073962) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0879966, -0.0826597, -0.18413694, -0.45214283, -0.07099291, 0.18281896, -0.04968678, -0.2972391, 0.1266757, -0.04559467, 0.09272433, 0.15423533, 0.13371879, 0.04663657, 0.0046742796, -0.018700417) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.014125536, -0.075809784, -0.035789613, -0.021541042, -0.12450234, -0.05360143, 0.0027416653, -0.013269928, 0.21931268, 0.03532649, 0.48571962, 0.17705992, -0.07050409, -0.073626116, -0.051987506, 0.06134899) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

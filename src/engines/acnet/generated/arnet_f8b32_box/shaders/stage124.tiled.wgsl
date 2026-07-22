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

  var result: vec4f = vec4f(0.06856784, -0.5591889, -0.22886081, 0.20838597);
      result += mat4x4<f32>(-0.1106741, 0.0413372, 0.025860418, 0.013153534, -0.0005135909, 0.0078833215, 0.0062385728, 0.14996073, -0.0018015425, -0.010870414, 0.010032947, -0.045387268, -0.0029742133, -0.056881312, 0.00026696463, -0.057196356) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.24545819, -0.40242952, -0.053291563, -0.058758177, -0.039453942, -0.28038368, -0.19576249, -0.23694198, 0.058016255, 0.029083228, 0.1030618, -0.030359782, 0.005775159, 0.1884238, 0.17168184, -0.19265752) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.074013494, 0.16289064, 0.1895, 0.0512655, -0.048788052, -0.13294394, -0.12938131, 0.051080093, 0.038966745, 0.10828528, -0.07138003, -0.009644547, 0.0029137977, 0.073172756, 0.10612938, 0.025249334) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3466563, -0.19097975, 0.0036233976, -0.30687788, -0.077318594, 0.07185715, -0.008683547, -0.1503444, -0.024982974, 0.14808965, 0.0605377, 0.072943434, 0.018525206, -0.036622502, -0.025912294, 0.036754813) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.1704918, 0.14335229, 0.27522057, -0.20307514, 0.34870148, 0.348955, -0.78807145, -0.52259237, -0.21407515, 0.2491042, -0.38844562, -0.05894261, -0.10906587, 0.57695043, 0.39356527, -0.39272887) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10571847, 0.453663, 0.01892643, 0.26618207, -0.094420545, -0.06753539, -0.10559555, -0.16974282, -0.1776709, -0.20059417, -0.08300277, -0.15081379, 0.21410929, 0.12545294, -0.03967016, -0.10216104) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.09416448, -0.024737496, -0.00040391326, -0.1394696, -0.0069182795, 0.034910604, -0.012799127, 0.03017164, 0.007433074, -0.026174618, 0.0069009494, -0.057933778, 0.019324794, -0.088909596, -0.035752732, 0.034109294) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06630759, -0.008815616, -0.29061234, -0.13741353, 0.051708173, 0.06333635, -0.34922993, -0.151231, -0.05540401, -0.0672461, -0.15849937, 0.13078624, 0.01996808, 0.14514631, -0.05766265, -0.036974743) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.008207777, 0.17735274, -0.05762945, -0.058686152, 0.020834131, 0.037973907, 0.06611647, 0.03477002, 0.01898515, 0.01350501, -0.06849284, -0.041359376, 0.050980743, 0.12954316, 0.04412899, 0.009608083) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.04895164, -0.03443829, 0.11047476, -0.1540283, -0.031364016, -0.007016811, 0.06394554, 0.12092387, -0.02216969, -0.04523069, -0.12284018, 0.08331707, -0.0041238246, -0.033731055, -0.05573768, 0.12767449) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14833112, 0.03320251, 0.17265649, 0.075395264, -0.024793103, -0.048022103, 0.0021653662, -0.14703898, -0.022871641, -0.0744181, -0.06985179, 0.07311676, 0.14879516, 0.1349529, 0.28587672, -0.30858484) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.023751473, 0.11849396, 0.05174098, 0.0905493, 0.010538566, 0.026076095, -0.016900875, 0.08544425, -0.05318262, 0.07510689, 0.09060223, 0.16072346, -0.0626097, -0.109967984, -0.17740855, 0.108255304) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.017331455, 0.065201364, 0.030302944, -0.12258469, 0.014900989, 0.38398498, -0.19893931, 0.28496042, 0.007663134, 0.0045049, 0.05535123, -0.07998822, -0.0021199947, -0.04369646, -0.040770456, 0.13192844) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13188195, 0.611665, -0.7194653, 0.05763739, 0.24069114, 0.33157015, 0.23924226, 0.28210366, 0.054040376, -0.0316192, 0.049336657, -0.099755, 0.15938936, 0.036422834, 0.94825757, 0.2942982) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.009337186, 0.29780787, 0.012106521, 0.01589094, -0.017297072, -0.18992667, -0.068264216, -0.042137723, -0.3887837, -0.28412467, 0.46415773, 0.29691362, -0.161952, 0.33353254, -0.43085182, 0.79145414) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0009179528, 0.05303799, 0.08893265, -0.019265432, 0.05632577, -0.03473804, 0.050448813, -0.100654334, -0.023560641, -0.10219335, -0.15655996, 0.11077321, -0.040271092, 0.009993579, -0.148072, 0.19995238) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.028866453, -0.03116869, -0.033656918, -0.09679215, 0.014038058, 0.016389765, 0.14858796, -0.08891551, 0.03631458, 0.03614777, 0.10368815, -0.027702086, -0.05665742, 0.034486964, 0.040914707, 0.18585196) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0032958435, -0.029818946, -0.077410914, 0.011780644, -0.044542447, -0.086850874, -0.14081034, -0.010048456, -0.12410195, -0.26685762, 0.12470257, -0.0022636554, -0.037319127, -0.03110313, -0.0011501067, 0.115381934) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

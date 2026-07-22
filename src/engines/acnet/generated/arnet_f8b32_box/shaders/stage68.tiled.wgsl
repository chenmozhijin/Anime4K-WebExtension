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

  var result: vec4f = vec4f(0.06096384, 0.0043560676, 0.18225434, -0.09137975);
      result += mat4x4<f32>(-0.023291932, -0.0011147227, 0.14235269, -0.061321586, -0.08787632, -0.09319565, -0.04961979, 0.016427461, 0.087927714, 0.14319897, -0.016069949, -0.1092897, 0.010777183, -0.08148983, 0.14453413, -0.0019541793) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.093698844, 0.15554725, -0.034615856, -0.21960282, -0.020280046, 0.07623419, 0.085119076, -0.11902708, 0.16009864, 0.33845308, -0.17124806, -0.03818743, 0.048107523, 0.0433616, -0.00993065, -0.1539827) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06647158, -0.002896684, 0.11548015, -0.077681646, 0.1310079, 0.11059969, -0.12616354, -0.15666927, 0.14320633, 0.3791451, 0.16860142, -0.12994714, 0.08767376, 0.22987886, 0.13030273, -0.18003395) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1623369, -0.026023094, 0.41366062, 0.22825903, 0.037366264, 0.061013203, -0.1323511, -0.046663295, -0.20646207, 0.15208937, 0.12002352, 0.12931198, -0.08195905, -0.009635375, 0.021839865, -0.022883268) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24372281, 0.29163015, 0.24438503, 0.13847195, 0.23554066, -0.28182262, 0.08032043, 0.0014332853, 0.23066016, -0.10116191, -0.5223873, 0.10288548, 0.07219955, -0.01800649, -0.07670883, -0.2835419) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.042962644, 0.06319311, -0.12098823, -0.17559144, 0.14897245, 0.053180955, -0.25657055, -0.023983328, 0.12902313, 0.094929226, 0.16391501, -0.021504125, 0.4511825, -0.10956332, -0.05118569, -0.29667354) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13244641, -0.053732727, -0.12870127, -0.1347696, -0.15189674, 0.06254628, -0.16605508, -0.14052236, 0.008736219, 0.050209127, 0.030314935, 0.114660226, 0.11671464, -0.0081708105, -0.18868369, -0.033447627) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.13901475, 0.116765276, -0.2970606, -0.10905987, -0.24268426, -0.005819431, -0.10817354, 0.27268597, -0.16374198, -0.14492004, 0.30845016, 0.03128642, -0.17469482, 0.26575267, -0.17573787, 0.1904034) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09023766, 0.25515828, 0.056709263, -0.08863236, 0.103207864, -0.10608732, -0.26230204, -0.085528985, 0.03265579, -0.070327714, 0.3010342, -0.10405288, -0.0066056047, -0.053273614, 0.23768498, -0.09264274) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07288676, 0.04184012, -0.024219686, -0.07225997, 0.059976894, 0.11888925, 0.040018845, -0.2048806, 0.0024960192, 0.030752577, -0.20445901, 0.11230593, -0.07722092, -0.04699519, 0.17840442, 0.10563037) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.15398318, 0.11609974, -0.12588564, -0.08230279, -0.042423848, 0.12671591, -0.032495905, -0.21364273, 0.21582997, 0.36641026, 0.14426774, -0.016287612, -0.20825362, 0.052446757, 0.34315774, -0.119024) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.069980495, 0.0041119438, 0.05521328, -0.05054422, -0.034422822, -0.13820185, 0.110664956, 0.08499016, -0.06457487, -0.2698092, -0.087122016, 0.27190703, -0.046573967, -0.014405588, -0.07490404, -0.038993828) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.063202985, -0.0694579, 0.072877, -0.049377505, -0.040476244, 0.1478148, 0.06744382, 0.25691906, -0.18499263, -0.23027351, -0.22355855, -0.06560049, -0.077138625, -0.07547022, -0.07493841, -0.50545335) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14344543, 0.31347317, -0.29849693, -0.31359747, 0.14169562, 0.50101316, -0.06337063, -0.16102853, 0.1389958, 0.040510807, 0.14185998, 0.16615203, 0.33182967, -0.36891347, -0.45945948, -0.18314347) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14181389, 0.16214976, -0.18824749, -0.280582, 0.06970729, -0.076780505, -0.03371255, -0.06311166, -0.1779014, -0.15744072, 0.33492038, 0.1279089, 0.17147632, 0.12829436, -0.48695064, -0.040228352) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04480632, -0.073558636, -0.2421131, -0.06593561, 0.12942249, 0.4241853, -0.18615806, -0.029969705, 0.038944818, 0.05813128, -0.1791645, -0.051507432, -0.18405357, -0.10032666, 0.012520917, 0.3423826) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2234212, -0.009985884, -0.59751594, -0.36302593, -0.08961509, 0.32571384, 0.8398098, -0.3670324, -0.0665335, -0.066234484, 0.15384546, 0.16188394, -0.37746805, -0.23917551, 0.22710347, -0.34434307) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16144802, 0.27254692, 0.015560698, -0.001284318, -0.088271216, 0.14592867, 0.19017418, -0.04408117, -0.12154656, -0.40199515, 0.023300106, 0.1161655, -0.13541698, -0.06028824, 0.05337058, -0.021258157) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

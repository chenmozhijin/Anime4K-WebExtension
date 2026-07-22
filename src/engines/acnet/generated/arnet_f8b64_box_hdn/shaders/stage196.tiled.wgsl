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

  var result: vec4f = vec4f(-0.019497711, 0.38969955, 0.7979029, 0.30025324);
      result += mat4x4<f32>(0.041702073, 0.14533943, -0.06525871, -0.08564942, 0.113580704, -0.051916808, 0.04454592, 0.21786393, -0.12843068, 0.004406052, -0.02390552, 0.06130717, -0.052447654, 0.07768289, -0.038499556, -0.0867965) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.044279013, 0.053319465, -0.25117752, -0.06870814, 0.014640479, 0.06280421, 0.23821293, 0.25362834, -0.038421385, 0.019001238, -0.0031408216, -0.14751254, 0.5595292, 0.53329325, -0.18302631, 0.3381268) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.01033203, -0.06510098, -0.20330252, 0.04985086, 0.047489606, 0.044505633, 0.07174583, 0.17266613, 0.09565088, -0.032136776, 0.13317926, -0.04539026, -0.07526281, -0.0863212, 0.002307836, -0.110641986) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.049412884, 0.11338266, -0.05661342, -0.05512497, -0.013952662, 0.098829456, 0.09041903, 0.14481612, 0.07587492, -0.33785406, -0.27847508, 0.23015799, 0.059767034, -0.095493205, -0.09809423, 0.09762118) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.74149626, 0.11031895, 0.30338463, -0.2797871, 0.13893501, -0.6112761, 0.659482, -0.17089126, -0.10938614, 0.36823985, -0.13526636, -0.97979707, 0.4433044, 0.16612673, 0.46671897, -0.520924) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18474767, -0.25819412, -0.0612247, 0.04223601, 0.19411843, 0.020514145, 0.12251346, 0.052994926, -0.34063345, 0.06441666, 0.3254573, 0.057485122, 0.0843212, 0.07851977, -0.11081216, 0.09620704) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.013471763, -0.019107122, -0.15876739, -0.017290222, 0.05190636, 0.022191754, -0.0031689482, 0.10485201, -0.13091464, -0.2635996, -0.092236504, 0.097571, 0.030272914, -0.07965702, -0.07450574, -0.00430143) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.030871982, -0.32438132, 0.021874385, 0.5068891, 0.16231966, 0.052375764, 0.14090435, 0.06610339, -0.49108535, -0.3236113, -0.5811491, 0.54815114, -0.22881004, -0.09318469, -0.2174748, -0.2508351) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.23926456, 0.08022163, -0.24673478, 0.04182611, 0.06650109, 0.044167597, -0.053684097, 0.037526723, -0.08087805, -0.08586929, -0.24718153, -0.11745452, -0.101750135, -0.09502017, -0.13557866, 0.0051991343) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.09218735, -0.29474074, 0.05416771, 0.10646619, 0.025819367, -0.1356697, -0.057676435, 0.042025667, 0.11457455, 0.15333739, -0.050003573, 0.20591898, -0.058705363, 0.060514696, -0.02673877, -0.0625849) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.25598225, -0.110183485, -0.1666559, 0.4190383, -0.24357003, -0.1282412, 0.02780849, 0.071560465, 0.17051637, -0.020440377, 0.42127135, 0.104450144, -0.57060635, 0.3028512, 0.37296575, -0.55560434) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.26332906, 0.1542877, 0.005761346, -0.21278383, 0.032461736, -0.015662506, -0.025868384, 0.016533723, -0.4753436, -0.018774062, 0.34669816, -0.3549552, 0.060537223, 0.09150121, -0.26527086, 0.013991126) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.11932586, -0.22295043, -0.16649365, 0.19944611, -0.21505368, 0.14079605, -0.015493418, -0.33182326, 0.1252781, 0.0844109, 0.19643445, 0.27112213, -0.112509266, 0.072220124, -0.011719659, -0.28227302) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.011314158, 0.139167, -0.48096633, -0.63060445, -0.47330585, -0.59889823, -0.6274617, -0.6371835, 0.3398266, -0.24002713, 1.6215614, 0.2599391, -0.6572356, -0.39512223, -0.33705613, 0.16776206) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1271465, 0.24865134, -0.015102497, -0.27159876, -0.055683542, -0.026741188, -0.05678811, -0.036499098, 0.29169092, -0.2673757, 0.29595548, 0.38662675, 0.095861554, -0.065180585, -0.12848717, 0.08298905) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10481448, -0.041586455, 0.065160885, -0.08330838, -0.044255286, 0.13650557, -0.017853646, -0.12950969, 0.12807871, 0.17614721, 0.1577749, 0.52360237, 0.011429422, 0.0016350591, -0.05859968, 0.06342822) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.020093802, 0.0052772816, -0.12520613, -0.47673833, 0.056737397, 0.158135, -0.015433104, -0.09933746, 0.117061965, 0.14312914, 0.24456142, 0.13353579, 0.011399316, 0.019179864, 0.09067732, 0.107621364) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0967959, 0.02769983, -0.059528347, -0.020527434, -0.109883755, -0.04328569, -0.07853928, 0.0075724637, 0.2259653, 0.03928313, 0.76231533, 0.3863791, 0.07254084, -0.015948609, 0.059364095, 0.019868508) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

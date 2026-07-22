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

  var result: vec4f = vec4f(-0.21641374, 0.3513004, -0.050302282, 0.36743525);
      result += mat4x4<f32>(0.018448442, -0.04201238, -0.06267801, -0.018584399, 0.029867616, 0.12660366, -0.16336119, 0.088144444, 0.013740139, -0.024499036, 0.16176222, 0.015999615, 0.090583384, -0.055862952, -0.06106708, -0.053145617) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09425509, 0.041285608, -0.15152094, 0.058305085, 0.18390235, 0.018867964, 0.05432312, 0.064590156, 0.09898865, -0.055677876, 0.19910134, -0.03782533, -0.5680826, 0.18626289, 0.1580019, -0.054896317) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.019869031, 0.03134374, -0.05712412, 0.05199262, 0.17683357, -0.15906188, 0.14677319, 0.025972398, 0.06669529, -0.08387306, 0.14151299, -0.030461567, 0.09387403, -0.14074257, -0.07902155, -0.076747924) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.090139404, 0.09952553, -0.17849849, 0.038991887, 0.1984156, 0.08719925, 0.22627886, 0.045661744, 0.022172373, -0.0743487, 0.2595455, -0.025456725, 0.2442494, -0.29518467, -0.010328771, -0.13489297) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0053968583, 0.10979655, -0.1567392, 0.1645663, 0.3737765, 0.27548835, 0.21450436, -0.2633263, 0.043615855, -0.27328944, 0.39395323, 0.024689779, -0.5883201, -0.08784366, -0.4628493, -0.10569743) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.049598705, 0.062797956, -0.24347578, 0.0026482947, 0.34107628, 0.1822283, 0.35860673, 0.041963253, 0.029503955, -0.1733145, 0.2844794, 0.026376145, 0.024707504, -0.633117, -0.22554244, 0.035850435) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.038763985, 0.016262865, -0.07309393, 0.0137994345, 0.18705104, -0.008640602, -0.06966038, -0.032249358, -0.009638552, -0.077742994, 0.19408675, -0.014321609, -0.05015279, -0.17970496, 0.045816585, 0.088271156) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.047223788, 0.15394333, -0.14545089, 0.016666844, 0.2375075, -0.080816254, 0.32912496, 0.04446297, 0.04249604, -0.17169142, 0.29887685, -0.01115325, -0.62752646, -0.23340091, 0.11410717, 0.21111046) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.042378545, -0.03420133, -0.114535354, -0.0039524254, 0.059862074, 0.75817716, 0.052794, -0.00625834, 0.038313624, -0.14289467, 0.17423533, -0.00061524555, -0.15869913, -0.30599153, 0.031576466, 0.057263203) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.3515347, -0.20122766, 0.019577054, -0.13605605, -0.024083508, 0.003860932, 0.11444493, 0.0043673455, -0.13175423, 0.07544759, -0.04250848, -0.0266235, 0.11029889, -0.0618604, -0.020986384, 0.05991988) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12246291, 0.12276669, 0.072242945, -0.07155461, 0.019721344, -0.046961095, 0.1623953, -0.019649154, -0.13776173, 0.020039462, -0.098336376, 0.051503446, 0.1875311, -0.1147725, -0.09809481, -0.0060774786) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.040440165, -0.07970817, 0.067616984, -0.056615513, 0.00018158313, -0.025738131, 0.10988582, -0.046839356, -0.19383994, 0.16302598, 0.049963884, 0.016429858, 0.32007873, -0.18970081, -0.1320536, -0.1330545) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.01747095, -0.1368927, 0.074316144, 0.7527368, -0.018305304, -0.09774609, 0.21113776, 0.011163254, -0.32436484, 0.18013932, 0.061320204, 0.0381314, 0.25510108, -0.09928565, -0.06652782, 0.039214574) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.31398532, 0.3239519, 0.14959496, -0.06431305, -0.0036610942, -0.17113745, 0.23827796, -0.041658968, -0.21319246, 0.5005625, 0.23948187, -0.078309946, 0.020591816, -0.2848527, -0.3777937, 0.049470447) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.022361906, -0.42635062, -0.0047620353, 0.27561057, -0.014804208, -0.1470742, 0.20584325, -0.03305654, -0.13693091, -0.18987703, 0.2389197, -0.009382525, 0.21972075, -0.24136193, -0.32440743, -0.055800885) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.2539125, -0.17223012, -0.18203235, -0.09117614, -0.0362073, -0.038748473, 0.120025426, -0.01804935, -0.2504751, 0.043177463, 0.031207142, 0.049779825, 0.14197482, 0.03411407, -0.07958929, 0.02159565) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.025019124, -0.028864332, 0.022075854, -0.24499889, -0.07583696, -0.12079446, 0.19452256, 0.02824183, -0.42988545, -0.011827317, 0.31088334, 0.11089103, 0.0011502131, 0.0859508, -0.19509986, -0.020053817) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.053817693, -0.1392875, 0.037422553, 0.021449208, 0.04324549, -0.073978394, 0.13453579, -0.013271871, -0.2174061, 0.061333407, 0.08781561, -0.025179602, 0.13153706, 0.18533477, -0.16375658, -0.14305809) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

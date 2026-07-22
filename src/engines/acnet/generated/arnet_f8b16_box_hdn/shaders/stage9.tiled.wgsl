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

  var result: vec4f = vec4f(-0.035085972, 0.17764004, -0.04278281, 0.37887162);
      result += mat4x4<f32>(-0.06837565, -0.10719444, -0.03383659, 0.023471046, 0.044216484, 0.018391399, -0.01214762, -0.064365424, -0.041518446, -0.025942104, -0.20055452, 0.060579453, -0.12436818, -0.03858922, -0.06526994, -0.022976385) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.23703572, 0.1430152, 0.040680245, -0.033556886, -0.2563112, -0.11152613, 0.0019854256, -0.14500251, 0.2480844, -0.55934197, -0.36035708, -0.3709709, -0.22879554, 0.11059356, -0.011557043, 0.2577368) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15130861, 0.031992197, 0.11107997, -0.027085502, -0.031012606, 0.17820555, 0.024715409, -0.14249884, -0.33544734, 0.055488113, -0.044054065, -0.08070949, -0.048620507, -0.19549759, -0.12230077, 0.038830694) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14289796, -0.029700696, 0.007472237, 0.09996743, -0.23494458, 0.0052257893, -0.020126637, -0.020959549, 0.024461264, -0.17760333, -0.22307108, -0.09105069, -0.03545323, -0.0191734, -0.031392977, -0.09617654) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.37061983, 0.0019012123, -0.23173709, -0.39134854, 0.8849951, 1.2955468, 1.1042389, 0.48114505, 0.40323007, -0.3266437, 0.035647, -0.0034515134, 0.13430138, -0.6087896, 0.20492738, -0.90329057) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12466486, -0.25637957, -0.13555944, 0.24962024, -0.16517591, 0.051256523, -0.30400607, -0.1778583, -0.16662638, 0.39753187, -0.009431265, -0.2863523, 0.24428323, 0.3961192, 0.12784867, 0.3294323) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.051068313, 0.052262884, 0.00094740646, 0.15315692, -0.007787098, 0.0033941828, -0.1718406, 0.016418835, 0.015335138, -0.058150474, 0.004134438, -0.062514625, 0.018648256, 0.022312084, -0.001620472, -0.029175045) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4966296, -0.07720782, -0.060944278, 0.23439693, 0.061335273, -0.060014784, -0.072832115, -0.1346578, 0.66819257, 0.11676236, -0.24681067, -0.20085238, 0.1281391, 0.10916259, 0.06560015, 0.024774011) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08195615, -0.101979434, -0.30221432, -0.24097958, -0.0115967095, -0.21902691, -0.10143772, 0.008033219, 0.16259499, 0.37222186, 0.2494392, 0.2719877, -0.12177425, -0.11724893, 0.041033056, 0.07738773) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.056909084, 0.39642856, 0.09899274, 0.0037272174, 0.05654359, -0.28273496, 0.14800242, -0.018128758, 0.051205806, -0.15536427, 0.013758809, -0.09804742, -0.08722212, -0.02329153, -0.20555083, -0.09223399) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.073756315, 0.5945727, 0.32140157, 0.110856324, -0.17323565, -0.42195994, -0.17540658, -0.15254417, 0.24567808, -0.088905044, 0.06485444, -0.07945481, 0.44522697, 0.07945188, -0.0067244875, -0.01056628) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12904795, 0.007935884, 0.028068267, -0.067010514, 0.1679741, -0.03451655, 0.122150704, -0.077822626, 0.014457984, -0.0226439, -0.083445914, 0.017319588, 0.02470793, 0.1607346, 0.017594548, -0.05143163) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3315961, 0.6210945, 0.3794043, 0.14219487, -0.048584186, -0.25178877, 0.02566647, -0.26044974, 0.046615914, 0.08124403, 0.038232926, -0.047678042, -0.085667394, 0.06375324, -0.15255134, 0.1795524) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21556692, 0.4153789, -0.0051718485, 0.04675171, -0.39223486, -0.18593527, -0.7001517, -0.38391614, 0.52074444, -0.13839047, -0.02368674, -0.4228353, -0.5815649, -0.1729456, -0.09926857, 0.500007) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13177274, -0.1420205, -0.17445931, -0.22065103, -0.12956136, -0.39880255, 0.015521815, -0.17530467, 0.07850183, -0.036843028, 0.15841715, -0.11471753, -0.35296264, 0.23220913, -0.4065163, -0.2518444) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.20752952, 0.17505936, -0.16423273, -0.45889878, -0.04965533, 0.042800963, -0.01548625, 0.030024594, -0.016351081, -0.005818884, -0.07014746, 0.0443956, 0.05569595, -0.070846885, 0.055195156, -0.016053436) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.8022677, -0.051160485, -0.25859383, -0.649494, -0.10027906, -0.058471423, -0.0121748755, 0.22435707, 0.064230934, -0.02451892, -0.6107556, -0.4910611, -0.06267428, -0.011812357, 0.117436744, 0.03489044) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.103983134, -0.13532943, -0.0772831, -0.21380301, 0.058402766, 0.16113946, 0.1378732, 0.31624195, -0.08451306, -0.03295505, 0.12028839, -0.02099977, -0.0038673815, 0.21594058, 0.037584946, -0.1899227) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

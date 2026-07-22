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

  var result: vec4f = vec4f(-0.07116954, -0.23047812, -0.21857503, 0.2239036);
      result += mat4x4<f32>(0.093036376, -0.06333122, -0.030113997, 0.03777817, -0.0834625, -0.026405077, -0.22786607, -0.030985266, 0.03238034, -0.051737987, 0.13806954, -0.0068638017, 0.04384229, -0.11581952, -0.039990373, 0.24159314) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.027896836, -0.05600649, 0.07065579, -0.0072037755, -0.072176196, -0.021090785, -0.12406127, 0.11636061, 0.017957011, 0.0025914183, 0.13372622, -0.047849894, 0.30879828, -0.62432986, -0.12226929, 0.32927516) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04941276, -0.022551525, 0.10396289, -0.06972986, -0.026302902, -0.13773972, -0.0713284, 0.046768587, -0.030152492, 0.0022485673, -0.044565655, 0.1078943, -0.06624268, -0.21414404, -0.09023519, -0.04738486) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.051534478, 0.06421393, -0.059191626, 0.070099995, -0.015618132, -0.037914976, -0.10472182, 0.09291556, -0.108235225, -0.012861943, 0.21238744, -0.024598425, -0.031634957, -0.07231284, 0.103873335, 0.10151361) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17620257, 0.15451024, 0.05080237, 0.056936163, -0.62387425, -0.43186793, -0.32424653, -0.23173723, 0.23570833, -0.16958933, -0.13960601, 0.017636547, 0.021760093, 0.021531455, -0.4827928, 0.014741515) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08394263, 0.292353, 0.035723183, -0.2917627, -0.059010103, -0.08115257, -0.0630199, -0.022969754, 0.008195028, -0.38311672, 0.30401927, 0.3220078, 0.012051472, -0.013624676, -0.39494482, 0.5410794) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05264776, 0.056587134, 0.12748149, -0.0900738, -0.038108617, 0.021060908, -0.09391204, 0.009896788, 0.004348042, 0.033210892, 0.37344423, -0.1303038, -0.0032416831, -0.047553673, 0.0042838976, 0.17823201) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2128488, -0.061684158, -0.22868493, -0.046889927, -0.065316364, -0.073263325, -0.03223161, -0.0006000651, -0.29032418, -0.13198587, -0.6048502, 0.2995527, -0.06019299, 0.21644554, -0.06517583, 0.33630365) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07542767, 0.17560051, 0.020004006, -0.44353017, -0.0029583622, -0.038998254, -0.16001204, 0.011140774, -0.14527497, -0.04843644, 0.0038454758, -0.0451024, -0.06043826, -0.08091673, -0.10914506, 0.32715842) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.18879257, 0.07169114, 0.07973288, -0.12321809, -0.04759212, -0.11483043, -0.021862945, 0.042393647, 0.15449409, 0.34868646, -0.037021026, 0.12786178, 0.03081577, 0.070135675, -0.08510214, 0.076269396) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.045395352, 0.30478773, -0.2665484, -0.5507841, 0.0093796635, 0.13783559, -0.16260852, 0.07401138, -0.121510945, 0.0032967052, -0.21882072, 0.13143916, 0.12546559, 0.24573904, -0.36114866, 0.24293283) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13828003, 0.12249123, -0.23697133, -0.11969476, 0.061305918, -0.0004890519, -0.045865916, 0.07339247, -0.18607628, -0.047314115, 0.2839298, -0.07635502, -0.04090752, -0.036362164, -0.35283503, -0.05716097) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.18640177, 0.11004124, -0.13762054, -0.13428754, -0.018830102, 0.06266222, -0.37530908, 0.06425545, 0.11818569, 0.38615698, 0.08173897, 0.37490886, 0.092156656, 0.0146717625, -0.025133608, 0.09491984) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21012345, -0.29705748, -0.67640716, 0.3109671, -0.20039763, 0.917711, -0.08367253, 0.02304562, -0.809732, -0.6268256, -0.22256085, -0.5293232, 0.021482272, 0.4515949, 0.4028572, -0.2839567) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13260934, -0.21931368, 0.2608045, -0.06629386, 0.0913123, 0.01509827, 0.09169343, -0.048407886, -0.35728976, -0.26177317, 0.02149465, -0.21610248, 0.0045785024, 0.20823881, -0.29997295, 0.023369975) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03966452, 0.14060259, 0.018637476, -0.07947473, -0.0050037093, 0.04998865, 0.0037004105, -0.045600727, 0.02794875, 0.21411763, -0.30841342, 0.34590083, 0.023664737, -0.083690695, 0.010758902, 0.058255944) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.016335368, 0.051237047, 0.24574797, 0.049087763, -0.03206047, -0.1681336, 0.1664785, -0.08861146, -0.053039648, 0.3908945, -0.16753913, 0.24936183, 0.029307354, -0.082429536, -0.007843861, -0.06720715) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.030259224, -0.043285135, 0.10419971, -0.045194134, -0.02888332, -0.054531578, 0.18989459, 0.033248663, -0.13502754, -0.052524388, 0.0072875256, 0.08528244, 0.007276555, 0.066003576, -0.09539447, 0.08784802) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

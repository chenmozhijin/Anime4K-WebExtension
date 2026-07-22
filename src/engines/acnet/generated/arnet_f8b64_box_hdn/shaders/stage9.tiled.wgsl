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

  var result: vec4f = vec4f(-0.2991172, 0.0704149, 0.24161386, -0.19189686);
      result += mat4x4<f32>(-0.04067485, 0.074875705, -0.16375062, -0.16855937, 0.08181458, -0.033867486, 0.100507066, -0.04419375, 0.0021707818, 0.077921964, 0.12198813, -0.055452988, 0.028768703, 0.05728487, -0.014487926, -0.029276315) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06796711, -0.19660875, -0.3286669, -0.011581943, 0.009563517, 0.002024706, 0.20940582, -0.07397094, -0.00034392986, 0.21632837, 0.052565187, -0.39864713, 0.026481671, 0.16297254, -0.50982034, -0.07671231) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08157391, -0.036907017, -0.11107961, -0.10530163, -0.08875901, -0.051057465, -0.07466156, -0.122414455, -0.03337746, -0.005298643, -0.03195985, -0.17683774, -0.018664936, 0.08438968, -0.13745013, -0.08723262) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.36378556, 0.34229487, 0.30914903, -0.49478072, 0.066913664, -0.15009578, -0.12284871, 0.14545628, 0.26426786, -0.6372371, -0.32379875, 0.58130234, 0.13113445, 0.12921676, -0.08963019, -0.030599691) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.65238965, 0.3081433, 0.3204614, -0.23011753, 0.113031715, 0.13400629, 0.023782654, 0.2884611, 0.6682795, -0.7829122, -0.18481143, 0.35288078, -0.04823734, 0.4409908, -1.6312592, -0.2470622) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18386826, 0.36295217, 0.20569901, 0.01606503, -0.09403262, 0.15379354, 0.05292967, -0.12902224, 0.28105894, -0.57355016, -0.10071796, 0.07940286, -0.043789707, 0.08665005, -0.11786381, -0.15590145) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.102953374, -0.22986369, -0.013320296, -0.0020938013, 0.040545996, -0.0827863, -0.071231164, 0.053864982, -0.057971004, 0.27139968, 0.05661627, -0.1812111, 0.004369515, 0.10360363, 0.007522366, -0.15454347) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.06824055, -0.3242024, 0.017765282, -0.15870711, -0.15670376, -0.06144844, -0.12758453, 0.10713661, -0.005912711, 0.6467842, 0.15957798, -0.18245773, -0.23098561, -0.20625128, -0.4823411, -0.047198463) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04510367, -0.09846774, 0.00091257464, 0.07879132, -0.22343355, -0.030208819, -0.02609054, 0.05672002, 0.10034357, -0.098243795, 0.06408544, -0.097011186, -0.01512234, -0.10655217, -0.08569678, -0.13213372) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.06671415, -0.031180706, 0.013933769, 0.094970785, 0.023689384, -0.09677992, -0.1661321, 0.070786156, -0.0771471, -0.15591425, -0.21547359, -0.07295791, -0.32777894, 0.3972808, -0.16179492, -0.18418622) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3085479, -0.49045688, 0.7163689, 0.2541751, -0.11157511, -0.066816084, 0.2975688, 0.030954022, 0.06959359, 0.19430594, 0.44171065, 0.10244537, 0.06376118, 0.3409454, -0.3813671, -0.028046185) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05618653, -0.106635034, -0.44162837, -0.059046276, -0.09907667, -0.22438951, -0.44188115, -0.28220853, 0.037343424, -0.20378824, -0.3866024, -0.2247678, 0.08807405, -0.32109258, -0.5232493, 0.1441745) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.000450195, 0.027683461, 0.032447696, -0.046197146, -0.09334834, -0.044958334, 0.1247189, -0.12884104, 0.19722131, -0.38073993, -0.05864524, 0.0023569048, -0.14874013, 0.23954357, 0.0034329083, -0.23048055) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20321457, -0.49976438, -0.67800707, 0.8527674, -0.06290394, -0.45147598, 0.25577012, 0.2676911, -0.272489, -0.22732598, 0.22551192, -0.108150385, 0.24341102, 0.14902493, 0.14712253, 0.15074407) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30202436, -0.81500024, -0.12959418, 0.2992884, 0.11685389, -0.22871391, -0.04614393, 0.090534315, 0.017261613, 0.41612542, 0.18679473, 0.08778739, 0.26597565, -0.34555227, -0.040865302, 0.21252778) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.068549566, 0.044269055, -0.029444115, 0.011129312, -0.22275916, -0.3544569, -0.13069424, 0.09322606, -0.11860268, -0.019826336, 0.20557751, -0.46892598, 0.032263692, 0.29469785, 0.30648848, -0.35320628) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.079279676, -0.0073420727, -0.383268, 0.16482669, -0.06371397, 0.17587553, 0.4202361, -0.6038722, -0.15189058, -0.3350405, -0.52092713, 0.05944593, 0.28862727, 0.10270763, 0.26043034, -0.33602443) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.14420502, 0.15447916, 0.19657001, 0.2784051, -0.44085428, -0.2207736, -0.27839935, -0.31946772, 0.011513659, -0.19973104, 0.03810493, -0.0034400194, 0.4126599, -0.23723164, 0.21124667, -0.042696685) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

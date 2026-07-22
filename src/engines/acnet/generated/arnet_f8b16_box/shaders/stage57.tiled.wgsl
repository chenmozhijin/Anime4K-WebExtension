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

  var result: vec4f = vec4f(-0.057907976, -0.8482248, -0.07184097, 0.114823684);
      result += mat4x4<f32>(0.064898565, 0.1383549, 0.0047343588, -0.04471427, 0.20775832, -0.029666923, 0.06578295, 0.08923786, -0.12530747, -0.008901441, -0.023161765, 0.08594896, -0.11354158, -0.095098786, -0.13434212, 0.0028079683) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16331185, 0.21424395, 0.09471821, -0.108179264, 0.1350444, -0.038382564, 0.12230523, 0.04230324, -0.06954894, 0.15328217, 0.034529142, -0.04546665, -0.15282702, 0.113397636, -0.17782214, 0.19755268) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.019800698, -0.011556714, 0.1055101, 0.20117994, 0.018699985, -0.10716026, 0.056865, 0.099205844, 0.018716257, 0.18762091, 0.0091167195, 0.11516654, 0.045211468, 0.02484059, 0.056058347, 0.099416696) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2723329, 0.1500713, -0.031429533, -0.07835568, -0.06786393, 0.096048005, 0.20656946, -0.0892609, -0.06935987, -0.025454752, 0.0637717, 0.05202718, -0.004922317, -0.06769008, -0.05419445, 0.1131732) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18335047, -0.28148583, 0.041323893, -0.42858222, 0.33529055, 0.6084374, 0.07874062, -0.7080247, -0.6504106, 0.55801207, 0.47666186, -0.13134766, 0.3521706, 0.454742, 0.4090221, 0.0023070858) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.39018363, -0.0028738086, -0.11077965, 0.24071422, 0.17570452, -0.017222542, 0.06401719, 0.10209268, -0.3382067, 0.030003332, 0.041268844, 0.31868556, -0.40412158, -0.066420004, -0.26965985, -0.0995258) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.036529884, 0.036270924, -0.03088603, 0.15235695, -0.0057439557, 0.007231528, -0.05231068, -0.054960772, -0.057448592, -0.037262715, -0.009938545, -0.0022714555, 0.036234785, -0.06294833, -0.014571351, -0.004982476) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.018040795, 0.276144, -0.06191796, 0.11289202, 0.082555056, -0.17648998, 0.087461844, 0.053023107, -0.042921465, -0.09362127, -0.010238753, -0.04354883, -0.15441617, -0.210759, -0.020258153, -0.018974124) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.19240925, -0.009623242, -0.12077932, 0.10326551, 0.11228397, -0.027513413, 0.031556394, 0.0704512, -0.010238425, -0.13143808, 0.027336778, 0.030801412, 0.036738962, 0.12040521, -0.029113796, -0.034072522) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.00201346, 0.06597398, 0.05004047, -0.15520868, 0.12703203, -0.06673811, -0.024021098, -0.06675491, 0.022643205, -0.031080164, 0.031290714, -0.036732897, 0.07913832, -0.032867372, 0.022064988, 0.0044290232) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16194665, 0.011301014, 0.0625416, -0.16985826, -0.16214517, -0.20864293, 0.044690657, 0.12587653, 0.12041255, -0.056165244, -0.013827361, -0.024201183, 0.31322035, -0.085083015, 0.19507027, 0.082987234) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.029957876, -0.070675805, 0.048625816, -0.10478771, 0.07981106, -0.014917314, 0.017261092, 0.013665748, -0.111861214, -0.052599538, -0.12830016, -0.019506741, 0.05484697, -0.05738552, 0.16461931, -0.0077737486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09615585, -0.11786231, 0.0018198042, -0.005633461, 0.05160804, 0.11070544, -0.008346003, 0.019802522, 0.07758301, -0.116629586, 0.01055397, -0.003848719, -0.20395054, -0.023157747, 0.08331625, -0.10709778) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3293158, 0.15952167, -0.13414867, 0.28222835, 0.44902495, 0.6357415, -0.34864634, -0.19017982, 0.020421343, -0.08447334, -0.09452873, 0.2719819, 0.02229547, 0.23330484, -0.30888698, 0.43131083) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.023151405, 0.6887723, -0.105332, 0.34527567, -0.13171074, -0.021413287, 0.03960014, 0.22253664, 0.70176727, 0.020326154, 0.4003046, -0.36463445, -0.35196742, 0.021893991, 0.00033611158, 0.3095652) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.19016264, 0.053367663, 0.039145797, -0.17353824, -0.021107629, 0.024740087, 0.057041395, 0.05766605, -0.01996353, 0.008799508, 0.0027830552, -0.027039051, 0.1906127, 0.012046796, 0.015652796, 0.29789838) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.14699231, -0.01757907, -0.007855342, -0.24590787, -0.1477601, 0.104015484, -0.04507854, -0.08691047, 0.12449883, 0.06311396, -0.020530699, -0.002772239, -0.01467942, 0.03282395, -0.0062141987, 0.32791135) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12195938, 0.12792301, -0.16853626, 0.065766364, 0.1062576, -0.056556657, 0.0508328, -0.0564345, -0.04319522, -0.13907646, 0.020665409, -0.021437585, -0.06220423, -0.06708397, 0.030223414, -0.0848076) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

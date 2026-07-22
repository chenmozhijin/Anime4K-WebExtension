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

  var result: vec4f = vec4f(0.10042002, 0.102552325, 0.2836186, -0.22400254);
      result += mat4x4<f32>(-0.16677636, 0.0992519, 0.08444601, -0.1761319, 0.041027643, 0.05180204, 0.013490076, 0.016910266, 0.038039856, 0.050152354, -0.027819132, 0.005086068, -0.07861849, 0.010540091, 0.11203161, -0.053718034) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1287941, -0.12940085, -0.015238018, -0.05488526, -0.12971172, -0.0071756435, 0.11749861, 0.057886474, 0.0071140216, -0.20785788, -0.46780688, -0.2074846, 0.10951035, 0.026676914, 0.16758798, -0.028469073) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.052368574, -0.03721243, -0.039268497, -0.059762042, 0.024804058, 0.1288328, 0.1054675, -0.029976172, -0.20262332, -0.012228623, -0.024461702, -0.24980521, 0.098801576, 0.07141257, 0.25443885, 0.30092618) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07168214, 0.14447078, 0.15108214, -0.53828675, -0.03968463, 0.169764, 0.112334184, -0.0014610077, 0.063310735, 0.020253293, -0.24108085, -0.08154653, -0.039626703, -0.08616387, -0.048032057, 0.20830703) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14942648, -0.37240294, -0.32760134, 0.00015171582, -0.0107072275, -0.015301291, -0.013564255, 0.6590845, -0.1365487, -0.23812833, -0.96057564, 0.18341793, -0.10238024, 0.51386833, 0.4163464, 0.11945363) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.117099956, -0.22752059, -0.11852284, -0.018817196, -0.21170355, -0.40647724, -0.42242694, -0.26437783, -0.26525408, -0.43034366, -0.6790078, -0.44168034, -0.29711145, 0.094460696, 0.23460345, 0.24670857) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.054109953, 0.009039539, -0.022966377, -0.1797664, 0.04290451, 0.12638263, -0.0432268, -0.15450102, 0.11255881, -0.06166307, 0.009619771, 0.15095843, 0.037884995, 0.03435842, -0.009066221, -0.1268105) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15824626, -0.3060441, -0.31562254, 0.27763328, -0.14897634, -0.014110539, 0.09731376, 0.331157, 0.09321931, -0.07497421, -0.07381951, 0.24719006, -0.17551066, 0.1085853, 0.019373782, -0.023538692) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15467945, -0.1412819, -0.0340472, 0.20967916, -0.023514558, -0.04157932, -0.110123724, -0.045447722, -0.06832421, -0.049967673, 0.079614416, -0.048682686, -0.12896976, 0.12586868, 0.12701029, -0.0011378687) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.046704166, -0.08068177, 0.044341363, 0.2341286, 0.0495862, 0.1577826, 0.13736102, -0.10624674, 0.020596672, -0.09517816, -0.09758784, -0.023214981, 0.2908206, 0.1046383, -0.05563132, 0.53026736) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.03399093, 0.06935065, 0.026834354, -0.1150325, -0.200947, 0.02267421, 0.081665516, 0.29432374, 0.13891742, 0.12401171, 0.13052665, 0.4446886, 0.12471199, 0.15141244, 0.3820356, 0.03223888) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.02335416, 0.10785045, 0.121902645, -0.06672897, -0.20827562, -0.13871324, -0.14278845, 0.014267899, -0.09787549, -0.06730757, 0.10697495, 0.025576847, -0.031166198, 0.07936921, 0.009229355, -0.10158704) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1686968, -0.21583478, -0.20085794, 0.26081172, 0.044313144, -0.26072854, -0.12599707, 0.38410142, -0.26552802, 0.20376995, 0.4010093, -0.310348, -0.008276567, 0.15723392, 0.21635337, 0.32709983) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17950477, 0.3781802, 0.49065563, 0.14209233, -0.6645877, -0.42988342, -0.37402433, -0.14726196, -0.4990572, -0.36205688, -0.40148795, -0.74182886, 0.07178382, 0.0719023, 0.09377552, -0.102954954) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0018491228, 0.18878208, 0.17889176, 0.11087643, 0.10684619, 0.17229818, 0.18994105, 0.013763267, 0.041441593, 0.1015099, 0.14072362, -0.041987754, -0.12711272, 0.09904491, 0.10047498, -0.17054072) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11055125, 0.013402017, 0.01664987, 0.22840689, -0.2047353, -0.16675524, -0.0073212786, 0.27118647, -0.08518804, -0.013572195, 0.057683162, -0.06374546, 0.08304793, -0.16587098, -0.12618694, -0.24510759) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.044846885, -0.384735, -0.23009893, 0.013427144, 0.07191924, -0.18046127, -0.30342177, -0.24324954, 0.25815934, 0.11866939, -0.0811382, -0.25772575, 0.03358074, -0.22855935, -0.2581292, -0.14428802) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0614372, 0.07986244, 0.027231159, -0.07870463, -0.11888313, -0.18197255, -0.05821851, 0.23519358, 0.16131869, 0.06705387, 0.11549014, -0.07685248, -0.028336462, 0.04196942, -0.023758978, -0.09584765) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

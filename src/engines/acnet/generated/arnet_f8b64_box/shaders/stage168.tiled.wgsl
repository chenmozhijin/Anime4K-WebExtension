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

  var result: vec4f = vec4f(0.10741265, 0.16866517, 0.065906875, -0.047674645);
      result += mat4x4<f32>(0.0018094016, 0.1669182, -0.094232455, 0.008070039, -0.054549385, -0.0611928, 0.03011792, 0.13533638, -0.10341003, 0.39770165, 0.3907827, -0.23967913, 0.22992711, 0.04904149, 0.30075252, 0.25064513) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09329859, -0.19645858, -0.16548762, -0.03044682, 0.01883562, 0.064154744, 0.17697562, -0.2181028, -0.04282746, 0.28434116, 0.07227571, -0.25683773, -0.056572955, 0.08681655, -0.010569448, 0.11767955) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.044663105, 0.13313507, 0.09773304, -0.030355161, 0.027159093, 0.05067134, 0.057272416, 0.05229358, -0.13039725, -0.17225865, -0.45133922, -0.19909129, -0.15727434, 0.5325238, 0.19354318, -0.26911366) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.05165479, 0.09229369, -0.033519514, 0.2750511, 0.13393497, 0.06957017, -0.09679943, 0.123723425, 0.028732162, 0.45808688, 0.38017926, 0.09308813, 0.23629932, -0.4544948, 0.066448875, 0.49525747) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6327669, -0.043043002, -0.23250037, -0.53838617, 0.23192677, -0.09007244, -0.40723184, -0.013149391, -0.17625101, 0.08734088, -0.24294482, -0.046492625, -0.03273551, -0.11301263, 0.025463168, -0.01292082) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.052108686, 0.046223372, -0.16904221, -0.19618209, 0.006409424, 0.087306984, 0.12020921, -0.03945749, -0.0807766, -0.46536058, -0.42456785, -0.20843501, -0.04677412, 0.015754486, -0.11829886, -0.27207106) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.042527676, -0.098750845, -0.05762008, 0.26561847, 0.20747413, 0.045771927, 0.06564703, 0.084827, 0.14837842, -0.018733421, 0.46797377, 0.28345302, 0.1866806, -0.35773903, -0.103953935, 0.24605621) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.06751895, 0.026416413, -0.10428748, -0.12631354, 0.010256414, 0.08733438, 0.05325567, 0.030171, 0.1434303, -0.1420092, 0.08471431, 0.17041619, -0.057157334, 0.055648804, -0.085519135, 0.01694146) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.039178062, 0.06568728, 0.08596631, -0.022963671, -0.032338858, 0.088198744, 0.084905654, 0.046076164, 0.1217568, -0.39452755, -0.3822788, 0.2410995, -0.25997716, 0.14335012, -0.23504667, -0.3400293) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.17101082, 0.17977999, 0.069841065, -0.22330764, -0.101361975, -0.05972151, -0.0046401117, -0.16442578, 0.12810162, -0.003750923, -0.05149043, -0.06260027, 0.57469064, -0.14020821, -0.49466914, 0.32665017) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16063799, 0.20159003, 0.037361477, -0.23790048, -0.08486521, -0.17143716, -0.09479748, -0.10175437, -0.35585538, -0.040547647, -0.107044235, -0.40012845, 0.2047447, 0.047697805, 0.16830699, 0.08127753) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.16391757, 0.29038596, 0.13359725, -0.17516598, 0.016726691, -0.15855715, -0.08851831, 0.022156158, 0.030775633, -0.113171786, -0.10025302, -0.16588207, 0.0389406, 0.042462904, 0.040003877, -0.21490237) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.24847011, 0.25495157, 0.030717447, -0.15211219, 0.061894823, -0.13307175, -0.14203231, -0.14991616, 0.16931783, -0.074012905, -0.32085145, -0.38990512, 0.113811105, 0.18324192, 0.06811867, 0.05589706) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.15275437, 0.22710869, -0.054585535, -0.19324984, -0.05986367, -0.15339614, -0.017231863, -0.07261494, -0.35560825, 0.016867802, -0.846888, -1.7032061, -0.053746462, -0.024791539, -0.21523339, -0.11935652) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.21530981, 0.22428198, 0.023538508, -0.22172901, 0.09672843, -0.21871346, -0.19118176, -0.044543687, -0.25447527, 0.1051005, -0.10864899, 0.12947494, -0.002538555, -0.07075425, 0.06883444, 0.18603808) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.153126, 0.17358153, 0.10493209, -0.21939482, 0.119668916, -0.093910426, -0.2201395, -0.04588207, -0.07589716, -0.07043745, -0.14555337, -0.12768151, -0.08500996, -0.016403558, 0.0627971, 0.16888706) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.21778253, 0.23015174, 0.04704875, -0.22314422, 0.115368925, -0.081656486, -0.14204098, 0.015004136, -0.0987728, 0.10263174, -0.13849226, 0.02896101, -0.051256374, -0.067631155, -0.1634053, -0.27979246) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1446023, 0.12954965, -0.0075971414, -0.3269203, -0.047194555, -0.082402885, -0.085838325, -0.1876996, -0.0042975326, 0.01101053, -0.008699898, 0.012103691, -0.039197307, -0.08599706, -0.037005704, 0.10886285) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(-0.07795978, 0.14420477, 0.28474367, -0.041458752);
      result += mat4x4<f32>(-0.121187285, 0.031691957, -0.20426317, -0.119818345, -0.0058177463, -0.08161774, -0.14416377, -0.14047427, -0.41271096, -0.49305254, 0.40088373, -0.058642108, 0.14545582, -0.14151417, 0.106269136, -0.20118849) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14999172, 0.40494734, -0.25222477, 0.15025988, -0.059990212, 0.13052039, 0.08702514, -0.19817631, 0.21163149, 0.3084408, -0.16949917, 0.006132772, 0.27337614, -0.69431275, 0.06344622, -0.12863708) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.027372368, -0.005158324, -0.1764496, 0.042071518, -0.124770924, 0.15106137, -0.3305585, -0.03273589, -0.041828014, 0.08302876, -0.14159332, -0.013772177, 0.07444062, 0.015363526, 0.2043768, -0.01620599) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12830688, 0.76287043, -0.31167233, 0.6150084, 0.10094568, -0.3276299, -0.3808491, -0.06921654, -0.09289734, -0.25368902, -0.48119462, -0.27871823, -0.15646014, -0.7021907, 0.09596873, -0.3093179) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16229275, 0.938291, 0.17693183, -0.35991326, 0.119527504, 0.25410965, 0.24490994, 0.12921436, -0.38232675, 0.4988574, 0.031142, 0.026906407, 0.5238546, -0.7471917, -0.7218682, 0.48686007) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13556193, 0.1514189, -0.120565064, 0.0016878117, -0.14548226, 0.17140512, 0.13033488, 0.11438901, 0.2747746, 0.14369881, 0.19543295, 0.14320838, 0.1296552, -0.017786358, 0.2630776, -0.12404781) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.016075598, 0.07319792, -0.12895368, 0.06669882, -0.11547881, -0.5321791, 0.05944964, -0.2222019, 0.0143131595, 0.10873617, -0.039189536, -0.07325871, 0.107953824, -0.1583196, 0.22209331, -0.008577144) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12796508, -0.2747658, -0.13796617, 0.13778786, -0.2224258, 0.19778317, -0.19547477, -0.13346119, 0.23731145, -0.19002777, -0.12230805, 0.08021524, 0.0509911, 0.24714771, 0.04624245, 0.048407342) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11627489, -0.09650563, -0.12886816, -0.13074465, -0.031123469, 0.27480844, -0.1916002, -0.035186447, -0.026233364, 0.05086271, -0.04077127, 0.27007294, 0.1251904, 0.28943753, 0.25356552, 0.19846968) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.19091181, 0.26317677, -0.49476984, -0.30159202, -0.07373498, 0.3134959, -0.17622516, 0.20537469, -0.032605737, 0.24912263, -0.08619746, -0.077512555, 0.10814235, -0.36171916, 0.1275644, -0.14679566) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.20771945, 1.4353826, -0.57762825, 1.0075341, -0.10680194, 0.24441977, 0.20331037, 0.22598818, -0.046064425, 0.024006417, 0.1183861, -0.19060875, 0.09318391, -0.035866994, -0.08357823, 0.07255554) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.048267927, 0.94519097, -0.19575894, 0.064872, 0.02431893, 0.028263923, -0.10084224, -0.14518566, 0.02114794, 0.004765359, -0.051155496, -0.0046483, 0.014201855, 0.13810647, 0.021694278, -0.049894527) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.009698413, -0.0064175855, -0.72795767, -0.4592406, 0.08233176, -0.12056216, -0.17280205, 0.09681268, 0.06565918, 0.0600242, 0.038643137, -0.20916706, -0.09039918, -0.031770222, -0.12552218, -0.25125283) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5360327, -1.8855634, 1.2178091, 1.5474353, -0.17188545, -0.075535595, -0.3794969, -0.15006927, -0.3518558, -0.12825932, -0.44741988, -0.6735195, 0.19684698, 0.2812581, 0.14498475, 0.57514185) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11031986, 0.29256862, -0.6463197, -0.36321893, 0.13108125, 0.0050694034, -0.15150051, 0.0044688117, 0.073667064, -0.21610692, -0.074155, 0.05451939, -0.18924041, 0.19415233, -0.037076056, -0.14775841) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.31394884, -0.28141126, -0.76366913, -0.73186034, -0.31426612, -0.433353, 0.3422957, 0.11667727, -0.044201095, -0.08555429, -0.07809006, -0.31671053, 0.10793032, 0.0723823, 0.1688213, 0.2308623) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.3270493, -0.009076324, 0.22912619, -0.28614286, -0.22790144, -0.14528175, -0.18915804, -0.15045711, -0.10685954, -0.26389852, 0.09532736, -0.061730307, 0.25787917, 0.2515789, -0.46772593, 0.1348038) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.44319353, 0.7955188, 0.09707825, -0.64941514, 0.03977512, 0.029386923, -0.16210747, -0.050132595, 0.050123073, 0.121875845, -0.12291564, -0.06915907, 0.054332502, -0.21492782, 0.112775594, 0.048592526) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

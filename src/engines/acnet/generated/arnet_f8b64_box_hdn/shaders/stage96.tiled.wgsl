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

  var result: vec4f = vec4f(0.3877288, -0.093598835, 0.3319535, -0.0038805155);
      result += mat4x4<f32>(0.13262004, 0.1486897, -0.18639885, 0.17140527, 0.043149833, 0.054753073, -0.14230916, 0.059789453, 0.12027398, -0.2751733, -0.021031942, 0.031939056, 0.4032507, 0.020505209, -0.38637727, 0.2914409) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21180828, -0.060799897, 0.09491472, 0.07014092, 0.03172915, 0.11530606, -0.09809358, 0.33009553, 0.17006359, -0.028713772, -0.089320056, -0.21982458, -0.36063102, -0.10504759, 0.026254857, -0.016760714) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.01202529, 0.023571294, 0.14767146, -0.0418503, -0.30133298, 0.18131186, -0.08495225, 0.21129203, 0.089188054, -0.15367933, -0.08475953, -0.13065429, -0.0895085, 0.16963507, 0.2833169, -0.41007847) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.26676422, -0.095436476, -0.04306647, 0.047389586, -0.19819212, 0.0029699085, -0.18647245, 0.23439349, 0.48480734, -0.06294888, -0.3317914, 0.02858611, 0.5391653, -0.16022244, -0.4940152, -0.036519695) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.8162042, 0.17572331, 0.06328107, -0.2847685, -0.20454377, 0.17333655, -0.0005901862, 0.42820948, 0.6664218, -0.007516404, -0.22866456, -0.17140986, -0.639194, -0.1472389, 0.33149555, 0.19434844) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.19118445, 0.26999766, -0.053012192, 0.07715749, -0.29808506, 0.045649465, -0.07800634, 0.3320096, 0.08934417, -0.10071094, -0.12548573, -0.15912725, -0.1867348, 0.22031504, 0.21486758, -0.037333842) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.15670635, 0.0041182335, 0.1350882, -0.06611709, 0.02388545, 0.019728437, -0.025438717, 0.05398704, -0.057575304, 0.021112788, -0.20040397, 0.194283, -0.14894459, 0.042489715, -0.570992, 0.26151156) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15625302, 0.06313013, 0.25127253, -0.051716354, -0.07553366, 0.029493228, -0.13278043, 0.045048416, 0.30351657, -0.13381848, -0.33459392, -0.11430806, 0.031746045, -0.17446801, -0.014137264, -0.20107496) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.3605382, 0.083215244, -0.020182556, -0.11981719, -0.0025290311, 0.055115942, 0.06713611, -0.03763847, 0.12417181, -0.12785277, 0.0712037, -0.21621493, 0.3670208, 0.16354714, 0.28947353, -0.16987523) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.38449857, 0.14008297, 0.10504337, -0.2072361, -0.058153268, 0.029915093, 0.07030318, -0.0039276765, -0.37046304, 0.013503751, -0.2075129, 0.35806113, 0.078180805, 0.0027130323, 0.1651006, -0.20668852) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20496175, 0.2673662, 0.066580765, -0.77945614, 0.25381222, 0.07893738, -0.103621274, 0.11877989, -0.15662363, -0.23878148, -0.47090948, 0.3961125, -0.2607265, 0.22595802, 0.6069633, -0.41372752) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.109286875, -0.1842036, -0.15920874, -0.063703254, 0.329278, 0.024754927, -0.17833595, 0.24614939, 0.11043365, 0.14939229, -0.13035154, 0.3706154, -0.264486, -0.06906557, 0.32642853, -0.57251805) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.25186253, -0.11665207, -0.07049616, -0.22817367, -0.16348863, -0.06676799, 0.04238966, 0.10794737, 0.1322455, 0.10754492, 0.03865119, -0.22653773, 0.033532128, 0.066324994, 0.12897366, 0.03678511) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7223881, -0.49183252, -0.68158877, -0.33263814, -0.03045066, -0.3862449, -0.10636632, 0.08431505, -0.1573352, -0.09608462, -0.2542405, -0.43581638, -0.28891736, -0.15055844, -0.42192477, 0.29362214) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.81778103, -0.04827577, 0.029787488, -0.21916261, 0.3342032, -0.0807834, -0.012861469, -0.12925509, -0.29904392, 0.131935, -0.028353876, 0.1568694, 0.48595998, -0.10207934, -0.3677226, 0.05598069) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.25936425, -0.016810806, -0.30467367, 0.17177387, 0.10395005, -0.017184995, 0.010071261, 0.059285395, 0.22056735, -0.04946188, 0.14848405, -0.11395158, -0.12505095, 0.03273876, -0.03474938, 0.21428831) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17414612, 0.071421005, 0.38248053, 0.1236635, 0.37061802, 0.14242539, 0.03156667, -0.14787842, 0.12610546, 0.36952302, 0.8102399, -0.43804672, 0.016993435, -0.3918008, -0.5453209, 0.1727967) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03877513, -0.108476296, 0.006429429, 0.31267858, 0.4600395, 0.0023730895, -0.10795266, -0.13106693, 0.09421137, -0.15271199, -0.06666832, -0.2661422, -0.2281718, -0.0053143236, -0.04029683, 0.18458733) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

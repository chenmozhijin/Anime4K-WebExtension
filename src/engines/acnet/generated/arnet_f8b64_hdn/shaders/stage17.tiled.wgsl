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

  var result: vec4f = vec4f(-0.18981425, 0.23824349, 0.06922282, -0.11866717);
      result += mat4x4<f32>(-0.07043454, 0.08882723, -0.40170935, -0.2874545, -0.15686095, 0.022994913, -0.23296487, -0.5540353, -0.07507783, -0.121694006, -0.042521793, 0.108958565, 0.090004295, 0.07150936, -0.35688403, -0.084118076) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.18502516, 0.14776611, 0.23613748, -0.19648768, -0.14360115, -0.006005882, -0.6403923, -0.26358584, -0.0017909136, 0.25372067, -0.2728268, -0.00032029214, 0.021078508, -0.11995512, 0.25940695, -0.09856102) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.107357316, -0.061243907, -0.13926993, -0.22724505, -0.10149305, 0.0056149075, -0.08751977, 0.47202095, -0.17304282, -0.023811102, -0.03144542, 0.33917433, -0.011253479, 0.044233985, -0.05751111, 0.04307148) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12586983, 0.29094273, -0.11512358, 0.100618474, -0.31959915, 0.30220336, 0.23698273, -0.29673553, 0.020428075, 0.00908576, 0.37046, 0.7430404, -0.120532334, -0.34738022, -0.21461146, 0.64795196) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.078890346, 0.39250365, 0.27712095, 1.6882622, -1.2813711, -0.072491996, 0.53357697, 0.5988468, -0.0013787344, -0.0710435, 1.4957955, 0.7862533, -0.037467003, -0.40927118, 1.0684091, -0.1608351) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.035120655, -0.34296837, 0.102486014, 0.41108686, 0.44347835, -0.39420134, 0.054092616, 0.26708123, 0.01564131, 0.18161255, 0.19223213, 0.15605824, -0.16250867, -0.18632597, -0.38808838, -0.19497643) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.052848265, 0.1868133, 0.11680224, 0.08189612, -0.011620661, 0.11569964, 0.10913068, -0.19593783, 0.1759968, 0.13661437, 0.31413388, -0.1787431, 0.06145564, -0.1957447, 0.101142615, 0.38747767) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.080647945, -0.09730693, -0.37838337, 0.36402163, 0.17872512, 0.09487404, 0.229079, -0.106944956, 0.28528956, 0.21880724, 0.671683, 0.27980354, 0.29063877, -0.13302784, 0.46675473, -0.66210747) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.016881773, -0.23300879, 0.09123809, -0.21712351, 0.10169748, -0.037234433, 0.10603106, 0.22866745, 0.03758308, 0.2471014, -0.102540806, 0.05564648, -0.06997357, -0.2769807, -0.17705344, 0.024586225) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08777678, -0.11849295, 0.20124528, 0.26954257, 0.08136623, -0.14425397, 0.03548761, -0.31535268, 0.085510954, -0.13032722, -0.15401056, 0.046752445, 0.10640677, -0.084010996, 0.26792663, 0.34444773) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.19102593, 0.021177502, 0.5977548, 0.2786597, -0.025871389, -0.02598431, -0.3167355, -0.1416389, 0.022199338, -0.2715654, 0.30954117, -0.11206163, -0.17915833, -0.28776497, -0.4735043, 0.36642486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.12060651, 0.0025043015, 0.2477974, -0.27190438, 0.004571497, 0.3552524, -0.0206124, -0.31404454, -0.009671595, -0.123351924, 0.1855114, 0.045871504, -0.029116327, 0.4104528, 0.119123556, 0.16541365) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.22076774, -0.086256236, -0.09122523, 0.118874565, 0.5174041, -1.5357122, -0.27913842, 0.3285734, -0.28159145, 0.3049069, 0.21748707, -0.9697597, 0.061470326, -0.08749697, 0.09813891, 0.36252886) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.72191554, -0.17040214, -0.41438732, -0.30136836, 0.46937343, -0.48486945, -0.06780881, 0.34879798, -0.19282715, 0.2542088, -0.006597627, -0.50789815, -0.1481263, -0.56866676, 0.040740807, 0.82495415) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24676134, 0.5056999, 0.07057305, 0.1349652, 0.09874421, -0.07159314, 0.07576174, 0.11233714, 0.050129127, -0.07620658, -0.101437174, 0.080401964, 0.042845957, -0.2516872, -0.17736816, 0.13967821) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07692546, 0.21375571, -0.016475726, -0.13333027, -0.032719295, -0.56907916, -0.23373607, 0.102052934, -0.01624658, 0.23571008, 0.19634911, -0.10501227, 0.103600174, 0.023019709, -0.034536056, -0.16984825) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09760594, -0.037357543, -0.24077222, 0.36066929, 0.27004024, -0.35542548, -0.05635867, 0.14582337, -0.19760713, 0.33416745, -0.23414351, -0.22876377, 0.09434806, -0.454632, 0.3637483, -0.51318884) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07971222, 0.029575896, -0.05182857, 0.066933386, 0.07089676, 0.0589611, -0.035722494, -0.13072304, -0.096332386, 0.055235393, -0.035326887, 0.1926664, 0.030203704, -0.31257585, -0.028863214, -0.3047102) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

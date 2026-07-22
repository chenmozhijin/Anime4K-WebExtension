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

@group(0) @binding(2) var tex_FEAT_TEX_0: texture_2d<f32>;

fn sample_FEAT_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_0: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_0[tileY][tileX] = sample_FEAT_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.30360907, -0.04194347, -0.43332514, -0.077371694);
      result += mat4x4<f32>(0.21190703, 0.526571, -0.23160699, -0.5575494, -0.020538501, -0.1442007, 0.11847148, 0.29422787, -0.039574742, -0.02577323, 0.05284875, -0.1014052, -0.08465421, -0.12583442, 0.12751655, -0.08194683) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.027411615, 0.016689809, 0.019169291, -0.17997278, 0.2122714, -0.19133909, 0.1563033, 0.30150148, 0.14756347, -0.0777555, 0.053068124, -0.16501872, -0.1902893, 0.0019458949, -0.036229372, -0.14537193) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.032388035, -0.008936837, -0.14180972, 0.16648623, 0.04661056, -0.0058587855, -0.24233367, -0.0014277968, 0.05303875, -0.11779282, 0.14017008, -0.024093114, -0.043051194, -0.08995963, 0.21413594, -0.044998888) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.25571626, 0.11548932, -0.2812796, -0.0003134637, -0.7594252, -0.34536546, 0.89460856, 0.23136988, 0.27378842, 0.36388737, -0.31468755, -0.28918, 0.39772275, -0.16235629, -0.45168653, 0.048320226) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.9035502, -0.28298572, -0.46535704, 0.18633898, -0.5693281, -0.15000562, 0.35241595, 0.24806623, 0.9308726, 0.33251777, -0.25127345, -0.49422282, -0.6440864, -0.10373421, -0.07200507, 0.016426919) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2246443, 0.18160805, -0.03180656, 0.32194382, -0.12714954, -0.1370116, -0.1741629, -0.020499991, 0.3222169, -0.28468865, 0.28209832, -0.16086014, -0.07330525, -0.090311304, 0.008568498, 0.2710087) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.08620802, 0.072664715, 0.44048217, -0.1541825, -0.08377864, 0.19011058, 0.3562757, -0.16872999, 0.027625995, -0.018713305, 0.08636551, -0.1016186, -0.0060184295, 0.098658174, -0.44343552, -0.05742071) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12106513, -0.2802857, 0.10438172, 0.03344079, -0.059006177, 0.11648687, 0.17348279, -0.064130366, 0.058747128, -0.0873777, 0.13218403, -0.071023196, -0.69488865, -0.47334772, 1.0641081, -0.3241703) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12192951, 0.13547045, 0.12095967, 0.114012904, -0.050337173, -0.0059314086, -0.04283341, -0.045447376, 0.18986608, -0.07212116, 0.26063424, -0.23258145, -0.13231352, 0.108070694, 0.05895995, 0.09143162) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.09293346, 0.097453244, -0.17401087, -0.07196565, 0.10263835, -0.070784636, -0.3550268, -0.01641234, 0.10575968, 0.0417425, -0.08564072, 0.21257931, -0.08336548, -0.32402736, 0.38085908, 0.168173) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19449982, -0.118711814, 0.038285386, 0.17587803, -0.124164395, -0.045149356, -0.20181403, -0.064888656, 0.29114363, -0.14948857, 0.029970353, 0.3948101, -0.091141745, -0.05666921, 0.2553753, -0.062387455) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07112785, -0.029750861, -0.049258087, 0.015754374, 0.1680319, 0.10827236, 0.06893964, -0.15214734, 0.04936897, 0.048265055, -0.30894563, 0.09329486, -0.10157131, 0.1387239, -0.14437735, -0.11953339) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.25903115, -0.37265277, 0.09941292, -0.019691458, 0.7843838, 1.0551939, -0.5378877, -0.5325393, -0.36021483, 0.069811605, 0.46782774, 0.020140719, -0.19989789, -0.57885873, 0.44682604, 0.37256083) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.37492326, 0.06327625, -0.34489676, -0.1867296, 0.1498367, -0.21133474, -0.65118384, 0.3562532, -0.06398974, -0.6185445, 0.71167785, 0.42512286, 1.3657959, 0.85656345, -0.22958101, -0.24814446) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.00097473484, -0.09956532, 0.062525354, -0.058733884, 0.3059618, 0.14491342, 0.08437284, -0.21014613, -0.13616902, -0.043075707, -0.20486419, -0.052498166, 0.19648367, 0.057379384, 0.11292024, 0.021345666) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.69319105, -0.029971471, -0.71676224, 0.10833028, -0.09225473, 0.15163067, -0.13761091, 0.021092677, 0.023748292, -0.18890117, 0.3889924, 0.047057208, 0.1935027, 0.13002294, 0.085951276, 0.032845423) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(1.0701238, 0.46619073, -0.7478537, -0.43720555, -0.036825042, -0.034826588, 0.029766353, -0.30553958, -0.18813583, 0.03834892, -0.31876218, 0.36643353, 0.17568639, -0.047443718, -0.0022119202, 0.33459958) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.37211403, 0.023404919, -0.098062456, -0.058313612, 0.16262226, 0.12732667, 0.024663923, -0.044999614, -0.23826678, -0.2642786, 0.12930001, -0.008300127, -0.35999423, 0.089212224, 0.24297926, -0.11962053) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

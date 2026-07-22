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

  var result: vec4f = vec4f(-0.37617746, 0.060323663, -0.77089715, -0.062850624);
      result += mat4x4<f32>(-0.021113759, -0.20394123, 0.13288404, 0.18958072, 0.12675798, 0.19527526, -0.112729326, 0.26531672, 0.1613281, 0.14125049, -0.051032737, 0.06713288, 0.13721749, -0.044237103, -0.018569859, 0.14675224) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.2696964, -0.42809817, 0.21398668, 0.32984218, 0.4928688, 0.5810189, 0.5990486, 0.023063472, 0.18532011, 0.3435495, 0.31252792, -0.20955189, -0.25049096, -0.13768153, -0.19554701, 0.30006433) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06804505, -0.4468988, 0.12777196, 0.12564006, 0.29161438, -0.05262338, -0.10255491, -0.10249444, -0.31401375, 0.020408846, 0.004690761, 0.037709955, -0.003274414, 0.24739558, 0.0713205, -0.3689995) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04523383, -0.051033296, -0.0127463555, 0.18892106, 0.21454902, -0.018546809, 0.15394105, 0.13629012, 0.34130272, 0.09247135, -0.13514291, 0.071161576, -0.49640885, -0.244558, 0.016643621, 0.0012511391) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17520297, -0.08188278, 0.071335666, 0.48252594, 0.19705208, 0.18518807, -0.9108555, 0.014902328, -0.5648975, -0.7307443, -0.29722646, 0.6017114, -0.08298194, 0.36911395, -0.44892195, 0.21449286) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.17780808, -0.7113803, 0.20093255, -0.01115658, -0.10794144, -0.062339954, -0.22397162, 0.1573324, 0.16004167, 0.17903009, 0.25332916, 0.055347223, 0.44815794, 0.10822118, -0.016795676, -0.29876333) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16135992, -0.009699514, 0.0066836188, 0.013663424, 0.08336288, 0.10344818, -0.0069579375, 0.04813991, -0.013483885, 0.14402086, -0.042768665, 0.07370146, 0.04655578, 0.12097252, -0.015232973, 0.00019232075) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.017145144, -0.316424, 0.0989974, 0.21132706, 0.0707861, 0.009066531, 0.25005534, 0.2249914, -0.050419804, 0.10264542, -0.1394174, -0.008732377, -0.23100291, -0.038189728, -0.0859365, 0.14795344) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.013502255, -0.3299046, 0.094342954, 0.032805223, -0.17815076, 0.17184696, -0.043749962, -0.045642063, -0.063263126, -0.08578269, 0.035272352, 0.090539694, -0.0726905, -0.0900726, 0.15766676, 0.22027484) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.21896327, -0.2146886, 0.12726204, -0.17657334, 0.18837406, -0.006580986, 0.12417412, 0.2258334, -0.13453181, -0.103105985, 0.010583667, -0.29222235, -0.055696987, 0.10491476, -0.055303384, 0.020993587) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.42833802, 0.05785609, 0.02437919, -0.5262844, 0.25640747, 0.044170864, 0.13435242, 0.06589222, 0.04466688, -0.81070316, -0.47323543, 0.26183817, -0.42113706, 0.43994805, -0.21680064, -0.61249393) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.039941553, -0.21265315, 0.097344354, 0.045100797, -0.20644966, -0.08789376, -0.0048866863, 0.08476792, -0.27422488, -0.2914694, 0.19946137, 0.27999413, 0.019120257, 0.2507857, -0.14190316, -0.028780226) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.36606824, -0.6248241, 0.24961554, -0.17357771, 0.005059236, -0.013004451, -0.10922881, 0.17154643, -0.72642004, -0.4002308, -0.052222688, -0.16628791, -0.46817538, -0.04512283, -0.12781124, -0.14255811) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.10390465, 0.40482897, 0.31537172, -0.5887453, -0.77663696, -1.1682853, 0.21694134, 0.44585302, 0.14297584, 0.14203627, 0.08333094, -0.57354313, 1.1376451, 0.2925808, -0.18858853, 0.47502154) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.26331735, 0.39380905, 0.26602098, -0.40438703, 0.06939488, 0.22392423, 0.039233007, -0.11550225, 0.11595067, 0.23472078, 0.14862385, -0.011602018, -0.33831328, -0.40673447, -0.09030395, 0.26320565) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.03527861, 0.02464637, 0.053896848, -0.05063533, 0.04604282, -0.39486066, 0.13398218, 0.14254683, -0.21658273, -0.1226304, -0.11104901, -0.20850933, -0.12620515, -0.039555427, -0.006235656, -0.09361184) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.20850277, -0.30927733, 0.39263055, -0.044429544, 0.40314996, -0.1973015, -0.017084343, 0.0271947, -0.050922763, 0.027507039, -0.084219344, -0.16842243, -0.020891488, -0.2780472, -0.31660274, 0.027697885) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.05423482, 0.050079312, 0.24170044, -0.19808318, -0.09573569, -0.43564394, 0.026378825, -0.033049136, -0.06680198, 0.17769378, -0.035133578, -0.12748834, 0.33887422, -0.4596756, -0.052951016, 0.118610874) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

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

  var result: vec4f = vec4f(0.2801568, 0.20598352, 0.35380122, -0.30651128);
      result += mat4x4<f32>(0.15989164, 0.036979023, 0.15935276, -0.057338018, 0.21964025, -0.016114827, -0.04634657, -0.2546278, 0.053739823, 0.07605635, -0.10652983, 0.10592772, 0.11617206, 0.054076802, -0.19726093, 0.13894545) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0437399, -0.12532252, 0.1545183, 0.08512837, -0.18054076, -0.46854702, -0.8061627, -0.24146122, 0.012342307, 0.037521463, 0.2513852, 0.16570213, 0.5216457, -0.17284068, -0.34620717, 0.09187684) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.018945094, 0.10280666, 0.057734508, 0.10406058, -0.10981249, -0.27717716, 0.16053171, -0.08489168, -0.122403376, 0.14056812, -0.29524317, 0.09467979, 0.6186532, -0.16859852, -0.06491067, -0.13750641) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.09312253, 0.010202925, -0.15620132, -0.15793586, -0.21904436, 0.10795982, 0.3058307, -0.3190993, 0.18087442, -0.08212628, -0.25085038, 0.18209897, -0.059864264, 0.27793735, 0.1433685, -0.1943951) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.24190094, 0.03356267, -0.15924242, 0.24250543, -0.4771014, -0.14239842, 0.34442177, -0.51415855, 0.49915573, -0.11974085, -0.020398943, 0.1442479, 0.307052, -0.06036114, 0.06239598, 0.21067393) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.03331612, -0.071801506, -0.035327688, -0.15650214, 0.18139414, -0.072747715, 0.08042789, -0.2197295, -0.034927107, -0.04705192, -0.29326415, 0.07366133, -0.10628492, 0.07329765, -0.13573036, 0.164488) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24285108, -0.03649069, 0.102128275, -0.11416626, 0.030315777, 0.05187001, -0.27151307, 0.26321268, 0.2179468, 0.12544, -0.13499999, 0.2374976, -0.19368705, 0.061166186, -0.13628194, 0.024300188) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.050852783, 0.25912502, -0.04162789, 0.17668948, -0.0191026, -0.2460032, 0.060929924, -0.33096057, 0.28482574, 0.2946461, 0.06888198, 0.17217782, 0.02382372, -0.3921678, -0.23723987, 0.33076227) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08548026, -0.10855528, -0.0026702483, -0.06463509, -0.0015867078, -0.40251634, -0.07895412, -0.011144456, 0.16269091, 0.04057797, -0.0665763, 0.20812681, -0.15747061, 0.1174313, -0.12952845, 0.0010343593) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.021098942, 0.011570313, 0.45936102, -0.26017463, 0.10015025, -0.15269864, 0.06333785, -0.13839975, 0.2906292, 0.13055441, -0.21001634, 0.23654902, -0.22711495, -0.015746022, 0.12113463, 0.042589687) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.5252693, -0.12784037, -0.0077965623, 0.0290835, -0.11614658, -0.14704141, 0.10020204, -0.0737445, 0.1586951, -0.075884655, -0.2491437, 0.17380711, -0.16313493, 0.22581984, 0.052656136, 0.19621082) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.36571553, 0.016217984, 0.08161397, 0.07209482, -0.17033374, -0.07516038, 0.07779112, -0.25613564, 0.109637216, -0.14966922, -0.053117868, -0.00366636, -0.21666378, -0.043728903, 0.0022969248, 0.15318717) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.30495304, 0.120538, -0.19908725, 0.4319349, 0.04222237, -0.1551433, -0.17044498, 0.13337061, 0.0049839457, -0.2129629, -0.051312666, 0.09878206, -0.1330068, 0.1956558, 0.2141913, 0.078094125) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.39232478, -0.2549894, -0.32939675, 0.75491357, -0.5171041, -0.46260583, -0.027692297, -0.43985304, 0.30120265, -0.22104378, -0.04780497, 0.27823225, -0.17960376, 0.5036657, 0.53389186, -0.21322113) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.3305289, 0.100473806, 0.13935404, 0.03907239, -0.44240615, -0.012988634, -0.0059283962, -0.2083035, 0.1758302, 0.10197591, -0.08399498, -0.372392, -0.3602212, 0.3138744, -0.017460603, 0.14892596) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.19953363, 0.061210636, 0.14491698, -0.35293227, -0.003973101, -0.14323714, -0.2720948, 0.0948467, 0.10763618, 0.048985988, -0.1537368, 0.26812327, -0.33804265, -0.0685174, 0.17504863, -0.19039834) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2788604, 0.39434293, -0.07880975, 0.05603466, -0.81558096, -0.712824, 0.024021873, -0.5691681, 0.04468012, -0.024484139, -0.113618806, 0.14958708, -0.273184, 0.48454192, 0.24649535, 0.12296273) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13601586, 0.043977067, 0.07925069, -0.13385485, -0.48693475, 0.181495, 0.06718591, 0.19643164, -0.0850189, -0.2783553, -0.0778708, 0.00607822, -0.3136885, 0.13412242, 0.009245659, 0.16982153) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

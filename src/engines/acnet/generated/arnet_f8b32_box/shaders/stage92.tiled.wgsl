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

  var result: vec4f = vec4f(0.27503, 0.28857818, 0.23569378, -0.15566877);
      result += mat4x4<f32>(-0.07305506, -0.20543244, -0.027897136, -0.14046583, -0.07006334, -0.2454318, -0.045092154, 0.15648162, -0.12330596, -0.04583067, 0.152282, 0.18955445, 0.27459058, -0.096054666, -0.0017894057, -0.77913386) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.098103784, 0.06806921, 0.04225707, 0.23625685, -0.012373527, 0.0422722, 0.040263023, 0.48862812, -0.10236166, -0.08472261, 0.16052198, 0.17030425, 0.06088402, 0.15674682, -0.07005785, 0.049175087) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.1553042, -0.083675645, 0.072161466, 0.061186768, 0.013869425, 0.24735926, -0.025435071, 0.046099853, -0.06996891, -0.036525723, 0.101785645, 0.16591375, 0.15273564, 0.3021629, -0.17187427, -0.21523736) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.10217767, 0.046406843, 0.033577003, 0.16874762, 0.032896083, 0.0059293336, -0.15492848, 0.060588155, -0.18936917, -0.24946822, 0.2578785, 0.2311306, 0.2579167, -0.09771198, -0.16869111, -0.32528514) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.25353938, -1.3283932, -0.011111172, -0.8167758, -0.17648579, -0.20969261, 0.33104268, 0.31285226, -0.20715545, -0.20385593, 0.27136347, 0.26417527, 0.2237602, 0.055332333, 0.30179453, -0.651184) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.10669, 0.042559184, 0.21652935, -0.023005094, -0.031059138, 0.024012882, -0.011309734, 0.022211723, -0.09713519, -0.09808547, 0.24019103, 0.22438054, 0.0016746784, 0.46833774, -0.23947641, 0.23230034) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18522418, 0.10419001, -0.053745773, 0.06388709, 0.06408675, 0.014983645, -0.36511856, -0.10042389, -0.13552737, -0.1751652, 0.13404304, 0.123168185, -0.09402201, -0.337175, 0.32404006, 0.14089692) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.39228988, 0.64354146, 0.20713358, 0.4076488, -0.08077489, -0.048694264, 0.23516595, 0.050667148, -0.10002222, -0.12926936, 0.122359306, 0.15918933, -0.31806347, -0.25238818, 0.30913964, 0.57857823) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.025823584, 0.25876307, -0.05554809, 0.06665617, 0.05456922, -0.0075283563, -0.13453805, 0.15350868, -0.06372792, -0.103870235, 0.15929879, 0.168894, -0.26406398, -0.042563006, -0.09889775, 0.6830015) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08675174, -0.20833512, -0.014084099, 0.18186179, 0.18935786, 0.09603936, -0.012378571, -0.035726774, 0.031420946, 0.3947845, -0.0086310785, 0.23668504, 0.03594272, 0.13972925, 0.059502557, -0.025305554) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11009382, -0.043615665, 0.23511854, -0.29805532, 0.07562445, -0.1727447, -0.23446299, -0.04272864, 0.048172593, -0.29926094, -0.094424784, 0.054409027, -0.06453805, -0.41572702, -0.2855207, -0.39771786) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13410418, -0.11798793, 0.02698701, -0.3880624, -0.0017372726, 0.17612743, -0.0053266576, 0.014796703, -0.035494793, -0.09510686, 0.10613615, 0.20344906, 0.047799278, -0.025893604, -0.01950137, 0.03647935) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.32067853, -0.2207023, 0.23180062, 0.43961197, 0.18716983, -0.19891684, -0.40429294, 0.14862208, 0.22174874, 0.7860294, -0.011446874, 0.5225238, 0.12430374, -0.0312992, -0.30458087, -0.085598946) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.29081962, 0.34138113, -0.33495018, -0.40678886, -0.23138526, 1.0125216, 0.7406279, -0.066970676, -0.11453423, -0.4567008, -0.17591377, 0.06736907, 0.0904446, 0.20089681, -0.725429, 0.14095043) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15730695, 0.039079137, -0.027027452, -0.36972693, 0.045777746, 0.07043878, 0.14712855, 0.020013258, -0.07886056, -0.08771892, 0.0928509, 0.3215481, -0.05025861, -0.13712312, -0.13260195, 0.0460445) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14956199, 0.14925897, 0.021650245, 0.8060943, -0.049130734, 0.10665701, 0.10749407, -0.069753155, 0.27995664, 0.58299124, -0.4557807, 0.24613073, -0.018694898, 0.01965696, 0.06856322, 0.0827837) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15176827, 0.051827986, -0.026673269, 0.2700578, 0.19876964, 0.114610314, 0.14324303, 0.24497275, 0.25680256, 0.42637658, -0.19788212, -0.14891614, -0.34103245, -0.37246934, 0.47468278, 0.026609002) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.110667266, 0.10981186, -0.21854554, -0.11765698, -0.025888234, -0.071095325, 0.12588386, 0.034328915, -0.022022577, 0.12316622, -0.20185824, 0.21971129, 0.11344136, 0.2186717, -0.17014635, 0.016647855) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

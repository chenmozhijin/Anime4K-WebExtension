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

  var result: vec4f = vec4f(0.04181419, -0.03067187, 0.24495517, -0.19220646);
      result += mat4x4<f32>(-0.083496645, -0.03936416, 0.11142661, -0.09340149, -0.04466988, -0.0747098, 0.02268805, 0.04591904, -0.071200125, 0.028394245, -0.13720226, -0.077335894, 0.14895245, 0.31597248, 0.23462857, 0.020136632) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07257564, 0.05604178, -0.02110098, -0.0720269, -0.051629264, 0.08759623, 0.21732002, 0.116265, -0.14341113, -0.061210856, -0.10583982, -0.0003484084, -0.20025384, 0.037854426, -0.03718056, 0.19208382) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.100074984, -0.08165314, -0.09916537, 0.085745975, 0.07899064, 0.007721066, -0.28494847, -0.1508075, -0.09269985, -0.14565994, -0.09740544, 0.08198212, -0.1722717, -0.24477977, 0.32202566, 0.30310082) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.008735625, 0.07911033, -0.02858575, 0.09858689, -0.043080043, -0.64611936, 0.085645184, 0.0033166686, -0.0020490736, -0.13673414, -0.21977414, -0.098871686, 0.058591142, -0.007033713, 0.09252108, -0.09434035) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30876517, -0.111552775, 0.20882021, 0.6882253, -0.1565832, -0.4073851, 0.11022308, -0.2363143, -0.15586868, -0.050514657, -0.17495103, 0.108000234, -0.0021022202, -0.031697772, -0.10892651, -0.054584727) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08279052, -0.07059496, -0.04339218, -0.09576778, -0.31699765, 0.13597113, 0.057376392, 0.09481713, -0.074951604, -0.037977207, -0.32460824, 0.16846046, -0.04928853, -0.22867045, -0.116385646, 0.12260188) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0722965, 0.25815243, 0.0038006569, 0.2168946, -0.12095428, -0.2806143, 0.011950228, 0.31566304, -0.24093299, -0.2581401, 0.024533866, 0.23192047, 0.19372933, 0.27482104, 0.024773683, -0.11707882) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.26750085, -0.12585601, -0.10413897, -0.044978403, 0.1358934, -0.2545148, -0.31560716, 0.06321966, -0.21647482, -0.22941181, 0.058142807, 0.083857074, 0.0742596, -0.066963874, 0.054984972, 0.019779654) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.3244037, 0.27636233, -0.17905805, -0.15254518, 0.16504942, -0.07353811, -0.17591111, 0.13571937, -0.13748276, -0.027676055, 0.0032618812, 0.084738225, -0.0069057927, -0.02493084, -0.23933336, 0.031695053) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.070042975, 0.028655963, -0.15114823, -0.1299673, 0.07131665, -0.024399925, -0.092164606, -0.20497966, 0.1276156, 0.06848425, -0.03036645, -0.03810405, -0.08377669, -0.20627351, -0.03524736, 0.25327584) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.008980061, 0.0043056244, -0.07026327, -0.049544774, 0.065591544, 0.13380201, 0.025167076, -0.058772776, -0.040294744, 0.04410977, 0.022416944, 0.27251804, 0.095253676, -0.09523485, 0.13371348, 0.26456574) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07953512, -0.04848734, -0.082948945, -0.0011108373, -0.017792094, 0.016001925, -0.089757435, -0.0485484, 0.05189481, 0.049498145, 0.062064487, 0.04850797, -0.12759097, 0.0046043154, 0.04790039, 0.13000494) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04850001, 0.18465152, -0.067974694, 0.3698733, 0.031935617, -0.17234056, 0.17600623, -0.20181999, -0.21256922, -0.12204601, 0.08983031, -0.17580089, -0.04225388, -0.051757414, -0.10268079, 0.09173183) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.039883558, -0.10563365, -0.17264487, 0.3661061, -0.074847974, 0.40695837, -0.0773904, -0.042577524, -0.37417772, -0.2435653, -0.17241432, -0.12855387, 0.24894151, -0.3037856, 0.29989204, 0.45836994) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.034827545, -0.12253822, 0.036212124, 0.2965432, -0.072856985, 0.2414294, -0.08202376, -0.3236769, 0.026996208, -0.2670319, 0.23323208, -0.17821169, 0.06086478, 0.11073051, -0.019140504, -0.122482955) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.095360845, -0.008566246, 0.040690515, 0.1492108, -0.007826993, 0.13595605, -0.01704876, -0.20702586, -0.06065509, 0.0704211, 0.053094424, -0.005620367, 0.07282319, -0.11481383, -0.2683872, 0.023317324) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18970375, -0.38672563, 0.34448728, 0.37217024, -0.14344032, 0.099170424, 0.09733373, 0.19641224, 0.029694624, 0.09393883, -0.23355141, 0.17368974, 0.19533503, 0.06378587, -0.46685737, 0.23548305) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.037749004, -0.104196765, -0.093908854, 0.21194898, 0.0050454033, 0.04089538, -0.33130684, -0.02792313, -0.095247366, -0.028438259, 0.04646653, 0.0044096517, 0.122830905, -0.105540596, -0.0673822, -0.07916745) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

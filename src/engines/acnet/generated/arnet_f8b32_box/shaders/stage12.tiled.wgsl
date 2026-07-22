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

  var result: vec4f = vec4f(-0.15932485, 0.14806819, 0.16548483, -0.09931751);
      result += mat4x4<f32>(0.03828506, 0.153131, 0.051119093, 0.030189974, -0.37655926, -0.49622768, 0.25142834, -0.4942176, -0.038413875, 0.2967551, 0.055533834, -0.06601193, -0.08312608, -0.29069117, -0.057010688, -0.1043492) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20891772, 0.21705195, 0.076795705, -0.08057121, -0.043522686, -1.1358722, -0.11291152, 0.3560559, -0.092818014, 0.37791154, 0.020909976, -0.01577274, -0.06703265, -0.08239964, -0.4083047, 0.010942507) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.042273782, -0.009947388, -0.09082321, 0.06672229, -0.037236787, -0.021823429, -0.022241361, 0.033111986, 0.07744438, 0.0059779924, 0.13258605, -0.13621055, -0.08682551, -0.19440965, -0.14065172, -0.053596433) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.21764554, 0.025953962, 0.117766306, -0.13535628, -0.19413932, 0.014780067, -0.084674016, -0.07818497, -0.20082648, 0.017937988, -0.19118325, 0.098862715, -0.10381253, -0.17818242, -0.034859784, 0.019931693) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5940476, 0.13479283, 0.43244165, -0.05910914, 0.14221996, 0.57518095, 0.023842694, 0.22825706, 0.1785564, 0.104367964, -0.16866985, -0.16494578, 0.27755088, -0.103474334, -0.4282507, 0.18300569) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.022054069, -0.12801293, -0.01850905, 0.24337076, 0.08210882, -0.0028543812, -0.066234045, 0.1777237, -0.11315921, -0.049985748, -0.27915615, 0.23197447, 0.1298486, 0.015276937, 0.17083475, -0.073671155) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.052085996, -0.016322616, 0.19391327, -0.06612864, 0.033010956, -0.0018503724, -0.04216164, 0.0052895425, 0.056695543, 0.040091235, -0.20267427, -0.32897854, -0.00062300893, 0.12938364, -0.125797, 0.115376115) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1353278, -0.045767453, 0.061254755, -0.032773055, -0.023881027, -0.011305531, -0.104550116, 0.11598091, -0.08002935, 0.4198123, -0.479067, -0.14150587, -0.10101387, -0.14040408, -0.039746605, -0.1472965) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.050099384, 0.0399573, -0.03588907, 0.106201634, 0.017541392, 0.016161779, -0.03324156, -0.0354757, -0.066990145, 0.3308474, 0.3839576, 0.02803078, 0.016704582, 0.045025054, -0.02547568, 0.003820273) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07837232, -0.02837636, -0.14692536, 0.006507738, -0.0146269305, 0.21259041, 0.017803011, 0.13797432, 0.020637564, 0.0743871, 0.29816005, 0.16810293, -0.14184529, 0.4293977, -0.05002368, 0.35139817) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.009341267, -0.008698904, -0.24938622, -0.020283058, -0.1268471, 0.19662435, 0.0942997, -0.07921981, 0.009709805, -0.07460033, 0.13906358, 0.04413343, -0.11712967, 0.31494018, 0.0032492569, 0.14342329) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08504826, 0.016133035, 0.030549306, 0.03175983, 0.018303555, -0.1958017, -0.16770178, 0.20998009, -0.062904134, 0.08530611, -0.2065923, -0.19446918, 0.08438169, -0.09859691, 0.26467365, -0.11771275) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.018350188, 0.29892108, -0.13340664, 0.3715408, 0.12509497, -0.01982724, -0.33273253, 0.20406541, -0.054678485, -0.16926713, 0.17356528, -0.38257343, 0.119505204, -0.02312595, -0.40976465, -0.12202978) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.12706877, 0.442489, -0.31928733, 0.3888176, -0.3367004, 0.089965984, 0.49140564, -0.021328727, 0.14895014, -0.09462127, -0.3656445, 0.6667361, 0.17899278, 0.15581812, -0.22292227, 0.42051926) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.21700127, 0.26571673, -0.005081499, -0.00086839224, -0.109014235, 0.07560968, 0.101469636, -0.088389724, 0.033129543, 0.5333817, 0.24752752, -0.23458427, 0.090164706, 0.052752238, 0.44757533, 0.009017802) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.025157994, 0.0037136488, -0.060376406, -0.0032339403, -0.03386155, -0.018466292, 0.37167016, 0.040361244, 0.056590937, -0.082233325, -0.016809914, 0.010021279, 0.009086875, 0.24146214, -0.0659014, -0.045602668) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.022103023, -0.10472731, -0.28965312, 0.08387152, -0.041941393, -0.2815045, 0.081718095, -0.0010553203, 0.11840709, 0.1902503, 0.11303471, 0.046667438, -0.033796538, -0.15781565, 0.09205222, -0.044725757) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1669299, -0.07650071, -0.52008826, 0.09947525, -0.06077123, 0.10284808, 0.32223967, -0.09294029, 0.028200986, 0.17357337, -0.118118376, 0.06879188, -0.08809692, 0.1403257, -0.09592375, -0.021375785) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

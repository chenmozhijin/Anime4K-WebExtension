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

  var result: vec4f = vec4f(-0.03443157, 0.08251731, 0.009384535, -0.021019384);
      result += mat4x4<f32>(-0.23037802, 0.077088274, 0.12425491, -0.28685963, 0.13031925, -0.17733695, 0.41042855, 0.074348025, -0.47473627, 0.028796425, -0.3477238, 0.3400864, 0.3911338, -0.4970629, -0.18853335, -0.29482305) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.25521812, -0.0634921, -0.4216848, -0.3428996, 0.276289, -0.10812961, 0.037629545, 0.5740677, -0.09498545, 0.22746135, -0.36898497, 0.37573534, 0.01803645, 0.24092868, 0.5881753, -0.1528364) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.32142118, 0.23606701, 0.059304643, -0.03448272, -0.035021544, 0.08076471, 0.2806552, 0.032921907, -0.3557795, 0.03167337, -0.9208076, -0.3575379, -0.12801665, -0.23625931, 0.40685824, 0.42089605) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17426571, -0.28996676, 0.49654737, 0.42489743, -0.04110357, -0.38302055, 0.17988336, -0.055144098, -0.38489595, -0.023718538, -0.41205612, 1.0105764, 0.21328318, 0.13769998, -0.29039523, -0.6315733) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14662774, -0.3627681, -0.51354116, -1.1613076, -0.23567832, 0.40080407, -0.9697361, -0.60201365, -0.1732441, 0.22861278, -0.64716035, 0.6741353, 0.29367808, 0.20041563, -0.15429074, -0.28086257) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13261355, 0.041071165, -0.36050192, -0.03439261, -0.38473436, 0.29271203, 0.25947863, 0.38226902, 0.5177671, -0.3586837, -0.3531852, 0.52360475, -0.07137416, -0.22824997, -0.05057242, 0.1554485) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.5493558, -0.25286177, 0.60357827, 0.30020744, 0.068198405, 0.0037599017, -0.030429054, 0.053877458, -0.28465703, 0.16805443, -0.36145237, 0.50523776, -0.16951244, -0.15451518, 0.003615546, -1.2237091) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.25923264, -0.042800922, 0.6100053, -0.1778941, -0.3134312, 0.062324442, -0.3730282, -0.04885869, -0.11978293, 0.22151867, -0.0730594, 0.51436794, -0.27975184, 0.37475967, 0.06219395, -0.09350871) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.017317364, 0.068303674, 0.23337844, 0.37924078, 0.037370164, 0.16204444, -0.31708488, 0.11624549, 0.047161967, -0.2649038, -0.3342802, 0.11040179, 0.079584844, -0.20423694, 0.5741449, -0.3489367) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.4451145, -0.14669189, -0.5873482, -0.1854124, -0.28489804, -0.31185037, -0.011698152, 0.2770125, 0.031024387, 0.21796678, 0.4156246, -0.67381024, 0.29512662, -0.24925786, 0.34069872, -0.35064214) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.22542967, -0.009967213, -0.3151246, -0.59064776, 0.43744043, -0.07617569, -0.3360228, 0.24306197, 0.066780426, -0.26972714, 0.75151527, 0.30794623, 0.3623678, -0.118519746, 0.019765869, 0.36751753) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16101955, -0.07208715, 0.32404292, -0.11303122, -0.15773651, -0.024050118, -0.5993706, -0.26209915, -0.09720204, -0.29406717, 0.6931211, -0.20047481, 0.2102383, -0.13962705, 0.74928105, -0.25128207) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0022451815, 0.0010909594, -0.28650677, 0.12822983, -0.07519457, -0.4572587, -0.093557894, 0.20710014, 0.14283402, 0.108958736, 0.06930623, 0.19098012, 0.5393198, -0.15350156, -0.07947246, 0.0928044) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.07256389, -0.6018133, 1.3322428, 0.9002582, -0.15108907, -0.261335, -0.5471358, -0.42452207, -0.5826987, 0.35991862, -0.81637746, -0.73571277, 0.51332283, 0.39131427, -0.59849375, -1.2604935) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20236845, -0.3291914, 0.25506946, 0.0002257587, -0.11356642, -0.04065652, -0.044293366, 0.116711944, -0.013465668, -0.062711164, 0.28597417, 0.7220637, 0.2762003, 0.37502074, 0.7167475, 0.23742102) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1621988, -0.28383034, -0.079013266, -0.47966555, -0.058336906, -0.010312931, -0.10357881, -0.16493076, 0.0510283, 0.004950494, 0.115941204, 0.045007944, 0.11259561, 0.12527122, 0.01244424, -0.19707283) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17360525, -0.033937953, -0.15838821, -0.037956662, -0.24581133, -0.12460899, -0.12366435, 0.0063554607, 0.1160462, 0.1889493, -0.43940994, 0.68872046, -0.15712814, 0.32103327, 0.13681783, 0.07430229) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.38738948, 0.14939408, 0.028938336, 0.054727517, 0.09396515, -0.012738315, -0.27949566, 0.124833316, -0.19005008, 0.15407737, -0.2801539, 0.8984437, 0.23105985, 0.15138538, -0.17090487, -0.2717445) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

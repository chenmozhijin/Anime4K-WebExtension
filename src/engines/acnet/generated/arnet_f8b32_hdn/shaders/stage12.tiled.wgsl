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

  var result: vec4f = vec4f(-0.22802286, 0.07217717, 0.35088515, -0.12229914);
      result += mat4x4<f32>(-0.101204455, -0.22598498, 0.06929911, 0.18416832, -0.20717548, -0.73832244, 0.2018788, -0.40704685, 0.03474071, 0.041571446, 0.014335517, -0.014584259, -0.01281759, -0.2281519, -0.1179072, -0.15782325) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.087757796, 0.25809667, -0.08537919, -0.08940129, 0.049027413, -1.3327656, -0.3371217, -0.088842325, -0.13382523, 0.19955906, 0.10365902, 0.058692873, -0.06594643, 0.27020133, -0.1261139, 0.16623317) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.01690149, -0.048556443, -0.10823571, 0.16116117, -0.11605673, 0.0050925105, 0.18095753, 0.34797427, 0.11886461, 0.21802026, -0.17827705, -0.14742811, -0.17650482, -0.07196662, 0.047445435, -0.24879597) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.17398739, -0.08675412, 0.09411016, -0.05226651, -0.182453, -0.25907516, 0.12871563, -0.33096457, -0.08916969, 0.028273918, 0.2275511, 0.33315185, 0.018503755, -0.25668976, -0.023094947, -0.124195494) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.4739009, -0.15735485, 0.18677846, 0.28986523, 0.23719287, 0.14544976, -0.2009826, 0.14794995, -0.020387515, 0.39457026, -0.14633307, -0.23989181, 0.20152986, 0.065823495, -0.55296814, 0.0655777) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0073621934, 0.13575235, 0.029753618, 0.11627363, 0.17184708, 0.043490294, -0.15587753, 0.07043934, -0.013277194, -0.10327057, -0.35217807, 0.5314798, 0.022765212, -0.1633774, 0.17260024, -0.19131252) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.022839712, 0.045181543, -0.02354323, -0.107283905, 0.018116873, -0.017468426, -0.16625217, -0.06674236, -0.092724465, 0.0039605824, 0.08201494, -0.03503302, -0.008249105, -0.111295335, -0.10322906, -0.029797291) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.061270542, -0.06909678, -0.06662955, 0.0897243, -0.015885301, 0.16215079, -0.13215804, -0.098313205, -0.35583678, 0.083122715, 0.0067138732, -0.40321478, -0.000404555, -0.1486128, 0.23054302, 0.12736067) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.042462908, -0.12688892, 0.022646787, -0.012581969, 0.028748948, 0.10207539, -0.18335491, -0.021472188, -0.15880832, 0.082738146, 0.17109735, -0.12170842, 0.07686167, -0.048798732, 0.01162282, -0.0181495) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.018293703, 0.0661101, -0.23986681, -0.19213681, -0.08580303, 0.31731722, 0.13066983, 0.00028664802, 0.10564375, 0.17357875, 0.05461142, 0.17105219, -0.0726706, 0.45727825, 0.04908497, 0.12899294) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.11179641, 0.18937872, -0.2840909, -0.008995384, -0.19292004, -0.14325814, -0.021185668, 0.07554068, 0.009210585, -0.03740632, -0.043970898, -0.018100465, -0.030976953, 0.08717806, -0.06397792, 0.113108784) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.113723695, -0.07158647, -0.2509365, 0.1693659, 0.06855024, 0.3170571, 0.00087246037, 0.38401487, -0.014686398, 0.11475406, -0.15236387, -0.133478, 0.017555414, -0.23136048, 0.26983005, 0.09548472) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.039853554, 0.37418067, -0.018764004, 0.47627738, 0.06888849, 0.37307042, -0.13781178, -0.012115662, 0.002909335, -0.35019982, 0.007869078, -0.36223733, 0.21748064, 0.35732415, -0.18243106, 0.08621435) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.31964552, 0.6031161, -0.25726792, 0.6401242, -0.449338, 0.13726676, 0.6600077, -0.34219837, 0.44616765, 0.1060267, -0.53360116, 0.44819054, 0.05165329, 0.15168716, -0.061197653, 0.23164715) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30972096, 0.05141676, -0.05308867, -0.047071107, -0.11192851, 0.10546414, -0.38533705, 0.3685143, 0.22130537, 0.7720766, 0.17044929, -0.20816852, 0.07918321, -0.051922884, 0.2581144, 0.06742743) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04772699, 0.0024152792, -0.22503544, -0.07765388, 0.046239823, 0.1296472, -0.17269921, -0.10970409, -0.003470633, -0.046954166, -0.023894005, 0.070491076, -0.028154822, 0.10787605, 0.037094887, 0.06055798) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.035668466, -0.13408217, -0.21211049, 0.27750516, -0.12289571, -0.33381382, 0.013619671, 0.027188309, 0.24457082, 0.43006137, -0.21466021, -0.039304253, -0.057293836, -0.10480633, 0.25696877, -0.10174573) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11942798, -0.22399794, -0.33899435, 0.28599322, -0.08912746, 0.37862423, -0.0686742, 0.066796705, 0.09142706, 0.043466367, -0.28447673, -0.072428234, -0.037967816, 0.017775446, 0.25918105, 0.21309963) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

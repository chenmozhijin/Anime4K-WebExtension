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

  var result: vec4f = vec4f(0.27058038, 0.0698418, 0.09704396, 0.048487864);
      result += mat4x4<f32>(0.07175796, -0.20841105, 0.03095913, -0.07638027, 0.14603084, -0.15917937, 0.33084136, 0.11660051, -0.0058154794, 0.31133285, -0.2066425, -0.1772535, -0.04497101, 0.03597045, -0.011376184, -0.10890407) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.023131073, -0.17195591, -0.34890825, -0.1531601, -0.00018677389, -0.19930266, 0.3554999, 0.15680224, -0.19511707, 0.14839667, -0.44625875, 0.03992961, -0.010493555, 0.10166897, -0.23506537, 0.16269615) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.116278894, 0.16323614, -0.24160422, -0.1791045, -0.085589156, -0.29275995, 0.11528046, -0.021116706, -0.012825472, -0.2597209, -0.26993346, -0.1572296, 0.09484764, -0.13839416, -0.34204772, -0.021987094) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.006137731, -0.15780091, 0.14778341, -0.1721805, -0.15161207, -0.3174236, 0.033431202, 0.13079421, -0.7656134, -0.24588679, 0.044454277, -0.37892467, -0.22334719, 0.19251087, 0.12531084, -0.33488327) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.38942128, -0.13698705, 0.0052437675, 0.029775785, -0.018245649, -0.5319177, 0.10609219, 0.547985, -0.9047551, -0.27550155, -0.30128112, -0.0881969, -0.11612467, -0.4145096, 0.3265527, 0.42460036) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.24310927, 0.19688202, -0.23771991, 0.25353137, -0.049836803, -0.22332165, -0.16469893, 0.21771398, -0.3015767, -0.072576575, -0.1261248, -0.15963045, 0.02724696, 0.141673, 0.1473544, -0.048902147) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.22921063, -0.128676, 0.02865159, -0.010265894, -0.1686541, -0.17243312, -0.03513047, -0.06402979, 0.042148672, -0.19520669, -0.0060144556, 0.11489199, 0.21398851, 0.067613214, 0.19819432, -0.095306106) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.30530965, 0.08651003, -0.066806175, -0.17683953, 0.1537745, -0.21088396, -0.05568911, 0.22511508, 0.05936842, -0.10959467, -0.11146319, 0.051936142, -0.31244555, -0.04717329, 0.26409006, -0.5560484) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.20297128, 0.043660473, -0.07897619, -0.0625709, 0.042678826, -0.1411714, -0.090024255, -0.031184291, -0.1620661, -0.26790228, -0.14768414, -0.017583182, -0.12835406, 0.20747413, 0.1644692, -0.052509855) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.13027054, 0.12428353, 0.15860517, 0.20105772, 0.019503098, -0.13876642, -0.0010557859, 0.14610748, -0.053379256, -0.35669613, 0.046654657, 0.09789328, 0.2567756, 0.1534275, 0.10227569, 0.008601989) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.11982707, 0.044940624, -0.036402293, 0.17034754, 0.62340134, -0.17183794, 0.6343525, 0.124760136, -0.18863165, 0.15605606, -0.40180385, -0.20625184, 0.08903419, -0.0055858134, 0.0040646764, 0.04288245) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04989192, -0.02815647, 0.044676058, 0.091757625, -0.049546886, 0.20928028, -0.05733736, 0.3487954, -0.09692212, -0.17935486, 0.09841724, -0.03018614, 0.010070636, -0.0561811, 0.1787947, 0.09475982) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17570727, 0.17455707, -0.1661901, 0.1361855, -0.023174569, -0.10389757, -0.24046652, 0.43257588, -0.32583192, 0.21379778, -0.003797459, 0.0022847147, 0.041087326, 0.21769643, 0.1877394, -0.050157003) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.08822815, 0.018386852, 0.1376124, 0.19929926, -0.009954041, -0.2859999, -0.2845366, 0.4081315, -0.2557048, 0.07148308, 0.05597733, 0.30805337, -0.52491254, -0.079753324, -0.45235002, -0.04264304) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04298775, 0.080195665, -0.06674521, 0.12553209, 0.02406021, -0.083576776, -0.20672348, -0.07119819, 0.28472883, -0.2878869, 0.0038052078, -0.37710395, 0.20429197, -0.057829883, 0.1501814, -0.099091165) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.42962524, -0.31358868, 0.022067022, -0.075184174, -0.12091834, 0.113025986, 0.105639026, 0.057157196, -0.37487727, 0.052194793, -0.089179166, -0.19443405, 0.31295708, 0.31091595, -0.043875642, 0.31518492) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17158274, 0.14725229, -0.050809544, 0.45908234, -0.032935977, 0.1395747, -0.08879085, 0.07706342, -0.1402735, 0.15591477, 0.21042289, 0.012645559, -0.5311777, 0.14558816, -0.05636637, -0.3824665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10818339, -0.12897769, 0.04311743, -0.20583399, 0.05116459, 0.04494524, -0.0027834075, 0.021929422, -0.013199879, -0.07006121, -0.01812624, -0.028131505, -0.20520018, -0.012363822, -0.11300493, 0.3514853) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}

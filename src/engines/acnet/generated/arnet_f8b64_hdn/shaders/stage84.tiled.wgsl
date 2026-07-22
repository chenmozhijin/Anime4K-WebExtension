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

  var result: vec4f = vec4f(0.30890703, 0.05950202, 0.6217194, -0.19249804);
      result += mat4x4<f32>(0.06669288, -0.059297323, 0.2021114, 0.03709401, 0.0041179513, -0.42672926, 0.11923479, 0.1286453, -0.001378239, 0.13398258, -0.039557826, -0.29651526, -0.2838406, 0.001378069, 0.068458356, -0.03452653) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.011221764, -0.3464567, 0.054634545, 0.08373379, -0.81433403, -0.15690167, 0.8248738, -0.26813608, -0.36616778, -0.070711404, 0.1141185, -0.46414623, -0.053207915, 0.030037327, -0.0177632, 0.24988325) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2998116, 0.028036395, -0.39249557, 0.07393215, -0.12884133, 0.22763631, 0.05315841, -0.53376025, 0.04021631, -0.07904342, 0.012668295, 0.022126773, 0.071634345, -0.023662038, -0.0061392663, -0.16458109) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06522963, 0.10614721, -0.013264223, 0.04084981, 0.293252, -0.057309546, -0.3194029, 0.06327448, 0.1954067, -0.29172915, -0.48291534, 0.1893251, -0.1554821, 0.37230343, 0.17529818, -0.31442875) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.46516606, -0.31592962, -0.23146948, 0.24964252, 0.027579159, 0.09355935, -0.46090534, 0.6168851, -0.032350123, 0.11891585, -0.4944373, -0.11887197, 0.002593419, -0.23390134, 0.2842843, -0.37475362) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15352523, -0.0044293315, -0.4690283, 0.12578465, 0.35033074, 0.36181265, -0.09166397, -0.0104717035, 0.25547707, -0.051927228, -0.5123019, 0.15991952, 0.41150165, -0.15389004, -0.09666516, -0.1329796) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.100012556, 0.0995715, 0.12942724, 0.051784694, 0.043358356, -0.039466523, 0.013732144, -0.02494988, 0.007332152, -0.07235739, -0.30461827, 0.14615749, 0.1827438, 0.13309751, -0.08170714, -0.12442014) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.021622287, 0.10395869, -0.0720285, 0.11946191, -0.08769037, 0.107207626, 0.40793568, -0.20400523, 0.21355316, 0.07541772, -0.06991566, 0.055514734, 0.38904, 0.028112521, -0.21986358, -0.13103391) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12892847, 0.01032761, -0.014451998, 0.10130822, 0.14292079, 0.031614043, 0.0542907, -0.22890718, -0.07386375, -0.020535065, -0.118433945, 0.08483457, 0.2256993, 0.037480276, -0.33426306, 0.046331953) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.34465557, 0.043056447, -0.17919165, -0.16646616, -0.14501329, 0.10391566, 0.086252905, -0.025046721, -0.0029654026, 0.044077307, -0.095633395, 0.12998421, -0.16180257, 0.13424528, 0.2807223, -0.060072225) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.06855435, -0.12140597, 0.121807724, -0.07372787, 0.63790363, -0.3985113, -0.22221303, -0.042946447, 0.089038305, -0.057717193, -0.32169914, 0.098817125, 0.31446335, 0.0043268115, 0.14301237, 0.054254264) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.055602495, 0.21829212, -0.13094649, 0.19101208, -0.05515644, -0.1357804, -0.1224341, -0.024391033, -0.033204332, 0.15782586, -0.19985478, 0.15594427, -0.35150072, -0.06621109, -0.167418, -0.23983417) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.54279274, 0.48106453, 0.2757602, -0.31437567, 0.030134102, 0.011930042, 0.120319024, 0.13122834, -0.0033768245, -0.014481234, -0.07214595, -0.0362929, 0.05329551, 0.068452194, 0.04467145, -0.075638264) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7955594, -0.22233957, -0.030809732, 0.4607241, 0.06590526, -0.095865786, 0.118564576, -0.25244942, 0.22580336, -0.10582242, 0.32786307, -0.1788981, 0.09372421, -0.49486214, -0.23031108, 0.8405718) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.42234632, -0.036013138, -0.5543486, 0.03817617, -0.21356362, 0.041215893, 0.046591066, -0.0025652044, -0.111904204, -0.15277961, 0.05498507, 0.25376737, -0.64622676, -0.40882638, -0.21124525, -0.50797015) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.42918327, 0.10458528, 0.2004048, -0.1973015, -0.04763518, -0.019215992, -0.036711324, -0.008364146, -0.07273092, -0.08934686, -0.1243935, 0.21355908, -0.037590045, 0.02407329, 0.12810607, 0.049870867) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.29454547, 0.13783537, -0.028562203, 0.35023755, -0.2261999, 0.028597664, 0.069972396, 0.19782339, 0.041103255, 0.0831385, 0.10963351, -0.172508, -0.05241217, 0.0421417, -0.22086139, 0.022008162) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.05055344, 0.042754076, -0.015623826, -0.387836, -0.10837974, 0.116638795, 0.18367752, 0.01391559, 0.13234569, -0.2959962, -0.15330434, 0.05939714, 0.11357373, -0.12472068, 0.15186866, -0.0005689049) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
